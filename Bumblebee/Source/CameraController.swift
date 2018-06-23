//
//  CameraController.swift
//  Bumblebee
//
//  Created by Naver on 2018. 6. 23..
//  Copyright © 2018년 benpark. All rights reserved.
//

import UIKit
import AVFoundation

class CameraController: NSObject {
    
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
    
    // MARK: Capture
    typealias PhotoOuputCompletion = (UIImage?, Error?) -> Void
    
    var photoCaptureCompletionBlock: PhotoOuputCompletion?
    
    func captureImage(completion: @escaping PhotoOuputCompletion) {
        guard let captureSession = captureSession, captureSession.isRunning else {
            completion(nil, CameraControllerError.captureSessionIsMissing)
            return
        }
        let settings = AVCapturePhotoSettings()
        let previewFormat = [kCVPixelBufferPixelFormatTypeKey as String: Int(kCVPixelFormatType_32BGRA),
                             kCVPixelBufferWidthKey as String: 160,
                             kCVPixelBufferHeightKey as String: 160]
        settings.previewPhotoFormat = previewFormat
        photoCaptureCompletionBlock = completion
        photoOutput?.capturePhoto(with: settings, delegate: self)
    }
}

extension CameraController: AVCapturePhotoCaptureDelegate {
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard error == nil else {
            photoCaptureCompletionBlock?(nil, error)
            return
        }
        guard let imageData = photo.fileDataRepresentation() else {
            photoCaptureCompletionBlock?(nil, error)
            return
        }
        photoCaptureCompletionBlock?(UIImage(data: imageData), nil)
    }
}
