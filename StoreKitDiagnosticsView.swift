//
//  StoreKitDiagnosticsView.swift
//  Savage By Design
//
//  Temporary diagnostics panel for debugging StoreKit In-App Purchase availability
//  This is for internal verification only during App Review and sandbox testing.
//

import SwiftUI
import StoreKit

/// Diagnostics data model for StoreKit state
struct StoreKitDiagnosticsData {
    let requestedProductIDs: [String]
    let returnedProductCount: Int
    let returnedProducts: [ProductInfo]
    let error: StoreKitDiagnosticsError?
    let timestamp: Date
    
    struct ProductInfo: Identifiable {
        let id = UUID()
        let productID: String
        let displayName: String
        let displayPrice: String
    }
    
    struct StoreKitDiagnosticsError {
        let domain: String
        let code: Int
        let localizedDescription: String
    }
}

/// Temporary diagnostics view for StoreKit debugging
/// 
/// This view is hidden by default and only accessible via debug gesture.
/// It displays read-only information about StoreKit state without interfering
/// with normal app behavior.
struct StoreKitDiagnosticsView: View {
    @EnvironmentObject private var subscriptionManager: SubscriptionManager
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.sbdTheme) private var theme
    
    @State private var diagnosticsData: StoreKitDiagnosticsData?
    @State private var isLoading = false
    
    var body: some View {
        VStack(spacing: 16) {
            // Header
            HStack {
                Image(systemName: "ladybug.fill")
                    .foregroundColor(.orange)
                Text("StoreKit Diagnostics")
                    .font(.system(size: 16, weight: .bold))
                Spacer()
            }
            .padding(.bottom, 4)
            
            if isLoading {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
                Text("Fetching StoreKit data...")
                    .font(.system(size: 14))
                    .foregroundColor(theme.mutedText)
            } else if let data = diagnosticsData {
                ScrollView {
                    VStack(alignment: .leading, spacing: 12) {
                        
                        // Timestamp
                        DiagnosticSection(title: "Last Updated") {
                            Text(formatTimestamp(data.timestamp))
                                .font(.system(size: 12, weight: .regular))
                                .foregroundColor(theme.mutedText)
                        }
                        
                        // Requested Product IDs
                        DiagnosticSection(title: "Requested Product IDs") {
                            VStack(alignment: .leading, spacing: 4) {
                                ForEach(data.requestedProductIDs, id: \.self) { productID in
                                    Text("• \(productID)")
                                        .font(.system(size: 12, weight: .regular, design: .monospaced))
                                        .foregroundColor(.primary)
                                }
                            }
                        }
                        
                        // Returned Product Count
                        DiagnosticSection(title: "Returned Product Count") {
                            Text("\(data.returnedProductCount)")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(data.returnedProductCount > 0 ? .green : .orange)
                        }
                        
                        // Returned Product Details
                        if !data.returnedProducts.isEmpty {
                            DiagnosticSection(title: "Returned Product Details") {
                                VStack(alignment: .leading, spacing: 8) {
                                    ForEach(data.returnedProducts) { product in
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text("Product ID: \(product.productID)")
                                                .font(.system(size: 12, weight: .semibold, design: .monospaced))
                                            Text("Name: \(product.displayName)")
                                                .font(.system(size: 12, weight: .regular))
                                            Text("Price: \(product.displayPrice)")
                                                .font(.system(size: 12, weight: .regular))
                                        }
                                        .padding(8)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .background(
                                            RoundedRectangle(cornerRadius: 6)
                                                .fill(Color.green.opacity(0.1))
                                        )
                                    }
                                }
                            }
                        }
                        
                        // Raw StoreKit Errors
                        if let error = data.error {
                            DiagnosticSection(title: "StoreKit Error") {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Domain: \(error.domain)")
                                        .font(.system(size: 12, weight: .regular, design: .monospaced))
                                    Text("Code: \(error.code)")
                                        .font(.system(size: 12, weight: .regular, design: .monospaced))
                                    Text("Description: \(error.localizedDescription)")
                                        .font(.system(size: 12, weight: .regular))
                                }
                                .padding(8)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(
                                    RoundedRectangle(cornerRadius: 6)
                                        .fill(Color.red.opacity(0.1))
                                )
                            }
                        }
                    }
                }
            } else {
                Text("Tap 'Refresh' to fetch diagnostics data")
                    .font(.system(size: 14))
                    .foregroundColor(theme.mutedText)
            }
            
            // Refresh Button
            Button {
                Task {
                    await fetchDiagnostics()
                }
            } label: {
                HStack {
                    if isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    } else {
                        Image(systemName: "arrow.clockwise")
                        Text("Refresh Diagnostics")
                    }
                }
                .font(.system(size: 14, weight: .semibold))
                .frame(maxWidth: .infinity)
                .frame(height: 44)
                .foregroundColor(.white)
                .background(theme.accent)
                .cornerRadius(8)
            }
            .disabled(isLoading)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(colorScheme == .dark ? Color.white.opacity(0.05) : Color.black.opacity(0.03))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.orange.opacity(0.5), lineWidth: 2)
        )
        .task {
            // Auto-fetch on appear
            await fetchDiagnostics()
        }
    }
    
    // MARK: - Diagnostics Fetch
    
    /// Fetch diagnostics data using the same StoreKit logic as production
    private func fetchDiagnostics() async {
        isLoading = true
        
        let requestedIDs = [SubscriptionConstants.monthlyProductID]
        var products: [StoreKitDiagnosticsData.ProductInfo] = []
        var diagnosticsError: StoreKitDiagnosticsData.StoreKitDiagnosticsError?
        
        do {
            let fetchedProducts = try await Product.products(for: requestedIDs)
            
            // Convert to diagnostics format
            products = fetchedProducts.map { product in
                StoreKitDiagnosticsData.ProductInfo(
                    productID: product.id,
                    displayName: product.displayName,
                    displayPrice: product.displayPrice
                )
            }
            
            if products.isEmpty {
                // No error thrown, but no products returned - synthetic diagnostic error
                diagnosticsError = StoreKitDiagnosticsData.StoreKitDiagnosticsError(
                    domain: "SBDDiagnostics",
                    code: 1001,
                    localizedDescription: "No products returned from StoreKit (empty array)"
                )
            }
            
        } catch {
            // Capture error details
            let nsError = error as NSError
            diagnosticsError = StoreKitDiagnosticsData.StoreKitDiagnosticsError(
                domain: nsError.domain,
                code: nsError.code,
                localizedDescription: error.localizedDescription
            )
        }
        
        // Create diagnostics data
        diagnosticsData = StoreKitDiagnosticsData(
            requestedProductIDs: requestedIDs,
            returnedProductCount: products.count,
            returnedProducts: products,
            error: diagnosticsError,
            timestamp: Date()
        )
        
        isLoading = false
    }
    
    // MARK: - Helpers
    
    private func formatTimestamp(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .medium
        return formatter.string(from: date)
    }
}

// MARK: - Diagnostic Section Component

struct DiagnosticSection<Content: View>: View {
    let title: String
    @ViewBuilder let content: () -> Content
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.system(size: 13, weight: .bold))
                .foregroundColor(.secondary)
            
            content()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// MARK: - Preview

struct StoreKitDiagnosticsView_Previews: PreviewProvider {
    static var previews: some View {
        StoreKitDiagnosticsView()
            .environmentObject(SubscriptionManager())
            .padding()
    }
}
