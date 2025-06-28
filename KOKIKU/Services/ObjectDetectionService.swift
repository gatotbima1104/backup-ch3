//
//  ObjectDetectionService.swift
//  MyQuickCook
//
//  Created by Muhamad Gatot Supiadin on 22/06/25.
//

import Foundation
import Vision
import CoreML
import UIKit

class ObjectDetectionService {
    
    // define model
    private var model: VNCoreMLModel?
    
    // Init model
    init() {
        do {
            let mlModel = try IngredientsDetector(configuration: MLModelConfiguration()).model
            model = try VNCoreMLModel(for: mlModel)
        } catch {
            print("Failed to load model: \(error)")
        }
    }
    
    // detect object
    func detectObjects(in image: UIImage, completion: @escaping ([String]) -> Void) {
        
        guard let model = model else {
            completion([])
            return
        }
        
        guard let cgImage = image.cgImage else {
            completion([])
            return
        }
        
        // Make request to model
        let request = VNCoreMLRequest(model: model) { request, error in
            var detectedObjects: [String] = []
            if let results = request.results as? [VNRecognizedObjectObservation] {
                for result in results {
                    if let topLabel = result.labels.first {
                        detectedObjects.append(topLabel.identifier)
                    }
                }
            }
            
            DispatchQueue.main.async {
                completion(detectedObjects)
            }
        }
        
        // Make handler to model
        let handler = VNImageRequestHandler(cgImage: cgImage, orientation: .up)
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                
                try handler.perform([request])
                
            } catch {
                print("Detected failed: \(error)")
                DispatchQueue.main.async {
                    completion([])
                }
            }
        }
    }
}
