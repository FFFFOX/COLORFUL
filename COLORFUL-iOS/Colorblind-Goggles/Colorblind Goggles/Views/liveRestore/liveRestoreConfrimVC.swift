//
//  liveEnhanceVC.swift
//  Colorful
//
//  Created by fox on 2021/10/4.
//  Copyright © 2021 fox. All rights reserved.
//

import UIKit
import AVFoundation
import SnapKit

class liveRestoreConfrimVC: UIViewController {
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        view.backgroundColor = .white
        print("************")
        
        
    }
    
//    var testImage:UIImageView!
//    var session: AVCaptureSession!
//    var device: AVCaptureDevice!
//    var output: AVCaptureVideoDataOutput!
//    override func viewDidLoad() {
//
//        view.backgroundColor = .white
//        super.viewDidLoad()
//
//        self.title = "Real Time"
//        self.view.backgroundColor = .white
//        testImage = UIImageView()
//        testImage.image = UIImage(named: "DSC_0775")
//        testImage.clipsToBounds = true
//        testImage.contentMode = .scaleAspectFill
//        self.view.addSubview(testImage);
//        testImage.snp.makeConstraints { (make) in
//            make.center.equalToSuperview()
//            make.width.equalToSuperview()
//            make.height.equalToSuperview()
//        }
//        //手势返回
//        let swipe = UISwipeGestureRecognizer(target: self, action: #selector(nextView))
//        swipe.direction = .right
//        testImage.addGestureRecognizer(swipe)
//
//        let nextViewButton = UIButton.init(type: .custom)
//
//        view.addSubview(nextViewButton)
////        self.view.addSubview(nextViewButton)
//        nextViewButton.snp.makeConstraints { (make) in
//            make.centerX.equalToSuperview()
//            make.bottom.equalToSuperview().offset(-100)
//            make.width.equalToSuperview().multipliedBy(0.9)
//            make.height.equalTo(50)
//        }
//        nextViewButton.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.8470588235)
//        nextViewButton.setTitle("返回菜单", for: UIControl.State())
//        nextViewButton.addTarget(self, action: #selector(self.nextView), for: .touchUpInside)
//        nextViewButton.layer.cornerRadius = 10
//        //MARK: - 🌟 搬运2 摄像头capture session
//        self.session = AVCaptureSession()
//        self.session.sessionPreset = AVCaptureSession.Preset.vga640x480 // not work in iOS simulator
////        self.session.sessionPreset = AVCaptureSession.Preset.
//        guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: AVMediaType.video, position: .back) else {
//            print("no device")
//            return
//        }
//        self.device = device
//        do {
//            let input = try AVCaptureDeviceInput(device: self.device)
//            self.session.addInput(input)
//        } catch {
//            print("no device input")
//            return
//        }
//        self.output = AVCaptureVideoDataOutput()
//        self.output.videoSettings = [ kCVPixelBufferPixelFormatTypeKey as String: Int(kCVPixelFormatType_32BGRA) ]
//        let queue: DispatchQueue = DispatchQueue(label: "videocapturequeue", attributes: [])
//        self.output.setSampleBufferDelegate(self, queue: queue)
////            self.output.setSampleBufferDelegate(self.transitioningDelegate, queue: queue)
//        self.output.alwaysDiscardsLateVideoFrames = true
//        if self.session.canAddOutput(self.output) {
//            self.session.addOutput(self.output)
//        } else {
//            print("could not add a session output")
//            return
//        }
//        do {
//            try self.device.lockForConfiguration()
//            self.device.activeVideoMinFrameDuration = CMTimeMake(value: 1, timescale: 20) // 20 fps
//            self.device.unlockForConfiguration()
//        } catch {
//            print("could not configure a device")
//            return
//        }
//
//        self.session.startRunning()
//        //MARK: - 🌟 搬运2结束 摄像头capture session
//
//
//    }
//    @objc func nextView() {
////        let secondVC = menuVC()
////        self.navigationController?.pushViewController(secondVC, animated: true)
////
////        print("next view")
//        dismiss(animated: true, completion: nil)
//    }
//
//    //MARK: - 🌟搬运3
//    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
//        // Convert a captured image buffer to UIImage.
//        guard let buffer: CVPixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
//            print("could not get a pixel buffer")
//            return
//        }
//        CVPixelBufferLockBaseAddress(buffer, CVPixelBufferLockFlags.readOnly)
//        let image = CIImage(cvPixelBuffer: buffer).oriented(CGImagePropertyOrientation.right)
//        let capturedImage = UIImage(ciImage: image)
//
//
//        // Show the result.
//        DispatchQueue.main.async(execute: {
//            self.testImage.image = capturedImage
//        })
//    }
//    //MARK: - 🌟搬运3结束
}
