//
//  BookDetailView.swift
//  Bookmarkd
//
//  Created by Aarav Gupta on 09/06/26.
//

import Aesthetics
import ComposableArchitecture
import Kingfisher
import SwiftUI

@ViewAction(for: BookDetailFeature.self)
struct BookDetailView: View {
    let store: StoreOf<BookDetailFeature>
    @State private var scrollOffset: CGFloat = 0
    @State private var isDescriptionExpanded = false
    @State private var openedSource: BookSource?

    var body: some View {
        NavigationBarView(
            title: store.book.title,
            titleColor: .highlight,
            scrollOffset: $scrollOffset,
            backAction: { send(.backTapped) },
            backgroundColor: .accent
        ) {
            content
        }
        // Aesthetics draws its own back button in the bar above.
        .navigationBarBackButtonHidden(true)
        .onAppear { send(.onAppear) }
        .sheet(item: $openedSource) { source in
            SafariView(url: source.linkURL)
                .ignoresSafeArea()
        }
    }

    private var content: some View {
        VStack(spacing: 20) {
            cover

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

                if let metadata = store.metadataLine {
                    Text(metadata)
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                }
            }

            shelfSection

            SourcesSection(
                groups: store.sourcesByKind,
                isLoading: store.isLoadingSources,
                onSelect: { openedSource = $0 }
            )

            if let description = store.detail?.description, !description.isEmpty {
                descriptionSection(description)
            } else if store.isLoadingDetail {
                ProgressView()
                    .tint(.highlight)
                    .padding(.top, 8)
            }

            if let subjects = store.detail?.subjects, !subjects.isEmpty {
                subjectSection(subjects)
            }
        }
        .padding()
    }

    private var cover: some View {
        KFImage(store.book.coverURL)
            .resizable()
            .placeholder { _ in
                RoundedRectangle(cornerRadius: 8)
                    .fill(.highlight.opacity(0.1))
                    .overlay(
                        Image(systemName: "book.closed.fill")
                            .font(.system(size: 40))
                            .foregroundStyle(.highlight.opacity(0.3))
                    )
            }
            .aspectRatio(contentMode: .fit)
            .frame(height: 280)
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .shadow(color: .black.opacity(0.2), radius: 8, y: 4)
    }

    private func descriptionSection(_ description: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("About")
                .font(.headline)
                .foregroundStyle(.highlight)

            Text(description)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .lineLimit(isDescriptionExpanded ? nil : 6)
                .animation(.default, value: isDescriptionExpanded)

            Button(isDescriptionExpanded ? "Show less" : "Show more") {
                isDescriptionExpanded.toggle()
            }
            .font(.caption)
            .fontWeight(.semibold)
            .foregroundStyle(.highlight)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func subjectSection(_ subjects: [String]) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Subjects")
                .font(.headline)
                .foregroundStyle(.highlight)

            // Cap it: Open Library lists hundreds of subjects for popular works.
            FlowLayout(spacing: 6) {
                ForEach(subjects.prefix(12), id: \.self) { subject in
                    Text(subject)
                        .font(.caption)
                        .foregroundStyle(.highlight)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(Color.highlight.opacity(0.12))
                        .clipShape(Capsule())
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var shelfSection: some View {
        Menu {
            ForEach(ShelfStatus.allCases, id: \.self) { status in
                Button {
                    send(.statusSelected(status))
                } label: {
                    Label(status.rawValue, systemImage: status.systemImage)
                }
            }
            if store.shelfStatus != nil {
                Divider()
                Button(role: .destructive) {
                    send(.removeTapped)
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

/// Wraps subviews onto as many lines as they need. `LazyVGrid` can't do this because subject
/// chips have wildly different widths.
private struct FlowLayout: Layout {
    var spacing: CGFloat = 6

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let maxWidth = proposal.width ?? .infinity
        var origin = CGPoint.zero
        var lineHeight: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if origin.x + size.width > maxWidth, origin.x > 0 {
                origin.x = 0
                origin.y += lineHeight + spacing
                lineHeight = 0
            }
            origin.x += size.width + spacing
            lineHeight = max(lineHeight, size.height)
        }
        return CGSize(width: maxWidth, height: origin.y + lineHeight)
    }

    func placeSubviews(
        in bounds: CGRect,
        proposal: ProposedViewSize,
        subviews: Subviews,
        cache: inout ()
    ) {
        var origin = bounds.origin
        var lineHeight: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if origin.x + size.width > bounds.maxX, origin.x > bounds.minX {
                origin.x = bounds.minX
                origin.y += lineHeight + spacing
                lineHeight = 0
            }
            subview.place(at: origin, proposal: ProposedViewSize(size))
            origin.x += size.width + spacing
            lineHeight = max(lineHeight, size.height)
        }
    }
}

#Preview {
    NavigationStack {
        BookDetailView(
            store: Store(
                initialState: BookDetailFeature.State(
                    book: Book(
                        id: "/works/OL20150260W",
                        title: "Normal People",
                        authors: ["Sally Rooney"],
                        firstPublishYear: 2018,
                        pageCount: 304,
                        editionCount: 27
                    )
                )
            ) {
                BookDetailFeature()
            }
        )
    }
}
