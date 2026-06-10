//
//  BookDetailView.swift
//  Bookmarkd
//
//  Created by Aarav Gupta on 09/06/26.
//

import Aesthetics
import SwiftUI
import ComposableArchitecture

struct BookDetailView: View {
    let metrics = NavigationBarMetrics.current
    @Bindable var store: StoreOf<BookDetailFeature>
    
    var body: some View {
        ZStack {
            Color.accent.ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 20) {
                    AsyncImage(url: store.book.coverURL) { image in
                        image.resizable().aspectRatio(contentMode: .fit)
                    } placeholder: {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(.highlight.opacity(0.1))
                            .overlay(
                                Image(systemName: "book.closed.fill")
                                    .font(.system(size: 40))
                                    .foregroundStyle(.highlight.opacity(0.3))
                            )
                    }
                    .frame(height: 280)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .shadow(color: .black.opacity(0.2), radius: 8, y: 4)
                    
                    VStack(spacing: 6) {
                        Text(store.book.title)
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundStyle(.highlight)
                            .multilineTextAlignment(.center)
                        
                        if !store.book.authors.isEmpty {
                            Text(store.book.authorDisplay)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                        
                        if let year = store.book.firstPublishYear {
                            Text("First published \(String(year))")
                                .font(.caption)
                                .foregroundStyle(.tertiary)
                        }
                    }
                    
                    shelfSection
                }
                .padding()
            }
            .contentMargins(.top, metrics.contentMarginTopWithSearch)
        }
        .onAppear { store.send(.onAppear) }
    }
    
    private var shelfSection: some View {
        Menu {
            ForEach(ShelfStatus.allCases, id: \.self) { status in
                Button {
                    store.send(.statusSelected(status))
                } label: {
                    Label(status.rawValue, systemImage: status.systemImage)
                }
            }
            if store.shelfStatus != nil {
                Divider()
                Button(role: .destructive) {
                    store.send(.removeFromShelf)
                } label: {
                    Label("Remove from Shelf", systemImage: "trash")
                }
            }
        } label: {
            HStack {
                Image(systemName: store.shelfStatus?.systemImage ?? "plus")
                Text(store.shelfStatus?.rawValue ?? "Add to Shelf")
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(.highlight)
            .foregroundStyle(.accent)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .fontWeight(.semibold)
        }
        .padding(.horizontal)
    }
}

#Preview {
    NavigationStack {
        BookDetailView(
            store: Store(
                initialState: BookDetailFeature.State(
                    book: Book(
                        id: "preview",
                        title: "Normal People",
                        authors: ["Sally Rooney"],
                        coverURL: nil,
                        firstPublishYear: 2018
                    )
                )
            ) {
                BookDetailFeature()
            }
        )
    }
}
