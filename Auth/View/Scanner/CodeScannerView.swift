//
//  CodeScannerView.swift
//  Authenticator
//
//  Created by Kel Reid on 06/29/23
//

import SwiftUI
import AVFoundation

/// A SwiftUI view that wraps AVFoundation's camera functionality to scan QR codes
/// This view handles the camera setup, QR code detection, and provides feedback through haptics
struct CodeScannerView: UIViewControllerRepresentable {
    /// Custom error types that can occur during QR code scanning
    enum ScanError: Error {
        case badInput, badOutput
        case invalidToken
        case emptyContent
        
        /// Localized error messages for each error type
        var localizedDescription: String {
            switch self {
            case .badInput:
                return "Failed to scan QR code. Bad input"
            case .badOutput:
                return "Failed to scan QR code. Bad output"
            case .invalidToken:
                return "Invalid QR code. Not a valid TOTP token"
            case .emptyContent:
                return "Invalid QR code. Empty content"
            }
        }
    }
    
    /// Coordinator class that handles the AVFoundation delegate methods and scanning logic
    class ScannerCoordinator: NSObject, AVCaptureMetadataOutputObjectsDelegate {
        var parent: CodeScannerView
        var codeFound = false
        var session: AVCaptureSession?

        init(parent: CodeScannerView) {
            self.parent = parent
        }
                
        /// Haptic feedback generator for providing tactile feedback during scanning
        private var feedbackGenerator: UINotificationFeedbackGenerator? = UINotificationFeedbackGenerator()
        
        /// Delegate method called when a QR code is detected
        /// - Parameters:
        ///   - output: The metadata output object
        ///   - metadataObjects: Array of detected metadata objects
        ///   - connection: The capture connection
        func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
            // Reset state after processing
            defer {
                codeFound = true
                feedbackGenerator = nil
            }
                
            feedbackGenerator?.prepare()
            guard !codeFound else { return }
            
            // Extract the QR code content
            guard let metadataObject: AVMetadataObject = metadataObjects.first else { return }
            guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject else { return }
            guard let stringValue: String = readableObject.stringValue else { return }
            
            // Process the scanned URI
            let uri: String = stringValue.trimmed()
            guard !uri.isEmpty else {
                parent.completion(.failure(.emptyContent))
                resetScanning()
                return
            }
            
            // Validate the token
            guard let _ = Token(uri: uri) else {
                parent.completion(.failure(.invalidToken))
                resetScanning()
                return
            }
            
            // Provide success feedback and complete
            feedbackGenerator?.notificationOccurred(.success)
            parent.completion(.success(uri))
        }

        /// Called when scanning fails
        /// - Parameter reason: The reason for the failure
        func didFail(reason: ScanError) {
            parent.completion(.failure(reason))
            resetScanning()
        }
        
        /// Resets the scanning state to allow for new scans
        private func resetScanning() {
            codeFound = false
            session?.startRunning()
        }
    }
    
    /// Types of codes that can be scanned (e.g., QR codes)
    let codeTypes: [AVMetadataObject.ObjectType]
    
    /// Completion handler called with the scanning result
    let completion: (Result<String, ScanError>) -> Void
    
    /// Creates and configures the camera view controller
    /// - Parameter context: The context containing the coordinator
    /// - Returns: A configured view controller with camera preview
    func makeUIViewController(context: Context) -> UIViewController {
        let viewController = UIViewController()
        let session = AVCaptureSession()
        context.coordinator.session = session
        
        // Configure camera input
        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else { return viewController }
        
        let videoInput: AVCaptureDeviceInput
        
        do {
            videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
        } catch {
            return viewController
        }
        
        // Add video input to session
        if session.canAddInput(videoInput) {
            session.addInput(videoInput)
        } else {
            return viewController
        }
        
        // Configure metadata output for QR code detection
        let metadataOutput = AVCaptureMetadataOutput()
        
        if session.canAddOutput(metadataOutput) {
            session.addOutput(metadataOutput)
            
            metadataOutput.setMetadataObjectsDelegate(context.coordinator, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = codeTypes
        } else {
            return viewController
        }
        
        // Configure preview layer
        let previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.frame = viewController.view.layer.bounds
        previewLayer.videoGravity = .resizeAspectFill
        viewController.view.layer.addSublayer(previewLayer)
        
        // Start the capture session
        session.startRunning()
        
        return viewController
    }
    
    /// Updates the view controller when SwiftUI updates the view
    /// - Parameters:
    ///   - uiViewController: The view controller to update
    ///   - context: The context containing the coordinator
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
    
    /// Creates a new coordinator instance
    /// - Returns: A new ScannerCoordinator instance
    func makeCoordinator() -> ScannerCoordinator {
        return ScannerCoordinator(parent: self)
    }
}

/// A SwiftUI view that presents the scanner with navigation and error handling
struct Scanner: View {
    @Binding var isPresented: Bool
    let codeTypes: [AVMetadataObject.ObjectType]
    let completion: (Result<String, CodeScannerView.ScanError>) -> Void
    
    @State private var showErrorAlert = false
    @State private var errorMessage = ""
    @Environment(\.managedObjectContext) private var viewContext
    
    var body: some View {
        NavigationView {
            CodeScannerView(codeTypes: codeTypes) { result in
                switch result {
                case .success(let uri):
                    if let newToken = Token(uri: uri) {
                        addItem(newToken)
                        completion(.success(uri))
                        isPresented = false
                    } else {
                        errorMessage = "Invalid QR code"
                        showErrorAlert = true
                    }
                case .failure(let error):
                    errorMessage = error.localizedDescription
                    showErrorAlert = true
                }
            }
            .navigationTitle("Scan QR Code")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        isPresented = false
                    }
                }
            }
            .alert(isPresented: $showErrorAlert) {
                Alert(title: Text("Error"), message: Text(errorMessage), dismissButton: .default(Text("OK")))
            }
        }
    }
    
    /// Adds a new token to the Core Data context
    /// - Parameter token: The token to add
    private func addItem(_ token: Token) {
        let newTokenData = TokenData(context: viewContext)
        newTokenData.id = token.id
        newTokenData.uri = token.uri
        newTokenData.displayIssuer = token.displayIssuer
        newTokenData.displayAccountName = token.displayAccountName
        
        do {
            try viewContext.save()
        } catch {
            errorMessage = error.localizedDescription
            showErrorAlert = true
        }
    }
}
