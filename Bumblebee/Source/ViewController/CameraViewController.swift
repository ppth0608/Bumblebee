//
//  CameraViewController.swift
//  Bumblebee
//
//  Created by Naver on 2018. 6. 23..
//  Copyright © 2018년 benpark. All rights reserved.
//

import UIKit
import Vision
import CoreML

class CameraViewController: UIViewController {
    
    @IBOutlet weak var capturePreviewView: UIView!
    
    let cameraController = CameraController()
    let classificationController = ClassificationController()
    
    @IBOutlet weak var resultContainerView: UIView!
    var resultViewController: ResultViewController?
    
    override var prefersStatusBarHidden: Bool {
        return true
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        resultContainerView?.isHidden = true
        do {
            let mlmodel = try VNCoreMLModel(for: CarRecognition().model)
            classificationController.setup(mlmodel: mlmodel)
            classificationController.delegate = self
        } catch {
            print(error)
        }
        configureCameraController()
    }
    
    func configureCameraController() {
        cameraController.prepare { error in
            if let error = error {
                print(error)
            }
            try? self.cameraController.displayPreview(on: self.capturePreviewView)
        }
    }
    
    @IBAction func captureButtonTapped(_ sender: UIButton) {
        cameraController.captureImage { image, error in
            guard error == nil else {
                print(error?.localizedDescription ?? "")
                return
            }
            self.classificationController.classfify(image: image)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier ?? "" {
        case "Result":
            let resultViewController = segue.destination as? ResultViewController
            self.resultViewController = resultViewController
        default: return
        }
    }
}

extension CameraViewController: ClassificationDelegate {
    
    func classfy(_ controller: ClassificationController, didDetect items: [ClassificationResult]) {
        if items.isEmpty {
            print("items is empty so notification gogo")
        } else {
            resultViewController?.items = items
            resultContainerView?.isHidden = false
        }
    }
}
