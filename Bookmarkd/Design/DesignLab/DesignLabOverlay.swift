//
//  DesignLabOverlay.swift
//  Bookmarkd
//
//  Created by Aarav Gupta on 25/07/26.
//

import ComposableArchitecture
import SwiftUI

/// Development-only chrome for comparing screen designs on a real device.
///
/// A small pill sits out of the way at low opacity; tapping it opens a panel with a slider
/// across the designs and a sample-data switch. The pill can be hidden entirely so a design
/// is judged exactly as a user would see it — restore it with a two-finger triple tap, a
/// gesture no design uses.
struct DesignLabOverlay: View {
    @Shared(.homeDesign) private var homeDesign
    @Shared(.usesSampleLibrary) private var usesSampleLibrary
    @Shared(.designPillHidden) private var pillHidden

    @State private var isPanelPresented = false
    @State private var isFontLabPresented = false

    #if DEBUG
    @State private var isDirectFontLabPresented = ProcessInfo.processInfo.arguments.contains("-openFontLab")
    #endif

    private var selection: HomeDesign {
        HomeDesign(rawValue: homeDesign) ?? .current
    }

    private var selectionIndex: Int {
        HomeDesign.allCases.firstIndex(of: selection) ?? 0
    }

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            // Invisible restore target, so a hidden pill is always recoverable.
            if pillHidden {
                Color.clear
                    .contentShape(Rectangle())
                    .onTapGesture(count: 3) { $pillHidden.withLock { $0 = false } }
                    .allowsHitTesting(true)
                    .accessibilityHidden(true)
            } else {
                pill
                    .padding(.trailing, 16)
                    .padding(.bottom, 96)
            }
        }
        .sheet(isPresented: $isPanelPresented) { panel }
        #if DEBUG
        // Lets the font lab be opened straight from a launch argument, so it can be captured
        // without driving the UI: `simctl launch <device> <bundle id> -openFontLab`.
        .sheet(isPresented: $isDirectFontLabPresented) { FontLabView() }
        #endif
    }

    private var pill: some View {
        Button {
            isPanelPresented = true
        } label: {
            HStack(spacing: 7) {
                Image(systemName: "paintpalette.fill")
                    .font(.system(size: 12, weight: .semibold))

                // The name, not just an index — "3/6" says nothing about what you're looking at.
                Text(selection.displayName)
                    .font(.system(size: 13, weight: .semibold))

                Text("\(selectionIndex + 1)/\(HomeDesign.allCases.count)")
                    .font(.system(size: 11, weight: .medium))
                    .opacity(0.65)
            }
            .foregroundStyle(.white)
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(Capsule().fill(.black.opacity(0.78)))
            .overlay(Capsule().strokeBorder(.white.opacity(0.22), lineWidth: 1))
            .shadow(color: .black.opacity(0.3), radius: 8, y: 3)
            // Generous, reliable hit area — the whole capsule, not just the glyphs.
            .contentShape(Capsule())
        }
        .buttonStyle(.plain)
        // Swipe the pill to step designs without opening anything — the fastest way to flick
        // back and forth between two candidates on the same screen.
        .highPriorityGesture(
            DragGesture(minimumDistance: 24)
                .onEnded { value in
                    guard abs(value.translation.width) > abs(value.translation.height) else { return }
                    step(by: value.translation.width < 0 ? 1 : -1)
                }
        )
        .accessibilityLabel("Design lab, showing \(selection.displayName)")
        .accessibilityHint("Swipe left or right to change design, or tap to open the panel")
    }

    /// Moves through the designs, wrapping at both ends.
    private func step(by offset: Int) {
        let all = HomeDesign.allCases
        let next = (selectionIndex + offset + all.count) % all.count
        withAnimation(.snappy) {
            $homeDesign.withLock { $0 = all[next].rawValue }
        }
    }

    private var panel: some View {
        NavigationStack {
            Form {
                Section("Home design") {
                    // A slider rather than tap-to-cycle, so any design is one gesture away.
                    Slider(
                        value: Binding(
                            get: { Double(selectionIndex) },
                            set: { newValue in
                                let index = min(HomeDesign.allCases.count - 1, max(0, Int(newValue.rounded())))
                                $homeDesign.withLock { $0 = HomeDesign.allCases[index].rawValue }
                            }
                        ),
                        in: 0...Double(HomeDesign.allCases.count - 1),
                        step: 1
                    )

                    VStack(alignment: .leading, spacing: 3) {
                        HStack {
                            Text(selection.displayName).fontWeight(.semibold)
                            Spacer()
                            Text("\(selectionIndex + 1) of \(HomeDesign.allCases.count)")
                                .foregroundStyle(.secondary)
                        }
                        // What makes this one different. Two rounds of designs failed by being
                        // four ideas wearing ten names, so the distinguishing axis is stated
                        // where it can be compared rather than left implied.
                        Text(selection.axis)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }

                    Picker("Jump to", selection: Binding(
                        get: { selection },
                        set: { newValue in $homeDesign.withLock { $0 = newValue.rawValue } }
                    )) {
                        ForEach(HomeDesign.allCases) { design in
                            Text(design.displayName).tag(design)
                        }
                    }
                    .pickerStyle(.inline)
                    .labelsHidden()
                }

                Section {
                    Button("Open the font lab") { isFontLabPresented = true }
                } header: {
                    Text("Type")
                } footer: {
                    Text("Every bundled face, set in the app's own words at the app's own sizes. Display and body are picked separately.")
                }

                Section {
                    Toggle("Sample library", isOn: Binding(
                        get: { usesSampleLibrary },
                        set: { newValue in $usesSampleLibrary.withLock { $0 = newValue } }
                    ))
                } header: {
                    Text("Data")
                } footer: {
                    Text("Fills Home with twelve books at varied progress so a design can be judged full. Your real shelf on disk is never modified.")
                }

                Section {
                    Button("Hide the pill", role: .destructive) {
                        $pillHidden.withLock { $0 = true }
                        isPanelPresented = false
                    }
                } footer: {
                    Text("Judge a design with no chrome at all. Triple-tap anywhere to bring it back.")
                }
            }
            .navigationTitle("Design lab")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { isPanelPresented = false }
                }
            }
        }
        // Presented from the panel rather than the pill: dismissing one sheet and presenting
        // another in the same tick drops the second one.
        .sheet(isPresented: $isFontLabPresented) { FontLabView() }
        .presentationDetents([.medium, .large])
    }
}
