//
//  SourcesSection.swift
//  Bookmarkd
//
//  Created by Aarav Gupta on 25/07/26.
//

import SwiftUI

/// "Where do I get this?" — one group per source kind, in free → borrow → buy order.
///
/// Groups arrive as their clients report, so this renders whatever is available rather than
/// waiting on the slowest. A source that failed is simply absent.
struct SourcesSection: View {
    let groups: [(BookSource.Kind, [BookSource])]
    let isLoading: Bool
    let onSelect: (BookSource) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            ForEach(groups, id: \.0) { kind, sources in
                VStack(alignment: .leading, spacing: 8) {
                    Text(kind.sectionTitle)
                        .font(.headline)
                        .foregroundStyle(.highlight)

                    ForEach(sources) { source in
                        Button {
                            onSelect(source)
                        } label: {
                            row(source)
                        }
                    }
                }
            }

            if isLoading {
                ProgressView()
                    .tint(.highlight)
                    .frame(maxWidth: .infinity)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func row(_ source: BookSource) -> some View {
        HStack(spacing: 10) {
            VStack(alignment: .leading, spacing: 2) {
                Text(source.sourceName)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(.highlight)

                if let detail = source.detail {
                    Text(detail)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()

            Image(systemName: "arrow.up.right")
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 14)
        .background(Color.highlight.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}
