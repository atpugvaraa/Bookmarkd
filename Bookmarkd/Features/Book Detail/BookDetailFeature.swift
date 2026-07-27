//
//  BookDetailFeature.swift
//  Bookmarkd
//
//  Created by Aarav Gupta on 09/06/26.
//

import ComposableArchitecture
import Foundation

@Reducer
struct BookDetailFeature {
    @ObservableState
    struct State: Equatable {
        var book: Book
        @Shared(.shelf) var shelf
        var detail: BookDetail?
        var isLoadingDetail = false

        @Shared(.sourceCache) var sourceCache
        var sources: IdentifiedArrayOf<BookSource> = []
        var pendingSourceCount = 0

        var isLoadingSources: Bool { pendingSourceCount > 0 }

        /// Grouped for display, always free → borrow → buy. Empty groups are omitted.
        var sourcesByKind: [(BookSource.Kind, [BookSource])] {
            BookSource.Kind.allCases
                .sorted { $0.sortOrder < $1.sortOrder }
                .compactMap { kind in
                    let matching = Array(sources.filter { $0.kind == kind })
                    return matching.isEmpty ? nil : (kind, matching)
                }
        }

        /// Read straight off the shared shelf so it can never drift out of sync with it.
        var shelfStatus: ShelfStatus? {
            shelf[id: book.id]?.status
        }

        /// "304 pages · 27 editions · 2018" — whichever parts are known.
        var metadataLine: String? {
            var parts: [String] = []
            if let pages = book.pageCount { parts.append("\(pages) pages") }
            if let editions = book.editionCount {
                parts.append("\(editions) edition\(editions == 1 ? "" : "s")")
            }
            if let year = book.firstPublishYear { parts.append(String(year)) }
            return parts.isEmpty ? nil : parts.joined(separator: " · ")
        }

        init(book: Book) {
            self.book = book
        }
    }

    enum Action: ViewAction {
        enum View {
            case onAppear
            case statusSelected(ShelfStatus)
            case removeTapped
            case backTapped
        }
        case view(View)
        case detailResponse(Result<BookDetail, any Error>)
        case sourcesResponse(Result<[BookSource], any Error>)
    }

    // \.date rather than \.date.now: the nested key path resolves when the reducer is
    // constructed, which escapes a TestStore's dependency overrides.
    @Dependency(\.date) var date
    @Dependency(\.dismiss) var dismiss
    @Dependency(\.openLibraryClient) var openLibrary
    @Dependency(\.gutendexClient) var gutendex
    @Dependency(\.standardEbooksClient) var standardEbooks

    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .view(.onAppear):
                let book = state.book
                var effects: [Effect<Action>] = []

                if state.detail == nil, !state.isLoadingDetail {
                    state.isLoadingDetail = true
                    effects.append(
                        .run { send in
                            await send(.detailResponse(Result { try await openLibrary.work(book.id) }))
                        }
                    )
                }

                if state.sources.isEmpty {
                    // Buy and borrow links need no network, so they render immediately.
                    state.sources = IdentifiedArray(uniqueElements: BuyLinks.sources(for: book))

                    if let cached = state.sourceCache[book.id] {
                        for source in cached { state.sources.updateOrAppend(source) }
                    } else {
                        state.pendingSourceCount = 2
                        effects.append(
                            .run { send in
                                await send(.sourcesResponse(Result { try await gutendex.find(book) }))
                            }
                        )
                        effects.append(
                            .run { send in
                                await send(.sourcesResponse(Result { try await standardEbooks.find(book) }))
                            }
                        )
                    }
                }

                return .merge(effects)

            case let .sourcesResponse(.success(found)):
                state.pendingSourceCount = max(0, state.pendingSourceCount - 1)
                for source in found { state.sources.updateOrAppend(source) }
                cacheIfComplete(&state)
                return .none

            case .sourcesResponse(.failure):
                // A source that fails is simply absent — no error UI, and its neighbours are
                // unaffected.
                state.pendingSourceCount = max(0, state.pendingSourceCount - 1)
                cacheIfComplete(&state)
                return .none

            case let .detailResponse(.success(detail)):
                state.detail = detail
                state.isLoadingDetail = false
                return .none

            case .detailResponse(.failure):
                // Degrade quietly: the cover, title and shelf controls all still work without
                // a description, so an alert here would be noise.
                state.isLoadingDetail = false
                return .none

            case let .view(.statusSelected(status)):
                let book = state.book
                // Read outside withLock: its closure runs outside the dependency scope,
                // where @Dependency would fall back to the live value.
                let now = date.now
                state.$shelf.withLock { shelf in
                    if var entry = shelf[id: book.id] {
                        entry.status = status
                        entry.dateUpdated = now
                        shelf[id: book.id] = entry
                    } else {
                        shelf.append(ShelfEntry(book: book, status: status, now: now))
                    }
                }
                return .none

            case .view(.removeTapped):
                let id = state.book.id
                state.$shelf.withLock { _ = $0.remove(id: id) }
                return .none

            case .view(.backTapped):
                return .run { _ in await dismiss() }
            }
        }
    }

    /// Store the fetched sources only once every client has reported, so a partial set is
    /// never cached and then served as if it were complete.
    private func cacheIfComplete(_ state: inout State) {
        guard state.pendingSourceCount == 0 else { return }
        let id = state.book.id
        let fetched = Array(state.sources.filter { $0.kind == .free })
        state.$sourceCache.withLock { $0[id] = fetched }
    }
}
