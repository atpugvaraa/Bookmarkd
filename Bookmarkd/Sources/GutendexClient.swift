//
//  GutendexClient.swift
//  Bookmarkd
//
//  Created by Aarav Gupta on 25/07/26.
//

import ComposableArchitecture
import DependenciesMacros
import Foundation

/// Project Gutenberg, via the Gutendex mirror. ~75,000 public-domain books, no auth.
@DependencyClient
struct GutendexClient: Sendable {
    var find: @Sendable (_ book: Book) async throws -> [BookSource]
}

extension GutendexClient: DependencyKey {
    static let liveValue = GutendexClient(
        find: { book in
            let query = book.title.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? book.title
            let url = URL(string: "https://gutendex.com/books/?search=\(query)")!
            var request = URLRequest(url: url)
            request.setValue("Bookmarkd/1.0 (contact@bookmarkd.app)", forHTTPHeaderField: "User-Agent")

            let (data, _) = try await URLSession.shared.data(for: request)
            return try sources(from: data, for: book)
        }
    )

    /// Split out from the network call so decoding and matching are testable offline.
    ///
    /// Returns **at most one** source. Gutenberg carries many records for a popular work — a
    /// live search for "Pride and Prejudice" matched six, all identically titled — and six
    /// identical rows is noise, not choice. Gutendex orders by relevance, so the first match
    /// is the one to keep; that also drops adaptations, which trail the original.
    static func sources(from data: Data, for book: Book) throws -> [BookSource] {
        let response = try JSONDecoder().decode(GutendexResponse.self, from: data)
        return Array(response.results.lazy.compactMap { result in
            let authors = result.authors.map(\.name)
            guard BookMatcher.matches(title: result.title, authors: authors, against: book) else {
                return nil
            }
            // Prefer the in-browser reading page; the EPUB only matters once a reader exists.
            guard let link = result.formats["text/html"] ?? result.formats["application/epub+zip"],
                  let linkURL = URL(string: link)
            else { return nil }

            return BookSource(
                id: "gutendex:\(result.id)",
                kind: .free,
                sourceName: "Project Gutenberg",
                title: result.title,
                detail: result.formats["application/epub+zip"] == nil ? "HTML" : "EPUB",
                linkURL: linkURL
            )
        }.prefix(1))
    }
}

extension GutendexClient: TestDependencyKey {
    /// Unimplemented by default, so a test must stub exactly what it exercises.
    static let testValue = GutendexClient()

    static let previewValue = GutendexClient(find: { _ in [] })
}

extension DependencyValues {
    var gutendexClient: GutendexClient {
        get { self[GutendexClient.self] }
        set { self[GutendexClient.self] = newValue }
    }
}

// MARK: - API Response Types

private struct GutendexResponse: Decodable {
    let results: [GutendexBook]
}

private struct GutendexBook: Decodable {
    let id: Int
    let title: String
    let authors: [GutendexAuthor]
    /// MIME type -> URL. Keys carry dots and slashes, so this stays a dictionary.
    let formats: [String: String]
}

private struct GutendexAuthor: Decodable {
    let name: String
}
