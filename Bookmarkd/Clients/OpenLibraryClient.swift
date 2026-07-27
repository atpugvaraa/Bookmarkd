//
//  OpenLibraryClient.swift
//  Bookmarkd
//
//  Created by Aarav Gupta on 09/06/26.
//

import ComposableArchitecture
import DependenciesMacros
import Foundation

/// One page of search results.
nonisolated struct SearchPage: Equatable, Sendable {
    var books: [Book]
    /// Total matches across all pages, used to decide whether another page exists.
    var numFound: Int

    init(books: [Book] = [], numFound: Int = 0) {
        self.books = books
        self.numFound = numFound
    }
}

@DependencyClient
struct OpenLibraryClient: Sendable {
    /// `page` is 1-based, matching Open Library.
    var search: @Sendable (_ query: String, _ page: Int) async throws -> SearchPage
    /// Fetches description and subjects for a work key such as `/works/OL20150260W`.
    var work: @Sendable (_ id: String) async throws -> BookDetail
}

extension OpenLibraryClient: DependencyKey {
    static let resultsPerPage = 20

    static let liveValue = OpenLibraryClient(
        search: { query, page in
            let encoded = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? query
            // Requesting explicit fields keeps the payload small and pulls page count, ISBNs
            // and ebook availability along with the basics.
            let fields = [
                "key", "title", "author_name", "cover_i", "first_publish_year",
                "edition_count", "ebook_access", "ia", "number_of_pages_median", "isbn",
            ].joined(separator: ",")
            let url = URL(
                string: "https://openlibrary.org/search.json"
                    + "?q=\(encoded)&page=\(page)&limit=\(resultsPerPage)&fields=\(fields)"
            )!

            let response: OpenLibraryResponse = try await get(url)
            return SearchPage(books: response.docs.map(Book.init(doc:)), numFound: response.numFound)
        },
        work: { id in
            // `id` is already "/works/OL…W".
            let url = URL(string: "https://openlibrary.org\(id).json")!
            let response: OpenLibraryWork = try await get(url)
            return BookDetail(
                description: response.description?.text,
                subjects: response.subjects ?? []
            )
        }
    )

    private static func get<T: Decodable>(_ url: URL) async throws -> T {
        var request = URLRequest(url: url)
        // Open Library allows 3 req/s with a User-Agent, 1 req/s without.
        request.setValue("Bookmarkd/1.0 (contact@bookmarkd.app)", forHTTPHeaderField: "User-Agent")

        let (data, _) = try await URLSession.shared.data(for: request)
        return try JSONDecoder().decode(T.self, from: data)
    }
}

extension OpenLibraryClient: TestDependencyKey {
    /// Every endpoint reports an issue when called, so a test must override exactly the
    /// endpoints it expects to be hit rather than silently getting empty results.
    static let testValue = OpenLibraryClient()

    static let previewValue = OpenLibraryClient(
        search: { _, _ in SearchPage() },
        work: { _ in BookDetail() }
    )
}

extension DependencyValues {
    var openLibraryClient: OpenLibraryClient {
        get { self[OpenLibraryClient.self] }
        set { self[OpenLibraryClient.self] = newValue }
    }
}

// MARK: - API Response Types

private struct OpenLibraryResponse: Decodable {
    let numFound: Int
    let docs: [OpenLibraryDoc]
}

private struct OpenLibraryDoc: Decodable {
    let key: String
    let title: String
    let authorName: [String]?
    let coverI: Int?
    let firstPublishYear: Int?
    let numberOfPagesMedian: Int?
    let isbn: [String]?
    let editionCount: Int?
    let ebookAccess: String?
    let ia: [String]?

    enum CodingKeys: String, CodingKey {
        case key, title, isbn, ia
        case authorName = "author_name"
        case coverI = "cover_i"
        case firstPublishYear = "first_publish_year"
        case numberOfPagesMedian = "number_of_pages_median"
        case editionCount = "edition_count"
        case ebookAccess = "ebook_access"
    }
}

private struct OpenLibraryWork: Decodable {
    let description: DescriptionValue?
    let subjects: [String]?
}

/// Open Library returns a work description either as a plain string or as
/// `{"type": "/type/text", "value": "…"}`. Decode both rather than losing the description
/// — or the whole request — to whichever shape happens to come back.
struct DescriptionValue: Decodable {
    let text: String

    init(from decoder: any Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let plain = try? container.decode(String.self) {
            text = plain
        } else {
            struct Keyed: Decodable { let value: String }
            text = try container.decode(Keyed.self).value
        }
    }
}

private extension Book {
    init(doc: OpenLibraryDoc) {
        // A popular work can list ~40 ISBNs and dozens of scans; cap them here so what gets
        // persisted with a shelf entry stays small.
        self.init(
            id: doc.key,
            title: doc.title,
            authors: doc.authorName ?? [],
            coverURL: doc.coverI.map { URL(string: "https://covers.openlibrary.org/b/id/\($0)-M.jpg")! },
            firstPublishYear: doc.firstPublishYear,
            pageCount: doc.numberOfPagesMedian,
            isbns: doc.isbn.map { Array($0.prefix(3)) },
            editionCount: doc.editionCount,
            ebookAccess: doc.ebookAccess,
            iaIdentifiers: doc.ia.map { Array($0.prefix(2)) }
        )
    }
}
