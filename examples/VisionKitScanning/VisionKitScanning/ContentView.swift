//
//  ContentView.swift
//  VisionKitScanning
//
//  Created by Jack on 9/27/24.
//

import SwiftUI

struct ContentView: View {
    @State private var isShowingScannerView: Bool = false
    @ObservedObject var scannerModel: ScannerModel
    
    var body: some View {
        VStack {
            Spacer()
            
            ScrollView {
                VStack {
                    ForEach(scannerModel.barcodeValues.reversed(), id: \.self) { value in
                        GeometryReader { geo in
                            let minY = geo.frame(in: .global).minY
                            let screenHeight = UIScreen.main.bounds.height
                            let opacity = minY / screenHeight
                            
                            Text(value)
                                .font(.title)
                                .opacity(opacity)
                                .frame(maxWidth: .infinity)
                                .rotationEffect(Angle(degrees: 180)).scaleEffect(x: -1.0, y: 1.0, anchor: .center)
                        }
                        .frame(height: 50)
                    }
                }
                .frame(maxHeight: .infinity)
                .animation(.easeInOut, value: scannerModel.barcodeValues)
            }
            .padding()
            .rotationEffect(Angle(degrees: 180)).scaleEffect(x: -1.0, y: 1.0, anchor: .center)
            .scrollIndicators(.hidden)
            
            
            Spacer()
            
            HStack {
                Spacer()
                
                Button {
                    isShowingScannerView.toggle()
                } label: {
                    Image(systemName: "barcode.viewfinder")
                        .imageScale(.large)
                        .tint(.buttonFG)
                        .padding()
                        .background(.buttonBG)
                        .clipShape(Circle())
                }
            }
            .padding()
            .sheet(isPresented: $isShowingScannerView) {
                ScannerView(scannerModel: scannerModel)
            }
        }
    }
}

#Preview {
    let testValues = [
        "1234567890123",
        "1234567890123",
        "1234567890123",
        "1234567890123",
        "1234567890123",
        "1234567890123",
        "1234567890123",
        "1234567890123",
        "1234567890123",
        "1234567890123",
        "1234567890123",
        "1234567890123"
    ]
    let testScannerModel = ScannerModel(testValues: testValues)
    return ContentView(scannerModel: testScannerModel)
}
