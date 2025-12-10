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

    public init(
        label: String,
        unit: String,
        value: Binding<Double?>,
        step: Double,
        formatter: NumberFormatter,
        min: Double
    ) {
        self.label = label
        self.unit = unit
        _value = value
        self.step = step
        self.formatter = formatter
        self.min = min
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
                        value = max(min, currentValue - step)
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
                        value = currentValue + step
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
// In SetControls.swift (Outside all other structs/extensions)

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
    // In SetControls.swift, add this new extension:

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

}
