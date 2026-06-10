//
//  AppFeature.swift
//  Bookmarkd
//
//  Created by Aarav Gupta on 14/06/26.
//

import ComposableArchitecture
import SwiftUI

struct AppFeature: Reducer {
    @ObservableState
    struct State: Sendable {
        
    }
    
    @CasePathable
    enum Action: Equatable {
        
    }
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            return .none
        }
    }
}
