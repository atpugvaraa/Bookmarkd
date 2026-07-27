//
//  ShelfView.swift
//  Bookmarkd
//
//  Created by Aarav Gupta on 10/06/26.
//

import Aesthetics
import ComposableArchitecture
import SwiftUI

@ViewAction(for: ShelfFeature.self)
struct ShelfView: View {
    @Bindable var store: StoreOf<ShelfFeature>
    @State private var scrollOffset: CGFloat = 0

    var body: some View {
        NavigationStack(path: $store.scope(state: \.path, action: \.path)) {
            NavigationBarView(
                title: "Your Shelf",
                titleColor: .highlight,
                scrollOffset: $scrollOffset,
                backgroundColor: .accent
            ) {
                filterBar
            } content: {
                content
            }
        } destination: { store in
            switch store.case {
            case let .bookDetail(store):
                BookDetailView(store: store)
            }
        }
    }

    private var content: some View {
        VStack(alignment: .leading, spacing: 20) {
            if store.filteredEntries.isEmpty {
                emptyState
            } else {
                shelfGrid
            }
        }
    }

    private var filterBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                filterChip(label: "All", isSelected: store.selectedFilter == nil) {
                    send(.filterChanged(nil))
                }
                ForEach(ShelfStatus.allCases, id: \.self) { status in
                    filterChip(label: status.rawValue, isSelected: store.selectedFilter == status) {
                        send(.filterChanged(status))
                    }
                }
            }
            .padding(.horizontal, 16)
        }
    }

    private func filterChip(label: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(label)
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundStyle(isSelected ? .accent : .highlight)
                .padding(.horizontal, 14)
                .padding(.vertical, 7)
                .background(isSelected ? Color.highlight : Color.highlight.opacity(0.12))
                .clipShape(Capsule())
        }
    }

    private var shelfGrid: some View {
        LazyVGrid(
            columns: [
                GridItem(.flexible(), spacing: 24),
                GridItem(.flexible(), spacing: 24)
            ],
            spacing: 28
        ) {
            ForEach(store.filteredEntries) { entry in
                Button {
                    send(.bookTapped(entry.book))
                } label: {
                    BookCard(book: entry.book)
                }
            }
        }
        .padding(.horizontal, 16)
    }

    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "books.vertical.fill")
                .font(.system(size: 48))
                .foregroundStyle(.highlight.opacity(0.4))
            Text(store.selectedFilter == nil ? "Your shelf is empty" : "Nothing here yet")
                .font(.headline)
                .foregroundStyle(.highlight)
            Text("Search for books and add them to your shelf")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 60)
    }
}

#Preview {
    ShelfView(
        store: Store(initialState: ShelfFeature.State()) {
            ShelfFeature()
        }
    )
}
