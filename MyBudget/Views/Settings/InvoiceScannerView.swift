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
            
            // Enhanced date pattern checking
            let datePattern = #/(\d{4}[-/.]\d{2}[-/.]\d{2}|\d{2}[-/.]\d{2}[-/.]\d{4})/#
            if cleanText.matches(of: datePattern).count > 0 {
                if let formattedDate = formatDate(cleanText) {
                    scannedDueDate.wrappedValue = formattedDate
                    print("Found date: \(formattedDate)")
                    return
                }
            }
            
            // Existing amount pattern check remains the same
            if cleanText.matches(of: #/^\d+[,\.]\d{2}$/#).count > 0 {
                let numericText = cleanText.replacingOccurrences(of: "[^0-9,.]", with: "", options: .regularExpression)
                scannedAmount.wrappedValue = numericText
                print("Found amount: \(numericText)")
                return
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
