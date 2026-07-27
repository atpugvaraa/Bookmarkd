//
//  SearchView.swift
//  Bookmarkd
//
//  Created by Aarav Gupta on 09/06/26.
//

import Aesthetics
import ComposableArchitecture
import Kingfisher
import SwiftUI

@ViewAction(for: SearchFeature.self)
struct SearchView: View {
    @Bindable var store: StoreOf<SearchFeature>
    @State private var scrollOffset: CGFloat = 0

    var body: some View {
        NavigationStack(path: $store.scope(state: \.path, action: \.path)) {
            NavigationBarView(
                title: "Search",
                titleColor: .highlight,
                scrollOffset: $scrollOffset,
                backgroundColor: .accent
            ) {
                content
            }
            .navigationBarStyle(.search)
            .navigationBarSearch(
                text: Binding(
                    get: { store.query },
                    set: { send(.queryChanged($0)) }
                ),
                prompt: "Search for a book..."
            ) {
                send(.searchSubmitted)
            }
            .alert($store.scope(state: \.alert, action: \.alert))
        } destination: { store in
            switch store.case {
            case let .bookDetail(store):
                BookDetailView(store: store)
            }
        }
    }

    private var content: some View {
        VStack(spacing: 0) {
            if !store.hasSearched && store.results.isEmpty && !store.isLoading {
                emptyState
            } else if store.isLoading {
                Spacer()
                ProgressView("Searching...")
                    .foregroundStyle(.highlight)
                Spacer()
            } else if store.results.isEmpty && store.hasSearched {
                Spacer()
                Text("No books found")
                    .foregroundStyle(.secondary)
                Spacer()
            } else {
                resultsList
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: 12) {
            Spacer()
            Image(systemName: "book.fill")
                .font(.system(size: 48))
                .foregroundStyle(.highlight.opacity(0.4))
            Text("Search for any book")
                .font(.headline)
                .foregroundStyle(.highlight)
            Text("Find where to read it, buy it, or get it free")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Spacer()
        }
    }

    private var resultsList: some View {
        LazyVStack(spacing: 0) {
            ForEach(store.results) { book in
                Button {
                    send(.bookTapped(book))
                } label: {
                    resultRow(book)
                }
                // Reaching the last row loads the next page.
                .onAppear { send(.resultAppeared(book.id)) }

                Divider()
                    .padding(.leading, 78)
            }

            if store.isLoadingPage {
                ProgressView()
                    .tint(.highlight)
                    .padding(.vertical, 16)
            }
        }
    }

    private func resultRow(_ book: Book) -> some View {
        HStack(spacing: 12) {
            KFImage(book.coverURL)
                .resizable()
                .placeholder { _ in
                    RoundedRectangle(cornerRadius: 4)
                        .fill(.highlight.opacity(0.1))
                        .overlay(
                            Image(systemName: "book.closed.fill")
                                .foregroundStyle(.highlight.opacity(0.3))
                        )
                }
                .aspectRatio(contentMode: .fill)
                .frame(width: 50, height: 72)
                .clipShape(RoundedRectangle(cornerRadius: 4))

            VStack(alignment: .leading, spacing: 4) {
                Text(book.title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(.highlight)
                    .lineLimit(2)

                if !book.authors.isEmpty {
                    Text(book.authorDisplay)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }

                HStack(spacing: 6) {
                    if let year = book.firstPublishYear {
                        Text(String(year))
                            .font(.caption2)
                            .foregroundStyle(.tertiary)
                    }
                    if book.isFreeToRead {
                        Text("Free")
                            .font(.caption2)
                            .fontWeight(.semibold)
                            .foregroundStyle(.accent)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.highlight)
                            .clipShape(Capsule())
                    }
                }
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 16)
    }
}

#Preview {
    SearchView(
        store: Store(initialState: SearchFeature.State()) {
            SearchFeature()
        }
    )
}
