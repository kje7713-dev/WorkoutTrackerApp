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
    public let accent: Color
    
    // Premium accents
    public let premiumGold: Color
    public let premiumGradientStart: Color
    public let premiumGradientEnd: Color
    
    // Button colors
    public let primaryButtonBackgroundLight: Color
    public let primaryButtonBackgroundDark: Color
    public let primaryButtonForegroundLight: Color
    public let primaryButtonForegroundDark: Color
    
    // Semantic colors
    public let warning: Color
    public let error: Color
    public let info: Color

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
        mutedText: Color,
        accent: Color,
        premiumGold: Color,
        premiumGradientStart: Color,
        premiumGradientEnd: Color,
        primaryButtonBackgroundLight: Color,
        primaryButtonBackgroundDark: Color,
        primaryButtonForegroundLight: Color,
        primaryButtonForegroundDark: Color,
        warning: Color,
        error: Color,
        info: Color
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
        self.accent = accent
        self.premiumGold = premiumGold
        self.premiumGradientStart = premiumGradientStart
        self.premiumGradientEnd = premiumGradientEnd
        self.primaryButtonBackgroundLight = primaryButtonBackgroundLight
        self.primaryButtonBackgroundDark = primaryButtonBackgroundDark
        self.primaryButtonForegroundLight = primaryButtonForegroundLight
        self.primaryButtonForegroundDark = primaryButtonForegroundDark
        self.warning = warning
        self.error = error
        self.info = info
    }
}

public extension SBDTheme {
    /// Default Savage By Design theme based on the Design System spec.
    static let `default` = SBDTheme(
        primaryTextLight: .black,
        primaryTextDark: Color(red: 0.96, green: 0.96, blue: 0.96),        // #F5F5F5 Off-White
        backgroundLight: .white,
        backgroundDark: Color(red: 0.05, green: 0.05, blue: 0.05),         // #0D0D0D Savage Black
        cardBackgroundLight: Color(red: 0.95, green: 0.95, blue: 0.97),    // #F2F2F7 approx
        cardBackgroundDark: Color(red: 0.10, green: 0.10, blue: 0.11),     // #1A1A1B Steel Gray
        cardBorderLight: Color(red: 0.90, green: 0.90, blue: 0.92),        // light gray
        cardBorderDark: Color(red: 0.18, green: 0.18, blue: 0.18),         // #2D2D2E border
        success: Color(red: 0.00, green: 0.90, blue: 0.46),                // #00E676 Electric Green
        mutedText: Color(red: 0.70, green: 0.70, blue: 0.70),              // lighter muted text
        accent: Color(red: 0.00, green: 0.90, blue: 0.46),                 // #00E676 Electric Green
        premiumGold: Color(red: 1.00, green: 0.84, blue: 0.00),            // Gold accent for premium features
        // Note: premiumGradientStart matches accent for consistency, but kept separate for future flexibility
        premiumGradientStart: Color(red: 0.00, green: 0.48, blue: 1.00),   // Gradient start (blue)
        premiumGradientEnd: Color(red: 0.50, green: 0.00, blue: 0.80),     // Gradient end (purple)
        primaryButtonBackgroundLight: .black,
        primaryButtonBackgroundDark: Color(red: 0.10, green: 0.10, blue: 0.11),  // #1A1A1B Steel Gray
        primaryButtonForegroundLight: .white,
        primaryButtonForegroundDark: Color(red: 0.96, green: 0.96, blue: 0.96),  // #F5F5F5 Off-White
        warning: Color(red: 1.00, green: 0.58, blue: 0.00),                // Orange
        error: Color(red: 1.00, green: 0.23, blue: 0.19),                  // Red
        info: Color(red: 0.00, green: 0.48, blue: 1.00)                    // Blue
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
                RoundedRectangle(cornerRadius: 12)
                    .stroke(cardBorder, lineWidth: 1)
            )
            .cornerRadius(12)
            .shadow(color: shadowColor, radius: 3, x: 0, y: 1)
    }

    private var cardBackground: some View {
        Group {
            if colorScheme == .dark {
                // Subtle gradient from #1A1A1B to #111112 for dark mode
                LinearGradient(
                    gradient: Gradient(colors: [
                        theme.cardBackgroundDark,
                        Color(red: 0.067, green: 0.067, blue: 0.071)  // #111112
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                )
            } else {
                theme.cardBackgroundLight
            }
        }
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
    @Environment(\.sbdTheme) private var theme

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
                .tracking(1.5)  // 1.5px letter-spacing
                .frame(maxWidth: .infinity)
                .frame(height: 48)  // Reduced from 52 for sleeker profile
                .foregroundColor(foregroundColor)
                .background(backgroundColor)
                .cornerRadius(12)  // Changed from 20 (pill-shaped) to 12 (tactical)
        }
        .buttonStyle(PlainButtonStyle())
        .shadow(color: shadowColor, radius: 4, x: 0, y: 2)
    }

    private var backgroundColor: Color {
        colorScheme == .dark ? theme.primaryButtonBackgroundDark : theme.primaryButtonBackgroundLight
    }

    private var foregroundColor: Color {
        colorScheme == .dark ? theme.primaryButtonForegroundDark : theme.primaryButtonForegroundLight
    }
    
    private var shadowColor: Color {
        colorScheme == .dark ? Color.clear : Color.black.opacity(0.15)
    }
}

// MARK: - SBDSecondaryButton Component

/// Secondary button with outlined style
public struct SBDSecondaryButton: View {
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.sbdTheme) private var theme

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
                .tracking(1.5)  // 1.5px letter-spacing
                .frame(maxWidth: .infinity)
                .frame(height: 48)  // Reduced from 52 for sleeker profile
                .foregroundColor(textColor)
                .background(backgroundColor)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(borderColor, lineWidth: 2)
                )
                .cornerRadius(12)  // Changed from 20 to 12
        }
        .buttonStyle(PlainButtonStyle())
    }

    private var backgroundColor: Color {
        Color.clear
    }

    private var textColor: Color {
        colorScheme == .dark ? theme.primaryTextDark : theme.primaryTextLight
    }
    
    private var borderColor: Color {
        colorScheme == .dark ? theme.primaryTextDark : theme.primaryTextLight
    }
}

// MARK: - SBDPremiumButton Component

/// Premium button with gold accent for special features
public struct SBDPremiumButton: View {
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.sbdTheme) private var theme

    private let title: String
    private let icon: String?
    private let isLocked: Bool
    private let action: () -> Void

    public init(
        _ title: String,
        icon: String? = nil,
        isLocked: Bool = false,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.icon = icon
        self.isLocked = isLocked
        self.action = action
    }

    public var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                if isLocked {
                    Image(systemName: "lock.fill")
                        .foregroundColor(theme.premiumGold)
                }
                if let icon = icon {
                    Image(systemName: icon)
                }
                Text(title.uppercased())
                    .font(.system(size: 16, weight: .semibold))
                    .tracking(1.5)  // 1.5px letter-spacing
            }
            .frame(maxWidth: .infinity)
            .frame(height: 48)  // Reduced from 52 for sleeker profile
            .foregroundColor(.white)  // White provides optimal contrast on gradient backgrounds
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [theme.premiumGradientStart, theme.premiumGradientEnd]),
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .cornerRadius(12)  // Changed from 20 to 12
        }
        .buttonStyle(PlainButtonStyle())
        .shadow(color: theme.premiumGradientStart.opacity(0.3), radius: 8, x: 0, y: 4)
    }
}
