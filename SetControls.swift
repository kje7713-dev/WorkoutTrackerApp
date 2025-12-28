//
//  SetControls.swift
//  Savage By Design
//
//  Reusable UI controls for logging set data.
//
import SwiftUI

// MARK: - Helper Struct for Reusability

public struct SetControlView: View {
    let label: String
    let unit: String
    @Binding var value: Double?
    let step: Double
    let formatter: NumberFormatter
    let min: Double
    let max: Double?

    public init(
        label: String,
        unit: String,
        value: Binding<Double?>,
        step: Double,
        formatter: NumberFormatter,
        min: Double,
        max: Double? = nil
    ) {
        self.label = label
        self.unit = unit
        _value = value
        self.step = step
        self.formatter = formatter
        self.min = min
        self.max = max
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            // Label
            Text(label)
                .font(.caption2)
                .foregroundColor(.secondary)

            // Controls
            HStack(spacing: 4) {
                Button {
                    if let currentValue = value {
                        value = Swift.max(min, currentValue - step)
                    } else {
                        value = min
                    }
                } label: {
                    Image(systemName: "minus.circle")
                }

                Text(value.flatMap { formatter.string(from: NSNumber(value: $0)) } ?? "-")
                    .font(.body.monospacedDigit())
                    .frame(width: 40)
                    .minimumScaleFactor(0.5)

                Button {
                    if let currentValue = value {
                        let newValue = currentValue + step
                        value = max.map { Swift.min(newValue, $0) } ?? newValue
                    } else {
                        value = min + step
                    }
                } label: {
                    Image(systemName: "plus.circle")
                }

                Text(unit)
                    .font(.body)
            }
        }
    }
}

// MARK: - BINDING EXTENSIONS

extension Binding where Value == Int? {
    /// Converts an optional Int binding to an optional Double binding.
    func toDouble() -> Binding<Double?> {
        return Binding<Double?>(
            get: { self.wrappedValue.map(Double.init) },
            set: { self.wrappedValue = $0.map { Int($0) } }
        )
    }
}

extension Binding where Value == Double? {
    /// Utility to simplify passing Double? bindings to SetControlView
    func toDouble() -> Binding<Double?> {
        return self
    }
}

// MARK: - String Optional Binding Helper

extension Binding where Value == String? {
    /// Creates a non-optional String binding that defaults to "" when the underlying optional is nil.
    public func toNonOptionalString() -> Binding<String> {
        return Binding<String>(
            get: {
                return self.wrappedValue ?? ""
            },
            set: { newValue in
                // Set back to nil if empty, otherwise set new value
                self.wrappedValue = newValue.isEmpty ? nil : newValue
            }
        )
    }
}

// MARK: - Time Conversion Binding Helper

extension Binding where Value == Double? {
    /// Converts a Binding<Double?> (seconds) to a Binding<Double?> (minutes).
    func toMinutes() -> Binding<Double?> {
        return Binding<Double?>(
            get: {
                // Read: Convert seconds to minutes
                self.wrappedValue.map { $0 / 60.0 }
            },
            set: { newValue in
                // Write: Convert minutes back to seconds
                self.wrappedValue = newValue.map { $0 * 60.0 }
            }
        )
    }
}

extension Binding where Value == Int? {
    /// Converts a Binding<Int?> (seconds) to a Binding<Int?> (minutes).
    func toMinutes() -> Binding<Int?> {
        return Binding<Int?>(
            get: {
                // Read: Convert seconds to minutes
                self.wrappedValue.map { $0 / 60 }
            },
            set: { newValue in
                // Write: Convert minutes back to seconds
                self.wrappedValue = newValue.map { $0 * 60 }
            }
        )
    }
}

// MARK: - Time Formatting Utilities

/// Utility struct for converting between seconds and HH:MM:SS format
public struct TimeFormatter {
    /// Converts total seconds to hours, minutes, seconds components
    /// - Parameter totalSeconds: Total seconds (can be Int or Double)
    /// - Returns: Tuple of (hours, minutes, seconds)
    public static func secondsToComponents(_ totalSeconds: Int) -> (hours: Int, minutes: Int, seconds: Int) {
        let hours = totalSeconds / 3600
        let minutes = (totalSeconds % 3600) / 60
        let seconds = totalSeconds % 60
        return (hours, minutes, seconds)
    }
    
    /// Converts hours, minutes, seconds to total seconds
    /// - Parameters:
    ///   - hours: Number of hours
    ///   - minutes: Number of minutes
    ///   - seconds: Number of seconds
    /// - Returns: Total seconds
    public static func componentsToSeconds(hours: Int, minutes: Int, seconds: Int) -> Int {
        return hours * 3600 + minutes * 60 + seconds
    }
    
    /// Formats total seconds as HH:MM:SS string
    /// - Parameter totalSeconds: Total seconds
    /// - Returns: Formatted string (e.g., "1:30:15" or "00:00:20")
    public static func formatTime(_ totalSeconds: Int) -> String {
        let (hours, minutes, seconds) = secondsToComponents(totalSeconds)
        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, minutes, seconds)
        } else {
            return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
        }
    }
    
    /// Parses HH:MM:SS string to total seconds
    /// - Parameter timeString: Time string (e.g., "1:30:15", "00:20", "90")
    /// - Returns: Total seconds, or nil if invalid format
    public static func parseTime(_ timeString: String) -> Int? {
        let components = timeString.split(separator: ":").compactMap { Int($0.trimmingCharacters(in: .whitespaces)) }
        
        switch components.count {
        case 1:
            // Just seconds (e.g., "90")
            return components[0]
        case 2:
            // MM:SS format
            return components[0] * 60 + components[1]
        case 3:
            // HH:MM:SS format
            return components[0] * 3600 + components[1] * 60 + components[2]
        default:
            return nil
        }
    }
}

// MARK: - Time Picker Control

/// A control for selecting time in HH:MM:SS format
public struct TimePickerControl: View {
    let label: String
    @Binding var totalSeconds: Int?
    
    // Local state for hours, minutes, seconds
    @State private var hours: Int = 0
    @State private var minutes: Int = 0
    @State private var seconds: Int = 0
    
    public init(label: String, totalSeconds: Binding<Int?>) {
        self.label = label
        self._totalSeconds = totalSeconds
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(.caption2)
                .foregroundColor(.secondary)
            
            HStack(spacing: 8) {
                // Hours
                timeComponent(
                    value: $hours,
                    label: "hr",
                    max: 23
                )
                
                Text(":")
                    .font(.title3)
                    .foregroundColor(.secondary)
                
                // Minutes
                timeComponent(
                    value: $minutes,
                    label: "min",
                    max: 59
                )
                
                Text(":")
                    .font(.title3)
                    .foregroundColor(.secondary)
                
                // Seconds
                timeComponent(
                    value: $seconds,
                    label: "sec",
                    max: 59
                )
            }
        }
        .onAppear {
            loadFromTotalSeconds()
        }
        .onChange(of: totalSeconds) { _, _ in
            loadFromTotalSeconds()
        }
        .onChange(of: hours) { _, _ in
            updateTotalSeconds()
        }
        .onChange(of: minutes) { _, _ in
            updateTotalSeconds()
        }
        .onChange(of: seconds) { _, _ in
            updateTotalSeconds()
        }
    }
    
    private func timeComponent(value: Binding<Int>, label: String, max: Int) -> some View {
        VStack(spacing: 2) {
            HStack(spacing: 4) {
                Button {
                    if value.wrappedValue > 0 {
                        value.wrappedValue -= 1
                    }
                } label: {
                    Image(systemName: "minus.circle")
                        .font(.caption)
                }
                
                Text(String(format: "%02d", value.wrappedValue))
                    .font(.body.monospacedDigit())
                    .frame(width: 30)
                
                Button {
                    if value.wrappedValue < max {
                        value.wrappedValue += 1
                    }
                } label: {
                    Image(systemName: "plus.circle")
                        .font(.caption)
                }
            }
            
            Text(label)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
    }
    
    private func loadFromTotalSeconds() {
        guard let total = totalSeconds else {
            hours = 0
            minutes = 0
            seconds = 0
            return
        }
        
        let components = TimeFormatter.secondsToComponents(total)
        hours = components.hours
        minutes = components.minutes
        seconds = components.seconds
    }
    
    private func updateTotalSeconds() {
        let total = TimeFormatter.componentsToSeconds(hours: hours, minutes: minutes, seconds: seconds)
        if total == 0 {
            totalSeconds = nil
        } else {
            totalSeconds = total
        }
    }
}

// MARK: - Time Picker Control for Double (Session Logging)

/// A control for selecting time in HH:MM:SS format (for Double? values used in session logging)
public struct TimePickerControlDouble: View {
    let label: String
    @Binding var totalSeconds: Double?
    
    // Local state for hours, minutes, seconds
    @State private var hours: Int = 0
    @State private var minutes: Int = 0
    @State private var seconds: Int = 0
    
    public init(label: String, totalSeconds: Binding<Double?>) {
        self.label = label
        self._totalSeconds = totalSeconds
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(.caption2)
                .foregroundColor(.secondary)
            
            HStack(spacing: 8) {
                // Hours
                timeComponent(
                    value: $hours,
                    label: "hr",
                    max: 23
                )
                
                Text(":")
                    .font(.title3)
                    .foregroundColor(.secondary)
                
                // Minutes
                timeComponent(
                    value: $minutes,
                    label: "min",
                    max: 59
                )
                
                Text(":")
                    .font(.title3)
                    .foregroundColor(.secondary)
                
                // Seconds
                timeComponent(
                    value: $seconds,
                    label: "sec",
                    max: 59
                )
            }
        }
        .onAppear {
            loadFromTotalSeconds()
        }
        .onChange(of: totalSeconds) { _, _ in
            loadFromTotalSeconds()
        }
        .onChange(of: hours) { _, _ in
            updateTotalSeconds()
        }
        .onChange(of: minutes) { _, _ in
            updateTotalSeconds()
        }
        .onChange(of: seconds) { _, _ in
            updateTotalSeconds()
        }
    }
    
    private func timeComponent(value: Binding<Int>, label: String, max: Int) -> some View {
        VStack(spacing: 2) {
            HStack(spacing: 4) {
                Button {
                    if value.wrappedValue > 0 {
                        value.wrappedValue -= 1
                    }
                } label: {
                    Image(systemName: "minus.circle")
                        .font(.caption)
                }
                
                Text(String(format: "%02d", value.wrappedValue))
                    .font(.body.monospacedDigit())
                    .frame(width: 30)
                
                Button {
                    if value.wrappedValue < max {
                        value.wrappedValue += 1
                    }
                } label: {
                    Image(systemName: "plus.circle")
                        .font(.caption)
                }
            }
            
            Text(label)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
    }
    
    private func loadFromTotalSeconds() {
        guard let total = totalSeconds else {
            hours = 0
            minutes = 0
            seconds = 0
            return
        }
        
        let totalInt = Int(total)
        let components = TimeFormatter.secondsToComponents(totalInt)
        hours = components.hours
        minutes = components.minutes
        seconds = components.seconds
    }
    
    private func updateTotalSeconds() {
        let total = TimeFormatter.componentsToSeconds(hours: hours, minutes: minutes, seconds: seconds)
        if total == 0 {
            totalSeconds = nil
        } else {
            totalSeconds = Double(total)
        }
    }
}




