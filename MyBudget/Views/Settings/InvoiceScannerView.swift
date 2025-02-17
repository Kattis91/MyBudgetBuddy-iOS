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
    
    var body: some View {
        NavigationView {
            if DataScannerViewController.isSupported && DataScannerViewController.isAvailable {
                DataScannerView(scannedAmount: $scannedAmount,
                              scannedDueDate: $scannedDueDate)
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
            } else {
                Text("Scanning not supported on this device")
            }
        }
    }
}

struct DataScannerView: UIViewControllerRepresentable {
    @Binding var scannedAmount: String
    @Binding var scannedDueDate: String
    
    func makeUIViewController(context: Context) -> DataScannerViewController {
        let scanner = DataScannerViewController(
            recognizedDataTypes: [.text()],
            qualityLevel: .accurate,  // Using .accurate for better precision
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
        Coordinator(scannedAmount: $scannedAmount, scannedDueDate: $scannedDueDate)
    }
    
    class Coordinator: NSObject, DataScannerViewControllerDelegate {
        var scannedAmount: Binding<String>
        var scannedDueDate: Binding<String>
        private var processedTexts = Set<String>()
        
        init(scannedAmount: Binding<String>, scannedDueDate: Binding<String>) {
            self.scannedAmount = scannedAmount
            self.scannedDueDate = scannedDueDate
        }
        
        func dataScanner(_ dataScanner: DataScannerViewController, didTapOn item: RecognizedItem) {
            switch item {
            case .text(let text):
                let cleanText = text.transcript.trimmingCharacters(in: .whitespacesAndNewlines)
                print("Tapped text: \(cleanText)")
                
                // Split text if it contains multiple lines
                let textComponents = cleanText.components(separatedBy: .whitespacesAndNewlines)
                
                for component in textComponents {
                    processScannedText(component)
                }
            default:
                break
            }
        }
        
        private func processScannedText(_ text: String) {
            let cleanText = text.trimmingCharacters(in: .whitespacesAndNewlines)
            
            // Check for date pattern
            if cleanText.matches(of: #/\d{4}-\d{2}-\d{2}/#).count > 0 {
                scannedDueDate.wrappedValue = cleanText
                print("Found date: \(cleanText)")
                return
            }
            
            // Check for amount pattern (handles both 50,00 and 440,25 formats)
            if cleanText.matches(of: #/^\d+[,\.]\d{2}$/#).count > 0 {
                let numericText = cleanText.replacingOccurrences(of: "[^0-9,.]", with: "", options: .regularExpression)
                scannedAmount.wrappedValue = numericText
                print("Found amount: \(numericText)")
                return
            }
        }
    }
}

#Preview {
    InvoiceScannerView(scannedAmount: .constant(""), scannedDueDate: .constant(""))
}
