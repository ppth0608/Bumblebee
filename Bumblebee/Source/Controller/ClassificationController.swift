//
//  ClassificationController.swift
//  Bumblebee
//
//  Created by Naver on 2018. 6. 23..
//  Copyright © 2018년 benpark. All rights reserved.
//

import UIKit
import CoreML
import Vision

protocol ClassificationDelegate: class {
    func classfy(_ controller: ClassificationController, didDetect items: [ClassificationResult])
}

typealias ClassificationResult = (identifier: String, identifierWithPercent: String)

class ClassificationController {
    
    weak var delegate: ClassificationDelegate?
    
    private var requests = [VNRequest]()
    
    func setup(mlmodel: VNCoreMLModel) {
        let request = VNCoreMLRequest(model: mlmodel, completionHandler: handleClassification)
        requests.append(request)
    }
    
    func classfify(image: UIImage?) {
        do {
            if let image = image, let ciImage = CIImage(image: image) {
                try requests.forEach {
                    let handler = VNImageRequestHandler(ciImage: ciImage, options: [:])
                    try handler.perform([$0])
                }                
            }
        } catch {
            print(error)
        }
    }
    
    @objc private func handleClassification(request: VNRequest, error: Error?) {
        let result = extractClassificationResults(from: request, count: 3)
        delegate?.classfy(self, didDetect: result)
    }
    
    private func extractClassificationResults(from request: VNRequest, count: Int) -> [ClassificationResult] {
        guard let observations = request.results as? [VNClassificationObservation] else {
            return []
        }
        return observations
            .prefix(upTo: count)
            .map { ($0.identifier, "\($0.identifier) (\($0.confidence.roundTo(places: 3) * 100.0)%)") }
    }
}
