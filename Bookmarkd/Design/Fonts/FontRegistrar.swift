//
//  FontRegistrar.swift
//  Bookmarkd
//
//  Created by Aarav Gupta on 25/07/26.
//

import CoreGraphics
import CoreText
import SwiftUI
import UIKit

/// One bundled type face, named by what CoreText actually registered.
nonisolated struct FontFace: Identifiable, Hashable, Sendable {
    /// The exact name `Font.custom(_:size:)` needs.
    let postScriptName: String
    let familyName: String

    var id: String { postScriptName }
}

/// Loads the bundled type faces and reports what genuinely registered.
///
/// The app has no `Info.plist` — `GENERATE_INFOPLIST_FILE` is on — so `UIAppFonts` is not
/// available and the faces are registered with CoreText at launch instead. The font files
/// reach the bundle automatically because `Bookmarkd/` is a file-system-synchronized group.
///
/// Names are read back off each file rather than hard-coded. A hard-coded name that drifts
/// from the file resolves to the system face *silently*, which would make the font lab lie
/// about what you are looking at. Adding a candidate is dropping a file in this folder.
enum FontRegistrar {
    /// Every face that registered, sorted by family. Empty until `registerBundledFonts` runs.
    private(set) nonisolated(unsafe) static var faces: [FontFace] = []

    static func registerBundledFonts() {
        let urls = ["ttf", "otf"].flatMap {
            Bundle.main.urls(forResourcesWithExtension: $0, subdirectory: nil) ?? []
        }
        guard !urls.isEmpty else {
            assertionFailure("No font files in the bundle — the app will silently fall back to system faces.")
            return
        }

        CTFontManagerRegisterFontURLs(urls as CFArray, .process, true) { errors, done in
            if done, CFArrayGetCount(errors) > 0 {
                print("[Fonts] registration reported: \(errors)")
            }
            return true
        }

        faces = urls.compactMap(face(at:)).sorted { $0.familyName < $1.familyName }
        print("[Fonts] registered \(faces.count) of \(urls.count) files")
    }

    /// Reads the PostScript and family names straight out of the file.
    private static func face(at url: URL) -> FontFace? {
        guard let provider = CGDataProvider(url: url as CFURL),
              let font = CGFont(provider),
              let postScriptName = font.postScriptName as String?
        else {
            print("[Fonts] unreadable: \(url.lastPathComponent)")
            return nil
        }
        let descriptor = CTFontDescriptorCreateWithNameAndSize(postScriptName as CFString, 0)
        let family = CTFontDescriptorCopyAttribute(descriptor, kCTFontFamilyNameAttribute) as? String
        return FontFace(postScriptName: postScriptName, familyName: family ?? postScriptName)
    }
}
