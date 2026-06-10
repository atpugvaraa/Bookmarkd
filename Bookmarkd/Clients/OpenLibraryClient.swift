//
//  OpenLibraryClient.swift
//  Bookmarkd
//
//  Created by Aarav Gupta on 09/06/26.
//

import Foundation
import ComposableArchitecture

struct OpenLibraryClient {
    var search: @Sendable (String) async throws -> [Book]
}

extension OpenLibraryClient: DependencyKey {
    static let liveValue = OpenLibraryClient(
        search: { query in
            let encoded = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? query
            let url = URL(string: "https://openlibrary.org/search.json?q=\(encoded)&limit=20")!
            
            var request = URLRequest(url: url)
            request.setValue("Bookmarkd/1.0 (contact@bookmarkd.app)", forHTTPHeaderField: "User-Agent")
            
            let (data, _) = try await URLSession.shared.data(for: request)
            let response = try JSONDecoder().decode(OpenLibraryResponse.self, from: data)
            
            return response.docs.map { doc in
                Book(
                    id: doc.key,
                    title: doc.title,
                    authors: doc.authorName ?? [],
                    coverURL: doc.coverI.map { URL(string: "https://covers.openlibrary.org/b/id/\($0)-M.jpg")! },
                    firstPublishYear: doc.firstPublishYear
                )
            }
        }
    )
}

extension OpenLibraryClient: TestDependencyKey {
    static let testValue = OpenLibraryClient(
        search: { _ in [] }
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
    let docs: [OpenLibraryDoc]
}

private struct OpenLibraryDoc: Decodable {
    let key: String
    let title: String
    let authorName: [String]?
    let coverI: Int?
    let firstPublishYear: Int?
    
    enum CodingKeys: String, CodingKey {
        case key, title
        case authorName = "author_name"
        case coverI = "cover_i"
        case firstPublishYear = "first_publish_year"
    }
}
