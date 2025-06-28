//
//  CameraViewController.swift
//  MyQuickCook
//
//  Created by Muhamad Gatot Supiadin on 24/06/25.
//

import UIKit
import AVFoundation

protocol CameraViewControllerDelegate: AnyObject {
    func didCapturePhoto(_ image: UIImage)
    func didTapGallery()
}

class CameraViewController: UIViewController, AVCapturePhotoCaptureDelegate {

    var captureSession: AVCaptureSession?
    let photoOutput = AVCapturePhotoOutput()
    var previewLayer: AVCaptureVideoPreviewLayer!
    weak var delegate: CameraViewControllerDelegate?

    private var hasSetupUI = false

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        setupCamera()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        previewLayer.frame = view.bounds

        if !hasSetupUI {
            setupUI()
            hasSetupUI = true
        }
    }

    func setupCamera() {
        captureSession = AVCaptureSession()
        captureSession?.sessionPreset = .photo

        guard let backCamera = AVCaptureDevice.default(for: .video),
              let input = try? AVCaptureDeviceInput(device: backCamera),
              captureSession?.canAddInput(input) == true else {
            return
        }

        captureSession?.addInput(input)

        if captureSession?.canAddOutput(photoOutput) == true {
            captureSession?.addOutput(photoOutput)
        }

        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession!)
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer)

        captureSession?.startRunning()
    }

    func setupUI() {
        let safeBottom = view.safeAreaInsets.bottom

        // Capture button
        let captureButton = UIButton(frame: CGRect(
            x: (view.frame.width - 70) / 2,
            y: view.frame.height - 70 - safeBottom - 16,
            width: 70,
            height: 70
        ))
        captureButton.backgroundColor = .white
        captureButton.layer.cornerRadius = 35
        captureButton.layer.borderColor = UIColor.gray.cgColor
        captureButton.layer.borderWidth = 2
        captureButton.addTarget(self, action: #selector(capturePhoto), for: .touchUpInside)
        view.addSubview(captureButton)

        // Gallery button
        let galleryButton = UIButton(frame: CGRect(
            x: 30,
            y: view.frame.height - 55 - safeBottom - 16,
            width: 40,
            height: 40
        ))
        galleryButton.setImage(UIImage(systemName: "photo.on.rectangle"), for: .normal)
        galleryButton.tintColor = .white
        galleryButton.addTarget(self, action: #selector(openGallery), for: .touchUpInside)
        view.addSubview(galleryButton)
    }

    @objc func capturePhoto() {
        let settings = AVCapturePhotoSettings()
        photoOutput.capturePhoto(with: settings, delegate: self)
    }

    @objc func openGallery() {
        delegate?.didTapGallery()
        dismiss(animated: true)
    }

    func photoOutput(_ output: AVCapturePhotoOutput,
                     didFinishProcessingPhoto photo: AVCapturePhoto,
                     error: Error?) {
        if let data = photo.fileDataRepresentation(),
           let image = UIImage(data: data) {
            delegate?.didCapturePhoto(image)
        }
        dismiss(animated: true)
    }
}
