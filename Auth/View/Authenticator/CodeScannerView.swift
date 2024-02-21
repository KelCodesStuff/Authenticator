//
//  CodeScannerView.swift
//  Authenticator
//
//  Created by Kel Reid on 06/29/23
//

import SwiftUI
import AVFoundation

struct CodeScannerView: UIViewControllerRepresentable {
    enum ScanError: Error {
        case badInput, badOutput
    }
    
    class ScannerCoordinator: NSObject, AVCaptureMetadataOutputObjectsDelegate {
        var parent: CodeScannerView
        var codeFound = false

        init(parent: CodeScannerView) {
            self.parent = parent
        }
                
        private var feedbackGenerator: UINotificationFeedbackGenerator? = UINotificationFeedbackGenerator()
        func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
            defer {
                codeFound = true
                feedbackGenerator = nil
            }
                
            feedbackGenerator?.prepare()
            guard !codeFound else { return }
            guard let metadataObject: AVMetadataObject = metadataObjects.first else { return }
            guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject else { return }
            guard let stringValue: String = readableObject.stringValue else { return }
            feedbackGenerator?.notificationOccurred(.success)
            found(code: stringValue)
        }

        func found(code: String) {
            parent.completion(.success(code))
        }

        func didFail(reason: ScanError) {
            parent.completion(.failure(reason))
        }
    }
        
    class ScannerViewController: UIViewController {
        private let captureSession: AVCaptureSession = AVCaptureSession()
        private var previewLayer: AVCaptureVideoPreviewLayer = AVCaptureVideoPreviewLayer()
        var delegate: ScannerCoordinator?
            
        override func viewDidLoad() {
            super.viewDidLoad()
                    
            guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else { return }
            guard let videoInput: AVCaptureDeviceInput = try? AVCaptureDeviceInput(device: videoCaptureDevice) else { return }
            guard captureSession.canAddInput(videoInput) else {
                    delegate?.didFail(reason: .badInput)
                    return
            }
            captureSession.addInput(videoInput)
            
            let metadataOutput = AVCaptureMetadataOutput()
            guard captureSession.canAddOutput(metadataOutput) else {
                    delegate?.didFail(reason: .badOutput)
                    return
            }
            captureSession.addOutput(metadataOutput)
            metadataOutput.setMetadataObjectsDelegate(delegate, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = delegate?.parent.codeTypes
        }
        
        private func addQRCodeOverlay() {
            let overlayView = UIView()
            overlayView.frame = view.layer.bounds
            overlayView.backgroundColor = UIColor.clear

            // Create a transparent cutout for the QR code area
            let maskLayer = CAShapeLayer()
            let path = UIBezierPath(rect: overlayView.bounds)
            let qrCodeRectSize: CGFloat = min(view.frame.width, view.frame.height) * 0.7
            let qrCodeRect = CGRect(x: (view.frame.width - qrCodeRectSize) / 2,
                                    y: (view.frame.height - qrCodeRectSize) / 2,
                                    width: qrCodeRectSize,
                                    height: qrCodeRectSize)
            path.append(UIBezierPath(rect: qrCodeRect))
            maskLayer.path = path.cgPath
            maskLayer.fillRule = .evenOdd
            overlayView.layer.mask = maskLayer

            // Add a border around the QR code area
            let borderLayer = CAShapeLayer()
            borderLayer.path = UIBezierPath(rect: qrCodeRect).cgPath
            borderLayer.strokeColor = UIColor.green.cgColor
            borderLayer.lineWidth = 2.0
            overlayView.layer.addSublayer(borderLayer)

            previewLayer.addSublayer(overlayView.layer)
        }
                
        override func viewWillLayoutSubviews() {
                previewLayer.frame = view.layer.bounds
        }

        override func viewDidAppear(_ animated: Bool) {
            super.viewDidAppear(animated)
            
            previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
            previewLayer.frame = view.layer.bounds
            previewLayer.videoGravity = .resizeAspectFill
            view.layer.addSublayer(previewLayer)
                
            if !captureSession.isRunning {
                    captureSession.startRunning()
            }
            
            // Add grid overlay
            addQRCodeOverlay()
        }
            
        override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)

            // Perform AVCaptureSession setup on a background thread
            DispatchQueue.global(qos: .background).async { [self] in
                if !self.captureSession.isRunning {
                    captureSession.startRunning()
                }
            }
        }
            
        override func viewWillDisappear(_ animated: Bool) {
            super.viewWillDisappear(animated)
            if captureSession.isRunning {
                        captureSession.stopRunning()
            }
        }
    }
    
    let codeTypes: [AVMetadataObject.ObjectType]
    let completion: (Result<String, ScanError>) -> Void
    
    init(codeTypes: [AVMetadataObject.ObjectType], completion: @escaping (Result<String, ScanError>) -> Void) {
            self.codeTypes = codeTypes
            self.completion = completion
    }
        
    func makeCoordinator() -> ScannerCoordinator {
            return ScannerCoordinator(parent: self)
    }
    func makeUIViewController(context: Context) -> ScannerViewController {
            let viewController = ScannerViewController()
            viewController.delegate = context.coordinator
            return viewController
    }
    func updateUIViewController(_ uiViewController: ScannerViewController, context: Context) {}
}

struct Scanner: View {
    @Binding var isPresented: Bool
    let codeTypes: [AVMetadataObject.ObjectType]
    let completion: (Result<String, CodeScannerView.ScanError>) -> Void
    
    var body: some View {
        NavigationView {
            CodeScannerView(codeTypes: codeTypes, completion: completion)
                .navigationTitle("Scanning")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel") {
                            isPresented = false
                        }
                    }
                }
        }
    }
}
