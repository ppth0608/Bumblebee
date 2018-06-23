//
//  CameraViewController.swift
//  Bumblebee
//
//  Created by Naver on 2018. 6. 23..
//  Copyright © 2018년 benpark. All rights reserved.
//

import UIKit

class CameraViewController: UIViewController {
    
    @IBOutlet weak var capturePreviewView: UIView!
    
    let cameraController = CameraController()
    
    override var prefersStatusBarHidden: Bool {
        return true
    }

    override func viewDidLoad() {
        super.viewDidLoad()
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
}
