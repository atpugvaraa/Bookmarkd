//
//  FontLabView.swift
//  Bookmarkd
//
//  Created by Aarav Gupta on 25/07/26.
//

import ComposableArchitecture
import SwiftUI

/// Every bundled face, set in the app's own words at the app's own sizes, on the app's own
/// background.
///
/// A specimen sheet renders a face large on white, which is exactly the condition under which
/// every face looks good. The judgement that matters here is whether "page 210 of 322" is still
/// readable at 13pt on tan — so that is what each row shows, alongside the 28pt title the same
/// face has to carry. Tap a row to set it live.
struct FontLabView: View {
    @Environment(\.theme) private var theme
    @Environment(\.dismiss) private var dismiss

    @Shared(.displayFontName) private var displayFontName
    @Shared(.bodyFontName) private var bodyFontName

    @State private var role: FontChoice.Role = .display

    /// Compact mode drops everything but the small sizes, so all the faces sit within a couple
    /// of screens and can be compared against each other rather than against memory. It is the
    /// view that answers "is this still readable at 13pt", which is the hard question.
    @State private var isCompact = ProcessInfo.processInfo.arguments.contains("-fontLabCompact")

    private var faces: [FontFace] { FontRegistrar.faces }

    private func assignedName(for role: FontChoice.Role) -> String {
        switch role {
        case .display: displayFontName
        case .body: bodyFontName
        }
    }

    private func assign(_ name: String) {
        withAnimation(.snappy) {
            switch role {
            case .display: $displayFontName.withLock { $0 = name }
            case .body: $bodyFontName.withLock { $0 = name }
            }
        }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(spacing: isCompact ? 2 : 14) {
                    if !isCompact { pairingPreview }

                    row(
                        title: "System rounded",
                        subtitle: "control",
                        fontName: nil,
                        isAssigned: assignedName(for: role).isEmpty
                    )
                    .onTapGesture { assign("") }

                    ForEach(faces) { face in
                        row(
                            title: face.familyName,
                            subtitle: face.postScriptName,
                            fontName: face.postScriptName,
                            isAssigned: assignedName(for: role) == face.postScriptName
                        )
                        .onTapGesture { assign(face.postScriptName) }
                    }

                    if faces.isEmpty {
                        Text("No faces registered. Check the launch log.")
                            .font(.footnote)
                            .foregroundStyle(theme.palette.inkMuted)
                            .padding(.vertical, 40)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 32)
            }
            #if DEBUG
            // Lets the tail of the list be captured without driving the UI.
            .defaultScrollAnchor(ProcessInfo.processInfo.arguments.contains("-fontLabBottom") ? .bottom : .top)
            #endif
            .background(theme.palette.background.ignoresSafeArea())
            .navigationTitle("Font lab")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    // Which role a tap assigns to. Display and body are picked separately
                    // because the winner is usually a pairing, not one face doing both jobs.
                    Picker("Assigning", selection: $role) {
                        ForEach(FontChoice.Role.allCases) { role in
                            Text(role.title).tag(role)
                        }
                    }
                    .pickerStyle(.segmented)
                    .frame(width: 180)
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        withAnimation(.snappy) { isCompact.toggle() }
                    } label: {
                        Image(systemName: isCompact ? "textformat.size.larger" : "textformat.size.smaller")
                    }
                    .accessibilityLabel(isCompact ? "Show full specimens" : "Show small sizes only")
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }

    /// What the app looks like right now, so a candidate is judged against the pairing it
    /// would replace rather than in isolation.
    private var pairingPreview: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Currently set")
                .font(.caption2.weight(.semibold))
                .foregroundStyle(theme.palette.inkMuted)
                .textCase(.uppercase)
                .kerning(0.6)

            Text("Atomic Habits")
                .font(BookmarkdFont.display(28))
                .foregroundStyle(theme.palette.ink)

            Text("page 210 of 322 · 6 day streak")
                .font(BookmarkdFont.body(13))
                .foregroundStyle(theme.palette.inkMuted)

            Text("Tap any face below to set it as the \(role.title.lowercased()) face.")
                .font(.caption2)
                .foregroundStyle(theme.palette.inkMuted)
                .padding(.top, 2)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: theme.shape.cardCornerRadius)
                .fill(theme.palette.material.opacity(0.22))
        )
        .padding(.top, 8)
    }

    @ViewBuilder
    private func row(
        title: String,
        subtitle: String,
        fontName: String?,
        isAssigned: Bool
    ) -> some View {
        let face: (CGFloat) -> Font = { size in
            if let fontName { .custom(fontName, size: size, relativeTo: .body) }
            else { .system(size: size, design: .rounded) }
        }
        let radius = theme.shape.cardCornerRadius

        Group {
            if isCompact {
                HStack(spacing: 10) {
                    Text("page 210 of 322 · 6 day streak")
                        .font(face(13))
                        .lineLimit(1)
                    Spacer(minLength: 6)
                    Text(title)
                        .font(.system(size: 9))
                        .foregroundStyle(theme.palette.inkMuted)
                        .lineLimit(1)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
            } else {
                // The app's four real strings at their four real sizes. 12pt is the smallest
                // thing in the app, and where characterful faces tend to fall apart.
                VStack(alignment: .leading, spacing: 8) {
                    HStack(alignment: .firstTextBaseline) {
                        Text(title)
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(theme.palette.inkMuted)
                        Spacer()
                        if isAssigned {
                            Text(role.title)
                                .font(.caption2.weight(.bold))
                                .foregroundStyle(theme.palette.onAccent)
                                .padding(.horizontal, 7)
                                .padding(.vertical, 3)
                                .background(Capsule().fill(theme.palette.accent))
                        }
                    }

                    Text("Atomic Habits").font(face(28))
                    Text("James Clear").font(face(15))
                    Text("page 210 of 322").font(face(13))
                    Text("6 day streak · 22 of 20 min").font(face(12))

                    Text(subtitle)
                        .font(.system(size: 9, design: .monospaced))
                        .foregroundStyle(theme.palette.inkMuted.opacity(0.7))
                }
                .padding(14)
            }
        }
        .foregroundStyle(theme.palette.ink)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: radius)
                .fill(theme.palette.surface.opacity(isAssigned ? 1 : 0.55))
        )
        .overlay(
            RoundedRectangle(cornerRadius: radius)
                .strokeBorder(theme.palette.ink.opacity(isAssigned ? 0.9 : 0.12), lineWidth: isAssigned ? 2 : 1)
        )
        .contentShape(RoundedRectangle(cornerRadius: radius))
    }
}
