//
//  CameraViewController.swift
//  CameraTest
//
//  Created by BH on 2023/02/19.
//

import AVFoundation
import UIKit

class CameraViewController: UIViewController {

    @IBOutlet weak var cameraView: PreviewView!
    
    private let captureSession = AVCaptureSession()
    
    private let sessionQueue = DispatchQueue(label: "session queue")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        checkCameraAuth()
    }

    func setupCamera() {
        captureSession.beginConfiguration()
        
        let videoDevice = AVCaptureDevice.default(.builtInWideAngleCamera,
                                                  for: .video,
                                                  position: .back)
        
        guard let videoDeviceInput = try? AVCaptureDeviceInput(device: videoDevice!),
              captureSession.canAddInput(videoDeviceInput) else {
            return
        }
        captureSession.addInput(videoDeviceInput)
        
        let photoOutput = AVCaptureVideoDataOutput()
        guard captureSession.canAddOutput(photoOutput) else {
            return
        }

        captureSession.sessionPreset = .medium // 화질
        captureSession.addOutput(photoOutput)
        captureSession.commitConfiguration()
        
        cameraView.videoPreviewLayer.session = captureSession
//        cameraView.videoPreviewLayer.connection?.videoOrientation = .portrait
        DispatchQueue.global(qos: .background).async {
            self.captureSession.startRunning()
        }
        
    }
    
}

// MARK: Check Camera Auth
extension CameraViewController {
    func checkCameraAuth() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            setupCamera()
        case .notDetermined:
            sessionQueue.suspend()
            AVCaptureDevice.requestAccess(for: .video, completionHandler: { granted in
                if granted {
                    DispatchQueue.main.async {
                        self.setupCamera()
                    }
                }
                self.sessionQueue.resume()
            })

        default:
            break
        }
    }
}
