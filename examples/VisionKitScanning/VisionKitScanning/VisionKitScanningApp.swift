//
//  VisionKitScanningApp.swift
//  VisionKitScanning
//
//  Created by Jack on 9/27/24.
//

import SwiftUI

@main
struct VisionKitScanningApp: App {
    var body: some Scene {
        let scannerModel: ScannerModel = ScannerModel()
        
        WindowGroup {
            ContentView(scannerModel: scannerModel)
        }
    }
}
