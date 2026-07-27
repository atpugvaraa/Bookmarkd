//
//  HomeView.swift
//  Bookmarkd
//
//  Created by Aarav Gupta on 10/06/26.
//

import Aesthetics
import ComposableArchitecture
import SwiftUI

@ViewAction(for: HomeFeature.self)
struct HomeView: View {
    @Bindable var store: StoreOf<HomeFeature>
    @State private var scrollOffset: CGFloat = 0
    @Shared(.homeDesign) private var homeDesign

    private var design: HomeDesign {
        HomeDesign(rawValue: homeDesign) ?? .current
    }

    /// A thin shell during design exploration: it owns the navigation stack (the path lives
    /// here) and hands the whole screen to whichever design is selected. Each design decides
    /// its own presentation, including whether it uses the Aesthetics nav bar at all.
    var body: some View {
        NavigationStack(path: $store.scope(state: \.path, action: \.path)) {
            selectedDesign
        } destination: { store in
            switch store.case {
            case let .bookDetail(store):
                BookDetailView(store: store)
            }
        }
    }

    @ViewBuilder
    private var selectedDesign: some View {
        // The store stops here. Designs take a plain `HomeSnapshot` and a callback, so they own
        // no TCA, can be previewed, and can be deleted without touching the feature — which is
        // the whole point after throwing ten of them away.
        let snapshot = HomeSnapshot(entries: store.entries)
        let openBook: (Book) -> Void = { send(.bookTapped($0)) }

        Group {
            switch design {
            case .current: baseline
            case .nightcap: HomeDesignNightcap(snapshot: snapshot, onSelect: openBook)
            case .epigraph: HomeDesignEpigraph(snapshot: snapshot, onSelect: openBook)
            case .marginalia: HomeDesignMarginalia(snapshot: snapshot, onSelect: openBook)
            case .chapters: HomeDesignChapters(snapshot: snapshot, onSelect: openBook)
            case .subjects: HomeDesignSubjects(snapshot: snapshot, onSelect: openBook)
            case .twoUp: HomeDesignTwoUp(snapshot: snapshot, onSelect: openBook)
            case .tally: HomeDesignTally(snapshot: snapshot, onSelect: openBook)
            case .plan: HomeDesignPlan(snapshot: snapshot, onSelect: openBook)
            case .hour: HomeDesignHour(snapshot: snapshot, onSelect: openBook)
            case .bands: HomeDesignBands(snapshot: snapshot, onSelect: openBook)
            case .wall: HomeDesignWall(snapshot: snapshot, onSelect: openBook)
            case .overleaf: HomeDesignOverleaf(snapshot: snapshot, onSelect: openBook)
            case .lean: HomeDesignLean(snapshot: snapshot, onSelect: openBook)
            case .halves: HomeDesignHalves(snapshot: snapshot, onSelect: openBook)
            case .lamp: HomeDesignLamp(snapshot: snapshot, onSelect: openBook)
            }
        }
        // Each design carries its own palette. Colour was held constant across all fifteen
        // rejected designs, which is the main reason the last five were indistinguishable.
        .environment(\.theme, design.theme)
    }

    /// The shipped layout, kept so there is always something to compare against.
    private var baseline: some View {
        NavigationBarView(
            title: "Bookmarkd",
            titleColor: .highlight,
            scrollOffset: $scrollOffset,
            backgroundColor: .accent
        ) {
            content
        }
    }

    private var content: some View {
        VStack(alignment: .leading, spacing: 28) {
            if store.isEmpty {
                emptyState
            } else {
                if !store.currentlyReading.isEmpty {
                    section(title: "Currently Reading", entries: store.currentlyReading)
                }
                if !store.recentlyAdded.isEmpty {
                    section(title: "Recently Added", entries: store.recentlyAdded)
                }
            }
        }
        .padding(.vertical)
    }

    private func section(title: String, entries: [ShelfEntry]) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            Text(title)
                .font(.title3)
                .fontWeight(.bold)
                .foregroundStyle(.highlight)
                .padding(.horizontal, 16)

            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(spacing: 24) {
                    ForEach(entries) { entry in
                        Button {
                            send(.bookTapped(entry.book))
                        } label: {
                            BookCard(book: entry.book)
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "book.fill")
                .font(.system(size: 48))
                .foregroundStyle(.highlight.opacity(0.4))
            Text("Welcome to Bookmarkd")
                .font(.headline)
                .foregroundStyle(.highlight)
            Text("Search for books and start building your shelf")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 60)
    }
}

#Preview {
    HomeView(
        store: Store(initialState: HomeFeature.State()) {
            HomeFeature()
        }
    )
}
