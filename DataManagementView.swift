//
//  DataManagementView.swift
//  Savage By Design
//
//  UI for data export, import, and retention management
//

import SwiftUI
import UniformTypeIdentifiers

struct DataManagementView: View {
    @EnvironmentObject private var blocksRepository: BlocksRepository
    @EnvironmentObject private var sessionsRepository: SessionsRepository
    @EnvironmentObject private var exerciseRepository: ExerciseLibraryRepository
    @Environment(\.sbdTheme) private var theme
    @Environment(\.dismiss) private var dismiss
    
    @State private var dataService: DataManagementService?
    @State private var statistics: DataSizeStatistics?
    
    // Export states
    @State private var showExportOptions = false
    @State private var showShareSheet = false
    @State private var exportedFileURL: URL?
    @State private var exportError: Error?
    @State private var showExportError = false
    
    // Import states
    @State private var showImportPicker = false
    @State private var showImportOptions = false
    @State private var importStrategy: DataManagementService.ImportStrategy = .merge
    @State private var pendingImportURL: URL?
    @State private var importError: Error?
    @State private var showImportError = false
    @State private var showImportSuccess = false
    
    // Cleanup states
    @State private var showCleanupConfirmation = false
    @State private var retentionPolicy = DataManagementService.RetentionPolicy.default
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                headerSection
                
                statisticsSection
                
                exportSection
                
                importSection
                
                cleanupSection
                
                Spacer(minLength: 40)
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
        }
        .navigationTitle("Data Management")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            setupDataService()
            loadStatistics()
        }
        .sheet(isPresented: $showShareSheet) {
            if let url = exportedFileURL {
                ShareSheet(items: [url])
            }
        }
        .sheet(isPresented: $showImportPicker) {
            DocumentPicker(
                allowedContentTypes: [.json],
                onDocumentPicked: handleImportFile
            )
        }
        .alert("Export Error", isPresented: $showExportError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(exportError?.localizedDescription ?? "Unknown error")
        }
        .alert("Import Error", isPresented: $showImportError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(importError?.localizedDescription ?? "Unknown error")
        }
        .alert("Import Successful", isPresented: $showImportSuccess) {
            Button("OK", role: .cancel) {
                loadStatistics()
            }
        } message: {
            Text("Your data has been imported successfully.")
        }
        .alert("Import Strategy", isPresented: $showImportOptions) {
            Button("Merge with Existing", role: .none) {
                importStrategy = .merge
                performImport()
            }
            Button("Replace All Data", role: .destructive) {
                importStrategy = .replace
                performImport()
            }
            Button("Cancel", role: .cancel) {
                pendingImportURL = nil
            }
        } message: {
            Text("How would you like to import the data?\n\n• Merge: Add new items without removing existing data\n• Replace: Remove all existing data and use only imported data")
        }
        .alert("Clean Up Old Data", isPresented: $showCleanupConfirmation) {
            Button("Clean Up", role: .destructive) {
                performCleanup()
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("This will remove sessions older than \(retentionPolicy.keepSessionsDays) days and excess archived blocks. This action cannot be undone.")
        }
    }
    
    // MARK: - Header Section
    
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Data Management")
                .font(.largeTitle)
                .bold()
            
            Text("Export, import, and manage your workout data")
                .font(.body)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    // MARK: - Statistics Section
    
    private var statisticsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            sectionHeader(title: "Storage Statistics", icon: "chart.bar.fill")
            
            if let stats = statistics {
                VStack(spacing: 12) {
                    statRow(label: "Active Blocks", value: "\(stats.blocksCount - stats.archivedBlocksCount)")
                    statRow(label: "Archived Blocks", value: "\(stats.archivedBlocksCount)")
                    statRow(label: "Total Sessions", value: "\(stats.sessionsCount)")
                    statRow(label: "Completed Sessions", value: "\(stats.completedSessionsCount)")
                    statRow(label: "Exercises in Library", value: "\(stats.exercisesCount)")
                    statRow(label: "Estimated Size", value: String(format: "%.2f MB", stats.estimatedTotalSizeMB))
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(.secondarySystemBackground))
                )
            } else {
                ProgressView()
                    .frame(maxWidth: .infinity)
                    .padding()
            }
        }
    }
    
    // MARK: - Export Section
    
    private var exportSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            sectionHeader(title: "Export Data", icon: "square.and.arrow.up.fill")
            
            Text("Back up your workout data to share or save externally.")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            VStack(spacing: 12) {
                Button {
                    exportAsJSON()
                } label: {
                    HStack {
                        Image(systemName: "doc.text.fill")
                        Text("Export as JSON")
                            .font(.body)
                            .fontWeight(.medium)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(12)
                }
                .buttonStyle(.plain)
                
                Button {
                    exportWorkoutHistoryAsCSV()
                } label: {
                    HStack {
                        Image(systemName: "tablecells.fill")
                        Text("Export Workout History (CSV)")
                            .font(.body)
                            .fontWeight(.medium)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(12)
                }
                .buttonStyle(.plain)
                
                Button {
                    exportBlocksSummaryAsCSV()
                } label: {
                    HStack {
                        Image(systemName: "list.bullet.rectangle.fill")
                        Text("Export Blocks Summary (CSV)")
                            .font(.body)
                            .fontWeight(.medium)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(12)
                }
                .buttonStyle(.plain)
            }
        }
    }
    
    // MARK: - Import Section
    
    private var importSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            sectionHeader(title: "Import Data", icon: "square.and.arrow.down.fill")
            
            Text("Restore data from a previous export or transfer from another device.")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Button {
                showImportPicker = true
            } label: {
                HStack {
                    Image(systemName: "doc.badge.plus")
                    Text("Import from JSON")
                        .font(.body)
                        .fontWeight(.medium)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color(.secondarySystemBackground))
                .cornerRadius(12)
            }
            .buttonStyle(.plain)
        }
    }
    
    // MARK: - Cleanup Section
    
    private var cleanupSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            sectionHeader(title: "Data Cleanup", icon: "trash.fill")
            
            Text("Remove old data to improve performance and free up storage.")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            VStack(spacing: 12) {
                HStack {
                    Text("Keep sessions from last")
                        .font(.body)
                    Spacer()
                    Picker("", selection: $retentionPolicy.keepSessionsDays) {
                        Text("90 days").tag(90)
                        Text("180 days").tag(180)
                        Text("1 year").tag(365)
                        Text("2 years").tag(730)
                    }
                    .pickerStyle(.menu)
                }
                .padding()
                .background(Color(.secondarySystemBackground))
                .cornerRadius(12)
                
                HStack {
                    Text("Max archived blocks")
                        .font(.body)
                    Spacer()
                    Picker("", selection: $retentionPolicy.maxArchivedBlocks) {
                        Text("20").tag(20)
                        Text("50").tag(50)
                        Text("100").tag(100)
                        Text("Unlimited").tag(Int.max)
                    }
                    .pickerStyle(.menu)
                }
                .padding()
                .background(Color(.secondarySystemBackground))
                .cornerRadius(12)
                
                Button {
                    showCleanupConfirmation = true
                } label: {
                    HStack {
                        Image(systemName: "trash.circle.fill")
                        Text("Clean Up Old Data")
                            .font(.body)
                            .fontWeight(.medium)
                        Spacer()
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .foregroundColor(.red)
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(12)
                }
                .buttonStyle(.plain)
            }
        }
    }
    
    // MARK: - Helper Views
    
    private func sectionHeader(title: String, icon: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .foregroundColor(.accentColor)
            Text(title)
                .font(.headline)
                .bold()
        }
    }
    
    private func statRow(label: String, value: String) -> some View {
        HStack {
            Text(label)
                .font(.body)
                .foregroundColor(.primary)
            Spacer()
            Text(value)
                .font(.body)
                .bold()
                .foregroundColor(.secondary)
        }
    }
    
    // MARK: - Actions
    
    private func setupDataService() {
        dataService = DataManagementService(
            blocksRepository: blocksRepository,
            sessionsRepository: sessionsRepository,
            exerciseRepository: exerciseRepository
        )
    }
    
    private func loadStatistics() {
        statistics = dataService?.getDataSizeStatistics()
    }
    
    private func exportAsJSON() {
        guard let service = dataService else { return }
        
        do {
            let data = try service.exportAllDataAsJSON()
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd-HHmmss"
            let dateString = dateFormatter.string(from: Date())
            let fileName = "savage-by-design-export-\(dateString).json"
            let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)
            try data.write(to: tempURL)
            exportedFileURL = tempURL
            showShareSheet = true
            
            AppLogger.info("Exported data to \(tempURL.path)", subsystem: .persistence, category: "DataManagement")
        } catch {
            exportError = error
            showExportError = true
            AppLogger.error(error, context: "Failed to export JSON", subsystem: .persistence)
        }
    }
    
    private func exportWorkoutHistoryAsCSV() {
        guard let service = dataService else { return }
        
        let csvString = service.exportWorkoutHistoryAsCSV()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd-HHmmss"
        let dateString = dateFormatter.string(from: Date())
        let fileName = "savage-by-design-workout-history-\(dateString).csv"
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)
        
        do {
            try csvString.write(to: tempURL, atomically: true, encoding: .utf8)
            exportedFileURL = tempURL
            showShareSheet = true
            
            AppLogger.info("Exported workout history to \(tempURL.path)", subsystem: .persistence, category: "DataManagement")
        } catch {
            exportError = error
            showExportError = true
            AppLogger.error(error, context: "Failed to export CSV", subsystem: .persistence)
        }
    }
    
    private func exportBlocksSummaryAsCSV() {
        guard let service = dataService else { return }
        
        let csvString = service.exportBlocksSummaryAsCSV()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd-HHmmss"
        let dateString = dateFormatter.string(from: Date())
        let fileName = "savage-by-design-blocks-summary-\(dateString).csv"
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)
        
        do {
            try csvString.write(to: tempURL, atomically: true, encoding: .utf8)
            exportedFileURL = tempURL
            showShareSheet = true
            
            AppLogger.info("Exported blocks summary to \(tempURL.path)", subsystem: .persistence, category: "DataManagement")
        } catch {
            exportError = error
            showExportError = true
            AppLogger.error(error, context: "Failed to export blocks CSV", subsystem: .persistence)
        }
    }
    
    private func handleImportFile(_ url: URL) {
        pendingImportURL = url
        showImportOptions = true
    }
    
    private func performImport() {
        guard let service = dataService, let url = pendingImportURL else { return }
        
        do {
            // Access security-scoped resource
            guard url.startAccessingSecurityScopedResource() else {
                throw NSError(domain: "DataManagement", code: 1, userInfo: [NSLocalizedDescriptionKey: "Could not access file"])
            }
            defer { url.stopAccessingSecurityScopedResource() }
            
            let data = try Data(contentsOf: url)
            try service.importDataFromJSON(data, strategy: importStrategy)
            
            showImportSuccess = true
            pendingImportURL = nil
            
            AppLogger.info("Imported data from \(url.path)", subsystem: .persistence, category: "DataManagement")
        } catch {
            importError = error
            showImportError = true
            pendingImportURL = nil
            AppLogger.error(error, context: "Failed to import data", subsystem: .persistence)
        }
    }
    
    private func performCleanup() {
        guard let service = dataService else { return }
        
        service.applyRetentionPolicy(retentionPolicy)
        loadStatistics()
        
        AppLogger.info("Applied retention policy", subsystem: .persistence, category: "DataManagement")
    }
}

// MARK: - Share Sheet

struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

// MARK: - Document Picker

struct DocumentPicker: UIViewControllerRepresentable {
    let allowedContentTypes: [UTType]
    let onDocumentPicked: (URL) -> Void
    
    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        let picker = UIDocumentPickerViewController(forOpeningContentTypes: allowedContentTypes)
        picker.delegate = context.coordinator
        picker.allowsMultipleSelection = false
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(onDocumentPicked: onDocumentPicked)
    }
    
    class Coordinator: NSObject, UIDocumentPickerDelegate {
        let onDocumentPicked: (URL) -> Void
        
        init(onDocumentPicked: @escaping (URL) -> Void) {
            self.onDocumentPicked = onDocumentPicked
        }
        
        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            guard let url = urls.first else { return }
            onDocumentPicked(url)
        }
    }
}
