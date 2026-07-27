//
//  SafariView.swift
//  Bookmarkd
//
//  Created by Aarav Gupta on 25/07/26.
//

import SafariServices
import SwiftUI

/// In-app browser. Keeps the reader inside Bookmarkd when they follow a source link,
/// rather than throwing them out to Safari and losing their place.
struct SafariView: UIViewControllerRepresentable {
    let url: URL

    func makeUIViewController(context: Context) -> SFSafariViewController {
        let configuration = SFSafariViewController.Configuration()
        configuration.entersReaderIfAvailable = true
        return SFSafariViewController(url: url, configuration: configuration)
    }

    func updateUIViewController(_ controller: SFSafariViewController, context: Context) {}
}
