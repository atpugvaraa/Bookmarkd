//
//  DesignCanvas.swift
//  Bookmarkd
//
//  Created by Aarav Gupta on 26/07/26.
//

import SwiftUI

/// The surface every Home design starts from.
///
/// Same background, same top inset under the status bar, same clearance for the floating tab
/// bar. Designs that each rolled their own padding differed by a few points in ways that read
/// as design decisions but were not — this makes the differences between designs real ones.
struct DesignCanvas<Content: View>: View {
    var background: Color?
    /// Off for designs that place their own full-bleed content, like a cover to the edges.
    var scrolls: Bool = true
    var horizontalMargin: CGFloat = 24
    @ViewBuilder var content: () -> Content

    @Environment(\.theme) private var theme

    /// Clears the Aesthetics tab bar, which floats over the content rather than insetting it.
    private let tabBarClearance: CGFloat = 118

    var body: some View {
        ZStack {
            (background ?? theme.palette.background).ignoresSafeArea()

            if scrolls {
                ScrollView {
                    content()
                        .padding(.horizontal, horizontalMargin)
                        .padding(.top, 58)
                        .padding(.bottom, tabBarClearance)
                }
                .scrollIndicators(.hidden)
            } else {
                content()
            }
        }
    }
}
