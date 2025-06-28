//
//  CustomCameraView.swift
//  MyQuickCook
//
//  Created by Muhamad Gatot Supiadin on 24/06/25.
//

import SwiftUI

struct CustomCameraView: UIViewControllerRepresentable {
    @Binding var selectedImage: UIImage?
    @Binding var showImagePicker: Bool
    @Binding var sourceType: UIImagePickerController.SourceType
    

    func makeUIViewController(context: Context) -> CameraViewController {
        let controller = CameraViewController()
        controller.delegate = context.coordinator
        return controller
    }

    func updateUIViewController(_ uiViewController: CameraViewController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    

    class Coordinator: NSObject, CameraViewControllerDelegate {
        var parent: CustomCameraView

        init(_ parent: CustomCameraView) {
            self.parent = parent
        }

        func didCapturePhoto(_ image: UIImage) {
            parent.selectedImage = image
            parent.showImagePicker = false
        }

        func didTapGallery() {
            parent.showImagePicker = false
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.parent.sourceType = .photoLibrary
                self.parent.showImagePicker = true
            }
        }

    }
}
