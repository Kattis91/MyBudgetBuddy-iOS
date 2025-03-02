//
//  InvoiceScannerView.swift
//  MyBudget
//
//  Created by Katya Durneva Svedmark on 2025-02-14.
//

import SwiftUI
import VisionKit

struct InvoiceScannerView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var scannedAmount: String
    @Binding var scannedDueDate: String
    @State private var showAlert = false
    @State private var recognizedItems: [RecognizedItem] = []
    @State private var feedbackMessage = ""
    @State private var showFeedback = false
    
    var body: some View {
        NavigationView {
            if DataScannerViewController.isSupported && DataScannerViewController.isAvailable {
                DataScannerView(
                    scannedAmount: $scannedAmount,
                    scannedDueDate: $scannedDueDate,
                    showFeedback: $showFeedback,
                    feedbackMessage: $feedbackMessage
                )
                .navigationTitle("Scan Invoice")
                .navigationBarItems(
                    leading: Button("Cancel") { dismiss() },
                    trailing: Button("Done") { dismiss() }
                )
                .overlay(
                    VStack {
                        if scannedAmount.isEmpty {
                            Text("Tap the amount")
                                .foregroundColor(.white)
                                .padding()
                                .background(Color.black.opacity(0.7))
                                .cornerRadius(8)
                        }
                        if scannedDueDate.isEmpty {
                            Text("Tap the due date")
                                .foregroundColor(.white)
                                .padding()
                                .background(Color.black.opacity(0.7))
                                .cornerRadius(8)
                        }
                    }
                    .padding()
                    , alignment: .top
                )
                .overlay(
                    Group {
                        if showFeedback {
                            Text(feedbackMessage)
                                .foregroundColor(.white)
                                .padding()
                                .background(
                                    LinearGradient(
                                        gradient: Gradient(colors: [
                                            .addIncomeStart,   // Start color
                                            .addIncomeMiddle,  // Middle color
                                            .addIncomeEnd     // End color
                                        ]),
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .cornerRadius(8)
                                .transition(.move(edge: .top).combined(with: .opacity))
                        }
                    }
                    .animation(.easeInOut, value: showFeedback)
                    .padding()
                    , alignment: .bottom
                )
            } else {
                Text("Scanning not supported on this device")
            }
        }
    }
}

struct DataScannerView: UIViewControllerRepresentable {
    @Binding var scannedAmount: String
    @Binding var scannedDueDate: String
    @Binding var showFeedback: Bool
    @Binding var feedbackMessage: String
    
    func makeUIViewController(context: Context) -> DataScannerViewController {
        let scanner = DataScannerViewController(
            recognizedDataTypes: [.text()],
            qualityLevel: .accurate,
            recognizesMultipleItems: true,
            isGuidanceEnabled: true,
            isHighlightingEnabled: true
        )
        
        scanner.delegate = context.coordinator
        scanner.overlayContainerView.backgroundColor = .clear
        scanner.overlayContainerView.tintColor = .yellow
        
        try? scanner.startScanning()
        return scanner
    }
    
    func updateUIViewController(_ uiViewController: DataScannerViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(
            scannedAmount: $scannedAmount,
            scannedDueDate: $scannedDueDate,
            showFeedback: $showFeedback,
            feedbackMessage: $feedbackMessage
        )
    }
    
    class Coordinator: NSObject, DataScannerViewControllerDelegate {
        var scannedAmount: Binding<String>
        var scannedDueDate: Binding<String>
        var showFeedback: Binding<Bool>
        var feedbackMessage: Binding<String>
        private var processedTexts = Set<String>()
        private var feedbackTimer: Timer?
        
        init(scannedAmount: Binding<String>,
             scannedDueDate: Binding<String>,
             showFeedback: Binding<Bool>,
             feedbackMessage: Binding<String>) {
            self.scannedAmount = scannedAmount
            self.scannedDueDate = scannedDueDate
            self.showFeedback = showFeedback
            self.feedbackMessage = feedbackMessage
        }
        
        func dataScanner(_ dataScanner: DataScannerViewController, didTapOn item: RecognizedItem) {
            switch item {
            case .text(let text):
                let cleanText = text.transcript.trimmingCharacters(in: .whitespacesAndNewlines)
                print("Tapped text: \(cleanText)")
                
                // First try to process the entire text as an amount or date
                if let message = processFullText(cleanText) {
                    showFeedback(message: message)
                    return // Exit early if we successfully processed the full text
                }
                
                // If full text processing didn't work, try component-based processing as fallback
                var messages: [String] = []
                let textComponents = cleanText.components(separatedBy: .whitespacesAndNewlines)
                
                for component in textComponents {
                    if let message = processScannedText(component) {
                        messages.append(message)
                    }
                }
                
                // Show combined feedback if we found any matches
                if !messages.isEmpty {
                    showFeedback(message: messages.joined(separator: "\n"))
                }
            default:
                break
            }
        }
        
        private func processFullText(_ text: String) -> String? {
            // Try to process the entire text without splitting
            
            // Check for amounts with spaces like "10 000,00"
            let amountPattern = #"(\d{1,3}(?: \d{3})+)[,.](\d{2})"#
            if let range = text.range(of: amountPattern, options: .regularExpression) {
                let match = String(text[range])
                print("Amount match found: \(match)")
                
                // Remove spaces for storage but keep the format consistent
                let numericText = match.replacingOccurrences(of: " ", with: "")
                scannedAmount.wrappedValue = numericText
                return "Amount captured: \(match)"
            }
            
            // Check for dates
            let datePattern = #/(\d{4}[-/.]\d{2}[-/.]\d{2}|\d{2}[-/.]\d{2}[-/.]\d{4})/#
            if text.matches(of: datePattern).count > 0 {
                if let formattedDate = formatDate(text) {
                    scannedDueDate.wrappedValue = formattedDate
                    return "Due date captured: \(formattedDate)"
                }
            }
            
            return nil
        }
        
        private func processScannedText(_ text: String) -> String? {
            let cleanText = text.trimmingCharacters(in: .whitespacesAndNewlines)
            
            var message: String? = nil
            
            // Enhanced date pattern checking
            let datePattern = #/(\d{4}[-/.]\d{2}[-/.]\d{2}|\d{2}[-/.]\d{2}[-/.]\d{4})/#
            if cleanText.matches(of: datePattern).count > 0 {
                if let formattedDate = formatDate(cleanText) {
                    scannedDueDate.wrappedValue = formattedDate
                    message = "Due date captured: \(formattedDate)"
                }
            }
            
            // Amount pattern check
            if cleanText.matches(of: #/^\d+[,\.]\d{2}$/#).count > 0 {
                let numericText = cleanText.replacingOccurrences(of: "[^0-9,.]", with: "", options: .regularExpression)
                scannedAmount.wrappedValue = numericText
                message = "Amount captured: \(numericText)"
            }
            
            return message
        }
        
        private func showFeedback(message: String) {
            // Cancel any existing timer
            feedbackTimer?.invalidate()
            
            // Update feedback message and show it
            DispatchQueue.main.async {
                self.feedbackMessage.wrappedValue = message
                self.showFeedback.wrappedValue = true
                
                // Hide feedback after 3 seconds
                self.feedbackTimer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: false) { [weak self] _ in
                    DispatchQueue.main.async {
                        self?.showFeedback.wrappedValue = false
                    }
                }
            }
        }

        private func formatDate(_ dateString: String) -> String? {
            let dateFormatter = DateFormatter()
            dateFormatter.locale = Locale(identifier: "en_US")
            
            // Try different date formats
            let formats = [
                "yyyy-MM-dd",
                "dd-MM-yyyy",
                "yyyy/MM/dd",
                "dd/MM/yyyy",
                "yyyy.MM.dd",
                "dd.MM.yyyy",
            ]
            
            for format in formats {
                dateFormatter.dateFormat = format
                if let date = dateFormatter.date(from: dateString) {
                    // Output in the format expected by the parent view
                    dateFormatter.dateFormat = "yyyy-MM-dd"
                    return dateFormatter.string(from: date)
                }
            }
            
            return nil
        }
    }
}

#Preview {
    InvoiceScannerView(scannedAmount: .constant(""), scannedDueDate: .constant(""))
}
