//
//  BookRoute.swift
//  Bookmarkd
//
//  Created by Aarav Gupta on 25/07/26.
//

import ComposableArchitecture

/// Destinations reachable from a tab's navigation stack.
///
/// Home, Shelf and Search all push the same screens, so they share one route enum.
/// Split it per-feature the moment their destinations actually diverge.
@Reducer(state: .equatable)
enum BookRoute {
    case bookDetail(BookDetailFeature)
}
