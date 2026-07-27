//
//  StandardEbooksClient.swift
//  Bookmarkd
//
//  Created by Aarav Gupta on 25/07/26.
//

import ComposableArchitecture
import DependenciesMacros
import Foundation

/// Standard Ebooks — ~900 carefully typeset public-domain books.
///
/// Their OPDS and Atom feeds now require authentication (HTTP 401), so the only open route is
/// the public search page. It carries RDFa/schema.org attributes, which survive a redesign far
/// better than class names would, so those are what gets parsed.
@DependencyClient
struct StandardEbooksClient: Sendable {
    var find: @Sendable (_ book: Book) async throws -> [BookSource]
}

extension StandardEbooksClient: DependencyKey {
    private static let host = "https://standardebooks.org"

    static let liveValue = StandardEbooksClient(
        find: { book in
            let query = book.title.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? book.title
            let url = URL(string: "\(host)/ebooks?query=\(query)")!
            var request = URLRequest(url: url)
            request.setValue("Bookmarkd/1.0 (contact@bookmarkd.app)", forHTTPHeaderField: "User-Agent")

            let (data, _) = try await URLSession.shared.data(for: request)
            guard let html = String(data: data, encoding: .utf8) else { return [] }
            return sources(fromHTML: html, for: book)
        }
    )

    /// Split out from the network call so parsing is testable offline.
    static func sources(fromHTML html: String, for book: Book) -> [BookSource] {
        entries(in: html).compactMap { entry in
            guard BookMatcher.matches(title: entry.title, authors: entry.authors, against: book),
                  let linkURL = URL(string: host + entry.slug)
            else { return nil }

            return BookSource(
                id: "standardebooks:\(entry.slug)",
                kind: .free,
                sourceName: "Standard Ebooks",
                title: entry.title,
                detail: "EPUB",
                linkURL: linkURL
            )
        }
    }

    /// `/ebooks/jane-austen/pride-and-prejudice`
    ///   -> `…/downloads/jane-austen_pride-and-prejudice.epub`
    ///
    /// Unused until the v2 reader, but the pattern is verified working today.
    static func epubURL(forSlug slug: String) -> URL? {
        let trimmed = slug.hasPrefix("/ebooks/") ? String(slug.dropFirst("/ebooks/".count)) : slug
        let fileName = trimmed.replacingOccurrences(of: "/", with: "_")
        return URL(string: "\(host)\(slug)/downloads/\(fileName).epub")
    }

    // MARK: - Parsing

    private struct Entry {
        let slug: String
        let title: String
        let authors: [String]
    }

    private static func entries(in html: String) -> [Entry] {
        // Each result is <li typeof="schema:Book" about="{slug}"> … </li>.
        html.components(separatedBy: #"<li typeof="schema:Book""#)
            .dropFirst()
            .compactMap { chunk in
                guard let slug = attribute("about", in: chunk) else { return nil }
                let names = propertyValues("schema:name", in: chunk)
                // The first schema:name is the book; any later ones are authors.
                guard let title = names.first else { return nil }
                return Entry(slug: slug, title: title, authors: Array(names.dropFirst()))
            }
    }

    private static func attribute(_ name: String, in chunk: String) -> String? {
        value(after: "\(name)=\"", in: chunk, terminator: "\"")
    }

    /// Every `>text<` immediately following `property="{name}"`.
    private static func propertyValues(_ property: String, in chunk: String) -> [String] {
        chunk.components(separatedBy: "property=\"\(property)\"")
            .dropFirst()
            .compactMap { part in
                guard let open = part.firstIndex(of: ">") else { return nil }
                let rest = part[part.index(after: open)...]
                guard let close = rest.firstIndex(of: "<") else { return nil }
                let text = rest[..<close].trimmingCharacters(in: .whitespacesAndNewlines)
                return text.isEmpty ? nil : text
            }
    }

    private static func value(after prefix: String, in text: String, terminator: Character) -> String? {
        guard let start = text.range(of: prefix) else { return nil }
        let rest = text[start.upperBound...]
        guard let end = rest.firstIndex(of: terminator) else { return nil }
        return String(rest[..<end])
    }
}

extension StandardEbooksClient: TestDependencyKey {
    static let testValue = StandardEbooksClient()

    static let previewValue = StandardEbooksClient(find: { _ in [] })
}

extension DependencyValues {
    var standardEbooksClient: StandardEbooksClient {
        get { self[StandardEbooksClient.self] }
        set { self[StandardEbooksClient.self] = newValue }
    }
}
