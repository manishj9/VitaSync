//
//  FoodScannerViewModel.swift
//  VitaSyncApp
//
//  Created by Manish Jawale on 21/03/26.
//

import AVFoundation
import SwiftUI
import SwiftData

@Observable
class FoodScannerViewModel: NSObject {
    
    // Camera
    let session = AVCaptureSession()
    private let output = AVCapturePhotoOutput()
    private let classifier = FoodClassifierService()
    
    // State
    var isScanning = false
    var capturedImage: UIImage?
    var result: FoodClassificationResult?
    var isSaved = false
    var errorMessage: String?
    
    // Continuation for photo capture bridge
    private var photoContinuation: CheckedContinuation<UIImage?, Never>?
    
    // MARK: Setup Camera
    
    func setupCamera() {
        guard AVCaptureDevice.authorizationStatus(for: .video) != .denied else {
            errorMessage = "Camera access denied. Enable it in Settings"
            return
        }
        
        Task(priority: .userInitiated) {
            await AVCaptureDevice.requestAccess(for: .video)
            
            guard let device = AVCaptureDevice.default(
                .builtInWideAngleCamera,
                for: .video,
                position: .back
            ),
            let input = try? AVCaptureDeviceInput(device: device)
            else { return }
            
            session.beginConfiguration()
            if session.canAddInput(input) { session.addInput(input)}
            if session.canAddOutput(output) { session.addOutput(output)}
            session.commitConfiguration()
            
            session.startRunning()
        }
    }
    
    func stopCamera() {
        session.stopRunning()
    }
    
    // MARK: - Capture and Classify
    
    func captureAndClassify() async {
        isScanning = true
        result = nil
        capturedImage = nil
        isSaved = false
        
        // Capture photo
        let image = await capturePhoto()
        capturedImage = image
        
        guard let image else {
            isScanning = false
            errorMessage = "Could not capture photo"
            return
        }
        
        // Classify with Vision
        let classification = await classifier.classify(image: image)
        result = classification
        isScanning = false
    }
    
    // MARK: Save to SWIFTDATA
    
    func saveEntry(context: ModelContext) {
        guard let result else { return }
        
        let entry = FoodEntry(
            date: Date(),
            name: result.name,
            estimatedCalories: result.calories
        )
        entry.note = result.confidencePercent
        context.insert(entry)
        try? context.save()
        isSaved = true
    }
    
    // MARK: - Reset for next scan
    
    func reset() {
        capturedImage = nil
        result = nil
        isSaved = false
        errorMessage = nil
    }
    
    // MARK: - Photo capture bridge
    
    private func capturePhoto() async -> UIImage? {
        await withCheckedContinuation { continuation in
            photoContinuation = continuation
            let settings = AVCapturePhotoSettings()
            output.capturePhoto(with: settings, delegate: self)
        }
    }
}

extension FoodScannerViewModel: AVCapturePhotoCaptureDelegate {
    func photoOutput(
        _ output: AVCapturePhotoOutput,
        didFinishProcessingPhoto photo: AVCapturePhoto,
        error: Error?
    ) {
        guard let data = photo.fileDataRepresentation(),
              let image = UIImage(data: data)
        else {
            photoContinuation?.resume(returning: nil)
            return
        }
        photoContinuation?.resume(returning: image)
        photoContinuation = nil
    }
}
