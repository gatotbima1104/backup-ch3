//
//  InputImageView.swift
//  MyQuickCook
//
//  Created by Wito Irawan on 17/06/25.
//

import SwiftUI
import Photos
import AVFoundation

struct InputImageView: View {

    @StateObject private var viewModel = InputImageViewModel()
    @Binding var dismissToRoot: Bool // ✅ Pass from FridgeView
        @State private var navigateToInputText = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                
                // Display the selected image or a placeholder from the ViewModel.
                if let image = viewModel.selectedImage {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .shadow(radius: 5)
                        .frame(maxWidth: .infinity, maxHeight: 800)

                    let cleanDetected = Array(Set(viewModel.detectedIngredients.filter { $0 != "bukan bahan masakan" }))
                } else {
                    Image(systemName: "photo.on.rectangle.angled")
                        .font(.system(size: 100))
                        .foregroundColor(.gray.opacity(0.5))
                        .frame(maxWidth: .infinity, maxHeight: 800)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(style: StrokeStyle(lineWidth: 2, dash: [10]))
                                .foregroundColor(.gray)
                        )
                }

                let cleanDetected = Array(Set(viewModel.detectedIngredients.filter { $0 != "bukan bahan masakan" }))
                
                if !cleanDetected.isEmpty {
                    HStack(spacing: 20) {
                        if UIImagePickerController.isSourceTypeAvailable(.camera) {
                            Button {
                                viewModel.requestCameraAccess()
                            } label: {
                                Image(systemName: "camera.fill")
                                    .frame(maxWidth: 40, maxHeight: 40)
                                    .font(.system(size: 24))
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 8)
                                    .background(Color(hex: "006E6D"))
                                    .cornerRadius(8)
                                    .padding(.vertical, 8)
                            }
                        }
                        
                        Text("\(cleanDetected.count) Bahan terdeteksi")
                            .font(.headline)
                        
                        NavigationLink(
                            destination: InputTextView(initialIngredients: cleanDetected, dismissToRoot: $dismissToRoot),
                            isActive: $navigateToInputText
                        ) {
                            Image(systemName: "checkmark")
                                .frame(maxWidth: 40, maxHeight: 40)
                                .font(.system(size: 24))
                                .foregroundColor(.white)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(Color(hex: "006E6D"))
                                .cornerRadius(8)
                                .padding(.vertical, 8)
                        }
                    }
                } else {
                    
                    // Here
                    HStack(spacing: 4) {
                        Button {
                            viewModel.requestPhotoLibraryAccess()
                        } label: {
                            Image(systemName: "photo.fill")
                                .frame(maxWidth: 40, maxHeight: 40)
                                .font(.system(size: 24))
                                .foregroundColor(.white)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(Color(hex: "006E6D"))
                                .cornerRadius(8)
                                .padding(.vertical, 8)
                        }
                        
                        if let image = viewModel.selectedImage {
                            Text("Tidak ada Bahan terdeteksi")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .padding(.horizontal, 8)
                        }

                        if UIImagePickerController.isSourceTypeAvailable(.camera) {
                            Button {
                                viewModel.requestCameraAccess()
                            } label: {
                                Image(systemName: "camera.fill")
                                    .frame(maxWidth: 40, maxHeight: 40)
                                    .font(.system(size: 24))
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 8)
                                    .background(Color(hex: "006E6D"))
                                    .cornerRadius(8)
                                    .padding(.vertical, 8)
                            }
                        }
                    }
                    .padding(.horizontal, -24)
                }
                

                Spacer()
            }
            .padding()
            .onAppear {
                viewModel.requestCameraAccess() // Automatically open the camera
            }
            .fullScreenCover(isPresented: $viewModel.isImagePickerShowing) {
                if viewModel.sourceType == .camera {
                    CustomCameraView(
                        selectedImage: $viewModel.selectedImage,
                        showImagePicker: $viewModel.isImagePickerShowing,
                        sourceType: $viewModel.sourceType
                    )
                } else {
                    ImagePicker(
                        selectedImage: $viewModel.selectedImage,
                        sourceType: viewModel.sourceType
                    )
                }
            }
            .alert(viewModel.permissionAlertTitle, isPresented: $viewModel.showPermissionAlert) {
                Button("Cancel", role: .cancel) {}
                Button("Settings") {
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(url)
                    }
                }
            } message: {
                Text(viewModel.permissionAlertMessage)
            }
        }
    }
}



struct ImagePicker: UIViewControllerRepresentable {
    
    // Binding to the image that will be selected in the SwiftUI view.
    @Binding var selectedImage: UIImage?
    var sourceType: UIImagePickerController.SourceType
    
    @Environment(\.presentationMode) var presentationMode
    
    // This function creates the UIImagePickerController.
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = sourceType
        picker.delegate = context.coordinator // The coordinator will handle events.
        return picker
    }
    
    // This function is required but we don't need to update the controller.
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    // This function creates the Coordinator, which acts as the delegate for the picker.
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    // The Coordinator class handles the UIImagePickerControllerDelegate methods.
    final class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        var parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        // This function is called when the user finishes picking an image.
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            // We try to get the original image from the info dictionary.
            if let image = info[.originalImage] as? UIImage {
                parent.selectedImage = image
            }
            
            // Dismiss the picker view.
            parent.presentationMode.wrappedValue.dismiss()
        }
        
        // This function is called when the user cancels.
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            // Dismiss the picker view.
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
}

//#Preview {
//    InputImageView()
//}
