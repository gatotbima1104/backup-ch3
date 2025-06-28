//
//  InputImageView.swift
//  MyQuickCook
//
//  Created by Wito Irawan on 18/06/25.
//
import SwiftUI
import Photos
import AVFoundation

class InputImageViewModel: ObservableObject {
    
//    @Published var selectedImage: UIImage?
    @Published var isImagePickerShowing = false
    @Published var showPermissionAlert = false
    @Published var sourceType: UIImagePickerController.SourceType = .photoLibrary
    
    // Detector service
    private let detector = ObjectDetectionService()
    @Published var detectedIngredients: [String] = []
    @Published var selectedImage: UIImage? {
        didSet {
            if let image = selectedImage {
                detectIngredients(from: image)
            }
        }
    }

    // Detect ingredients
    private func detectIngredients(from image: UIImage) {
        detector.detectObjects(in: image) { [weak self] results in
            self?.detectedIngredients = results
            print("🧠 Detected ingredients: \(results)")
        }
    }

    // MARK: Properties
    let permissionAlertTitle = "Permission Required"
    var permissionAlertMessage: String {
        switch sourceType {
        case .camera:
            return "To use the camera, you must grant permission in Settings."
        case .photoLibrary, .savedPhotosAlbum:
            return "To select a photo, you must grant permission in Settings."
        @unknown default:
            return "To use this feature, you must grant permission in Settings."
        }
    }

    func requestPhotoLibraryAccess() {
        self.sourceType = .photoLibrary
        checkPhotoLibraryPermission()
    }
    
    func requestCameraAccess() {
        self.sourceType = .camera
        checkCameraPermission()
    }

    /// Checks for and requests photo library permission.
    private func checkPhotoLibraryPermission() {
        let status = PHPhotoLibrary.authorizationStatus(for: .readWrite)
        switch status {
        case .authorized, .limited:
            isImagePickerShowing = true
        case .notDetermined:
            // Request permission. The response is handled on the main thread.
            PHPhotoLibrary.requestAuthorization(for: .readWrite) { newStatus in
                DispatchQueue.main.async {
                    if newStatus == .authorized {
                        self.isImagePickerShowing = true
                    } else {
                        self.showPermissionAlert = true
                    }
                }
            }
        case .denied, .restricted:
            showPermissionAlert = true
        @unknown default:
            showPermissionAlert = true
        }
    }
    
    /// Checks for and requests camera permission.
    private func checkCameraPermission() {
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        switch status {
        case .authorized:
            isImagePickerShowing = true
        case .notDetermined:
            // Request permission. The response is handled on the main thread.
            AVCaptureDevice.requestAccess(for: .video) { granted in
                DispatchQueue.main.async {
                    if granted {
                        self.isImagePickerShowing = true
                    } else {
                        self.showPermissionAlert = true
                    }
                }
            }
        case .denied, .restricted:
            showPermissionAlert = true
        @unknown default:
            showPermissionAlert = true
        }
    }
}
