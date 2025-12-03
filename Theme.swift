//
//  Theme.swift
//  Savage By Design – Design System
//
//  Phase 2: Theme + basic components
//

import SwiftUI

// MARK: - SBDTheme Definition

public struct SBDTheme {
    // Core colors
    public let primaryTextLight: Color
    public let primaryTextDark: Color

    public let backgroundLight: Color
    public let backgroundDark: Color

    public let cardBackgroundLight: Color
    public let cardBackgroundDark: Color

    public let cardBorderLight: Color
    public let cardBorderDark: Color

    public let success: Color
    public let mutedText: Color

    public init(
        primaryTextLight: Color,
        primaryTextDark: Color,
        backgroundLight: Color,
        backgroundDark: Color,
        cardBackgroundLight: Color,
        cardBackgroundDark: Color,
        cardBorderLight: Color,
        cardBorderDark: Color,
        success: Color,
        mutedText: Color
    ) {
        self.primaryTextLight = primaryTextLight
        self.primaryTextDark = primaryTextDark
        self.backgroundLight = backgroundLight
        self.backgroundDark = backgroundDark
        self.cardBackgroundLight = cardBackgroundLight
        self.cardBackgroundDark = cardBackgroundDark
        self.cardBorderLight = cardBorderLight
        self.cardBorderDark = cardBorderDark
        self.success = success
        self.mutedText = mutedText
    }
}

public extension SBDTheme {
    /// Default Savage By Design theme based on the Design System spec.
    static let `default` = SBDTheme(
        primaryTextLight: .black,
        primaryTextDark: .white,
        backgroundLight: .white,
        backgroundDark: .black,
        cardBackgroundLight: Color(red: 0.95, green: 0.95, blue: 0.97),    // #F2F2F7 approx
        cardBackgroundDark: Color(red: 0.11, green: 0.11, blue: 0.12),     // #1C1C1E approx
        cardBorderLight: Color(red: 0.90, green: 0.90, blue: 0.92),        // light gray
        cardBorderDark: Color(red: 0.17, green: 0.17, blue: 0.18),         // dark border
        success: Color(red: 0.19, green: 0.82, blue: 0.34),                // system green feel
        mutedText: Color(red: 0.56, green: 0.56, blue: 0.58)               // neutral gray
    )
}

// MARK: - Environment Key

private struct ThemeKey: EnvironmentKey {
    static let defaultValue: SBDTheme = .default
}

public extension EnvironmentValues {
    var sbdTheme: SBDTheme {
        get { self[ThemeKey.self] }
        set { self[ThemeKey.self] = newValue }
    }
}

// MARK: - SBDCard Component

/// Generic card container using Savage By Design theme colors.
public struct SBDCard<Content: View>: View {
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.sbdTheme) private var theme

    private let content: Content

    public init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    public var body: some View {
        content
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(cardBackground)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(cardBorder, lineWidth: 1)
            )
            .cornerRadius(16)
            .shadow(color: shadowColor, radius: 3, x: 0, y: 1)
    }

    private var cardBackground: Color {
        colorScheme == .dark ? theme.cardBackgroundDark : theme.cardBackgroundLight
    }

    private var cardBorder: Color {
        colorScheme == .dark ? theme.cardBorderDark : theme.cardBorderLight
    }

    private var shadowColor: Color {
        colorScheme == .dark
            ? .clear
            : Color.black.opacity(0.10)
    }
}

// MARK: - SBDPrimaryButton Component

/// Primary CTA button with inverted black/white branding.
public struct SBDPrimaryButton: View {
    @Environment(\.colorScheme) private var colorScheme

    private let title: String
    private let action: () -> Void

    public init(
        _ title: String,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.action = action
    }

    public var body: some View {
        Button(action: action) {
            Text(title.uppercased())
                .font(.system(size: 16, weight: .semibold))
                .frame(maxWidth: .infinity)
                .frame(height: 52)
                .foregroundColor(foregroundColor)
                .background(backgroundColor)
                .cornerRadius(20)
        }
        .buttonStyle(PlainButtonStyle())
    }

    private var backgroundColor: Color {
        colorScheme == .dark ? .white : .black
    }

    private var foregroundColor: Color {
        colorScheme == .dark ? .black : .white
    }
}
