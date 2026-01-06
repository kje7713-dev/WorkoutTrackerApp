//
//  Theme.swift
//  Savage By Design – Design System
//
//  Phase 2: Theme + basic components + Pro Home Design Tokens
//

import SwiftUI

// MARK: - Design Tokens

public struct DesignTokens {
    // Spacing (8pt grid)
    public static let spacing4: CGFloat = 4
    public static let spacing8: CGFloat = 8
    public static let spacing12: CGFloat = 12
    public static let spacing14: CGFloat = 14
    public static let spacing16: CGFloat = 16
    public static let spacing20: CGFloat = 20
    public static let spacing24: CGFloat = 24
    public static let spacing32: CGFloat = 32
    
    // Corner radius
    public static let cornerCard: CGFloat = 16
    public static let cornerRow: CGFloat = 14
    public static let cornerPill: CGFloat = 999
    
    // Stroke
    public static let strokeHairline: CGFloat = 1
}

// MARK: - Pro Design Colors

public extension Color {
    // Pro Home colors (system-friendly)
    static let proBackground = Color(hex: "F7F7F7")
    static let proSurface = Color(hex: "FFFFFF")
    static let proTextPrimary = Color(hex: "0B0B0B")
    static let proTextSecondary = Color(hex: "5A5A5A")
    static let proDivider = Color.black.opacity(0.08)
    static let proBrandBlack = Color(hex: "0F0F10")
    static let proBrandGreen = Color(hex: "22C55E")
    static let proAccentGold = Color(hex: "D4AF37")
    
    // Hex initializer
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

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
        primaryTextLight: .proTextPrimary,
        primaryTextDark: .white,
        backgroundLight: .proBackground,
        backgroundDark: .black,
        cardBackgroundLight: .proSurface,
        cardBackgroundDark: Color(red: 0.11, green: 0.11, blue: 0.12),     // #1C1C1E approx
        cardBorderLight: .proDivider,
        cardBorderDark: Color(red: 0.17, green: 0.17, blue: 0.18),         // dark border
        success: .proBrandGreen,
        mutedText: .proTextSecondary,
        accent: Color(red: 0.00, green: 0.48, blue: 1.00),                 // iOS system blue
        premiumGold: .proAccentGold,
        // Note: premiumGradientStart matches accent for consistency, but kept separate for future flexibility
        premiumGradientStart: Color(red: 0.00, green: 0.48, blue: 1.00),   // Gradient start (blue)
        premiumGradientEnd: Color(red: 0.50, green: 0.00, blue: 0.80),     // Gradient end (purple)
        primaryButtonBackgroundLight: .proBrandBlack,
        primaryButtonBackgroundDark: .white,
        primaryButtonForegroundLight: .white,
        primaryButtonForegroundDark: .black,
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
                .frame(maxWidth: .infinity)
                .frame(height: 52)
                .foregroundColor(foregroundColor)
                .background(backgroundColor)
                .cornerRadius(20)
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
                .frame(maxWidth: .infinity)
                .frame(height: 52)
                .foregroundColor(textColor)
                .background(backgroundColor)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(borderColor, lineWidth: 2)
                )
                .cornerRadius(20)
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
            }
            .frame(maxWidth: .infinity)
            .frame(height: 52)
            .foregroundColor(.white)  // White provides optimal contrast on gradient backgrounds
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [theme.premiumGradientStart, theme.premiumGradientEnd]),
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .cornerRadius(20)
        }
        .buttonStyle(PlainButtonStyle())
        .shadow(color: theme.premiumGradientStart.opacity(0.3), radius: 8, x: 0, y: 4)
    }
}

// MARK: - Pro Home Components

/// Status pill for displaying pro status
public struct StatusPill: View {
    private let text: String
    private let isActive: Bool
    @Environment(\.sbdTheme) private var theme
    
    public init(text: String, isActive: Bool = true) {
        self.text = text
        self.isActive = isActive
    }
    
    public var body: some View {
        HStack(spacing: 6) {
            Circle()
                .fill(isActive ? Color.proBrandGreen : Color.proTextSecondary)
                .frame(width: 6, height: 6)
            
            Text(text)
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(isActive ? Color.proBrandGreen : Color.proTextSecondary)
                .textCase(.uppercase)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .frame(height: 26)
        .background(
            isActive 
                ? Color.proBrandGreen.opacity(0.18)
                : Color.proTextSecondary.opacity(0.18)
        )
        .cornerRadius(DesignTokens.cornerPill)
    }
}

/// Mini chip for hero card metrics
public struct MetricChip: View {
    private let icon: String
    private let label: String
    
    public init(icon: String, label: String) {
        self.icon = icon
        self.label = label
    }
    
    public var body: some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 14))
            Text(label)
                .font(.system(size: 12, weight: .regular))
        }
        .foregroundColor(.white.opacity(0.85))
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .frame(height: 28)
        .background(Color.white.opacity(0.10))
        .cornerRadius(DesignTokens.cornerPill)
    }
}

/// Hero card component for pro home
public struct HeroCard<Content: View>: View {
    private let content: Content
    
    public init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    public var body: some View {
        content
            .padding(DesignTokens.spacing16)
            .frame(maxWidth: .infinity)
            .background(Color.proBrandBlack)
            .cornerRadius(DesignTokens.cornerCard)
            .shadow(color: Color.black.opacity(0.12), radius: 10, x: 0, y: 10)
    }
}

/// Feature row content for navigation items
public struct FeatureRowContent: View {
    private let icon: String
    private let title: String
    private let subtitle: String
    
    public init(icon: String, title: String, subtitle: String) {
        self.icon = icon
        self.title = title
        self.subtitle = subtitle
    }
    
    public var body: some View {
        HStack(spacing: DesignTokens.spacing12) {
            // Icon container
            ZStack {
                Circle()
                    .fill(Color.proBrandBlack.opacity(0.06))
                    .frame(width: 36, height: 36)
                
                Image(systemName: icon)
                    .font(.system(size: 18))
                    .foregroundColor(Color.proTextPrimary)
            }
            
            // Text content
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(Color.proTextPrimary)
                
                Text(subtitle)
                    .font(.system(size: 13, weight: .regular))
                    .foregroundColor(Color.proTextSecondary)
                    .multilineTextAlignment(.leading)
            }
            
            Spacer()
            
            // Chevron
            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(Color.proTextPrimary.opacity(0.35))
        }
        .padding(DesignTokens.spacing14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.proSurface)
        .overlay(
            RoundedRectangle(cornerRadius: DesignTokens.cornerRow)
                .stroke(Color.proDivider, lineWidth: DesignTokens.strokeHairline)
        )
        .cornerRadius(DesignTokens.cornerRow)
        .shadow(color: Color.black.opacity(0.06), radius: 3, x: 0, y: 3)
    }
}

/// Feature row for navigation items (with action)
public struct FeatureRow: View {
    private let icon: String
    private let title: String
    private let subtitle: String
    private let action: () -> Void
    
    public init(icon: String, title: String, subtitle: String, action: @escaping () -> Void) {
        self.icon = icon
        self.title = title
        self.subtitle = subtitle
        self.action = action
    }
    
    public var body: some View {
        Button(action: action) {
            FeatureRowContent(icon: icon, title: title, subtitle: subtitle)
        }
        .buttonStyle(PlainButtonStyle())
    }
}
