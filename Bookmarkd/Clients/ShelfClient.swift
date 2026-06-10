//
//  ShelfClient.swift
//  Bookmarkd
//
//  Created by Aarav Gupta on 14/06/26.
//


import Foundation
import ComposableArchitecture

struct ShelfClient: Sendable {
    var loadAll: @Sendable () async -> [ShelfEntry]
    var save: @Sendable (ShelfEntry) async -> Void
    var remove: @Sendable (String) async -> Void   // by book id
    var entry: @Sendable (String) async -> ShelfEntry?  // get one by book id
}

extension ShelfClient: DependencyKey {
    static let liveValue: ShelfClient = {
        let store = ShelfStore()
        return ShelfClient(
            loadAll: { await store.all() },
            save: { await store.save($0) },
            remove: { await store.remove($0) },
            entry: { await store.entry($0) }
        )
    }()
    
    static let testValue = ShelfClient(
        loadAll: { [] },
        save: { _ in },
        remove: { _ in },
        entry: { _ in nil }
    )
}

extension DependencyValues {
    var shelfClient: ShelfClient {
        get { self[ShelfClient.self] }
        set { self[ShelfClient.self] = newValue }
    }
}

// Simple actor-backed store persisting to UserDefaults as JSON
private actor ShelfStore {
    private let key = "bookmarkd.shelf.entries"
    private var entries: [ShelfEntry] = []
    
    init() {
        if let data = UserDefaults.standard.data(forKey: key),
           let decoded = try? JSONDecoder().decode([ShelfEntry].self, from: data) {
            entries = decoded
        }
    }
    
    func all() -> [ShelfEntry] { entries }
    
    func entry(_ id: String) -> ShelfEntry? {
        entries.first { $0.id == id }
    }
    
    func save(_ entry: ShelfEntry) {
        if let index = entries.firstIndex(where: { $0.id == entry.id }) {
            entries[index] = entry
        } else {
            entries.append(entry)
        }
        persist()
    }
    
    func remove(_ id: String) {
        entries.removeAll { $0.id == id }
        persist()
    }
    
    private func persist() {
        if let data = try? JSONEncoder().encode(entries) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }
}
