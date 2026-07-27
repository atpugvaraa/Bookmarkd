//
//  BookMatcher.swift
//  Bookmarkd
//
//  Created by Aarav Gupta on 25/07/26.
//

import Foundation

/// Decides whether a search result from some source is actually *this* book.
///
/// Retail and marketplace search is a fuzzy category match — one real capture returned 19
/// results for a specific title, of which 2 were the book and one was a deodorant. Every
/// candidate passes through here before it can become a `BookSource`.
nonisolated enum BookMatcher {
    /// Words carrying no identifying signal, dropped before comparison.
    private static let stopWords: Set<String> = ["the", "a", "an", "of", "and", "or", "by"]

    /// A title reduced to lowercase, unpunctuated, article-free tokens.
    static func normalizedTitleTokens(_ title: String) -> Set<String> {
        let folded = title.folding(options: [.diacriticInsensitive, .caseInsensitive], locale: nil)
        let cleaned = folded.map { $0.isLetter || $0.isNumber ? $0 : " " }
        return Set(
            String(cleaned)
                .split(separator: " ")
                .map(String.init)
                .filter { !stopWords.contains($0) && !$0.isEmpty }
        )
    }

    /// The surname, normalised. Handles both "Jane Austen" and Gutendex's "Austen, Jane".
    static func normalizedAuthorSurname(_ author: String) -> String? {
        let folded = author.folding(options: [.diacriticInsensitive, .caseInsensitive], locale: nil)
        if let comma = folded.firstIndex(of: ",") {
            let surname = folded[..<comma].trimmingCharacters(in: .whitespaces)
            return surname.isEmpty ? nil : surname
        }
        return folded.split(separator: " ").last.map(String.init)
    }

    /// True when `title` and `authors` confidently identify `book`.
    static func matches(title: String, authors: [String], against book: Book) -> Bool {
        let targetTokens = normalizedTitleTokens(book.title)
        guard !targetTokens.isEmpty else { return false }

        // Every significant word of the target must appear. This tolerates edition suffixes
        // ("…: 10th Anniversary Edition") while rejecting unrelated titles outright.
        let candidateTokens = normalizedTitleTokens(title)
        guard targetTokens.isSubset(of: candidateTokens) else { return false }

        let targetSurnames = Set(book.authors.compactMap(normalizedAuthorSurname))
        let candidateSurnames = Set(authors.compactMap(normalizedAuthorSurname))

        // Both sides named an author: they have to agree.
        if !targetSurnames.isEmpty, !candidateSurnames.isEmpty {
            return !targetSurnames.isDisjoint(with: candidateSurnames)
        }

        // The source gave no author, so the title alone has to carry the match. One
        // significant word is not enough — "The Secret" would swallow "The Secret of Secrets".
        return targetTokens.count >= 2
    }
}
