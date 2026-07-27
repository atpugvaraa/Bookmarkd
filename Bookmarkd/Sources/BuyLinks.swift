//
//  BuyLinks.swift
//  Bookmarkd
//
//  Created by Aarav Gupta on 25/07/26.
//

import Foundation

/// Borrow and buy destinations built purely from what a `Book` already carries.
///
/// No network, no API keys, and no affiliate tags — Bookmarkd links straight to the seller.
/// Nothing here does I/O, so nothing here can fail: it needs no client and no error handling.
nonisolated enum BuyLinks {
    static func sources(for book: Book) -> [BookSource] {
        borrowSources(for: book) + buySources(for: book)
    }

    private static func borrowSources(for book: Book) -> [BookSource] {
        // Controlled digital lending — the right answer for out-of-print but in-copyright books.
        (book.iaIdentifiers ?? []).compactMap { identifier in
            guard let url = URL(string: "https://archive.org/details/\(identifier)") else { return nil }
            return BookSource(
                id: "archive:\(identifier)",
                kind: .borrow,
                sourceName: "Internet Archive",
                title: book.title,
                detail: "Borrow",
                linkURL: url
            )
        }
    }

    private static func buySources(for book: Book) -> [BookSource] {
        let query = searchQuery(for: book)
        let destinations: [(name: String, detail: String, urlString: String)] = [
            ("Amazon.in", "Search", "https://www.amazon.in/s?k=\(query)"),
            ("Flipkart", "Search", "https://www.flipkart.com/search?q=\(query)"),
            ("Quick commerce", "Compare prices", "https://quickcompare.in/search-results?q=\(query)"),
        ]

        return destinations.compactMap { destination in
            guard let url = URL(string: destination.urlString) else { return nil }
            return BookSource(
                id: "buy:\(destination.name)",
                kind: .buy,
                sourceName: destination.name,
                title: book.title,
                detail: destination.detail,
                linkURL: url
            )
        }
    }

    /// ISBN when we have one — far more precise than a title — otherwise title plus author.
    private static func searchQuery(for book: Book) -> String {
        if let isbn = book.isbns?.first {
            return isbn
        }
        let terms = ([book.title] + book.authors.prefix(1)).joined(separator: " ")
        return terms.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? terms
    }
}
