//
//  CameraController.swift
//  Bumblebee
//
//  Created by Naver on 2018. 6. 23..
//  Copyright © 2018년 benpark. All rights reserved.
//

import UIKit
import AVFoundation

class CameraController {
    
    // MARK: Error
    enum CameraControllerError: Error {
        case captureSessionAlreadyRunning
        case captureSessionIsMissing
        case inputsAreInvalid
        case invalidOperation
        case cameraNotAvailiable
        case unknown
    }
    
    // MARK: CaptureSession
    var captureSession: AVCaptureSession?
    
    var camera: AVCaptureDevice?
    var cameraInput: AVCaptureDeviceInput?
    var photoOutput: AVCapturePhotoOutput?
    
    func prepare(completion: @escaping (Error?) -> Void) {
        DispatchQueue(label: "CameraController").async {
            do {
                self.createCaptureSession()
                try self.configureCaptureDevices()
                try self.configureDeviceInputs()
                try self.configurePhotoOutput()
            } catch {
                DispatchQueue.main.async {
                    completion(error)
                }
                return
            }
            DispatchQueue.main.async {
                completion(nil)
            }
        }
    }
    
    func createCaptureSession() {
        captureSession = AVCaptureSession()
    }
    
    func configureCaptureDevices() throws {
        let session = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: .video, position: .unspecified)
        let cameras = session.devices.compactMap { $0 }
        
        if cameras.isEmpty {
            throw CameraControllerError.cameraNotAvailiable
        }
        camera = cameras.first { $0.position == .back }
        try camera?.lockForConfiguration()
        camera?.focusMode = .continuousAutoFocus
        camera?.unlockForConfiguration()
    }
    
    func configureDeviceInputs() throws {
        guard let captureSession = captureSession, let camera = camera else {
            throw CameraControllerError.captureSessionIsMissing
        }
        cameraInput = try AVCaptureDeviceInput(device: camera)
        
        if let cameraInput = cameraInput, captureSession.canAddInput(cameraInput) {
            captureSession.addInput(cameraInput)
        } else {
            throw CameraControllerError.cameraNotAvailiable
        }
    }
    
    func configurePhotoOutput() throws {
        guard let captureSession = captureSession else {
            throw CameraControllerError.captureSessionIsMissing
        }
        photoOutput = AVCapturePhotoOutput()
        photoOutput?.setPreparedPhotoSettingsArray([AVCapturePhotoSettings(format: [AVVideoCodecKey : AVVideoCodecType.jpeg])], completionHandler: nil)
        
        if let photoOutput = photoOutput, captureSession.canAddOutput(photoOutput) {
            captureSession.addOutput(photoOutput)
        }
        captureSession.startRunning()
    }
    
    // MARK: Display View
    var previewLayer: AVCaptureVideoPreviewLayer?
    
    func displayPreview(on view: UIView) throws {
        guard let captureSession = captureSession, captureSession.isRunning else {
            throw CameraControllerError.captureSessionIsMissing
        }
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer?.videoGravity = .resizeAspectFill
        previewLayer?.connection?.videoOrientation = .portrait
        
        if let previewLayer = previewLayer {
            view.layer.insertSublayer(previewLayer, at: 0)
        }
        previewLayer?.frame = view.frame
    }
}
