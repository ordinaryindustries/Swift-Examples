//
//  CameraViewController.swift
//  VisionKitScanning
//
//  Created by Jack on 9/27/24.
//

import SwiftUI
import VisionKit

// Protocol to ensure a scanner model contains everything it needs.
protocol ScannerModelProtocol {
    var barcodeValues: [String] { get set }
}


/// A Scanner model used to store found barcode data.
class ScannerModel: ObservableObject, ScannerModelProtocol {
    @Published var barcodeValues: [String] = []
    
    init(testValues: [String] = []) {
        self.barcodeValues = testValues
    }
}

/// A view that conforms to the UIViewControllerRepresentable protocol. This is a view that bridges the gap between a
/// SwiftUI view and the VisionKit data scanner. SwiftUI doesn't offer a direct way to interface with a data scanner so we need the bridge.
struct ScannerView: UIViewControllerRepresentable {
    
    // A model to hold information about data the scanner finds.
    @ObservedObject var scannerModel: ScannerModel
    
    // An environment object that can be called to dismiss the scanner view.
    @Environment(\.dismiss) private var dismiss
    
    // Called automatically by SwiftUI when creating the UIViewControllerRepresentable. This creates the UIViewController that ends up getting embedded in the SwiftUI view.
    func makeUIViewController(context: Context) -> DataScannerViewController {
        
        // Create the VisionKit DataScannerViewController.
        let dataScanner = DataScannerViewController(recognizedDataTypes: [.barcode()], isHighlightingEnabled: true)
        
        // Set the scanner's delegate. This delegate will conform to the DataScannerViewControllerDelegate protocol
        // which would force it to have various methods required by the delegate.
        dataScanner.delegate = context.coordinator
        
        // Try to start the data scanner.
        try? dataScanner.startScanning()
        
        // Return the DataScannerViewController
        return dataScanner
    }
    
    // Called automatically by SwiftUI when creating the UIViewControllerRepresentable.
    func updateUIViewController(_ uiViewController: DataScannerViewController, context: Context) { return }
    
    
    // Called automatically by SwiftUI when creating the UIViewControllerRepresentable. The coordinator allows us to interface
    // between the SwiftUI view and the data scanner.
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    // A coordinator that is used as a bridge between the SwiftUI view and the VisionKit layer. This conforms
    // to the DataScannerViewControllerDelegate protocol which requires methods for didAdd, didRemove, and didUpdate.
    class Coordinator: NSObject, DataScannerViewControllerDelegate {
        
        // A parent view that allows the coordinator to talk to it's parent view properties and methods.
        var parent: ScannerView
        
        init(_ parent: ScannerView) {
            print("Coordinator initialized")
            self.parent = parent
        }
        
        // A method that is called automatically by the data scanner when it detects a data object.
        @MainActor
        func dataScanner(_ dataScanner: DataScannerViewController, didAdd addedItems: [RecognizedItem], allItems: [RecognizedItem]) {
            print("didAdd called")
            guard let firstData = addedItems.first else { return }
        
            switch firstData {
            case let .barcode(barcode):
                print("Barcode: \(barcode.payloadStringValue ?? "Unknown barcode data")")
                
                guard let barcodeValue = barcode.payloadStringValue else { return }
                parent.scannerModel.barcodeValues.append(barcodeValue)
            default:
                print("Scanned unrecognized data")
            }
            
            dataScanner.stopScanning()
            parent.dismiss()
        }
        
        // A method that is called automatically by the data scanner when it removes a data object.
        func dataScanner(_ dataScanner: DataScannerViewController, didRemove allItems: [RecognizedItem]) {
            print("didRemove called")
        }
        
        // A method that is called automatically by the data scanner when it updates a data object.
        func dataScanner(_ dataScanner: DataScannerViewController, didUpdate allItems: [RecognizedItem]) {
            print("didUpdate called")
        }
    
        func dataScanner(_ dataScanner: DataScannerViewController, didFailWithError error: Error) {
            print("Scanning failed with error: \(error.localizedDescription)")
        }

        func dataScannerDidStopScanning(_ dataScanner: DataScannerViewController) {
            print("Scanning stopped")
        }
    }
}
