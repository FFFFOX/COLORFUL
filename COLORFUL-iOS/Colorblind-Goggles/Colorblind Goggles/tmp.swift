//
//  colorRestoreVC.swift
//  Colorful
//
//  Created by fox on 2021/10/4.
//  Copyright © 2021 fox. All rights reserved.
//

import Foundation
import UIKit
import CoreGraphics
import QuartzCore
import AVFoundation
import Alamofire
import SnapKit

typealias CGGammaValue = Float
typealias CGDirectDisplayID = UInt32

@available(iOS 11.0, *)
class colorRestoreVC: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate,UIActionSheetDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    var screenshot: UIImage!
    var imageOverlay: UIImageView!
    var timer: Timer!
    var mainWindow: UIWindow!
    var colorMode: ColorBlindType!
    
    var testImage: UIImageView!
    
    
    override func viewDidAppear(_ animated: Bool) {
        mainWindow = self.view.window

    }
    
    override func viewDidLoad() {
        
//        let longpressGesutre = UILongPressGestureRecognizer(target: self, action: Selector(("handleLongpressGesture:")))
//        //长按时间为1秒
//        longpressGesutre.minimumPressDuration = 1
//        //允许15秒运动
//        longpressGesutre.allowableMovement = 15
//        //所需触摸1次
//        longpressGesutre.numberOfTouchesRequired = 1
//        self.view.addGestureRecognizer(longpressGesutre)
        addLongPressGes()
        
        
        view.backgroundColor = .white
        super.viewDidLoad()
        
        
        
        testImage = UIImageView()
        self.view.addSubview(testImage);
        testImage.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview().offset(-100)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.9)
            make.height.equalToSuperview().multipliedBy(0.7)
        }
//        testImage.image = UIImage(named: "DSC_0775")
        testImage.clipsToBounds = true
        testImage.contentMode = .scaleAspectFit
        testImage.layer.cornerRadius = 10
        
        
        let albumButton = UIButton()
        self.view.addSubview(albumButton)
        albumButton.snp.makeConstraints { (make) in
            make.width.equalTo(testImage).dividedBy(2).offset(-5)
//            make.centerX.equalToSuperview()
            make.left.equalTo(testImage)
            make.top.equalTo(testImage.snp.bottom).offset(10)
            make.height.equalTo(50)
        }

//        albumButton.backgroundColor = #colorLiteral(red: 0.8417847157, green: 0.8507048488, blue: 0.8811554909, alpha: 1)
        albumButton.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.8470588235)
        albumButton.setTitle("相册", for: UIControl.State())
        albumButton.addTarget(self, action: #selector(self.demoClicked), for: .touchUpInside)
        albumButton.layer.cornerRadius = 10
        
        let camButton = UIButton()
        self.view.addSubview(camButton)
        camButton.snp.makeConstraints { (make) in
            make.width.equalTo(testImage).dividedBy(2).offset(-5)
            make.right.equalTo(testImage)
            make.top.equalTo(testImage.snp.bottom).offset(10)
            make.height.equalTo(50)
        }

//        camButton.backgroundColor = #colorLiteral(red: 0.8417847157, green: 0.8507048488, blue: 0.8811554909, alpha: 1)
        camButton.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.8470588235)
        camButton.setTitle("拍照", for: UIControl.State())
        camButton.addTarget(self, action: #selector(self.demoCameera), for: .touchUpInside)
        camButton.layer.cornerRadius = 10
        
        
        let changeButton = UIButton.init(type: .custom)
        self.view.addSubview(changeButton)
        changeButton.snp.makeConstraints { (make) in
            make.width.equalTo(testImage)
            make.centerX.equalToSuperview()
            make.top.equalTo(camButton.snp.bottom).offset(10)
            make.height.equalTo(50)
        }
//        changeButton.frame = CGRect(x: 20, y: nextViewButton.frame.size.height + nextViewButton.frame.origin.y + 20, width: self.view.bounds.size.width - 40, height: 50)
//        changeButton.backgroundColor =  #colorLiteral(red: 0.8417847157, green: 0.8507048488, blue: 0.8811554909, alpha: 1)
        changeButton.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.8470588235)
        changeButton.setTitle("切换", for: UIControl.State())
//        changeButton.addTarget(self, action: #selector(CBController.startColorBlinds), for: .touchUpInside)
        changeButton.addTarget(self, action: #selector(httpConvert), for: .touchUpInside)
        changeButton.layer.cornerRadius = 10
        
        let nextViewButton = UIButton()
        self.view.addSubview(nextViewButton)
        nextViewButton.snp.makeConstraints { (make) in
            make.width.equalTo(testImage)
            make.centerX.equalToSuperview()
            make.top.equalTo(changeButton.snp.bottom).offset(10)
            make.height.equalTo(50)
        }
//        nextViewButton.frame = CGRect(x: 20, y: testImage.frame.size.height + testImage.frame.origin.y + 20, width: self.view.bounds.size.width - 40, height: 50)
//        nextViewButton.backgroundColor = #colorLiteral(red: 0.8417847157, green: 0.8507048488, blue: 0.8811554909, alpha: 1)
        nextViewButton.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.8470588235)
        nextViewButton.setTitle("返回菜单", for: UIControl.State())
        nextViewButton.addTarget(self, action: #selector(self.nextView), for: .touchUpInside)
        nextViewButton.layer.cornerRadius = 10
        
        
    }
    
    @objc func nextView() {
        dismiss(animated: true, completion: nil)
    }
    @objc func httpConvert() {
        
        let urls:String = "http://121.40.64.188:5100/iosTest/"
        //参数
//        let parameters:Dictionary = ["type":"1","name":"customer","password":"123456"]

//        let imgData = getStrFromImage("DSC_0775")
        let imgData = getStrFromImage(testImage.image!)
//        let imgData = testImage.image?.pngData()?.base64EncodedString()
        
        let parameters: [String: [String]] = [
            "imgData": ["\(imgData))"],
            "baz": ["a", "b"],
            "qux": ["x", "y", "z"]
        ]
        //Alamofire 请求实例
        AF.request(URL(string: urls)!, method: .post, parameters: parameters, encoder: JSONParameterEncoder.sortedKeys)
                        .responseString { (responses) in
                            print(responses)
                            let data = responses.data
                            let data_error:Data! = UIImage(named: "DSC_0775")?.pngData()
//                            let
                            let res: UIImage! = UIImage(data: data ?? data_error)
                            self.testImage.image = res
//                            self.testImage.contentMode = .scaleAspectFit
                            
        }
                            }
    //MARK:- 🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟
    @objc func demoCameera(){
        openCamera()
    }
    
    @objc func demoClicked(){
        openAlbum()
    }
    
    //打开相册
    
    func openAlbum(){
        //判断设置是否支持图片库
        
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary){
            //初始化图片控制器
            let picker = UIImagePickerController()
            //设置代理
            picker.delegate = self
            //指定图片控制器类型
            picker.sourceType = UIImagePickerController.SourceType.photoLibrary
            //设置是否允许编辑
            
            picker.allowsEditing = true
            
            
            //弹出控制器，显示界面
            self.present(picker, animated:true, completion: {
                () -> Void in
            })
        }else{
            print("读取相册错误")
        }
        
    }
    
    
    
    func openCamera(){
        if UIImagePickerController.isSourceTypeAvailable(.camera){
            
            //创建图片控制器
            let picker = UIImagePickerController()
            //设置代理
            picker.delegate = self
            //设置来源
            picker.sourceType = UIImagePickerController.SourceType.camera
            //允许编辑
            picker.allowsEditing = true
            
//            picker.mediaTypes
            //打开相机
            self.present(picker, animated:true, completion: { () -> Void in})
            
        }else{
            debugPrint("找不到相机")
            
        }
        
    }
    //MARK:- 🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            self.testImage.image = image


        } else if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            self.testImage.image = image

        }
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    //保存图片
    @objc func savedPhotosAlbum(image: UIImage, didFinishSavingWithError error: NSError?, contextInfo: AnyObject) {
        
        if error != nil {
            print("save failed")
        } else {
            print("save succeed")

        }
    }
    //MARK:- ✨手势长按
    func addLongPressGes() {
        //添加长按手势
        let longPressGes = UILongPressGestureRecognizer(target: self, action: #selector(longPressedGesture(recognizer:)))
        longPressGes.minimumPressDuration = 1
        //一定要遵循代理
        longPressGes.delegate = self
//        longpressGes.minimumPressDuration = 1
        self.view.addGestureRecognizer(longPressGes)


    }
    
    @objc func longPressedGesture(recognizer: UILongPressGestureRecognizer) {
        let alertV = UIAlertController()
        let saveAction = UIAlertAction(title: "保存图片", style: .default) { (alertV) in
            UIImageWriteToSavedPhotosAlbum(self.testImage.image!, self, #selector(self.savedPhotosAlbum), nil)
        }
        //取消保存不作处理
        let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        
        alertV.addAction(saveAction)
        alertV.addAction(cancelAction)
        self.present(alertV, animated: true, completion: nil)
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    



}

//不实现该代理方法,长按无效
//MARK: 手势代理方法
extension colorRestoreVC : UIGestureRecognizerDelegate{
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}

 
extension UIImage {
    // 修复图片旋转
    func fixOrientation() -> UIImage {
        if self.imageOrientation == .up {
            return self
        }
         
        var transform = CGAffineTransform.identity
         
        switch self.imageOrientation {
        case .down, .downMirrored:
            transform = transform.translatedBy(x: self.size.width, y: self.size.height)
            transform = transform.rotated(by: .pi)
            break
             
        case .left, .leftMirrored:
            transform = transform.translatedBy(x: self.size.width, y: 0)
            transform = transform.rotated(by: .pi / 2)
            break
             
        case .right, .rightMirrored:
            transform = transform.translatedBy(x: 0, y: self.size.height)
            transform = transform.rotated(by: -.pi / 2)
            break
             
        default:
            break
        }
         
        switch self.imageOrientation {
        case .upMirrored, .downMirrored:
            transform = transform.translatedBy(x: self.size.width, y: 0)
            transform = transform.scaledBy(x: -1, y: 1)
            break
             
        case .leftMirrored, .rightMirrored:
            transform = transform.translatedBy(x: self.size.height, y: 0);
            transform = transform.scaledBy(x: -1, y: 1)
            break
             
        default:
            break
        }
         
        let ctx = CGContext(data: nil, width: Int(self.size.width), height: Int(self.size.height), bitsPerComponent: self.cgImage!.bitsPerComponent, bytesPerRow: 0, space: self.cgImage!.colorSpace!, bitmapInfo: self.cgImage!.bitmapInfo.rawValue)
        ctx?.concatenate(transform)
         
        switch self.imageOrientation {
        case .left, .leftMirrored, .right, .rightMirrored:
            ctx?.draw(self.cgImage!, in: CGRect(x: CGFloat(0), y: CGFloat(0), width: CGFloat(size.height), height: CGFloat(size.width)))
            break
             
        default:
            ctx?.draw(self.cgImage!, in: CGRect(x: CGFloat(0), y: CGFloat(0), width: CGFloat(size.width), height: CGFloat(size.height)))
            break
        }
         
        let cgimg: CGImage = (ctx?.makeImage())!
        let img = UIImage(cgImage: cgimg)
         
        return img
    }
}
//
//  colorRestoreVC.swift
//  Colorful
//
//  Created by fox on 2021/10/4.
//  Copyright © 2021 fox. All rights reserved.
//

import Foundation
import UIKit
import CoreGraphics
import QuartzCore
import AVFoundation
import Alamofire
import SnapKit

typealias CGGammaValue = Float
typealias CGDirectDisplayID = UInt32

@available(iOS 11.0, *)
class colorRestoreVC: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate,UIActionSheetDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    var screenshot: UIImage!
    var imageOverlay: UIImageView!
    var timer: Timer!
    var mainWindow: UIWindow!
    var colorMode: ColorBlindType!
    
    var testImage: UIImageView!
    
    
    override func viewDidAppear(_ animated: Bool) {
        mainWindow = self.view.window

    }
    
    override func viewDidLoad() {
        
//        let longpressGesutre = UILongPressGestureRecognizer(target: self, action: Selector(("handleLongpressGesture:")))
//        //长按时间为1秒
//        longpressGesutre.minimumPressDuration = 1
//        //允许15秒运动
//        longpressGesutre.allowableMovement = 15
//        //所需触摸1次
//        longpressGesutre.numberOfTouchesRequired = 1
//        self.view.addGestureRecognizer(longpressGesutre)
        addLongPressGes()
        
        
        view.backgroundColor = .white
        super.viewDidLoad()
        
        
        
        testImage = UIImageView()
        self.view.addSubview(testImage);
        testImage.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview().offset(-100)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.9)
            make.height.equalToSuperview().multipliedBy(0.7)
        }
//        testImage.image = UIImage(named: "DSC_0775")
        testImage.clipsToBounds = true
        testImage.contentMode = .scaleAspectFit
        testImage.layer.cornerRadius = 10
        
        
        let albumButton = UIButton()
        self.view.addSubview(albumButton)
        albumButton.snp.makeConstraints { (make) in
            make.width.equalTo(testImage).dividedBy(2).offset(-5)
//            make.centerX.equalToSuperview()
            make.left.equalTo(testImage)
            make.top.equalTo(testImage.snp.bottom).offset(10)
            make.height.equalTo(50)
        }

//        albumButton.backgroundColor = #colorLiteral(red: 0.8417847157, green: 0.8507048488, blue: 0.8811554909, alpha: 1)
        albumButton.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.8470588235)
        albumButton.setTitle("相册", for: UIControl.State())
        albumButton.addTarget(self, action: #selector(self.demoClicked), for: .touchUpInside)
        albumButton.layer.cornerRadius = 10
        
        let camButton = UIButton()
        self.view.addSubview(camButton)
        camButton.snp.makeConstraints { (make) in
            make.width.equalTo(testImage).dividedBy(2).offset(-5)
            make.right.equalTo(testImage)
            make.top.equalTo(testImage.snp.bottom).offset(10)
            make.height.equalTo(50)
        }

//        camButton.backgroundColor = #colorLiteral(red: 0.8417847157, green: 0.8507048488, blue: 0.8811554909, alpha: 1)
        camButton.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.8470588235)
        camButton.setTitle("拍照", for: UIControl.State())
        camButton.addTarget(self, action: #selector(self.demoCameera), for: .touchUpInside)
        camButton.layer.cornerRadius = 10
        
        
        let changeButton = UIButton.init(type: .custom)
        self.view.addSubview(changeButton)
        changeButton.snp.makeConstraints { (make) in
            make.width.equalTo(testImage)
            make.centerX.equalToSuperview()
            make.top.equalTo(camButton.snp.bottom).offset(10)
            make.height.equalTo(50)
        }
//        changeButton.frame = CGRect(x: 20, y: nextViewButton.frame.size.height + nextViewButton.frame.origin.y + 20, width: self.view.bounds.size.width - 40, height: 50)
//        changeButton.backgroundColor =  #colorLiteral(red: 0.8417847157, green: 0.8507048488, blue: 0.8811554909, alpha: 1)
        changeButton.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.8470588235)
        changeButton.setTitle("切换", for: UIControl.State())
//        changeButton.addTarget(self, action: #selector(CBController.startColorBlinds), for: .touchUpInside)
        changeButton.addTarget(self, action: #selector(httpConvert), for: .touchUpInside)
        changeButton.layer.cornerRadius = 10
        
        let nextViewButton = UIButton()
        self.view.addSubview(nextViewButton)
        nextViewButton.snp.makeConstraints { (make) in
            make.width.equalTo(testImage)
            make.centerX.equalToSuperview()
            make.top.equalTo(changeButton.snp.bottom).offset(10)
            make.height.equalTo(50)
        }
//        nextViewButton.frame = CGRect(x: 20, y: testImage.frame.size.height + testImage.frame.origin.y + 20, width: self.view.bounds.size.width - 40, height: 50)
//        nextViewButton.backgroundColor = #colorLiteral(red: 0.8417847157, green: 0.8507048488, blue: 0.8811554909, alpha: 1)
        nextViewButton.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.8470588235)
        nextViewButton.setTitle("返回菜单", for: UIControl.State())
        nextViewButton.addTarget(self, action: #selector(self.nextView), for: .touchUpInside)
        nextViewButton.layer.cornerRadius = 10
        
        
    }
    
    @objc func nextView() {
        dismiss(animated: true, completion: nil)
    }
    @objc func httpConvert() {
        
        let urls:String = "http://121.40.64.188:5100/iosTest/"
        //参数
//        let parameters:Dictionary = ["type":"1","name":"customer","password":"123456"]

//        let imgData = getStrFromImage("DSC_0775")
        let imgData = getStrFromImage(testImage.image!)
//        let imgData = testImage.image?.pngData()?.base64EncodedString()
        
        let parameters: [String: [String]] = [
            "imgData": ["\(imgData))"],
            "baz": ["a", "b"],
            "qux": ["x", "y", "z"]
        ]
        //Alamofire 请求实例
        AF.request(URL(string: urls)!, method: .post, parameters: parameters, encoder: JSONParameterEncoder.sortedKeys)
                        .responseString { (responses) in
                            print(responses)
                            let data = responses.data
                            let data_error:Data! = UIImage(named: "DSC_0775")?.pngData()
//                            let
                            let res: UIImage! = UIImage(data: data ?? data_error)
                            self.testImage.image = res
//                            self.testImage.contentMode = .scaleAspectFit
                            
        }
                            }
    //MARK:- 🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟
    @objc func demoCameera(){
        openCamera()
    }
    
    @objc func demoClicked(){
        openAlbum()
    }
    
    //打开相册
    
    func openAlbum(){
        //判断设置是否支持图片库
        
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary){
            //初始化图片控制器
            let picker = UIImagePickerController()
            //设置代理
            picker.delegate = self
            //指定图片控制器类型
            picker.sourceType = UIImagePickerController.SourceType.photoLibrary
            //设置是否允许编辑
            
            picker.allowsEditing = true
            
            
            //弹出控制器，显示界面
            self.present(picker, animated:true, completion: {
                () -> Void in
            })
        }else{
            print("读取相册错误")
        }
        
    }
    
    
    
    func openCamera(){
        if UIImagePickerController.isSourceTypeAvailable(.camera){
            
            //创建图片控制器
            let picker = UIImagePickerController()
            //设置代理
            picker.delegate = self
            //设置来源
            picker.sourceType = UIImagePickerController.SourceType.camera
            //允许编辑
            picker.allowsEditing = true
            
//            picker.mediaTypes
            //打开相机
            self.present(picker, animated:true, completion: { () -> Void in})
            
        }else{
            debugPrint("找不到相机")
            
        }
        
    }
    //MARK:- 🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            self.testImage.image = image


        } else if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            self.testImage.image = image

        }
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    //保存图片
    @objc func savedPhotosAlbum(image: UIImage, didFinishSavingWithError error: NSError?, contextInfo: AnyObject) {
        
        if error != nil {
            print("save failed")
        } else {
            print("save succeed")

        }
    }
    //MARK:- ✨手势长按
    func addLongPressGes() {
        //添加长按手势
        let longPressGes = UILongPressGestureRecognizer(target: self, action: #selector(longPressedGesture(recognizer:)))
        longPressGes.minimumPressDuration = 1
        //一定要遵循代理
        longPressGes.delegate = self
//        longpressGes.minimumPressDuration = 1
        self.view.addGestureRecognizer(longPressGes)


    }
    
    @objc func longPressedGesture(recognizer: UILongPressGestureRecognizer) {
        let alertV = UIAlertController()
        let saveAction = UIAlertAction(title: "保存图片", style: .default) { (alertV) in
            UIImageWriteToSavedPhotosAlbum(self.testImage.image!, self, #selector(self.savedPhotosAlbum), nil)
        }
        //取消保存不作处理
        let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        
        alertV.addAction(saveAction)
        alertV.addAction(cancelAction)
        self.present(alertV, animated: true, completion: nil)
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    



}

//不实现该代理方法,长按无效
//MARK: 手势代理方法
extension colorRestoreVC : UIGestureRecognizerDelegate{
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}

 
extension UIImage {
    // 修复图片旋转
    func fixOrientation() -> UIImage {
        if self.imageOrientation == .up {
            return self
        }
         
        var transform = CGAffineTransform.identity
         
        switch self.imageOrientation {
        case .down, .downMirrored:
            transform = transform.translatedBy(x: self.size.width, y: self.size.height)
            transform = transform.rotated(by: .pi)
            break
             
        case .left, .leftMirrored:
            transform = transform.translatedBy(x: self.size.width, y: 0)
            transform = transform.rotated(by: .pi / 2)
            break
             
        case .right, .rightMirrored:
            transform = transform.translatedBy(x: 0, y: self.size.height)
            transform = transform.rotated(by: -.pi / 2)
            break
             
        default:
            break
        }
         
        switch self.imageOrientation {
        case .upMirrored, .downMirrored:
            transform = transform.translatedBy(x: self.size.width, y: 0)
            transform = transform.scaledBy(x: -1, y: 1)
            break
             
        case .leftMirrored, .rightMirrored:
            transform = transform.translatedBy(x: self.size.height, y: 0);
            transform = transform.scaledBy(x: -1, y: 1)
            break
             
        default:
            break
        }
         
        let ctx = CGContext(data: nil, width: Int(self.size.width), height: Int(self.size.height), bitsPerComponent: self.cgImage!.bitsPerComponent, bytesPerRow: 0, space: self.cgImage!.colorSpace!, bitmapInfo: self.cgImage!.bitmapInfo.rawValue)
        ctx?.concatenate(transform)
         
        switch self.imageOrientation {
        case .left, .leftMirrored, .right, .rightMirrored:
            ctx?.draw(self.cgImage!, in: CGRect(x: CGFloat(0), y: CGFloat(0), width: CGFloat(size.height), height: CGFloat(size.width)))
            break
             
        default:
            ctx?.draw(self.cgImage!, in: CGRect(x: CGFloat(0), y: CGFloat(0), width: CGFloat(size.width), height: CGFloat(size.height)))
            break
        }
         
        let cgimg: CGImage = (ctx?.makeImage())!
        let img = UIImage(cgImage: cgimg)
         
        return img
    }
}
//
//  colorRestoreVC.swift
//  Colorful
//
//  Created by fox on 2021/10/4.
//  Copyright © 2021 fox. All rights reserved.
//

import Foundation
import UIKit
import CoreGraphics
import QuartzCore
import AVFoundation
import Alamofire
import SnapKit

typealias CGGammaValue = Float
typealias CGDirectDisplayID = UInt32

@available(iOS 11.0, *)
class colorRestoreVC: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate,UIActionSheetDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    var screenshot: UIImage!
    var imageOverlay: UIImageView!
    var timer: Timer!
    var mainWindow: UIWindow!
    var colorMode: ColorBlindType!
    
    var testImage: UIImageView!
    
    
    override func viewDidAppear(_ animated: Bool) {
        mainWindow = self.view.window

    }
    
    override func viewDidLoad() {
        
//        let longpressGesutre = UILongPressGestureRecognizer(target: self, action: Selector(("handleLongpressGesture:")))
//        //长按时间为1秒
//        longpressGesutre.minimumPressDuration = 1
//        //允许15秒运动
//        longpressGesutre.allowableMovement = 15
//        //所需触摸1次
//        longpressGesutre.numberOfTouchesRequired = 1
//        self.view.addGestureRecognizer(longpressGesutre)
        addLongPressGes()
        
        
        view.backgroundColor = .white
        super.viewDidLoad()
        
        
        
        testImage = UIImageView()
        self.view.addSubview(testImage);
        testImage.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview().offset(-100)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.9)
            make.height.equalToSuperview().multipliedBy(0.7)
        }
//        testImage.image = UIImage(named: "DSC_0775")
        testImage.clipsToBounds = true
        testImage.contentMode = .scaleAspectFit
        testImage.layer.cornerRadius = 10
        
        
        let albumButton = UIButton()
        self.view.addSubview(albumButton)
        albumButton.snp.makeConstraints { (make) in
            make.width.equalTo(testImage).dividedBy(2).offset(-5)
//            make.centerX.equalToSuperview()
            make.left.equalTo(testImage)
            make.top.equalTo(testImage.snp.bottom).offset(10)
            make.height.equalTo(50)
        }

//        albumButton.backgroundColor = #colorLiteral(red: 0.8417847157, green: 0.8507048488, blue: 0.8811554909, alpha: 1)
        albumButton.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.8470588235)
        albumButton.setTitle("相册", for: UIControl.State())
        albumButton.addTarget(self, action: #selector(self.demoClicked), for: .touchUpInside)
        albumButton.layer.cornerRadius = 10
        
        let camButton = UIButton()
        self.view.addSubview(camButton)
        camButton.snp.makeConstraints { (make) in
            make.width.equalTo(testImage).dividedBy(2).offset(-5)
            make.right.equalTo(testImage)
            make.top.equalTo(testImage.snp.bottom).offset(10)
            make.height.equalTo(50)
        }

//        camButton.backgroundColor = #colorLiteral(red: 0.8417847157, green: 0.8507048488, blue: 0.8811554909, alpha: 1)
        camButton.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.8470588235)
        camButton.setTitle("拍照", for: UIControl.State())
        camButton.addTarget(self, action: #selector(self.demoCameera), for: .touchUpInside)
        camButton.layer.cornerRadius = 10
        
        
        let changeButton = UIButton.init(type: .custom)
        self.view.addSubview(changeButton)
        changeButton.snp.makeConstraints { (make) in
            make.width.equalTo(testImage)
            make.centerX.equalToSuperview()
            make.top.equalTo(camButton.snp.bottom).offset(10)
            make.height.equalTo(50)
        }
//        changeButton.frame = CGRect(x: 20, y: nextViewButton.frame.size.height + nextViewButton.frame.origin.y + 20, width: self.view.bounds.size.width - 40, height: 50)
//        changeButton.backgroundColor =  #colorLiteral(red: 0.8417847157, green: 0.8507048488, blue: 0.8811554909, alpha: 1)
        changeButton.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.8470588235)
        changeButton.setTitle("切换", for: UIControl.State())
//        changeButton.addTarget(self, action: #selector(CBController.startColorBlinds), for: .touchUpInside)
        changeButton.addTarget(self, action: #selector(httpConvert), for: .touchUpInside)
        changeButton.layer.cornerRadius = 10
        
        let nextViewButton = UIButton()
        self.view.addSubview(nextViewButton)
        nextViewButton.snp.makeConstraints { (make) in
            make.width.equalTo(testImage)
            make.centerX.equalToSuperview()
            make.top.equalTo(changeButton.snp.bottom).offset(10)
            make.height.equalTo(50)
        }
//        nextViewButton.frame = CGRect(x: 20, y: testImage.frame.size.height + testImage.frame.origin.y + 20, width: self.view.bounds.size.width - 40, height: 50)
//        nextViewButton.backgroundColor = #colorLiteral(red: 0.8417847157, green: 0.8507048488, blue: 0.8811554909, alpha: 1)
        nextViewButton.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.8470588235)
        nextViewButton.setTitle("返回菜单", for: UIControl.State())
        nextViewButton.addTarget(self, action: #selector(self.nextView), for: .touchUpInside)
        nextViewButton.layer.cornerRadius = 10
        
        
    }
    
    @objc func nextView() {
        dismiss(animated: true, completion: nil)
    }
    @objc func httpConvert() {
        
        let urls:String = "http://121.40.64.188:5100/iosTest/"
        //参数
//        let parameters:Dictionary = ["type":"1","name":"customer","password":"123456"]

//        let imgData = getStrFromImage("DSC_0775")
        let imgData = getStrFromImage(testImage.image!)
//        let imgData = testImage.image?.pngData()?.base64EncodedString()
        
        let parameters: [String: [String]] = [
            "imgData": ["\(imgData))"],
            "baz": ["a", "b"],
            "qux": ["x", "y", "z"]
        ]
        //Alamofire 请求实例
        AF.request(URL(string: urls)!, method: .post, parameters: parameters, encoder: JSONParameterEncoder.sortedKeys)
                        .responseString { (responses) in
                            print(responses)
                            let data = responses.data
                            let data_error:Data! = UIImage(named: "DSC_0775")?.pngData()
//                            let
                            let res: UIImage! = UIImage(data: data ?? data_error)
                            self.testImage.image = res
//                            self.testImage.contentMode = .scaleAspectFit
                            
        }
                            }
    //MARK:- 🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟
    @objc func demoCameera(){
        openCamera()
    }
    
    @objc func demoClicked(){
        openAlbum()
    }
    
    //打开相册
    
    func openAlbum(){
        //判断设置是否支持图片库
        
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary){
            //初始化图片控制器
            let picker = UIImagePickerController()
            //设置代理
            picker.delegate = self
            //指定图片控制器类型
            picker.sourceType = UIImagePickerController.SourceType.photoLibrary
            //设置是否允许编辑
            
            picker.allowsEditing = true
            
            
            //弹出控制器，显示界面
            self.present(picker, animated:true, completion: {
                () -> Void in
            })
        }else{
            print("读取相册错误")
        }
        
    }
    
    
    
    func openCamera(){
        if UIImagePickerController.isSourceTypeAvailable(.camera){
            
            //创建图片控制器
            let picker = UIImagePickerController()
            //设置代理
            picker.delegate = self
            //设置来源
            picker.sourceType = UIImagePickerController.SourceType.camera
            //允许编辑
            picker.allowsEditing = true
            
//            picker.mediaTypes
            //打开相机
            self.present(picker, animated:true, completion: { () -> Void in})
            
        }else{
            debugPrint("找不到相机")
            
        }
        
    }
    //MARK:- 🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            self.testImage.image = image


        } else if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            self.testImage.image = image

        }
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    //保存图片
    @objc func savedPhotosAlbum(image: UIImage, didFinishSavingWithError error: NSError?, contextInfo: AnyObject) {
        
        if error != nil {
            print("save failed")
        } else {
            print("save succeed")

        }
    }
    //MARK:- ✨手势长按
    func addLongPressGes() {
        //添加长按手势
        let longPressGes = UILongPressGestureRecognizer(target: self, action: #selector(longPressedGesture(recognizer:)))
        longPressGes.minimumPressDuration = 1
        //一定要遵循代理
        longPressGes.delegate = self
//        longpressGes.minimumPressDuration = 1
        self.view.addGestureRecognizer(longPressGes)


    }
    
    @objc func longPressedGesture(recognizer: UILongPressGestureRecognizer) {
        let alertV = UIAlertController()
        let saveAction = UIAlertAction(title: "保存图片", style: .default) { (alertV) in
            UIImageWriteToSavedPhotosAlbum(self.testImage.image!, self, #selector(self.savedPhotosAlbum), nil)
        }
        //取消保存不作处理
        let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        
        alertV.addAction(saveAction)
        alertV.addAction(cancelAction)
        self.present(alertV, animated: true, completion: nil)
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    



}

//不实现该代理方法,长按无效
//MARK: 手势代理方法
extension colorRestoreVC : UIGestureRecognizerDelegate{
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}

 
extension UIImage {
    // 修复图片旋转
    func fixOrientation() -> UIImage {
        if self.imageOrientation == .up {
            return self
        }
         
        var transform = CGAffineTransform.identity
         
        switch self.imageOrientation {
        case .down, .downMirrored:
            transform = transform.translatedBy(x: self.size.width, y: self.size.height)
            transform = transform.rotated(by: .pi)
            break
             
        case .left, .leftMirrored:
            transform = transform.translatedBy(x: self.size.width, y: 0)
            transform = transform.rotated(by: .pi / 2)
            break
             
        case .right, .rightMirrored:
            transform = transform.translatedBy(x: 0, y: self.size.height)
            transform = transform.rotated(by: -.pi / 2)
            break
             
        default:
            break
        }
         
        switch self.imageOrientation {
        case .upMirrored, .downMirrored:
            transform = transform.translatedBy(x: self.size.width, y: 0)
            transform = transform.scaledBy(x: -1, y: 1)
            break
             
        case .leftMirrored, .rightMirrored:
            transform = transform.translatedBy(x: self.size.height, y: 0);
            transform = transform.scaledBy(x: -1, y: 1)
            break
             
        default:
            break
        }
         
        let ctx = CGContext(data: nil, width: Int(self.size.width), height: Int(self.size.height), bitsPerComponent: self.cgImage!.bitsPerComponent, bytesPerRow: 0, space: self.cgImage!.colorSpace!, bitmapInfo: self.cgImage!.bitmapInfo.rawValue)
        ctx?.concatenate(transform)
         
        switch self.imageOrientation {
        case .left, .leftMirrored, .right, .rightMirrored:
            ctx?.draw(self.cgImage!, in: CGRect(x: CGFloat(0), y: CGFloat(0), width: CGFloat(size.height), height: CGFloat(size.width)))
            break
             
        default:
            ctx?.draw(self.cgImage!, in: CGRect(x: CGFloat(0), y: CGFloat(0), width: CGFloat(size.width), height: CGFloat(size.height)))
            break
        }
         
        let cgimg: CGImage = (ctx?.makeImage())!
        let img = UIImage(cgImage: cgimg)
         
        return img
    }
}
//
//  colorRestoreVC.swift
//  Colorful
//
//  Created by fox on 2021/10/4.
//  Copyright © 2021 fox. All rights reserved.
//

import Foundation
import UIKit
import CoreGraphics
import QuartzCore
import AVFoundation
import Alamofire
import SnapKit

typealias CGGammaValue = Float
typealias CGDirectDisplayID = UInt32

@available(iOS 11.0, *)
class colorRestoreVC: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate,UIActionSheetDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    var screenshot: UIImage!
    var imageOverlay: UIImageView!
    var timer: Timer!
    var mainWindow: UIWindow!
    var colorMode: ColorBlindType!
    
    var testImage: UIImageView!
    
    
    override func viewDidAppear(_ animated: Bool) {
        mainWindow = self.view.window

    }
    
    override func viewDidLoad() {
        
//        let longpressGesutre = UILongPressGestureRecognizer(target: self, action: Selector(("handleLongpressGesture:")))
//        //长按时间为1秒
//        longpressGesutre.minimumPressDuration = 1
//        //允许15秒运动
//        longpressGesutre.allowableMovement = 15
//        //所需触摸1次
//        longpressGesutre.numberOfTouchesRequired = 1
//        self.view.addGestureRecognizer(longpressGesutre)
        addLongPressGes()
        
        
        view.backgroundColor = .white
        super.viewDidLoad()
        
        
        
        testImage = UIImageView()
        self.view.addSubview(testImage);
        testImage.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview().offset(-100)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.9)
            make.height.equalToSuperview().multipliedBy(0.7)
        }
//        testImage.image = UIImage(named: "DSC_0775")
        testImage.clipsToBounds = true
        testImage.contentMode = .scaleAspectFit
        testImage.layer.cornerRadius = 10
        
        
        let albumButton = UIButton()
        self.view.addSubview(albumButton)
        albumButton.snp.makeConstraints { (make) in
            make.width.equalTo(testImage).dividedBy(2).offset(-5)
//            make.centerX.equalToSuperview()
            make.left.equalTo(testImage)
            make.top.equalTo(testImage.snp.bottom).offset(10)
            make.height.equalTo(50)
        }

//        albumButton.backgroundColor = #colorLiteral(red: 0.8417847157, green: 0.8507048488, blue: 0.8811554909, alpha: 1)
        albumButton.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.8470588235)
        albumButton.setTitle("相册", for: UIControl.State())
        albumButton.addTarget(self, action: #selector(self.demoClicked), for: .touchUpInside)
        albumButton.layer.cornerRadius = 10
        
        let camButton = UIButton()
        self.view.addSubview(camButton)
        camButton.snp.makeConstraints { (make) in
            make.width.equalTo(testImage).dividedBy(2).offset(-5)
            make.right.equalTo(testImage)
            make.top.equalTo(testImage.snp.bottom).offset(10)
            make.height.equalTo(50)
        }

//        camButton.backgroundColor = #colorLiteral(red: 0.8417847157, green: 0.8507048488, blue: 0.8811554909, alpha: 1)
        camButton.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.8470588235)
        camButton.setTitle("拍照", for: UIControl.State())
        camButton.addTarget(self, action: #selector(self.demoCameera), for: .touchUpInside)
        camButton.layer.cornerRadius = 10
        
        
        let changeButton = UIButton.init(type: .custom)
        self.view.addSubview(changeButton)
        changeButton.snp.makeConstraints { (make) in
            make.width.equalTo(testImage)
            make.centerX.equalToSuperview()
            make.top.equalTo(camButton.snp.bottom).offset(10)
            make.height.equalTo(50)
        }
//        changeButton.frame = CGRect(x: 20, y: nextViewButton.frame.size.height + nextViewButton.frame.origin.y + 20, width: self.view.bounds.size.width - 40, height: 50)
//        changeButton.backgroundColor =  #colorLiteral(red: 0.8417847157, green: 0.8507048488, blue: 0.8811554909, alpha: 1)
        changeButton.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.8470588235)
        changeButton.setTitle("切换", for: UIControl.State())
//        changeButton.addTarget(self, action: #selector(CBController.startColorBlinds), for: .touchUpInside)
        changeButton.addTarget(self, action: #selector(httpConvert), for: .touchUpInside)
        changeButton.layer.cornerRadius = 10
        
        let nextViewButton = UIButton()
        self.view.addSubview(nextViewButton)
        nextViewButton.snp.makeConstraints { (make) in
            make.width.equalTo(testImage)
            make.centerX.equalToSuperview()
            make.top.equalTo(changeButton.snp.bottom).offset(10)
            make.height.equalTo(50)
        }
//        nextViewButton.frame = CGRect(x: 20, y: testImage.frame.size.height + testImage.frame.origin.y + 20, width: self.view.bounds.size.width - 40, height: 50)
//        nextViewButton.backgroundColor = #colorLiteral(red: 0.8417847157, green: 0.8507048488, blue: 0.8811554909, alpha: 1)
        nextViewButton.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.8470588235)
        nextViewButton.setTitle("返回菜单", for: UIControl.State())
        nextViewButton.addTarget(self, action: #selector(self.nextView), for: .touchUpInside)
        nextViewButton.layer.cornerRadius = 10
        
        
    }
    
    @objc func nextView() {
        dismiss(animated: true, completion: nil)
    }
    @objc func httpConvert() {
        
        let urls:String = "http://121.40.64.188:5100/iosTest/"
        //参数
//        let parameters:Dictionary = ["type":"1","name":"customer","password":"123456"]

//        let imgData = getStrFromImage("DSC_0775")
        let imgData = getStrFromImage(testImage.image!)
//        let imgData = testImage.image?.pngData()?.base64EncodedString()
        
        let parameters: [String: [String]] = [
            "imgData": ["\(imgData))"],
            "baz": ["a", "b"],
            "qux": ["x", "y", "z"]
        ]
        //Alamofire 请求实例
        AF.request(URL(string: urls)!, method: .post, parameters: parameters, encoder: JSONParameterEncoder.sortedKeys)
                        .responseString { (responses) in
                            print(responses)
                            let data = responses.data
                            let data_error:Data! = UIImage(named: "DSC_0775")?.pngData()
//                            let
                            let res: UIImage! = UIImage(data: data ?? data_error)
                            self.testImage.image = res
//                            self.testImage.contentMode = .scaleAspectFit
                            
        }
                            }
    //MARK:- 🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟
    @objc func demoCameera(){
        openCamera()
    }
    
    @objc func demoClicked(){
        openAlbum()
    }
    
    //打开相册
    
    func openAlbum(){
        //判断设置是否支持图片库
        
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary){
            //初始化图片控制器
            let picker = UIImagePickerController()
            //设置代理
            picker.delegate = self
            //指定图片控制器类型
            picker.sourceType = UIImagePickerController.SourceType.photoLibrary
            //设置是否允许编辑
            
            picker.allowsEditing = true
            
            
            //弹出控制器，显示界面
            self.present(picker, animated:true, completion: {
                () -> Void in
            })
        }else{
            print("读取相册错误")
        }
        
    }
    
    
    
    func openCamera(){
        if UIImagePickerController.isSourceTypeAvailable(.camera){
            
            //创建图片控制器
            let picker = UIImagePickerController()
            //设置代理
            picker.delegate = self
            //设置来源
            picker.sourceType = UIImagePickerController.SourceType.camera
            //允许编辑
            picker.allowsEditing = true
            
//            picker.mediaTypes
            //打开相机
            self.present(picker, animated:true, completion: { () -> Void in})
            
        }else{
            debugPrint("找不到相机")
            
        }
        
    }
    //MARK:- 🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            self.testImage.image = image


        } else if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            self.testImage.image = image

        }
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    //保存图片
    @objc func savedPhotosAlbum(image: UIImage, didFinishSavingWithError error: NSError?, contextInfo: AnyObject) {
        
        if error != nil {
            print("save failed")
        } else {
            print("save succeed")

        }
    }
    //MARK:- ✨手势长按
    func addLongPressGes() {
        //添加长按手势
        let longPressGes = UILongPressGestureRecognizer(target: self, action: #selector(longPressedGesture(recognizer:)))
        longPressGes.minimumPressDuration = 1
        //一定要遵循代理
        longPressGes.delegate = self
//        longpressGes.minimumPressDuration = 1
        self.view.addGestureRecognizer(longPressGes)


    }
    
    @objc func longPressedGesture(recognizer: UILongPressGestureRecognizer) {
        let alertV = UIAlertController()
        let saveAction = UIAlertAction(title: "保存图片", style: .default) { (alertV) in
            UIImageWriteToSavedPhotosAlbum(self.testImage.image!, self, #selector(self.savedPhotosAlbum), nil)
        }
        //取消保存不作处理
        let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        
        alertV.addAction(saveAction)
        alertV.addAction(cancelAction)
        self.present(alertV, animated: true, completion: nil)
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    



}

//不实现该代理方法,长按无效
//MARK: 手势代理方法
extension colorRestoreVC : UIGestureRecognizerDelegate{
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}

 
extension UIImage {
    // 修复图片旋转
    func fixOrientation() -> UIImage {
        if self.imageOrientation == .up {
            return self
        }
         
        var transform = CGAffineTransform.identity
         
        switch self.imageOrientation {
        case .down, .downMirrored:
            transform = transform.translatedBy(x: self.size.width, y: self.size.height)
            transform = transform.rotated(by: .pi)
            break
             
        case .left, .leftMirrored:
            transform = transform.translatedBy(x: self.size.width, y: 0)
            transform = transform.rotated(by: .pi / 2)
            break
             
        case .right, .rightMirrored:
            transform = transform.translatedBy(x: 0, y: self.size.height)
            transform = transform.rotated(by: -.pi / 2)
            break
             
        default:
            break
        }
         
        switch self.imageOrientation {
        case .upMirrored, .downMirrored:
            transform = transform.translatedBy(x: self.size.width, y: 0)
            transform = transform.scaledBy(x: -1, y: 1)
            break
             
        case .leftMirrored, .rightMirrored:
            transform = transform.translatedBy(x: self.size.height, y: 0);
            transform = transform.scaledBy(x: -1, y: 1)
            break
             
        default:
            break
        }
         
        let ctx = CGContext(data: nil, width: Int(self.size.width), height: Int(self.size.height), bitsPerComponent: self.cgImage!.bitsPerComponent, bytesPerRow: 0, space: self.cgImage!.colorSpace!, bitmapInfo: self.cgImage!.bitmapInfo.rawValue)
        ctx?.concatenate(transform)
         
        switch self.imageOrientation {
        case .left, .leftMirrored, .right, .rightMirrored:
            ctx?.draw(self.cgImage!, in: CGRect(x: CGFloat(0), y: CGFloat(0), width: CGFloat(size.height), height: CGFloat(size.width)))
            break
             
        default:
            ctx?.draw(self.cgImage!, in: CGRect(x: CGFloat(0), y: CGFloat(0), width: CGFloat(size.width), height: CGFloat(size.height)))
            break
        }
         
        let cgimg: CGImage = (ctx?.makeImage())!
        let img = UIImage(cgImage: cgimg)
         
        return img
    }
}
//
//  colorRestoreVC.swift
//  Colorful
//
//  Created by fox on 2021/10/4.
//  Copyright © 2021 fox. All rights reserved.
//

import Foundation
import UIKit
import CoreGraphics
import QuartzCore
import AVFoundation
import Alamofire
import SnapKit

typealias CGGammaValue = Float
typealias CGDirectDisplayID = UInt32

@available(iOS 11.0, *)
class colorRestoreVC: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate,UIActionSheetDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    var screenshot: UIImage!
    var imageOverlay: UIImageView!
    var timer: Timer!
    var mainWindow: UIWindow!
    var colorMode: ColorBlindType!
    
    var testImage: UIImageView!
    
    
    override func viewDidAppear(_ animated: Bool) {
        mainWindow = self.view.window

    }
    
    override func viewDidLoad() {
        
//        let longpressGesutre = UILongPressGestureRecognizer(target: self, action: Selector(("handleLongpressGesture:")))
//        //长按时间为1秒
//        longpressGesutre.minimumPressDuration = 1
//        //允许15秒运动
//        longpressGesutre.allowableMovement = 15
//        //所需触摸1次
//        longpressGesutre.numberOfTouchesRequired = 1
//        self.view.addGestureRecognizer(longpressGesutre)
        addLongPressGes()
        
        
        view.backgroundColor = .white
        super.viewDidLoad()
        
        
        
        testImage = UIImageView()
        self.view.addSubview(testImage);
        testImage.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview().offset(-100)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.9)
            make.height.equalToSuperview().multipliedBy(0.7)
        }
//        testImage.image = UIImage(named: "DSC_0775")
        testImage.clipsToBounds = true
        testImage.contentMode = .scaleAspectFit
        testImage.layer.cornerRadius = 10
        
        
        let albumButton = UIButton()
        self.view.addSubview(albumButton)
        albumButton.snp.makeConstraints { (make) in
            make.width.equalTo(testImage).dividedBy(2).offset(-5)
//            make.centerX.equalToSuperview()
            make.left.equalTo(testImage)
            make.top.equalTo(testImage.snp.bottom).offset(10)
            make.height.equalTo(50)
        }

//        albumButton.backgroundColor = #colorLiteral(red: 0.8417847157, green: 0.8507048488, blue: 0.8811554909, alpha: 1)
        albumButton.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.8470588235)
        albumButton.setTitle("相册", for: UIControl.State())
        albumButton.addTarget(self, action: #selector(self.demoClicked), for: .touchUpInside)
        albumButton.layer.cornerRadius = 10
        
        let camButton = UIButton()
        self.view.addSubview(camButton)
        camButton.snp.makeConstraints { (make) in
            make.width.equalTo(testImage).dividedBy(2).offset(-5)
            make.right.equalTo(testImage)
            make.top.equalTo(testImage.snp.bottom).offset(10)
            make.height.equalTo(50)
        }

//        camButton.backgroundColor = #colorLiteral(red: 0.8417847157, green: 0.8507048488, blue: 0.8811554909, alpha: 1)
        camButton.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.8470588235)
        camButton.setTitle("拍照", for: UIControl.State())
        camButton.addTarget(self, action: #selector(self.demoCameera), for: .touchUpInside)
        camButton.layer.cornerRadius = 10
        
        
        let changeButton = UIButton.init(type: .custom)
        self.view.addSubview(changeButton)
        changeButton.snp.makeConstraints { (make) in
            make.width.equalTo(testImage)
            make.centerX.equalToSuperview()
            make.top.equalTo(camButton.snp.bottom).offset(10)
            make.height.equalTo(50)
        }
//        changeButton.frame = CGRect(x: 20, y: nextViewButton.frame.size.height + nextViewButton.frame.origin.y + 20, width: self.view.bounds.size.width - 40, height: 50)
//        changeButton.backgroundColor =  #colorLiteral(red: 0.8417847157, green: 0.8507048488, blue: 0.8811554909, alpha: 1)
        changeButton.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.8470588235)
        changeButton.setTitle("切换", for: UIControl.State())
//        changeButton.addTarget(self, action: #selector(CBController.startColorBlinds), for: .touchUpInside)
        changeButton.addTarget(self, action: #selector(httpConvert), for: .touchUpInside)
        changeButton.layer.cornerRadius = 10
        
        let nextViewButton = UIButton()
        self.view.addSubview(nextViewButton)
        nextViewButton.snp.makeConstraints { (make) in
            make.width.equalTo(testImage)
            make.centerX.equalToSuperview()
            make.top.equalTo(changeButton.snp.bottom).offset(10)
            make.height.equalTo(50)
        }
//        nextViewButton.frame = CGRect(x: 20, y: testImage.frame.size.height + testImage.frame.origin.y + 20, width: self.view.bounds.size.width - 40, height: 50)
//        nextViewButton.backgroundColor = #colorLiteral(red: 0.8417847157, green: 0.8507048488, blue: 0.8811554909, alpha: 1)
        nextViewButton.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.8470588235)
        nextViewButton.setTitle("返回菜单", for: UIControl.State())
        nextViewButton.addTarget(self, action: #selector(self.nextView), for: .touchUpInside)
        nextViewButton.layer.cornerRadius = 10
        
        
    }
    
    @objc func nextView() {
        dismiss(animated: true, completion: nil)
    }
    @objc func httpConvert() {
        
        let urls:String = "http://121.40.64.188:5100/iosTest/"
        //参数
//        let parameters:Dictionary = ["type":"1","name":"customer","password":"123456"]

//        let imgData = getStrFromImage("DSC_0775")
        let imgData = getStrFromImage(testImage.image!)
//        let imgData = testImage.image?.pngData()?.base64EncodedString()
        
        let parameters: [String: [String]] = [
            "imgData": ["\(imgData))"],
            "baz": ["a", "b"],
            "qux": ["x", "y", "z"]
        ]
        //Alamofire 请求实例
        AF.request(URL(string: urls)!, method: .post, parameters: parameters, encoder: JSONParameterEncoder.sortedKeys)
                        .responseString { (responses) in
                            print(responses)
                            let data = responses.data
                            let data_error:Data! = UIImage(named: "DSC_0775")?.pngData()
//                            let
                            let res: UIImage! = UIImage(data: data ?? data_error)
                            self.testImage.image = res
//                            self.testImage.contentMode = .scaleAspectFit
                            
        }
                            }
    //MARK:- 🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟
    @objc func demoCameera(){
        openCamera()
    }
    
    @objc func demoClicked(){
        openAlbum()
    }
    
    //打开相册
    
    func openAlbum(){
        //判断设置是否支持图片库
        
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary){
            //初始化图片控制器
            let picker = UIImagePickerController()
            //设置代理
            picker.delegate = self
            //指定图片控制器类型
            picker.sourceType = UIImagePickerController.SourceType.photoLibrary
            //设置是否允许编辑
            
            picker.allowsEditing = true
            
            
            //弹出控制器，显示界面
            self.present(picker, animated:true, completion: {
                () -> Void in
            })
        }else{
            print("读取相册错误")
        }
        
    }
    
    
    
    func openCamera(){
        if UIImagePickerController.isSourceTypeAvailable(.camera){
            
            //创建图片控制器
            let picker = UIImagePickerController()
            //设置代理
            picker.delegate = self
            //设置来源
            picker.sourceType = UIImagePickerController.SourceType.camera
            //允许编辑
            picker.allowsEditing = true
            
//            picker.mediaTypes
            //打开相机
            self.present(picker, animated:true, completion: { () -> Void in})
            
        }else{
            debugPrint("找不到相机")
            
        }
        
    }
    //MARK:- 🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            self.testImage.image = image


        } else if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            self.testImage.image = image

        }
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    //保存图片
    @objc func savedPhotosAlbum(image: UIImage, didFinishSavingWithError error: NSError?, contextInfo: AnyObject) {
        
        if error != nil {
            print("save failed")
        } else {
            print("save succeed")

        }
    }
    //MARK:- ✨手势长按
    func addLongPressGes() {
        //添加长按手势
        let longPressGes = UILongPressGestureRecognizer(target: self, action: #selector(longPressedGesture(recognizer:)))
        longPressGes.minimumPressDuration = 1
        //一定要遵循代理
        longPressGes.delegate = self
//        longpressGes.minimumPressDuration = 1
        self.view.addGestureRecognizer(longPressGes)


    }
    
    @objc func longPressedGesture(recognizer: UILongPressGestureRecognizer) {
        let alertV = UIAlertController()
        let saveAction = UIAlertAction(title: "保存图片", style: .default) { (alertV) in
            UIImageWriteToSavedPhotosAlbum(self.testImage.image!, self, #selector(self.savedPhotosAlbum), nil)
        }
        //取消保存不作处理
        let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        
        alertV.addAction(saveAction)
        alertV.addAction(cancelAction)
        self.present(alertV, animated: true, completion: nil)
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    



}

//不实现该代理方法,长按无效
//MARK: 手势代理方法
extension colorRestoreVC : UIGestureRecognizerDelegate{
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}

 
extension UIImage {
    // 修复图片旋转
    func fixOrientation() -> UIImage {
        if self.imageOrientation == .up {
            return self
        }
         
        var transform = CGAffineTransform.identity
         
        switch self.imageOrientation {
        case .down, .downMirrored:
            transform = transform.translatedBy(x: self.size.width, y: self.size.height)
            transform = transform.rotated(by: .pi)
            break
             
        case .left, .leftMirrored:
            transform = transform.translatedBy(x: self.size.width, y: 0)
            transform = transform.rotated(by: .pi / 2)
            break
             
        case .right, .rightMirrored:
            transform = transform.translatedBy(x: 0, y: self.size.height)
            transform = transform.rotated(by: -.pi / 2)
            break
             
        default:
            break
        }
         
        switch self.imageOrientation {
        case .upMirrored, .downMirrored:
            transform = transform.translatedBy(x: self.size.width, y: 0)
            transform = transform.scaledBy(x: -1, y: 1)
            break
             
        case .leftMirrored, .rightMirrored:
            transform = transform.translatedBy(x: self.size.height, y: 0);
            transform = transform.scaledBy(x: -1, y: 1)
            break
             
        default:
            break
        }
         
        let ctx = CGContext(data: nil, width: Int(self.size.width), height: Int(self.size.height), bitsPerComponent: self.cgImage!.bitsPerComponent, bytesPerRow: 0, space: self.cgImage!.colorSpace!, bitmapInfo: self.cgImage!.bitmapInfo.rawValue)
        ctx?.concatenate(transform)
         
        switch self.imageOrientation {
        case .left, .leftMirrored, .right, .rightMirrored:
            ctx?.draw(self.cgImage!, in: CGRect(x: CGFloat(0), y: CGFloat(0), width: CGFloat(size.height), height: CGFloat(size.width)))
            break
             
        default:
            ctx?.draw(self.cgImage!, in: CGRect(x: CGFloat(0), y: CGFloat(0), width: CGFloat(size.width), height: CGFloat(size.height)))
            break
        }
         
        let cgimg: CGImage = (ctx?.makeImage())!
        let img = UIImage(cgImage: cgimg)
         
        return img
    }
}
//
//  colorRestoreVC.swift
//  Colorful
//
//  Created by fox on 2021/10/4.
//  Copyright © 2021 fox. All rights reserved.
//

import Foundation
import UIKit
import CoreGraphics
import QuartzCore
import AVFoundation
import Alamofire
import SnapKit

typealias CGGammaValue = Float
typealias CGDirectDisplayID = UInt32

@available(iOS 11.0, *)
class colorRestoreVC: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate,UIActionSheetDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    var screenshot: UIImage!
    var imageOverlay: UIImageView!
    var timer: Timer!
    var mainWindow: UIWindow!
    var colorMode: ColorBlindType!
    
    var testImage: UIImageView!
    
    
    override func viewDidAppear(_ animated: Bool) {
        mainWindow = self.view.window

    }
    
    override func viewDidLoad() {
        
//        let longpressGesutre = UILongPressGestureRecognizer(target: self, action: Selector(("handleLongpressGesture:")))
//        //长按时间为1秒
//        longpressGesutre.minimumPressDuration = 1
//        //允许15秒运动
//        longpressGesutre.allowableMovement = 15
//        //所需触摸1次
//        longpressGesutre.numberOfTouchesRequired = 1
//        self.view.addGestureRecognizer(longpressGesutre)
        addLongPressGes()
        
        
        view.backgroundColor = .white
        super.viewDidLoad()
        
        
        
        testImage = UIImageView()
        self.view.addSubview(testImage);
        testImage.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview().offset(-100)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.9)
            make.height.equalToSuperview().multipliedBy(0.7)
        }
//        testImage.image = UIImage(named: "DSC_0775")
        testImage.clipsToBounds = true
        testImage.contentMode = .scaleAspectFit
        testImage.layer.cornerRadius = 10
        
        
        let albumButton = UIButton()
        self.view.addSubview(albumButton)
        albumButton.snp.makeConstraints { (make) in
            make.width.equalTo(testImage).dividedBy(2).offset(-5)
//            make.centerX.equalToSuperview()
            make.left.equalTo(testImage)
            make.top.equalTo(testImage.snp.bottom).offset(10)
            make.height.equalTo(50)
        }

//        albumButton.backgroundColor = #colorLiteral(red: 0.8417847157, green: 0.8507048488, blue: 0.8811554909, alpha: 1)
        albumButton.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.8470588235)
        albumButton.setTitle("相册", for: UIControl.State())
        albumButton.addTarget(self, action: #selector(self.demoClicked), for: .touchUpInside)
        albumButton.layer.cornerRadius = 10
        
        let camButton = UIButton()
        self.view.addSubview(camButton)
        camButton.snp.makeConstraints { (make) in
            make.width.equalTo(testImage).dividedBy(2).offset(-5)
            make.right.equalTo(testImage)
            make.top.equalTo(testImage.snp.bottom).offset(10)
            make.height.equalTo(50)
        }

//        camButton.backgroundColor = #colorLiteral(red: 0.8417847157, green: 0.8507048488, blue: 0.8811554909, alpha: 1)
        camButton.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.8470588235)
        camButton.setTitle("拍照", for: UIControl.State())
        camButton.addTarget(self, action: #selector(self.demoCameera), for: .touchUpInside)
        camButton.layer.cornerRadius = 10
        
        
        let changeButton = UIButton.init(type: .custom)
        self.view.addSubview(changeButton)
        changeButton.snp.makeConstraints { (make) in
            make.width.equalTo(testImage)
            make.centerX.equalToSuperview()
            make.top.equalTo(camButton.snp.bottom).offset(10)
            make.height.equalTo(50)
        }
//        changeButton.frame = CGRect(x: 20, y: nextViewButton.frame.size.height + nextViewButton.frame.origin.y + 20, width: self.view.bounds.size.width - 40, height: 50)
//        changeButton.backgroundColor =  #colorLiteral(red: 0.8417847157, green: 0.8507048488, blue: 0.8811554909, alpha: 1)
        changeButton.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.8470588235)
        changeButton.setTitle("切换", for: UIControl.State())
//        changeButton.addTarget(self, action: #selector(CBController.startColorBlinds), for: .touchUpInside)
        changeButton.addTarget(self, action: #selector(httpConvert), for: .touchUpInside)
        changeButton.layer.cornerRadius = 10
        
        let nextViewButton = UIButton()
        self.view.addSubview(nextViewButton)
        nextViewButton.snp.makeConstraints { (make) in
            make.width.equalTo(testImage)
            make.centerX.equalToSuperview()
            make.top.equalTo(changeButton.snp.bottom).offset(10)
            make.height.equalTo(50)
        }
//        nextViewButton.frame = CGRect(x: 20, y: testImage.frame.size.height + testImage.frame.origin.y + 20, width: self.view.bounds.size.width - 40, height: 50)
//        nextViewButton.backgroundColor = #colorLiteral(red: 0.8417847157, green: 0.8507048488, blue: 0.8811554909, alpha: 1)
        nextViewButton.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.8470588235)
        nextViewButton.setTitle("返回菜单", for: UIControl.State())
        nextViewButton.addTarget(self, action: #selector(self.nextView), for: .touchUpInside)
        nextViewButton.layer.cornerRadius = 10
        
        
    }
    
    @objc func nextView() {
        dismiss(animated: true, completion: nil)
    }
    @objc func httpConvert() {
        
        let urls:String = "http://121.40.64.188:5100/iosTest/"
        //参数
//        let parameters:Dictionary = ["type":"1","name":"customer","password":"123456"]

//        let imgData = getStrFromImage("DSC_0775")
        let imgData = getStrFromImage(testImage.image!)
//        let imgData = testImage.image?.pngData()?.base64EncodedString()
        
        let parameters: [String: [String]] = [
            "imgData": ["\(imgData))"],
            "baz": ["a", "b"],
            "qux": ["x", "y", "z"]
        ]
        //Alamofire 请求实例
        AF.request(URL(string: urls)!, method: .post, parameters: parameters, encoder: JSONParameterEncoder.sortedKeys)
                        .responseString { (responses) in
                            print(responses)
                            let data = responses.data
                            let data_error:Data! = UIImage(named: "DSC_0775")?.pngData()
//                            let
                            let res: UIImage! = UIImage(data: data ?? data_error)
                            self.testImage.image = res
//                            self.testImage.contentMode = .scaleAspectFit
                            
        }
                            }
    //MARK:- 🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟
    @objc func demoCameera(){
        openCamera()
    }
    
    @objc func demoClicked(){
        openAlbum()
    }
    
    //打开相册
    
    func openAlbum(){
        //判断设置是否支持图片库
        
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary){
            //初始化图片控制器
            let picker = UIImagePickerController()
            //设置代理
            picker.delegate = self
            //指定图片控制器类型
            picker.sourceType = UIImagePickerController.SourceType.photoLibrary
            //设置是否允许编辑
            
            picker.allowsEditing = true
            
            
            //弹出控制器，显示界面
            self.present(picker, animated:true, completion: {
                () -> Void in
            })
        }else{
            print("读取相册错误")
        }
        
    }
    
    
    
    func openCamera(){
        if UIImagePickerController.isSourceTypeAvailable(.camera){
            
            //创建图片控制器
            let picker = UIImagePickerController()
            //设置代理
            picker.delegate = self
            //设置来源
            picker.sourceType = UIImagePickerController.SourceType.camera
            //允许编辑
            picker.allowsEditing = true
            
//            picker.mediaTypes
            //打开相机
            self.present(picker, animated:true, completion: { () -> Void in})
            
        }else{
            debugPrint("找不到相机")
            
        }
        
    }
    //MARK:- 🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            self.testImage.image = image


        } else if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            self.testImage.image = image

        }
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    //保存图片
    @objc func savedPhotosAlbum(image: UIImage, didFinishSavingWithError error: NSError?, contextInfo: AnyObject) {
        
        if error != nil {
            print("save failed")
        } else {
            print("save succeed")

        }
    }
    //MARK:- ✨手势长按
    func addLongPressGes() {
        //添加长按手势
        let longPressGes = UILongPressGestureRecognizer(target: self, action: #selector(longPressedGesture(recognizer:)))
        longPressGes.minimumPressDuration = 1
        //一定要遵循代理
        longPressGes.delegate = self
//        longpressGes.minimumPressDuration = 1
        self.view.addGestureRecognizer(longPressGes)


    }
    
    @objc func longPressedGesture(recognizer: UILongPressGestureRecognizer) {
        let alertV = UIAlertController()
        let saveAction = UIAlertAction(title: "保存图片", style: .default) { (alertV) in
            UIImageWriteToSavedPhotosAlbum(self.testImage.image!, self, #selector(self.savedPhotosAlbum), nil)
        }
        //取消保存不作处理
        let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        
        alertV.addAction(saveAction)
        alertV.addAction(cancelAction)
        self.present(alertV, animated: true, completion: nil)
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    



}

//不实现该代理方法,长按无效
//MARK: 手势代理方法
extension colorRestoreVC : UIGestureRecognizerDelegate{
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}

 
extension UIImage {
    // 修复图片旋转
    func fixOrientation() -> UIImage {
        if self.imageOrientation == .up {
            return self
        }
         
        var transform = CGAffineTransform.identity
         
        switch self.imageOrientation {
        case .down, .downMirrored:
            transform = transform.translatedBy(x: self.size.width, y: self.size.height)
            transform = transform.rotated(by: .pi)
            break
             
        case .left, .leftMirrored:
            transform = transform.translatedBy(x: self.size.width, y: 0)
            transform = transform.rotated(by: .pi / 2)
            break
             
        case .right, .rightMirrored:
            transform = transform.translatedBy(x: 0, y: self.size.height)
            transform = transform.rotated(by: -.pi / 2)
            break
             
        default:
            break
        }
         
        switch self.imageOrientation {
        case .upMirrored, .downMirrored:
            transform = transform.translatedBy(x: self.size.width, y: 0)
            transform = transform.scaledBy(x: -1, y: 1)
            break
             
        case .leftMirrored, .rightMirrored:
            transform = transform.translatedBy(x: self.size.height, y: 0);
            transform = transform.scaledBy(x: -1, y: 1)
            break
             
        default:
            break
        }
         
        let ctx = CGContext(data: nil, width: Int(self.size.width), height: Int(self.size.height), bitsPerComponent: self.cgImage!.bitsPerComponent, bytesPerRow: 0, space: self.cgImage!.colorSpace!, bitmapInfo: self.cgImage!.bitmapInfo.rawValue)
        ctx?.concatenate(transform)
         
        switch self.imageOrientation {
        case .left, .leftMirrored, .right, .rightMirrored:
            ctx?.draw(self.cgImage!, in: CGRect(x: CGFloat(0), y: CGFloat(0), width: CGFloat(size.height), height: CGFloat(size.width)))
            break
             
        default:
            ctx?.draw(self.cgImage!, in: CGRect(x: CGFloat(0), y: CGFloat(0), width: CGFloat(size.width), height: CGFloat(size.height)))
            break
        }
         
        let cgimg: CGImage = (ctx?.makeImage())!
        let img = UIImage(cgImage: cgimg)
         
        return img
    }
}
//
//  colorRestoreVC.swift
//  Colorful
//
//  Created by fox on 2021/10/4.
//  Copyright © 2021 fox. All rights reserved.
//

import Foundation
import UIKit
import CoreGraphics
import QuartzCore
import AVFoundation
import Alamofire
import SnapKit

typealias CGGammaValue = Float
typealias CGDirectDisplayID = UInt32

@available(iOS 11.0, *)
class colorRestoreVC: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate,UIActionSheetDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    var screenshot: UIImage!
    var imageOverlay: UIImageView!
    var timer: Timer!
    var mainWindow: UIWindow!
    var colorMode: ColorBlindType!
    
    var testImage: UIImageView!
    
    
    override func viewDidAppear(_ animated: Bool) {
        mainWindow = self.view.window

    }
    
    override func viewDidLoad() {
        
//        let longpressGesutre = UILongPressGestureRecognizer(target: self, action: Selector(("handleLongpressGesture:")))
//        //长按时间为1秒
//        longpressGesutre.minimumPressDuration = 1
//        //允许15秒运动
//        longpressGesutre.allowableMovement = 15
//        //所需触摸1次
//        longpressGesutre.numberOfTouchesRequired = 1
//        self.view.addGestureRecognizer(longpressGesutre)
        addLongPressGes()
        
        
        view.backgroundColor = .white
        super.viewDidLoad()
        
        
        
        testImage = UIImageView()
        self.view.addSubview(testImage);
        testImage.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview().offset(-100)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.9)
            make.height.equalToSuperview().multipliedBy(0.7)
        }
//        testImage.image = UIImage(named: "DSC_0775")
        testImage.clipsToBounds = true
        testImage.contentMode = .scaleAspectFit
        testImage.layer.cornerRadius = 10
        
        
        let albumButton = UIButton()
        self.view.addSubview(albumButton)
        albumButton.snp.makeConstraints { (make) in
            make.width.equalTo(testImage).dividedBy(2).offset(-5)
//            make.centerX.equalToSuperview()
            make.left.equalTo(testImage)
            make.top.equalTo(testImage.snp.bottom).offset(10)
            make.height.equalTo(50)
        }

//        albumButton.backgroundColor = #colorLiteral(red: 0.8417847157, green: 0.8507048488, blue: 0.8811554909, alpha: 1)
        albumButton.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.8470588235)
        albumButton.setTitle("相册", for: UIControl.State())
        albumButton.addTarget(self, action: #selector(self.demoClicked), for: .touchUpInside)
        albumButton.layer.cornerRadius = 10
        
        let camButton = UIButton()
        self.view.addSubview(camButton)
        camButton.snp.makeConstraints { (make) in
            make.width.equalTo(testImage).dividedBy(2).offset(-5)
            make.right.equalTo(testImage)
            make.top.equalTo(testImage.snp.bottom).offset(10)
            make.height.equalTo(50)
        }

//        camButton.backgroundColor = #colorLiteral(red: 0.8417847157, green: 0.8507048488, blue: 0.8811554909, alpha: 1)
        camButton.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.8470588235)
        camButton.setTitle("拍照", for: UIControl.State())
        camButton.addTarget(self, action: #selector(self.demoCameera), for: .touchUpInside)
        camButton.layer.cornerRadius = 10
        
        
        let changeButton = UIButton.init(type: .custom)
        self.view.addSubview(changeButton)
        changeButton.snp.makeConstraints { (make) in
            make.width.equalTo(testImage)
            make.centerX.equalToSuperview()
            make.top.equalTo(camButton.snp.bottom).offset(10)
            make.height.equalTo(50)
        }
//        changeButton.frame = CGRect(x: 20, y: nextViewButton.frame.size.height + nextViewButton.frame.origin.y + 20, width: self.view.bounds.size.width - 40, height: 50)
//        changeButton.backgroundColor =  #colorLiteral(red: 0.8417847157, green: 0.8507048488, blue: 0.8811554909, alpha: 1)
        changeButton.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.8470588235)
        changeButton.setTitle("切换", for: UIControl.State())
//        changeButton.addTarget(self, action: #selector(CBController.startColorBlinds), for: .touchUpInside)
        changeButton.addTarget(self, action: #selector(httpConvert), for: .touchUpInside)
        changeButton.layer.cornerRadius = 10
        
        let nextViewButton = UIButton()
        self.view.addSubview(nextViewButton)
        nextViewButton.snp.makeConstraints { (make) in
            make.width.equalTo(testImage)
            make.centerX.equalToSuperview()
            make.top.equalTo(changeButton.snp.bottom).offset(10)
            make.height.equalTo(50)
        }
//        nextViewButton.frame = CGRect(x: 20, y: testImage.frame.size.height + testImage.frame.origin.y + 20, width: self.view.bounds.size.width - 40, height: 50)
//        nextViewButton.backgroundColor = #colorLiteral(red: 0.8417847157, green: 0.8507048488, blue: 0.8811554909, alpha: 1)
        nextViewButton.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.8470588235)
        nextViewButton.setTitle("返回菜单", for: UIControl.State())
        nextViewButton.addTarget(self, action: #selector(self.nextView), for: .touchUpInside)
        nextViewButton.layer.cornerRadius = 10
        
        
    }
    
    @objc func nextView() {
        dismiss(animated: true, completion: nil)
    }
    @objc func httpConvert() {
        
        let urls:String = "http://121.40.64.188:5100/iosTest/"
        //参数
//        let parameters:Dictionary = ["type":"1","name":"customer","password":"123456"]

//        let imgData = getStrFromImage("DSC_0775")
        let imgData = getStrFromImage(testImage.image!)
//        let imgData = testImage.image?.pngData()?.base64EncodedString()
        
        let parameters: [String: [String]] = [
            "imgData": ["\(imgData))"],
            "baz": ["a", "b"],
            "qux": ["x", "y", "z"]
        ]
        //Alamofire 请求实例
        AF.request(URL(string: urls)!, method: .post, parameters: parameters, encoder: JSONParameterEncoder.sortedKeys)
                        .responseString { (responses) in
                            print(responses)
                            let data = responses.data
                            let data_error:Data! = UIImage(named: "DSC_0775")?.pngData()
//                            let
                            let res: UIImage! = UIImage(data: data ?? data_error)
                            self.testImage.image = res
//                            self.testImage.contentMode = .scaleAspectFit
                            
        }
                            }
    //MARK:- 🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟
    @objc func demoCameera(){
        openCamera()
    }
    
    @objc func demoClicked(){
        openAlbum()
    }
    
    //打开相册
    
    func openAlbum(){
        //判断设置是否支持图片库
        
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary){
            //初始化图片控制器
            let picker = UIImagePickerController()
            //设置代理
            picker.delegate = self
            //指定图片控制器类型
            picker.sourceType = UIImagePickerController.SourceType.photoLibrary
            //设置是否允许编辑
            
            picker.allowsEditing = true
            
            
            //弹出控制器，显示界面
            self.present(picker, animated:true, completion: {
                () -> Void in
            })
        }else{
            print("读取相册错误")
        }
        
    }
    
    
    
    func openCamera(){
        if UIImagePickerController.isSourceTypeAvailable(.camera){
            
            //创建图片控制器
            let picker = UIImagePickerController()
            //设置代理
            picker.delegate = self
            //设置来源
            picker.sourceType = UIImagePickerController.SourceType.camera
            //允许编辑
            picker.allowsEditing = true
            
//            picker.mediaTypes
            //打开相机
            self.present(picker, animated:true, completion: { () -> Void in})
            
        }else{
            debugPrint("找不到相机")
            
        }
        
    }
    //MARK:- 🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            self.testImage.image = image


        } else if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            self.testImage.image = image

        }
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    //保存图片
    @objc func savedPhotosAlbum(image: UIImage, didFinishSavingWithError error: NSError?, contextInfo: AnyObject) {
        
        if error != nil {
            print("save failed")
        } else {
            print("save succeed")

        }
    }
    //MARK:- ✨手势长按
    func addLongPressGes() {
        //添加长按手势
        let longPressGes = UILongPressGestureRecognizer(target: self, action: #selector(longPressedGesture(recognizer:)))
        longPressGes.minimumPressDuration = 1
        //一定要遵循代理
        longPressGes.delegate = self
//        longpressGes.minimumPressDuration = 1
        self.view.addGestureRecognizer(longPressGes)


    }
    
    @objc func longPressedGesture(recognizer: UILongPressGestureRecognizer) {
        let alertV = UIAlertController()
        let saveAction = UIAlertAction(title: "保存图片", style: .default) { (alertV) in
            UIImageWriteToSavedPhotosAlbum(self.testImage.image!, self, #selector(self.savedPhotosAlbum), nil)
        }
        //取消保存不作处理
        let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        
        alertV.addAction(saveAction)
        alertV.addAction(cancelAction)
        self.present(alertV, animated: true, completion: nil)
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    



}

//不实现该代理方法,长按无效
//MARK: 手势代理方法
extension colorRestoreVC : UIGestureRecognizerDelegate{
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}

 
extension UIImage {
    // 修复图片旋转
    func fixOrientation() -> UIImage {
        if self.imageOrientation == .up {
            return self
        }
         
        var transform = CGAffineTransform.identity
         
        switch self.imageOrientation {
        case .down, .downMirrored:
            transform = transform.translatedBy(x: self.size.width, y: self.size.height)
            transform = transform.rotated(by: .pi)
            break
             
        case .left, .leftMirrored:
            transform = transform.translatedBy(x: self.size.width, y: 0)
            transform = transform.rotated(by: .pi / 2)
            break
             
        case .right, .rightMirrored:
            transform = transform.translatedBy(x: 0, y: self.size.height)
            transform = transform.rotated(by: -.pi / 2)
            break
             
        default:
            break
        }
         
        switch self.imageOrientation {
        case .upMirrored, .downMirrored:
            transform = transform.translatedBy(x: self.size.width, y: 0)
            transform = transform.scaledBy(x: -1, y: 1)
            break
             
        case .leftMirrored, .rightMirrored:
            transform = transform.translatedBy(x: self.size.height, y: 0);
            transform = transform.scaledBy(x: -1, y: 1)
            break
             
        default:
            break
        }
         
        let ctx = CGContext(data: nil, width: Int(self.size.width), height: Int(self.size.height), bitsPerComponent: self.cgImage!.bitsPerComponent, bytesPerRow: 0, space: self.cgImage!.colorSpace!, bitmapInfo: self.cgImage!.bitmapInfo.rawValue)
        ctx?.concatenate(transform)
         
        switch self.imageOrientation {
        case .left, .leftMirrored, .right, .rightMirrored:
            ctx?.draw(self.cgImage!, in: CGRect(x: CGFloat(0), y: CGFloat(0), width: CGFloat(size.height), height: CGFloat(size.width)))
            break
             
        default:
            ctx?.draw(self.cgImage!, in: CGRect(x: CGFloat(0), y: CGFloat(0), width: CGFloat(size.width), height: CGFloat(size.height)))
            break
        }
         
        let cgimg: CGImage = (ctx?.makeImage())!
        let img = UIImage(cgImage: cgimg)
         
        return img
    }
}
//
//  colorRestoreVC.swift
//  Colorful
//
//  Created by fox on 2021/10/4.
//  Copyright © 2021 fox. All rights reserved.
//

import Foundation
import UIKit
import CoreGraphics
import QuartzCore
import AVFoundation
import Alamofire
import SnapKit

typealias CGGammaValue = Float
typealias CGDirectDisplayID = UInt32

@available(iOS 11.0, *)
class colorRestoreVC: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate,UIActionSheetDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    var screenshot: UIImage!
    var imageOverlay: UIImageView!
    var timer: Timer!
    var mainWindow: UIWindow!
    var colorMode: ColorBlindType!
    
    var testImage: UIImageView!
    
    
    override func viewDidAppear(_ animated: Bool) {
        mainWindow = self.view.window

    }
    
    override func viewDidLoad() {
        
//        let longpressGesutre = UILongPressGestureRecognizer(target: self, action: Selector(("handleLongpressGesture:")))
//        //长按时间为1秒
//        longpressGesutre.minimumPressDuration = 1
//        //允许15秒运动
//        longpressGesutre.allowableMovement = 15
//        //所需触摸1次
//        longpressGesutre.numberOfTouchesRequired = 1
//        self.view.addGestureRecognizer(longpressGesutre)
        addLongPressGes()
        
        
        view.backgroundColor = .white
        super.viewDidLoad()
        
        
        
        testImage = UIImageView()
        self.view.addSubview(testImage);
        testImage.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview().offset(-100)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.9)
            make.height.equalToSuperview().multipliedBy(0.7)
        }
//        testImage.image = UIImage(named: "DSC_0775")
        testImage.clipsToBounds = true
        testImage.contentMode = .scaleAspectFit
        testImage.layer.cornerRadius = 10
        
        
        let albumButton = UIButton()
        self.view.addSubview(albumButton)
        albumButton.snp.makeConstraints { (make) in
            make.width.equalTo(testImage).dividedBy(2).offset(-5)
//            make.centerX.equalToSuperview()
            make.left.equalTo(testImage)
            make.top.equalTo(testImage.snp.bottom).offset(10)
            make.height.equalTo(50)
        }

//        albumButton.backgroundColor = #colorLiteral(red: 0.8417847157, green: 0.8507048488, blue: 0.8811554909, alpha: 1)
        albumButton.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.8470588235)
        albumButton.setTitle("相册", for: UIControl.State())
        albumButton.addTarget(self, action: #selector(self.demoClicked), for: .touchUpInside)
        albumButton.layer.cornerRadius = 10
        
        let camButton = UIButton()
        self.view.addSubview(camButton)
        camButton.snp.makeConstraints { (make) in
            make.width.equalTo(testImage).dividedBy(2).offset(-5)
            make.right.equalTo(testImage)
            make.top.equalTo(testImage.snp.bottom).offset(10)
            make.height.equalTo(50)
        }

//        camButton.backgroundColor = #colorLiteral(red: 0.8417847157, green: 0.8507048488, blue: 0.8811554909, alpha: 1)
        camButton.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.8470588235)
        camButton.setTitle("拍照", for: UIControl.State())
        camButton.addTarget(self, action: #selector(self.demoCameera), for: .touchUpInside)
        camButton.layer.cornerRadius = 10
        
        
        let changeButton = UIButton.init(type: .custom)
        self.view.addSubview(changeButton)
        changeButton.snp.makeConstraints { (make) in
            make.width.equalTo(testImage)
            make.centerX.equalToSuperview()
            make.top.equalTo(camButton.snp.bottom).offset(10)
            make.height.equalTo(50)
        }
//        changeButton.frame = CGRect(x: 20, y: nextViewButton.frame.size.height + nextViewButton.frame.origin.y + 20, width: self.view.bounds.size.width - 40, height: 50)
//        changeButton.backgroundColor =  #colorLiteral(red: 0.8417847157, green: 0.8507048488, blue: 0.8811554909, alpha: 1)
        changeButton.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.8470588235)
        changeButton.setTitle("切换", for: UIControl.State())
//        changeButton.addTarget(self, action: #selector(CBController.startColorBlinds), for: .touchUpInside)
        changeButton.addTarget(self, action: #selector(httpConvert), for: .touchUpInside)
        changeButton.layer.cornerRadius = 10
        
        let nextViewButton = UIButton()
        self.view.addSubview(nextViewButton)
        nextViewButton.snp.makeConstraints { (make) in
            make.width.equalTo(testImage)
            make.centerX.equalToSuperview()
            make.top.equalTo(changeButton.snp.bottom).offset(10)
            make.height.equalTo(50)
        }
//        nextViewButton.frame = CGRect(x: 20, y: testImage.frame.size.height + testImage.frame.origin.y + 20, width: self.view.bounds.size.width - 40, height: 50)
//        nextViewButton.backgroundColor = #colorLiteral(red: 0.8417847157, green: 0.8507048488, blue: 0.8811554909, alpha: 1)
        nextViewButton.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.8470588235)
        nextViewButton.setTitle("返回菜单", for: UIControl.State())
        nextViewButton.addTarget(self, action: #selector(self.nextView), for: .touchUpInside)
        nextViewButton.layer.cornerRadius = 10
        
        
    }
    
    @objc func nextView() {
        dismiss(animated: true, completion: nil)
    }
    @objc func httpConvert() {
        
        let urls:String = "http://121.40.64.188:5100/iosTest/"
        //参数
//        let parameters:Dictionary = ["type":"1","name":"customer","password":"123456"]

//        let imgData = getStrFromImage("DSC_0775")
        let imgData = getStrFromImage(testImage.image!)
//        let imgData = testImage.image?.pngData()?.base64EncodedString()
        
        let parameters: [String: [String]] = [
            "imgData": ["\(imgData))"],
            "baz": ["a", "b"],
            "qux": ["x", "y", "z"]
        ]
        //Alamofire 请求实例
        AF.request(URL(string: urls)!, method: .post, parameters: parameters, encoder: JSONParameterEncoder.sortedKeys)
                        .responseString { (responses) in
                            print(responses)
                            let data = responses.data
                            let data_error:Data! = UIImage(named: "DSC_0775")?.pngData()
//                            let
                            let res: UIImage! = UIImage(data: data ?? data_error)
                            self.testImage.image = res
//                            self.testImage.contentMode = .scaleAspectFit
                            
        }
                            }
    //MARK:- 🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟
    @objc func demoCameera(){
        openCamera()
    }
    
    @objc func demoClicked(){
        openAlbum()
    }
    
    //打开相册
    
    func openAlbum(){
        //判断设置是否支持图片库
        
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary){
            //初始化图片控制器
            let picker = UIImagePickerController()
            //设置代理
            picker.delegate = self
            //指定图片控制器类型
            picker.sourceType = UIImagePickerController.SourceType.photoLibrary
            //设置是否允许编辑
            
            picker.allowsEditing = true
            
            
            //弹出控制器，显示界面
            self.present(picker, animated:true, completion: {
                () -> Void in
            })
        }else{
            print("读取相册错误")
        }
        
    }
    
    
    
    func openCamera(){
        if UIImagePickerController.isSourceTypeAvailable(.camera){
            
            //创建图片控制器
            let picker = UIImagePickerController()
            //设置代理
            picker.delegate = self
            //设置来源
            picker.sourceType = UIImagePickerController.SourceType.camera
            //允许编辑
            picker.allowsEditing = true
            
//            picker.mediaTypes
            //打开相机
            self.present(picker, animated:true, completion: { () -> Void in})
            
        }else{
            debugPrint("找不到相机")
            
        }
        
    }
    //MARK:- 🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            self.testImage.image = image


        } else if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            self.testImage.image = image

        }
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    //保存图片
    @objc func savedPhotosAlbum(image: UIImage, didFinishSavingWithError error: NSError?, contextInfo: AnyObject) {
        
        if error != nil {
            print("save failed")
        } else {
            print("save succeed")

        }
    }
    //MARK:- ✨手势长按
    func addLongPressGes() {
        //添加长按手势
        let longPressGes = UILongPressGestureRecognizer(target: self, action: #selector(longPressedGesture(recognizer:)))
        longPressGes.minimumPressDuration = 1
        //一定要遵循代理
        longPressGes.delegate = self
//        longpressGes.minimumPressDuration = 1
        self.view.addGestureRecognizer(longPressGes)


    }
    
    @objc func longPressedGesture(recognizer: UILongPressGestureRecognizer) {
        let alertV = UIAlertController()
        let saveAction = UIAlertAction(title: "保存图片", style: .default) { (alertV) in
            UIImageWriteToSavedPhotosAlbum(self.testImage.image!, self, #selector(self.savedPhotosAlbum), nil)
        }
        //取消保存不作处理
        let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        
        alertV.addAction(saveAction)
        alertV.addAction(cancelAction)
        self.present(alertV, animated: true, completion: nil)
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    



}

//不实现该代理方法,长按无效
//MARK: 手势代理方法
extension colorRestoreVC : UIGestureRecognizerDelegate{
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}

 
extension UIImage {
    // 修复图片旋转
    func fixOrientation() -> UIImage {
        if self.imageOrientation == .up {
            return self
        }
         
        var transform = CGAffineTransform.identity
         
        switch self.imageOrientation {
        case .down, .downMirrored:
            transform = transform.translatedBy(x: self.size.width, y: self.size.height)
            transform = transform.rotated(by: .pi)
            break
             
        case .left, .leftMirrored:
            transform = transform.translatedBy(x: self.size.width, y: 0)
            transform = transform.rotated(by: .pi / 2)
            break
             
        case .right, .rightMirrored:
            transform = transform.translatedBy(x: 0, y: self.size.height)
            transform = transform.rotated(by: -.pi / 2)
            break
             
        default:
            break
        }
         
        switch self.imageOrientation {
        case .upMirrored, .downMirrored:
            transform = transform.translatedBy(x: self.size.width, y: 0)
            transform = transform.scaledBy(x: -1, y: 1)
            break
             
        case .leftMirrored, .rightMirrored:
            transform = transform.translatedBy(x: self.size.height, y: 0);
            transform = transform.scaledBy(x: -1, y: 1)
            break
             
        default:
            break
        }
         
        let ctx = CGContext(data: nil, width: Int(self.size.width), height: Int(self.size.height), bitsPerComponent: self.cgImage!.bitsPerComponent, bytesPerRow: 0, space: self.cgImage!.colorSpace!, bitmapInfo: self.cgImage!.bitmapInfo.rawValue)
        ctx?.concatenate(transform)
         
        switch self.imageOrientation {
        case .left, .leftMirrored, .right, .rightMirrored:
            ctx?.draw(self.cgImage!, in: CGRect(x: CGFloat(0), y: CGFloat(0), width: CGFloat(size.height), height: CGFloat(size.width)))
            break
             
        default:
            ctx?.draw(self.cgImage!, in: CGRect(x: CGFloat(0), y: CGFloat(0), width: CGFloat(size.width), height: CGFloat(size.height)))
            break
        }
         
        let cgimg: CGImage = (ctx?.makeImage())!
        let img = UIImage(cgImage: cgimg)
         
        return img
    }
}
//
//  colorRestoreVC.swift
//  Colorful
//
//  Created by fox on 2021/10/4.
//  Copyright © 2021 fox. All rights reserved.
//

import Foundation
import UIKit
import CoreGraphics
import QuartzCore
import AVFoundation
import Alamofire
import SnapKit

typealias CGGammaValue = Float
typealias CGDirectDisplayID = UInt32

@available(iOS 11.0, *)
class colorRestoreVC: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate,UIActionSheetDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    var screenshot: UIImage!
    var imageOverlay: UIImageView!
    var timer: Timer!
    var mainWindow: UIWindow!
    var colorMode: ColorBlindType!
    
    var testImage: UIImageView!
    
    
    override func viewDidAppear(_ animated: Bool) {
        mainWindow = self.view.window

    }
    
    override func viewDidLoad() {
        
//        let longpressGesutre = UILongPressGestureRecognizer(target: self, action: Selector(("handleLongpressGesture:")))
//        //长按时间为1秒
//        longpressGesutre.minimumPressDuration = 1
//        //允许15秒运动
//        longpressGesutre.allowableMovement = 15
//        //所需触摸1次
//        longpressGesutre.numberOfTouchesRequired = 1
//        self.view.addGestureRecognizer(longpressGesutre)
        addLongPressGes()
        
        
        view.backgroundColor = .white
        super.viewDidLoad()
        
        
        
        testImage = UIImageView()
        self.view.addSubview(testImage);
        testImage.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview().offset(-100)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.9)
            make.height.equalToSuperview().multipliedBy(0.7)
        }
//        testImage.image = UIImage(named: "DSC_0775")
        testImage.clipsToBounds = true
        testImage.contentMode = .scaleAspectFit
        testImage.layer.cornerRadius = 10
        
        
        let albumButton = UIButton()
        self.view.addSubview(albumButton)
        albumButton.snp.makeConstraints { (make) in
            make.width.equalTo(testImage).dividedBy(2).offset(-5)
//            make.centerX.equalToSuperview()
            make.left.equalTo(testImage)
            make.top.equalTo(testImage.snp.bottom).offset(10)
            make.height.equalTo(50)
        }

//        albumButton.backgroundColor = #colorLiteral(red: 0.8417847157, green: 0.8507048488, blue: 0.8811554909, alpha: 1)
        albumButton.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.8470588235)
        albumButton.setTitle("相册", for: UIControl.State())
        albumButton.addTarget(self, action: #selector(self.demoClicked), for: .touchUpInside)
        albumButton.layer.cornerRadius = 10
        
        let camButton = UIButton()
        self.view.addSubview(camButton)
        camButton.snp.makeConstraints { (make) in
            make.width.equalTo(testImage).dividedBy(2).offset(-5)
            make.right.equalTo(testImage)
            make.top.equalTo(testImage.snp.bottom).offset(10)
            make.height.equalTo(50)
        }

//        camButton.backgroundColor = #colorLiteral(red: 0.8417847157, green: 0.8507048488, blue: 0.8811554909, alpha: 1)
        camButton.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.8470588235)
        camButton.setTitle("拍照", for: UIControl.State())
        camButton.addTarget(self, action: #selector(self.demoCameera), for: .touchUpInside)
        camButton.layer.cornerRadius = 10
        
        
        let changeButton = UIButton.init(type: .custom)
        self.view.addSubview(changeButton)
        changeButton.snp.makeConstraints { (make) in
            make.width.equalTo(testImage)
            make.centerX.equalToSuperview()
            make.top.equalTo(camButton.snp.bottom).offset(10)
            make.height.equalTo(50)
        }
//        changeButton.frame = CGRect(x: 20, y: nextViewButton.frame.size.height + nextViewButton.frame.origin.y + 20, width: self.view.bounds.size.width - 40, height: 50)
//        changeButton.backgroundColor =  #colorLiteral(red: 0.8417847157, green: 0.8507048488, blue: 0.8811554909, alpha: 1)
        changeButton.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.8470588235)
        changeButton.setTitle("切换", for: UIControl.State())
//        changeButton.addTarget(self, action: #selector(CBController.startColorBlinds), for: .touchUpInside)
        changeButton.addTarget(self, action: #selector(httpConvert), for: .touchUpInside)
        changeButton.layer.cornerRadius = 10
        
        let nextViewButton = UIButton()
        self.view.addSubview(nextViewButton)
        nextViewButton.snp.makeConstraints { (make) in
            make.width.equalTo(testImage)
            make.centerX.equalToSuperview()
            make.top.equalTo(changeButton.snp.bottom).offset(10)
            make.height.equalTo(50)
        }
//        nextViewButton.frame = CGRect(x: 20, y: testImage.frame.size.height + testImage.frame.origin.y + 20, width: self.view.bounds.size.width - 40, height: 50)
//        nextViewButton.backgroundColor = #colorLiteral(red: 0.8417847157, green: 0.8507048488, blue: 0.8811554909, alpha: 1)
        nextViewButton.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.8470588235)
        nextViewButton.setTitle("返回菜单", for: UIControl.State())
        nextViewButton.addTarget(self, action: #selector(self.nextView), for: .touchUpInside)
        nextViewButton.layer.cornerRadius = 10
        
        
    }
    
    @objc func nextView() {
        dismiss(animated: true, completion: nil)
    }
    @objc func httpConvert() {
        
        let urls:String = "http://121.40.64.188:5100/iosTest/"
        //参数
//        let parameters:Dictionary = ["type":"1","name":"customer","password":"123456"]

//        let imgData = getStrFromImage("DSC_0775")
        let imgData = getStrFromImage(testImage.image!)
//        let imgData = testImage.image?.pngData()?.base64EncodedString()
        
        let parameters: [String: [String]] = [
            "imgData": ["\(imgData))"],
            "baz": ["a", "b"],
            "qux": ["x", "y", "z"]
        ]
        //Alamofire 请求实例
        AF.request(URL(string: urls)!, method: .post, parameters: parameters, encoder: JSONParameterEncoder.sortedKeys)
                        .responseString { (responses) in
                            print(responses)
                            let data = responses.data
                            let data_error:Data! = UIImage(named: "DSC_0775")?.pngData()
//                            let
                            let res: UIImage! = UIImage(data: data ?? data_error)
                            self.testImage.image = res
//                            self.testImage.contentMode = .scaleAspectFit
                            
        }
                            }
    //MARK:- 🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟
    @objc func demoCameera(){
        openCamera()
    }
    
    @objc func demoClicked(){
        openAlbum()
    }
    
    //打开相册
    
    func openAlbum(){
        //判断设置是否支持图片库
        
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary){
            //初始化图片控制器
            let picker = UIImagePickerController()
            //设置代理
            picker.delegate = self
            //指定图片控制器类型
            picker.sourceType = UIImagePickerController.SourceType.photoLibrary
            //设置是否允许编辑
            
            picker.allowsEditing = true
            
            
            //弹出控制器，显示界面
            self.present(picker, animated:true, completion: {
                () -> Void in
            })
        }else{
            print("读取相册错误")
        }
        
    }
    
    
    
    func openCamera(){
        if UIImagePickerController.isSourceTypeAvailable(.camera){
            
            //创建图片控制器
            let picker = UIImagePickerController()
            //设置代理
            picker.delegate = self
            //设置来源
            picker.sourceType = UIImagePickerController.SourceType.camera
            //允许编辑
            picker.allowsEditing = true
            
//            picker.mediaTypes
            //打开相机
            self.present(picker, animated:true, completion: { () -> Void in})
            
        }else{
            debugPrint("找不到相机")
            
        }
        
    }
    //MARK:- 🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            self.testImage.image = image


        } else if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            self.testImage.image = image

        }
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    //保存图片
    @objc func savedPhotosAlbum(image: UIImage, didFinishSavingWithError error: NSError?, contextInfo: AnyObject) {
        
        if error != nil {
            print("save failed")
        } else {
            print("save succeed")

        }
    }
    //MARK:- ✨手势长按
    func addLongPressGes() {
        //添加长按手势
        let longPressGes = UILongPressGestureRecognizer(target: self, action: #selector(longPressedGesture(recognizer:)))
        longPressGes.minimumPressDuration = 1
        //一定要遵循代理
        longPressGes.delegate = self
//        longpressGes.minimumPressDuration = 1
        self.view.addGestureRecognizer(longPressGes)


    }
    
    @objc func longPressedGesture(recognizer: UILongPressGestureRecognizer) {
        let alertV = UIAlertController()
        let saveAction = UIAlertAction(title: "保存图片", style: .default) { (alertV) in
            UIImageWriteToSavedPhotosAlbum(self.testImage.image!, self, #selector(self.savedPhotosAlbum), nil)
        }
        //取消保存不作处理
        let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        
        alertV.addAction(saveAction)
        alertV.addAction(cancelAction)
        self.present(alertV, animated: true, completion: nil)
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    



}

//不实现该代理方法,长按无效
//MARK: 手势代理方法
extension colorRestoreVC : UIGestureRecognizerDelegate{
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}

 
extension UIImage {
    // 修复图片旋转
    func fixOrientation() -> UIImage {
        if self.imageOrientation == .up {
            return self
        }
         
        var transform = CGAffineTransform.identity
         
        switch self.imageOrientation {
        case .down, .downMirrored:
            transform = transform.translatedBy(x: self.size.width, y: self.size.height)
            transform = transform.rotated(by: .pi)
            break
             
        case .left, .leftMirrored:
            transform = transform.translatedBy(x: self.size.width, y: 0)
            transform = transform.rotated(by: .pi / 2)
            break
             
        case .right, .rightMirrored:
            transform = transform.translatedBy(x: 0, y: self.size.height)
            transform = transform.rotated(by: -.pi / 2)
            break
             
        default:
            break
        }
         
        switch self.imageOrientation {
        case .upMirrored, .downMirrored:
            transform = transform.translatedBy(x: self.size.width, y: 0)
            transform = transform.scaledBy(x: -1, y: 1)
            break
             
        case .leftMirrored, .rightMirrored:
            transform = transform.translatedBy(x: self.size.height, y: 0);
            transform = transform.scaledBy(x: -1, y: 1)
            break
             
        default:
            break
        }
         
        let ctx = CGContext(data: nil, width: Int(self.size.width), height: Int(self.size.height), bitsPerComponent: self.cgImage!.bitsPerComponent, bytesPerRow: 0, space: self.cgImage!.colorSpace!, bitmapInfo: self.cgImage!.bitmapInfo.rawValue)
        ctx?.concatenate(transform)
         
        switch self.imageOrientation {
        case .left, .leftMirrored, .right, .rightMirrored:
            ctx?.draw(self.cgImage!, in: CGRect(x: CGFloat(0), y: CGFloat(0), width: CGFloat(size.height), height: CGFloat(size.width)))
            break
             
        default:
            ctx?.draw(self.cgImage!, in: CGRect(x: CGFloat(0), y: CGFloat(0), width: CGFloat(size.width), height: CGFloat(size.height)))
            break
        }
         
        let cgimg: CGImage = (ctx?.makeImage())!
        let img = UIImage(cgImage: cgimg)
         
        return img
    }
}
//
//  colorRestoreVC.swift
//  Colorful
//
//  Created by fox on 2021/10/4.
//  Copyright © 2021 fox. All rights reserved.
//

import Foundation
import UIKit
import CoreGraphics
import QuartzCore
import AVFoundation
import Alamofire
import SnapKit

typealias CGGammaValue = Float
typealias CGDirectDisplayID = UInt32

@available(iOS 11.0, *)
class colorRestoreVC: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate,UIActionSheetDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    var screenshot: UIImage!
    var imageOverlay: UIImageView!
    var timer: Timer!
    var mainWindow: UIWindow!
    var colorMode: ColorBlindType!
    
    var testImage: UIImageView!
    
    
    override func viewDidAppear(_ animated: Bool) {
        mainWindow = self.view.window

    }
    
    override func viewDidLoad() {
        
//        let longpressGesutre = UILongPressGestureRecognizer(target: self, action: Selector(("handleLongpressGesture:")))
//        //长按时间为1秒
//        longpressGesutre.minimumPressDuration = 1
//        //允许15秒运动
//        longpressGesutre.allowableMovement = 15
//        //所需触摸1次
//        longpressGesutre.numberOfTouchesRequired = 1
//        self.view.addGestureRecognizer(longpressGesutre)
        addLongPressGes()
        
        
        view.backgroundColor = .white
        super.viewDidLoad()
        
        
        
        testImage = UIImageView()
        self.view.addSubview(testImage);
        testImage.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview().offset(-100)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.9)
            make.height.equalToSuperview().multipliedBy(0.7)
        }
//        testImage.image = UIImage(named: "DSC_0775")
        testImage.clipsToBounds = true
        testImage.contentMode = .scaleAspectFit
        testImage.layer.cornerRadius = 10
        
        
        let albumButton = UIButton()
        self.view.addSubview(albumButton)
        albumButton.snp.makeConstraints { (make) in
            make.width.equalTo(testImage).dividedBy(2).offset(-5)
//            make.centerX.equalToSuperview()
            make.left.equalTo(testImage)
            make.top.equalTo(testImage.snp.bottom).offset(10)
            make.height.equalTo(50)
        }

//        albumButton.backgroundColor = #colorLiteral(red: 0.8417847157, green: 0.8507048488, blue: 0.8811554909, alpha: 1)
        albumButton.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.8470588235)
        albumButton.setTitle("相册", for: UIControl.State())
        albumButton.addTarget(self, action: #selector(self.demoClicked), for: .touchUpInside)
        albumButton.layer.cornerRadius = 10
        
        let camButton = UIButton()
        self.view.addSubview(camButton)
        camButton.snp.makeConstraints { (make) in
            make.width.equalTo(testImage).dividedBy(2).offset(-5)
            make.right.equalTo(testImage)
            make.top.equalTo(testImage.snp.bottom).offset(10)
            make.height.equalTo(50)
        }

//        camButton.backgroundColor = #colorLiteral(red: 0.8417847157, green: 0.8507048488, blue: 0.8811554909, alpha: 1)
        camButton.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.8470588235)
        camButton.setTitle("拍照", for: UIControl.State())
        camButton.addTarget(self, action: #selector(self.demoCameera), for: .touchUpInside)
        camButton.layer.cornerRadius = 10
        
        
        let changeButton = UIButton.init(type: .custom)
        self.view.addSubview(changeButton)
        changeButton.snp.makeConstraints { (make) in
            make.width.equalTo(testImage)
            make.centerX.equalToSuperview()
            make.top.equalTo(camButton.snp.bottom).offset(10)
            make.height.equalTo(50)
        }
//        changeButton.frame = CGRect(x: 20, y: nextViewButton.frame.size.height + nextViewButton.frame.origin.y + 20, width: self.view.bounds.size.width - 40, height: 50)
//        changeButton.backgroundColor =  #colorLiteral(red: 0.8417847157, green: 0.8507048488, blue: 0.8811554909, alpha: 1)
        changeButton.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.8470588235)
        changeButton.setTitle("切换", for: UIControl.State())
//        changeButton.addTarget(self, action: #selector(CBController.startColorBlinds), for: .touchUpInside)
        changeButton.addTarget(self, action: #selector(httpConvert), for: .touchUpInside)
        changeButton.layer.cornerRadius = 10
        
        let nextViewButton = UIButton()
        self.view.addSubview(nextViewButton)
        nextViewButton.snp.makeConstraints { (make) in
            make.width.equalTo(testImage)
            make.centerX.equalToSuperview()
            make.top.equalTo(changeButton.snp.bottom).offset(10)
            make.height.equalTo(50)
        }
//        nextViewButton.frame = CGRect(x: 20, y: testImage.frame.size.height + testImage.frame.origin.y + 20, width: self.view.bounds.size.width - 40, height: 50)
//        nextViewButton.backgroundColor = #colorLiteral(red: 0.8417847157, green: 0.8507048488, blue: 0.8811554909, alpha: 1)
        nextViewButton.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.8470588235)
        nextViewButton.setTitle("返回菜单", for: UIControl.State())
        nextViewButton.addTarget(self, action: #selector(self.nextView), for: .touchUpInside)
        nextViewButton.layer.cornerRadius = 10
        
        
    }
    
    @objc func nextView() {
        dismiss(animated: true, completion: nil)
    }
    @objc func httpConvert() {
        
        let urls:String = "http://121.40.64.188:5100/iosTest/"
        //参数
//        let parameters:Dictionary = ["type":"1","name":"customer","password":"123456"]

//        let imgData = getStrFromImage("DSC_0775")
        let imgData = getStrFromImage(testImage.image!)
//        let imgData = testImage.image?.pngData()?.base64EncodedString()
        
        let parameters: [String: [String]] = [
            "imgData": ["\(imgData))"],
            "baz": ["a", "b"],
            "qux": ["x", "y", "z"]
        ]
        //Alamofire 请求实例
        AF.request(URL(string: urls)!, method: .post, parameters: parameters, encoder: JSONParameterEncoder.sortedKeys)
                        .responseString { (responses) in
                            print(responses)
                            let data = responses.data
                            let data_error:Data! = UIImage(named: "DSC_0775")?.pngData()
//                            let
                            let res: UIImage! = UIImage(data: data ?? data_error)
                            self.testImage.image = res
//                            self.testImage.contentMode = .scaleAspectFit
                            
        }
                            }
    //MARK:- 🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟
    @objc func demoCameera(){
        openCamera()
    }
    
    @objc func demoClicked(){
        openAlbum()
    }
    
    //打开相册
    
    func openAlbum(){
        //判断设置是否支持图片库
        
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary){
            //初始化图片控制器
            let picker = UIImagePickerController()
            //设置代理
            picker.delegate = self
            //指定图片控制器类型
            picker.sourceType = UIImagePickerController.SourceType.photoLibrary
            //设置是否允许编辑
            
            picker.allowsEditing = true
            
            
            //弹出控制器，显示界面
            self.present(picker, animated:true, completion: {
                () -> Void in
            })
        }else{
            print("读取相册错误")
        }
        
    }
    
    
    
    func openCamera(){
        if UIImagePickerController.isSourceTypeAvailable(.camera){
            
            //创建图片控制器
            let picker = UIImagePickerController()
            //设置代理
            picker.delegate = self
            //设置来源
            picker.sourceType = UIImagePickerController.SourceType.camera
            //允许编辑
            picker.allowsEditing = true
            
//            picker.mediaTypes
            //打开相机
            self.present(picker, animated:true, completion: { () -> Void in})
            
        }else{
            debugPrint("找不到相机")
            
        }
        
    }
    //MARK:- 🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            self.testImage.image = image


        } else if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            self.testImage.image = image

        }
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    //保存图片
    @objc func savedPhotosAlbum(image: UIImage, didFinishSavingWithError error: NSError?, contextInfo: AnyObject) {
        
        if error != nil {
            print("save failed")
        } else {
            print("save succeed")

        }
    }
    //MARK:- ✨手势长按
    func addLongPressGes() {
        //添加长按手势
        let longPressGes = UILongPressGestureRecognizer(target: self, action: #selector(longPressedGesture(recognizer:)))
        longPressGes.minimumPressDuration = 1
        //一定要遵循代理
        longPressGes.delegate = self
//        longpressGes.minimumPressDuration = 1
        self.view.addGestureRecognizer(longPressGes)


    }
    
    @objc func longPressedGesture(recognizer: UILongPressGestureRecognizer) {
        let alertV = UIAlertController()
        let saveAction = UIAlertAction(title: "保存图片", style: .default) { (alertV) in
            UIImageWriteToSavedPhotosAlbum(self.testImage.image!, self, #selector(self.savedPhotosAlbum), nil)
        }
        //取消保存不作处理
        let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        
        alertV.addAction(saveAction)
        alertV.addAction(cancelAction)
        self.present(alertV, animated: true, completion: nil)
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    



}

//不实现该代理方法,长按无效
//MARK: 手势代理方法
extension colorRestoreVC : UIGestureRecognizerDelegate{
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}

 
extension UIImage {
    // 修复图片旋转
    func fixOrientation() -> UIImage {
        if self.imageOrientation == .up {
            return self
        }
         
        var transform = CGAffineTransform.identity
         
        switch self.imageOrientation {
        case .down, .downMirrored:
            transform = transform.translatedBy(x: self.size.width, y: self.size.height)
            transform = transform.rotated(by: .pi)
            break
             
        case .left, .leftMirrored:
            transform = transform.translatedBy(x: self.size.width, y: 0)
            transform = transform.rotated(by: .pi / 2)
            break
             
        case .right, .rightMirrored:
            transform = transform.translatedBy(x: 0, y: self.size.height)
            transform = transform.rotated(by: -.pi / 2)
            break
             
        default:
            break
        }
         
        switch self.imageOrientation {
        case .upMirrored, .downMirrored:
            transform = transform.translatedBy(x: self.size.width, y: 0)
            transform = transform.scaledBy(x: -1, y: 1)
            break
             
        case .leftMirrored, .rightMirrored:
            transform = transform.translatedBy(x: self.size.height, y: 0);
            transform = transform.scaledBy(x: -1, y: 1)
            break
             
        default:
            break
        }
         
        let ctx = CGContext(data: nil, width: Int(self.size.width), height: Int(self.size.height), bitsPerComponent: self.cgImage!.bitsPerComponent, bytesPerRow: 0, space: self.cgImage!.colorSpace!, bitmapInfo: self.cgImage!.bitmapInfo.rawValue)
        ctx?.concatenate(transform)
         
        switch self.imageOrientation {
        case .left, .leftMirrored, .right, .rightMirrored:
            ctx?.draw(self.cgImage!, in: CGRect(x: CGFloat(0), y: CGFloat(0), width: CGFloat(size.height), height: CGFloat(size.width)))
            break
             
        default:
            ctx?.draw(self.cgImage!, in: CGRect(x: CGFloat(0), y: CGFloat(0), width: CGFloat(size.width), height: CGFloat(size.height)))
            break
        }
         
        let cgimg: CGImage = (ctx?.makeImage())!
        let img = UIImage(cgImage: cgimg)
         
        return img
    }
}
//
//  colorRestoreVC.swift
//  Colorful
//
//  Created by fox on 2021/10/4.
//  Copyright © 2021 fox. All rights reserved.
//

import Foundation
import UIKit
import CoreGraphics
import QuartzCore
import AVFoundation
import Alamofire
import SnapKit

typealias CGGammaValue = Float
typealias CGDirectDisplayID = UInt32

@available(iOS 11.0, *)
class colorRestoreVC: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate,UIActionSheetDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    var screenshot: UIImage!
    var imageOverlay: UIImageView!
    var timer: Timer!
    var mainWindow: UIWindow!
    var colorMode: ColorBlindType!
    
    var testImage: UIImageView!
    
    
    override func viewDidAppear(_ animated: Bool) {
        mainWindow = self.view.window

    }
    
    override func viewDidLoad() {
        
//        let longpressGesutre = UILongPressGestureRecognizer(target: self, action: Selector(("handleLongpressGesture:")))
//        //长按时间为1秒
//        longpressGesutre.minimumPressDuration = 1
//        //允许15秒运动
//        longpressGesutre.allowableMovement = 15
//        //所需触摸1次
//        longpressGesutre.numberOfTouchesRequired = 1
//        self.view.addGestureRecognizer(longpressGesutre)
        addLongPressGes()
        
        
        view.backgroundColor = .white
        super.viewDidLoad()
        
        
        
        testImage = UIImageView()
        self.view.addSubview(testImage);
        testImage.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview().offset(-100)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.9)
            make.height.equalToSuperview().multipliedBy(0.7)
        }
//        testImage.image = UIImage(named: "DSC_0775")
        testImage.clipsToBounds = true
        testImage.contentMode = .scaleAspectFit
        testImage.layer.cornerRadius = 10
        
        
        let albumButton = UIButton()
        self.view.addSubview(albumButton)
        albumButton.snp.makeConstraints { (make) in
            make.width.equalTo(testImage).dividedBy(2).offset(-5)
//            make.centerX.equalToSuperview()
            make.left.equalTo(testImage)
            make.top.equalTo(testImage.snp.bottom).offset(10)
            make.height.equalTo(50)
        }

//        albumButton.backgroundColor = #colorLiteral(red: 0.8417847157, green: 0.8507048488, blue: 0.8811554909, alpha: 1)
        albumButton.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.8470588235)
        albumButton.setTitle("相册", for: UIControl.State())
        albumButton.addTarget(self, action: #selector(self.demoClicked), for: .touchUpInside)
        albumButton.layer.cornerRadius = 10
        
        let camButton = UIButton()
        self.view.addSubview(camButton)
        camButton.snp.makeConstraints { (make) in
            make.width.equalTo(testImage).dividedBy(2).offset(-5)
            make.right.equalTo(testImage)
            make.top.equalTo(testImage.snp.bottom).offset(10)
            make.height.equalTo(50)
        }

//        camButton.backgroundColor = #colorLiteral(red: 0.8417847157, green: 0.8507048488, blue: 0.8811554909, alpha: 1)
        camButton.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.8470588235)
        camButton.setTitle("拍照", for: UIControl.State())
        camButton.addTarget(self, action: #selector(self.demoCameera), for: .touchUpInside)
        camButton.layer.cornerRadius = 10
        
        
        let changeButton = UIButton.init(type: .custom)
        self.view.addSubview(changeButton)
        changeButton.snp.makeConstraints { (make) in
            make.width.equalTo(testImage)
            make.centerX.equalToSuperview()
            make.top.equalTo(camButton.snp.bottom).offset(10)
            make.height.equalTo(50)
        }
//        changeButton.frame = CGRect(x: 20, y: nextViewButton.frame.size.height + nextViewButton.frame.origin.y + 20, width: self.view.bounds.size.width - 40, height: 50)
//        changeButton.backgroundColor =  #colorLiteral(red: 0.8417847157, green: 0.8507048488, blue: 0.8811554909, alpha: 1)
        changeButton.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.8470588235)
        changeButton.setTitle("切换", for: UIControl.State())
//        changeButton.addTarget(self, action: #selector(CBController.startColorBlinds), for: .touchUpInside)
        changeButton.addTarget(self, action: #selector(httpConvert), for: .touchUpInside)
        changeButton.layer.cornerRadius = 10
        
        let nextViewButton = UIButton()
        self.view.addSubview(nextViewButton)
        nextViewButton.snp.makeConstraints { (make) in
            make.width.equalTo(testImage)
            make.centerX.equalToSuperview()
            make.top.equalTo(changeButton.snp.bottom).offset(10)
            make.height.equalTo(50)
        }
//        nextViewButton.frame = CGRect(x: 20, y: testImage.frame.size.height + testImage.frame.origin.y + 20, width: self.view.bounds.size.width - 40, height: 50)
//        nextViewButton.backgroundColor = #colorLiteral(red: 0.8417847157, green: 0.8507048488, blue: 0.8811554909, alpha: 1)
        nextViewButton.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.8470588235)
        nextViewButton.setTitle("返回菜单", for: UIControl.State())
        nextViewButton.addTarget(self, action: #selector(self.nextView), for: .touchUpInside)
        nextViewButton.layer.cornerRadius = 10
        
        
    }
    
    @objc func nextView() {
        dismiss(animated: true, completion: nil)
    }
    @objc func httpConvert() {
        
        let urls:String = "http://121.40.64.188:5100/iosTest/"
        //参数
//        let parameters:Dictionary = ["type":"1","name":"customer","password":"123456"]

//        let imgData = getStrFromImage("DSC_0775")
        let imgData = getStrFromImage(testImage.image!)
//        let imgData = testImage.image?.pngData()?.base64EncodedString()
        
        let parameters: [String: [String]] = [
            "imgData": ["\(imgData))"],
            "baz": ["a", "b"],
            "qux": ["x", "y", "z"]
        ]
        //Alamofire 请求实例
        AF.request(URL(string: urls)!, method: .post, parameters: parameters, encoder: JSONParameterEncoder.sortedKeys)
                        .responseString { (responses) in
                            print(responses)
                            let data = responses.data
                            let data_error:Data! = UIImage(named: "DSC_0775")?.pngData()
//                            let
                            let res: UIImage! = UIImage(data: data ?? data_error)
                            self.testImage.image = res
//                            self.testImage.contentMode = .scaleAspectFit
                            
        }
                            }
    //MARK:- 🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟
    @objc func demoCameera(){
        openCamera()
    }
    
    @objc func demoClicked(){
        openAlbum()
    }
    
    //打开相册
    
    func openAlbum(){
        //判断设置是否支持图片库
        
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary){
            //初始化图片控制器
            let picker = UIImagePickerController()
            //设置代理
            picker.delegate = self
            //指定图片控制器类型
            picker.sourceType = UIImagePickerController.SourceType.photoLibrary
            //设置是否允许编辑
            
            picker.allowsEditing = true
            
            
            //弹出控制器，显示界面
            self.present(picker, animated:true, completion: {
                () -> Void in
            })
        }else{
            print("读取相册错误")
        }
        
    }
    
    
    
    func openCamera(){
        if UIImagePickerController.isSourceTypeAvailable(.camera){
            
            //创建图片控制器
            let picker = UIImagePickerController()
            //设置代理
            picker.delegate = self
            //设置来源
            picker.sourceType = UIImagePickerController.SourceType.camera
            //允许编辑
            picker.allowsEditing = true
            
//            picker.mediaTypes
            //打开相机
            self.present(picker, animated:true, completion: { () -> Void in})
            
        }else{
            debugPrint("找不到相机")
            
        }
        
    }
    //MARK:- 🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            self.testImage.image = image


        } else if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            self.testImage.image = image

        }
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    //保存图片
    @objc func savedPhotosAlbum(image: UIImage, didFinishSavingWithError error: NSError?, contextInfo: AnyObject) {
        
        if error != nil {
            print("save failed")
        } else {
            print("save succeed")

        }
    }
    //MARK:- ✨手势长按
    func addLongPressGes() {
        //添加长按手势
        let longPressGes = UILongPressGestureRecognizer(target: self, action: #selector(longPressedGesture(recognizer:)))
        longPressGes.minimumPressDuration = 1
        //一定要遵循代理
        longPressGes.delegate = self
//        longpressGes.minimumPressDuration = 1
        self.view.addGestureRecognizer(longPressGes)


    }
    
    @objc func longPressedGesture(recognizer: UILongPressGestureRecognizer) {
        let alertV = UIAlertController()
        let saveAction = UIAlertAction(title: "保存图片", style: .default) { (alertV) in
            UIImageWriteToSavedPhotosAlbum(self.testImage.image!, self, #selector(self.savedPhotosAlbum), nil)
        }
        //取消保存不作处理
        let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        
        alertV.addAction(saveAction)
        alertV.addAction(cancelAction)
        self.present(alertV, animated: true, completion: nil)
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    



}

//不实现该代理方法,长按无效
//MARK: 手势代理方法
extension colorRestoreVC : UIGestureRecognizerDelegate{
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}

 
extension UIImage {
    // 修复图片旋转
    func fixOrientation() -> UIImage {
        if self.imageOrientation == .up {
            return self
        }
         
        var transform = CGAffineTransform.identity
         
        switch self.imageOrientation {
        case .down, .downMirrored:
            transform = transform.translatedBy(x: self.size.width, y: self.size.height)
            transform = transform.rotated(by: .pi)
            break
             
        case .left, .leftMirrored:
            transform = transform.translatedBy(x: self.size.width, y: 0)
            transform = transform.rotated(by: .pi / 2)
            break
             
        case .right, .rightMirrored:
            transform = transform.translatedBy(x: 0, y: self.size.height)
            transform = transform.rotated(by: -.pi / 2)
            break
             
        default:
            break
        }
         
        switch self.imageOrientation {
        case .upMirrored, .downMirrored:
            transform = transform.translatedBy(x: self.size.width, y: 0)
            transform = transform.scaledBy(x: -1, y: 1)
            break
             
        case .leftMirrored, .rightMirrored:
            transform = transform.translatedBy(x: self.size.height, y: 0);
            transform = transform.scaledBy(x: -1, y: 1)
            break
             
        default:
            break
        }
         
        let ctx = CGContext(data: nil, width: Int(self.size.width), height: Int(self.size.height), bitsPerComponent: self.cgImage!.bitsPerComponent, bytesPerRow: 0, space: self.cgImage!.colorSpace!, bitmapInfo: self.cgImage!.bitmapInfo.rawValue)
        ctx?.concatenate(transform)
         
        switch self.imageOrientation {
        case .left, .leftMirrored, .right, .rightMirrored:
            ctx?.draw(self.cgImage!, in: CGRect(x: CGFloat(0), y: CGFloat(0), width: CGFloat(size.height), height: CGFloat(size.width)))
            break
             
        default:
            ctx?.draw(self.cgImage!, in: CGRect(x: CGFloat(0), y: CGFloat(0), width: CGFloat(size.width), height: CGFloat(size.height)))
            break
        }
         
        let cgimg: CGImage = (ctx?.makeImage())!
        let img = UIImage(cgImage: cgimg)
         
        return img
    }
}
//
//  colorRestoreVC.swift
//  Colorful
//
//  Created by fox on 2021/10/4.
//  Copyright © 2021 fox. All rights reserved.
//

import Foundation
import UIKit
import CoreGraphics
import QuartzCore
import AVFoundation
import Alamofire
import SnapKit

typealias CGGammaValue = Float
typealias CGDirectDisplayID = UInt32

@available(iOS 11.0, *)
class colorRestoreVC: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate,UIActionSheetDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    var screenshot: UIImage!
    var imageOverlay: UIImageView!
    var timer: Timer!
    var mainWindow: UIWindow!
    var colorMode: ColorBlindType!
    
    var testImage: UIImageView!
    
    
    override func viewDidAppear(_ animated: Bool) {
        mainWindow = self.view.window

    }
    
    override func viewDidLoad() {
        
//        let longpressGesutre = UILongPressGestureRecognizer(target: self, action: Selector(("handleLongpressGesture:")))
//        //长按时间为1秒
//        longpressGesutre.minimumPressDuration = 1
//        //允许15秒运动
//        longpressGesutre.allowableMovement = 15
//        //所需触摸1次
//        longpressGesutre.numberOfTouchesRequired = 1
//        self.view.addGestureRecognizer(longpressGesutre)
        addLongPressGes()
        
        
        view.backgroundColor = .white
        super.viewDidLoad()
        
        
        
        testImage = UIImageView()
        self.view.addSubview(testImage);
        testImage.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview().offset(-100)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.9)
            make.height.equalToSuperview().multipliedBy(0.7)
        }
//        testImage.image = UIImage(named: "DSC_0775")
        testImage.clipsToBounds = true
        testImage.contentMode = .scaleAspectFit
        testImage.layer.cornerRadius = 10
        
        
        let albumButton = UIButton()
        self.view.addSubview(albumButton)
        albumButton.snp.makeConstraints { (make) in
            make.width.equalTo(testImage).dividedBy(2).offset(-5)
//            make.centerX.equalToSuperview()
            make.left.equalTo(testImage)
            make.top.equalTo(testImage.snp.bottom).offset(10)
            make.height.equalTo(50)
        }

//        albumButton.backgroundColor = #colorLiteral(red: 0.8417847157, green: 0.8507048488, blue: 0.8811554909, alpha: 1)
        albumButton.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.8470588235)
        albumButton.setTitle("相册", for: UIControl.State())
        albumButton.addTarget(self, action: #selector(self.demoClicked), for: .touchUpInside)
        albumButton.layer.cornerRadius = 10
        
        let camButton = UIButton()
        self.view.addSubview(camButton)
        camButton.snp.makeConstraints { (make) in
            make.width.equalTo(testImage).dividedBy(2).offset(-5)
            make.right.equalTo(testImage)
            make.top.equalTo(testImage.snp.bottom).offset(10)
            make.height.equalTo(50)
        }

//        camButton.backgroundColor = #colorLiteral(red: 0.8417847157, green: 0.8507048488, blue: 0.8811554909, alpha: 1)
        camButton.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.8470588235)
        camButton.setTitle("拍照", for: UIControl.State())
        camButton.addTarget(self, action: #selector(self.demoCameera), for: .touchUpInside)
        camButton.layer.cornerRadius = 10
        
        
        let changeButton = UIButton.init(type: .custom)
        self.view.addSubview(changeButton)
        changeButton.snp.makeConstraints { (make) in
            make.width.equalTo(testImage)
            make.centerX.equalToSuperview()
            make.top.equalTo(camButton.snp.bottom).offset(10)
            make.height.equalTo(50)
        }
//        changeButton.frame = CGRect(x: 20, y: nextViewButton.frame.size.height + nextViewButton.frame.origin.y + 20, width: self.view.bounds.size.width - 40, height: 50)
//        changeButton.backgroundColor =  #colorLiteral(red: 0.8417847157, green: 0.8507048488, blue: 0.8811554909, alpha: 1)
        changeButton.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.8470588235)
        changeButton.setTitle("切换", for: UIControl.State())
//        changeButton.addTarget(self, action: #selector(CBController.startColorBlinds), for: .touchUpInside)
        changeButton.addTarget(self, action: #selector(httpConvert), for: .touchUpInside)
        changeButton.layer.cornerRadius = 10
        
        let nextViewButton = UIButton()
        self.view.addSubview(nextViewButton)
        nextViewButton.snp.makeConstraints { (make) in
            make.width.equalTo(testImage)
            make.centerX.equalToSuperview()
            make.top.equalTo(changeButton.snp.bottom).offset(10)
            make.height.equalTo(50)
        }
//        nextViewButton.frame = CGRect(x: 20, y: testImage.frame.size.height + testImage.frame.origin.y + 20, width: self.view.bounds.size.width - 40, height: 50)
//        nextViewButton.backgroundColor = #colorLiteral(red: 0.8417847157, green: 0.8507048488, blue: 0.8811554909, alpha: 1)
        nextViewButton.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.8470588235)
        nextViewButton.setTitle("返回菜单", for: UIControl.State())
        nextViewButton.addTarget(self, action: #selector(self.nextView), for: .touchUpInside)
        nextViewButton.layer.cornerRadius = 10
        
        
    }
    
    @objc func nextView() {
        dismiss(animated: true, completion: nil)
    }
    @objc func httpConvert() {
        
        let urls:String = "http://121.40.64.188:5100/iosTest/"
        //参数
//        let parameters:Dictionary = ["type":"1","name":"customer","password":"123456"]

//        let imgData = getStrFromImage("DSC_0775")
        let imgData = getStrFromImage(testImage.image!)
//        let imgData = testImage.image?.pngData()?.base64EncodedString()
        
        let parameters: [String: [String]] = [
            "imgData": ["\(imgData))"],
            "baz": ["a", "b"],
            "qux": ["x", "y", "z"]
        ]
        //Alamofire 请求实例
        AF.request(URL(string: urls)!, method: .post, parameters: parameters, encoder: JSONParameterEncoder.sortedKeys)
                        .responseString { (responses) in
                            print(responses)
                            let data = responses.data
                            let data_error:Data! = UIImage(named: "DSC_0775")?.pngData()
//                            let
                            let res: UIImage! = UIImage(data: data ?? data_error)
                            self.testImage.image = res
//                            self.testImage.contentMode = .scaleAspectFit
                            
        }
                            }
    //MARK:- 🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟
    @objc func demoCameera(){
        openCamera()
    }
    
    @objc func demoClicked(){
        openAlbum()
    }
    
    //打开相册
    
    func openAlbum(){
        //判断设置是否支持图片库
        
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary){
            //初始化图片控制器
            let picker = UIImagePickerController()
            //设置代理
            picker.delegate = self
            //指定图片控制器类型
            picker.sourceType = UIImagePickerController.SourceType.photoLibrary
            //设置是否允许编辑
            
            picker.allowsEditing = true
            
            
            //弹出控制器，显示界面
            self.present(picker, animated:true, completion: {
                () -> Void in
            })
        }else{
            print("读取相册错误")
        }
        
    }
    
    
    
    func openCamera(){
        if UIImagePickerController.isSourceTypeAvailable(.camera){
            
            //创建图片控制器
            let picker = UIImagePickerController()
            //设置代理
            picker.delegate = self
            //设置来源
            picker.sourceType = UIImagePickerController.SourceType.camera
            //允许编辑
            picker.allowsEditing = true
            
//            picker.mediaTypes
            //打开相机
            self.present(picker, animated:true, completion: { () -> Void in})
            
        }else{
            debugPrint("找不到相机")
            
        }
        
    }
    //MARK:- 🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            self.testImage.image = image


        } else if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            self.testImage.image = image

        }
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    //保存图片
    @objc func savedPhotosAlbum(image: UIImage, didFinishSavingWithError error: NSError?, contextInfo: AnyObject) {
        
        if error != nil {
            print("save failed")
        } else {
            print("save succeed")

        }
    }
    //MARK:- ✨手势长按
    func addLongPressGes() {
        //添加长按手势
        let longPressGes = UILongPressGestureRecognizer(target: self, action: #selector(longPressedGesture(recognizer:)))
        longPressGes.minimumPressDuration = 1
        //一定要遵循代理
        longPressGes.delegate = self
//        longpressGes.minimumPressDuration = 1
        self.view.addGestureRecognizer(longPressGes)


    }
    
    @objc func longPressedGesture(recognizer: UILongPressGestureRecognizer) {
        let alertV = UIAlertController()
        let saveAction = UIAlertAction(title: "保存图片", style: .default) { (alertV) in
            UIImageWriteToSavedPhotosAlbum(self.testImage.image!, self, #selector(self.savedPhotosAlbum), nil)
        }
        //取消保存不作处理
        let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        
        alertV.addAction(saveAction)
        alertV.addAction(cancelAction)
        self.present(alertV, animated: true, completion: nil)
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    



}

//不实现该代理方法,长按无效
//MARK: 手势代理方法
extension colorRestoreVC : UIGestureRecognizerDelegate{
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}

 
extension UIImage {
    // 修复图片旋转
    func fixOrientation() -> UIImage {
        if self.imageOrientation == .up {
            return self
        }
         
        var transform = CGAffineTransform.identity
         
        switch self.imageOrientation {
        case .down, .downMirrored:
            transform = transform.translatedBy(x: self.size.width, y: self.size.height)
            transform = transform.rotated(by: .pi)
            break
             
        case .left, .leftMirrored:
            transform = transform.translatedBy(x: self.size.width, y: 0)
            transform = transform.rotated(by: .pi / 2)
            break
             
        case .right, .rightMirrored:
            transform = transform.translatedBy(x: 0, y: self.size.height)
            transform = transform.rotated(by: -.pi / 2)
            break
             
        default:
            break
        }
         
        switch self.imageOrientation {
        case .upMirrored, .downMirrored:
            transform = transform.translatedBy(x: self.size.width, y: 0)
            transform = transform.scaledBy(x: -1, y: 1)
            break
             
        case .leftMirrored, .rightMirrored:
            transform = transform.translatedBy(x: self.size.height, y: 0);
            transform = transform.scaledBy(x: -1, y: 1)
            break
             
        default:
            break
        }
         
        let ctx = CGContext(data: nil, width: Int(self.size.width), height: Int(self.size.height), bitsPerComponent: self.cgImage!.bitsPerComponent, bytesPerRow: 0, space: self.cgImage!.colorSpace!, bitmapInfo: self.cgImage!.bitmapInfo.rawValue)
        ctx?.concatenate(transform)
         
        switch self.imageOrientation {
        case .left, .leftMirrored, .right, .rightMirrored:
            ctx?.draw(self.cgImage!, in: CGRect(x: CGFloat(0), y: CGFloat(0), width: CGFloat(size.height), height: CGFloat(size.width)))
            break
             
        default:
            ctx?.draw(self.cgImage!, in: CGRect(x: CGFloat(0), y: CGFloat(0), width: CGFloat(size.width), height: CGFloat(size.height)))
            break
        }
         
        let cgimg: CGImage = (ctx?.makeImage())!
        let img = UIImage(cgImage: cgimg)
         
        return img
    }
}
//
//  colorRestoreVC.swift
//  Colorful
//
//  Created by fox on 2021/10/4.
//  Copyright © 2021 fox. All rights reserved.
//

import Foundation
import UIKit
import CoreGraphics
import QuartzCore
import AVFoundation
import Alamofire
import SnapKit

typealias CGGammaValue = Float
typealias CGDirectDisplayID = UInt32

@available(iOS 11.0, *)
class colorRestoreVC: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate,UIActionSheetDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    var screenshot: UIImage!
    var imageOverlay: UIImageView!
    var timer: Timer!
    var mainWindow: UIWindow!
    var colorMode: ColorBlindType!
    
    var testImage: UIImageView!
    
    
    override func viewDidAppear(_ animated: Bool) {
        mainWindow = self.view.window

    }
    
    override func viewDidLoad() {
        
//        let longpressGesutre = UILongPressGestureRecognizer(target: self, action: Selector(("handleLongpressGesture:")))
//        //长按时间为1秒
//        longpressGesutre.minimumPressDuration = 1
//        //允许15秒运动
//        longpressGesutre.allowableMovement = 15
//        //所需触摸1次
//        longpressGesutre.numberOfTouchesRequired = 1
//        self.view.addGestureRecognizer(longpressGesutre)
        addLongPressGes()
        
        
        view.backgroundColor = .white
        super.viewDidLoad()
        
        
        
        testImage = UIImageView()
        self.view.addSubview(testImage);
        testImage.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview().offset(-100)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.9)
            make.height.equalToSuperview().multipliedBy(0.7)
        }
//        testImage.image = UIImage(named: "DSC_0775")
        testImage.clipsToBounds = true
        testImage.contentMode = .scaleAspectFit
        testImage.layer.cornerRadius = 10
        
        
        let albumButton = UIButton()
        self.view.addSubview(albumButton)
        albumButton.snp.makeConstraints { (make) in
            make.width.equalTo(testImage).dividedBy(2).offset(-5)
//            make.centerX.equalToSuperview()
            make.left.equalTo(testImage)
            make.top.equalTo(testImage.snp.bottom).offset(10)
            make.height.equalTo(50)
        }

//        albumButton.backgroundColor = #colorLiteral(red: 0.8417847157, green: 0.8507048488, blue: 0.8811554909, alpha: 1)
        albumButton.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.8470588235)
        albumButton.setTitle("相册", for: UIControl.State())
        albumButton.addTarget(self, action: #selector(self.demoClicked), for: .touchUpInside)
        albumButton.layer.cornerRadius = 10
        
        let camButton = UIButton()
        self.view.addSubview(camButton)
        camButton.snp.makeConstraints { (make) in
            make.width.equalTo(testImage).dividedBy(2).offset(-5)
            make.right.equalTo(testImage)
            make.top.equalTo(testImage.snp.bottom).offset(10)
            make.height.equalTo(50)
        }

//        camButton.backgroundColor = #colorLiteral(red: 0.8417847157, green: 0.8507048488, blue: 0.8811554909, alpha: 1)
        camButton.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.8470588235)
        camButton.setTitle("拍照", for: UIControl.State())
        camButton.addTarget(self, action: #selector(self.demoCameera), for: .touchUpInside)
        camButton.layer.cornerRadius = 10
        
        
        let changeButton = UIButton.init(type: .custom)
        self.view.addSubview(changeButton)
        changeButton.snp.makeConstraints { (make) in
            make.width.equalTo(testImage)
            make.centerX.equalToSuperview()
            make.top.equalTo(camButton.snp.bottom).offset(10)
            make.height.equalTo(50)
        }
//        changeButton.frame = CGRect(x: 20, y: nextViewButton.frame.size.height + nextViewButton.frame.origin.y + 20, width: self.view.bounds.size.width - 40, height: 50)
//        changeButton.backgroundColor =  #colorLiteral(red: 0.8417847157, green: 0.8507048488, blue: 0.8811554909, alpha: 1)
        changeButton.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.8470588235)
        changeButton.setTitle("切换", for: UIControl.State())
//        changeButton.addTarget(self, action: #selector(CBController.startColorBlinds), for: .touchUpInside)
        changeButton.addTarget(self, action: #selector(httpConvert), for: .touchUpInside)
        changeButton.layer.cornerRadius = 10
        
        let nextViewButton = UIButton()
        self.view.addSubview(nextViewButton)
        nextViewButton.snp.makeConstraints { (make) in
            make.width.equalTo(testImage)
            make.centerX.equalToSuperview()
            make.top.equalTo(changeButton.snp.bottom).offset(10)
            make.height.equalTo(50)
        }
//        nextViewButton.frame = CGRect(x: 20, y: testImage.frame.size.height + testImage.frame.origin.y + 20, width: self.view.bounds.size.width - 40, height: 50)
//        nextViewButton.backgroundColor = #colorLiteral(red: 0.8417847157, green: 0.8507048488, blue: 0.8811554909, alpha: 1)
        nextViewButton.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.8470588235)
        nextViewButton.setTitle("返回菜单", for: UIControl.State())
        nextViewButton.addTarget(self, action: #selector(self.nextView), for: .touchUpInside)
        nextViewButton.layer.cornerRadius = 10
        
        
    }
    
    @objc func nextView() {
        dismiss(animated: true, completion: nil)
    }
    @objc func httpConvert() {
        
        let urls:String = "http://121.40.64.188:5100/iosTest/"
        //参数
//        let parameters:Dictionary = ["type":"1","name":"customer","password":"123456"]

//        let imgData = getStrFromImage("DSC_0775")
        let imgData = getStrFromImage(testImage.image!)
//        let imgData = testImage.image?.pngData()?.base64EncodedString()
        
        let parameters: [String: [String]] = [
            "imgData": ["\(imgData))"],
            "baz": ["a", "b"],
            "qux": ["x", "y", "z"]
        ]
        //Alamofire 请求实例
        AF.request(URL(string: urls)!, method: .post, parameters: parameters, encoder: JSONParameterEncoder.sortedKeys)
                        .responseString { (responses) in
                            print(responses)
                            let data = responses.data
                            let data_error:Data! = UIImage(named: "DSC_0775")?.pngData()
//                            let
                            let res: UIImage! = UIImage(data: data ?? data_error)
                            self.testImage.image = res
//                            self.testImage.contentMode = .scaleAspectFit
                            
        }
                            }
    //MARK:- 🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟
    @objc func demoCameera(){
        openCamera()
    }
    
    @objc func demoClicked(){
        openAlbum()
    }
    
    //打开相册
    
    func openAlbum(){
        //判断设置是否支持图片库
        
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary){
            //初始化图片控制器
            let picker = UIImagePickerController()
            //设置代理
            picker.delegate = self
            //指定图片控制器类型
            picker.sourceType = UIImagePickerController.SourceType.photoLibrary
            //设置是否允许编辑
            
            picker.allowsEditing = true
            
            
            //弹出控制器，显示界面
            self.present(picker, animated:true, completion: {
                () -> Void in
            })
        }else{
            print("读取相册错误")
        }
        
    }
    
    
    
    func openCamera(){
        if UIImagePickerController.isSourceTypeAvailable(.camera){
            
            //创建图片控制器
            let picker = UIImagePickerController()
            //设置代理
            picker.delegate = self
            //设置来源
            picker.sourceType = UIImagePickerController.SourceType.camera
            //允许编辑
            picker.allowsEditing = true
            
//            picker.mediaTypes
            //打开相机
            self.present(picker, animated:true, completion: { () -> Void in})
            
        }else{
            debugPrint("找不到相机")
            
        }
        
    }
    //MARK:- 🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            self.testImage.image = image


        } else if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            self.testImage.image = image

        }
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    //保存图片
    @objc func savedPhotosAlbum(image: UIImage, didFinishSavingWithError error: NSError?, contextInfo: AnyObject) {
        
        if error != nil {
            print("save failed")
        } else {
            print("save succeed")

        }
    }
    //MARK:- ✨手势长按
    func addLongPressGes() {
        //添加长按手势
        let longPressGes = UILongPressGestureRecognizer(target: self, action: #selector(longPressedGesture(recognizer:)))
        longPressGes.minimumPressDuration = 1
        //一定要遵循代理
        longPressGes.delegate = self
//        longpressGes.minimumPressDuration = 1
        self.view.addGestureRecognizer(longPressGes)


    }
    
    @objc func longPressedGesture(recognizer: UILongPressGestureRecognizer) {
        let alertV = UIAlertController()
        let saveAction = UIAlertAction(title: "保存图片", style: .default) { (alertV) in
            UIImageWriteToSavedPhotosAlbum(self.testImage.image!, self, #selector(self.savedPhotosAlbum), nil)
        }
        //取消保存不作处理
        let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        
        alertV.addAction(saveAction)
        alertV.addAction(cancelAction)
        self.present(alertV, animated: true, completion: nil)
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    



}

//不实现该代理方法,长按无效
//MARK: 手势代理方法
extension colorRestoreVC : UIGestureRecognizerDelegate{
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}

 
extension UIImage {
    // 修复图片旋转
    func fixOrientation() -> UIImage {
        if self.imageOrientation == .up {
            return self
        }
         
        var transform = CGAffineTransform.identity
         
        switch self.imageOrientation {
        case .down, .downMirrored:
            transform = transform.translatedBy(x: self.size.width, y: self.size.height)
            transform = transform.rotated(by: .pi)
            break
             
        case .left, .leftMirrored:
            transform = transform.translatedBy(x: self.size.width, y: 0)
            transform = transform.rotated(by: .pi / 2)
            break
             
        case .right, .rightMirrored:
            transform = transform.translatedBy(x: 0, y: self.size.height)
            transform = transform.rotated(by: -.pi / 2)
            break
             
        default:
            break
        }
         
        switch self.imageOrientation {
        case .upMirrored, .downMirrored:
            transform = transform.translatedBy(x: self.size.width, y: 0)
            transform = transform.scaledBy(x: -1, y: 1)
            break
             
        case .leftMirrored, .rightMirrored:
            transform = transform.translatedBy(x: self.size.height, y: 0);
            transform = transform.scaledBy(x: -1, y: 1)
            break
             
        default:
            break
        }
         
        let ctx = CGContext(data: nil, width: Int(self.size.width), height: Int(self.size.height), bitsPerComponent: self.cgImage!.bitsPerComponent, bytesPerRow: 0, space: self.cgImage!.colorSpace!, bitmapInfo: self.cgImage!.bitmapInfo.rawValue)
        ctx?.concatenate(transform)
         
        switch self.imageOrientation {
        case .left, .leftMirrored, .right, .rightMirrored:
            ctx?.draw(self.cgImage!, in: CGRect(x: CGFloat(0), y: CGFloat(0), width: CGFloat(size.height), height: CGFloat(size.width)))
            break
             
        default:
            ctx?.draw(self.cgImage!, in: CGRect(x: CGFloat(0), y: CGFloat(0), width: CGFloat(size.width), height: CGFloat(size.height)))
            break
        }
         
        let cgimg: CGImage = (ctx?.makeImage())!
        let img = UIImage(cgImage: cgimg)
         
        return img
    }
}
//
//  colorRestoreVC.swift
//  Colorful
//
//  Created by fox on 2021/10/4.
//  Copyright © 2021 fox. All rights reserved.
//

import Foundation
import UIKit
import CoreGraphics
import QuartzCore
import AVFoundation
import Alamofire
import SnapKit

typealias CGGammaValue = Float
typealias CGDirectDisplayID = UInt32

@available(iOS 11.0, *)
class colorRestoreVC: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate,UIActionSheetDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    var screenshot: UIImage!
    var imageOverlay: UIImageView!
    var timer: Timer!
    var mainWindow: UIWindow!
    var colorMode: ColorBlindType!
    
    var testImage: UIImageView!
    
    
    override func viewDidAppear(_ animated: Bool) {
        mainWindow = self.view.window

    }
    
    override func viewDidLoad() {
        
//        let longpressGesutre = UILongPressGestureRecognizer(target: self, action: Selector(("handleLongpressGesture:")))
//        //长按时间为1秒
//        longpressGesutre.minimumPressDuration = 1
//        //允许15秒运动
//        longpressGesutre.allowableMovement = 15
//        //所需触摸1次
//        longpressGesutre.numberOfTouchesRequired = 1
//        self.view.addGestureRecognizer(longpressGesutre)
        addLongPressGes()
        
        
        view.backgroundColor = .white
        super.viewDidLoad()
        
        
        
        testImage = UIImageView()
        self.view.addSubview(testImage);
        testImage.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview().offset(-100)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.9)
            make.height.equalToSuperview().multipliedBy(0.7)
        }
//        testImage.image = UIImage(named: "DSC_0775")
        testImage.clipsToBounds = true
        testImage.contentMode = .scaleAspectFit
        testImage.layer.cornerRadius = 10
        
        
        let albumButton = UIButton()
        self.view.addSubview(albumButton)
        albumButton.snp.makeConstraints { (make) in
            make.width.equalTo(testImage).dividedBy(2).offset(-5)
//            make.centerX.equalToSuperview()
            make.left.equalTo(testImage)
            make.top.equalTo(testImage.snp.bottom).offset(10)
            make.height.equalTo(50)
        }

//        albumButton.backgroundColor = #colorLiteral(red: 0.8417847157, green: 0.8507048488, blue: 0.8811554909, alpha: 1)
        albumButton.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.8470588235)
        albumButton.setTitle("相册", for: UIControl.State())
        albumButton.addTarget(self, action: #selector(self.demoClicked), for: .touchUpInside)
        albumButton.layer.cornerRadius = 10
        
        let camButton = UIButton()
        self.view.addSubview(camButton)
        camButton.snp.makeConstraints { (make) in
            make.width.equalTo(testImage).dividedBy(2).offset(-5)
            make.right.equalTo(testImage)
            make.top.equalTo(testImage.snp.bottom).offset(10)
            make.height.equalTo(50)
        }

//        camButton.backgroundColor = #colorLiteral(red: 0.8417847157, green: 0.8507048488, blue: 0.8811554909, alpha: 1)
        camButton.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.8470588235)
        camButton.setTitle("拍照", for: UIControl.State())
        camButton.addTarget(self, action: #selector(self.demoCameera), for: .touchUpInside)
        camButton.layer.cornerRadius = 10
        
        
        let changeButton = UIButton.init(type: .custom)
        self.view.addSubview(changeButton)
        changeButton.snp.makeConstraints { (make) in
            make.width.equalTo(testImage)
            make.centerX.equalToSuperview()
            make.top.equalTo(camButton.snp.bottom).offset(10)
            make.height.equalTo(50)
        }
//        changeButton.frame = CGRect(x: 20, y: nextViewButton.frame.size.height + nextViewButton.frame.origin.y + 20, width: self.view.bounds.size.width - 40, height: 50)
//        changeButton.backgroundColor =  #colorLiteral(red: 0.8417847157, green: 0.8507048488, blue: 0.8811554909, alpha: 1)
        changeButton.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.8470588235)
        changeButton.setTitle("切换", for: UIControl.State())
//        changeButton.addTarget(self, action: #selector(CBController.startColorBlinds), for: .touchUpInside)
        changeButton.addTarget(self, action: #selector(httpConvert), for: .touchUpInside)
        changeButton.layer.cornerRadius = 10
        
        let nextViewButton = UIButton()
        self.view.addSubview(nextViewButton)
        nextViewButton.snp.makeConstraints { (make) in
            make.width.equalTo(testImage)
            make.centerX.equalToSuperview()
            make.top.equalTo(changeButton.snp.bottom).offset(10)
            make.height.equalTo(50)
        }
//        nextViewButton.frame = CGRect(x: 20, y: testImage.frame.size.height + testImage.frame.origin.y + 20, width: self.view.bounds.size.width - 40, height: 50)
//        nextViewButton.backgroundColor = #colorLiteral(red: 0.8417847157, green: 0.8507048488, blue: 0.8811554909, alpha: 1)
        nextViewButton.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.8470588235)
        nextViewButton.setTitle("返回菜单", for: UIControl.State())
        nextViewButton.addTarget(self, action: #selector(self.nextView), for: .touchUpInside)
        nextViewButton.layer.cornerRadius = 10
        
        
    }
    
    @objc func nextView() {
        dismiss(animated: true, completion: nil)
    }
    @objc func httpConvert() {
        
        let urls:String = "http://121.40.64.188:5100/iosTest/"
        //参数
//        let parameters:Dictionary = ["type":"1","name":"customer","password":"123456"]

//        let imgData = getStrFromImage("DSC_0775")
        let imgData = getStrFromImage(testImage.image!)
//        let imgData = testImage.image?.pngData()?.base64EncodedString()
        
        let parameters: [String: [String]] = [
            "imgData": ["\(imgData))"],
            "baz": ["a", "b"],
            "qux": ["x", "y", "z"]
        ]
        //Alamofire 请求实例
        AF.request(URL(string: urls)!, method: .post, parameters: parameters, encoder: JSONParameterEncoder.sortedKeys)
                        .responseString { (responses) in
                            print(responses)
                            let data = responses.data
                            let data_error:Data! = UIImage(named: "DSC_0775")?.pngData()
//                            let
                            let res: UIImage! = UIImage(data: data ?? data_error)
                            self.testImage.image = res
//                            self.testImage.contentMode = .scaleAspectFit
                            
        }
                            }
    //MARK:- 🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟
    @objc func demoCameera(){
        openCamera()
    }
    
    @objc func demoClicked(){
        openAlbum()
    }
    
    //打开相册
    
    func openAlbum(){
        //判断设置是否支持图片库
        
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary){
            //初始化图片控制器
            let picker = UIImagePickerController()
            //设置代理
            picker.delegate = self
            //指定图片控制器类型
            picker.sourceType = UIImagePickerController.SourceType.photoLibrary
            //设置是否允许编辑
            
            picker.allowsEditing = true
            
            
            //弹出控制器，显示界面
            self.present(picker, animated:true, completion: {
                () -> Void in
            })
        }else{
            print("读取相册错误")
        }
        
    }
    
    
    
    func openCamera(){
        if UIImagePickerController.isSourceTypeAvailable(.camera){
            
            //创建图片控制器
            let picker = UIImagePickerController()
            //设置代理
            picker.delegate = self
            //设置来源
            picker.sourceType = UIImagePickerController.SourceType.camera
            //允许编辑
            picker.allowsEditing = true
            
//            picker.mediaTypes
            //打开相机
            self.present(picker, animated:true, completion: { () -> Void in})
            
        }else{
            debugPrint("找不到相机")
            
        }
        
    }
    //MARK:- 🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            self.testImage.image = image


        } else if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            self.testImage.image = image

        }
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    //保存图片
    @objc func savedPhotosAlbum(image: UIImage, didFinishSavingWithError error: NSError?, contextInfo: AnyObject) {
        
        if error != nil {
            print("save failed")
        } else {
            print("save succeed")

        }
    }
    //MARK:- ✨手势长按
    func addLongPressGes() {
        //添加长按手势
        let longPressGes = UILongPressGestureRecognizer(target: self, action: #selector(longPressedGesture(recognizer:)))
        longPressGes.minimumPressDuration = 1
        //一定要遵循代理
        longPressGes.delegate = self
//        longpressGes.minimumPressDuration = 1
        self.view.addGestureRecognizer(longPressGes)


    }
    
    @objc func longPressedGesture(recognizer: UILongPressGestureRecognizer) {
        let alertV = UIAlertController()
        let saveAction = UIAlertAction(title: "保存图片", style: .default) { (alertV) in
            UIImageWriteToSavedPhotosAlbum(self.testImage.image!, self, #selector(self.savedPhotosAlbum), nil)
        }
        //取消保存不作处理
        let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        
        alertV.addAction(saveAction)
        alertV.addAction(cancelAction)
        self.present(alertV, animated: true, completion: nil)
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    



}

//不实现该代理方法,长按无效
//MARK: 手势代理方法
extension colorRestoreVC : UIGestureRecognizerDelegate{
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}

 
extension UIImage {
    // 修复图片旋转
    func fixOrientation() -> UIImage {
        if self.imageOrientation == .up {
            return self
        }
         
        var transform = CGAffineTransform.identity
         
        switch self.imageOrientation {
        case .down, .downMirrored:
            transform = transform.translatedBy(x: self.size.width, y: self.size.height)
            transform = transform.rotated(by: .pi)
            break
             
        case .left, .leftMirrored:
            transform = transform.translatedBy(x: self.size.width, y: 0)
            transform = transform.rotated(by: .pi / 2)
            break
             
        case .right, .rightMirrored:
            transform = transform.translatedBy(x: 0, y: self.size.height)
            transform = transform.rotated(by: -.pi / 2)
            break
             
        default:
            break
        }
         
        switch self.imageOrientation {
        case .upMirrored, .downMirrored:
            transform = transform.translatedBy(x: self.size.width, y: 0)
            transform = transform.scaledBy(x: -1, y: 1)
            break
             
        case .leftMirrored, .rightMirrored:
            transform = transform.translatedBy(x: self.size.height, y: 0);
            transform = transform.scaledBy(x: -1, y: 1)
            break
             
        default:
            break
        }
         
        let ctx = CGContext(data: nil, width: Int(self.size.width), height: Int(self.size.height), bitsPerComponent: self.cgImage!.bitsPerComponent, bytesPerRow: 0, space: self.cgImage!.colorSpace!, bitmapInfo: self.cgImage!.bitmapInfo.rawValue)
        ctx?.concatenate(transform)
         
        switch self.imageOrientation {
        case .left, .leftMirrored, .right, .rightMirrored:
            ctx?.draw(self.cgImage!, in: CGRect(x: CGFloat(0), y: CGFloat(0), width: CGFloat(size.height), height: CGFloat(size.width)))
            break
             
        default:
            ctx?.draw(self.cgImage!, in: CGRect(x: CGFloat(0), y: CGFloat(0), width: CGFloat(size.width), height: CGFloat(size.height)))
            break
        }
         
        let cgimg: CGImage = (ctx?.makeImage())!
        let img = UIImage(cgImage: cgimg)
         
        return img
    }
}
//
//  colorRestoreVC.swift
//  Colorful
//
//  Created by fox on 2021/10/4.
//  Copyright © 2021 fox. All rights reserved.
//

import Foundation
import UIKit
import CoreGraphics
import QuartzCore
import AVFoundation
import Alamofire
import SnapKit

typealias CGGammaValue = Float
typealias CGDirectDisplayID = UInt32

@available(iOS 11.0, *)
class colorRestoreVC: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate,UIActionSheetDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    var screenshot: UIImage!
    var imageOverlay: UIImageView!
    var timer: Timer!
    var mainWindow: UIWindow!
    var colorMode: ColorBlindType!
    
    var testImage: UIImageView!
    
    
    override func viewDidAppear(_ animated: Bool) {
        mainWindow = self.view.window

    }
    
    override func viewDidLoad() {
        
//        let longpressGesutre = UILongPressGestureRecognizer(target: self, action: Selector(("handleLongpressGesture:")))
//        //长按时间为1秒
//        longpressGesutre.minimumPressDuration = 1
//        //允许15秒运动
//        longpressGesutre.allowableMovement = 15
//        //所需触摸1次
//        longpressGesutre.numberOfTouchesRequired = 1
//        self.view.addGestureRecognizer(longpressGesutre)
        addLongPressGes()
        
        
        view.backgroundColor = .white
        super.viewDidLoad()
        
        
        
        testImage = UIImageView()
        self.view.addSubview(testImage);
        testImage.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview().offset(-100)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.9)
            make.height.equalToSuperview().multipliedBy(0.7)
        }
//        testImage.image = UIImage(named: "DSC_0775")
        testImage.clipsToBounds = true
        testImage.contentMode = .scaleAspectFit
        testImage.layer.cornerRadius = 10
        
        
        let albumButton = UIButton()
        self.view.addSubview(albumButton)
        albumButton.snp.makeConstraints { (make) in
            make.width.equalTo(testImage).dividedBy(2).offset(-5)
//            make.centerX.equalToSuperview()
            make.left.equalTo(testImage)
            make.top.equalTo(testImage.snp.bottom).offset(10)
            make.height.equalTo(50)
        }

//        albumButton.backgroundColor = #colorLiteral(red: 0.8417847157, green: 0.8507048488, blue: 0.8811554909, alpha: 1)
        albumButton.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.8470588235)
        albumButton.setTitle("相册", for: UIControl.State())
        albumButton.addTarget(self, action: #selector(self.demoClicked), for: .touchUpInside)
        albumButton.layer.cornerRadius = 10
        
        let camButton = UIButton()
        self.view.addSubview(camButton)
        camButton.snp.makeConstraints { (make) in
            make.width.equalTo(testImage).dividedBy(2).offset(-5)
            make.right.equalTo(testImage)
            make.top.equalTo(testImage.snp.bottom).offset(10)
            make.height.equalTo(50)
        }

//        camButton.backgroundColor = #colorLiteral(red: 0.8417847157, green: 0.8507048488, blue: 0.8811554909, alpha: 1)
        camButton.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.8470588235)
        camButton.setTitle("拍照", for: UIControl.State())
        camButton.addTarget(self, action: #selector(self.demoCameera), for: .touchUpInside)
        camButton.layer.cornerRadius = 10
        
        
        let changeButton = UIButton.init(type: .custom)
        self.view.addSubview(changeButton)
        changeButton.snp.makeConstraints { (make) in
            make.width.equalTo(testImage)
            make.centerX.equalToSuperview()
            make.top.equalTo(camButton.snp.bottom).offset(10)
            make.height.equalTo(50)
        }
//        changeButton.frame = CGRect(x: 20, y: nextViewButton.frame.size.height + nextViewButton.frame.origin.y + 20, width: self.view.bounds.size.width - 40, height: 50)
//        changeButton.backgroundColor =  #colorLiteral(red: 0.8417847157, green: 0.8507048488, blue: 0.8811554909, alpha: 1)
        changeButton.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.8470588235)
        changeButton.setTitle("切换", for: UIControl.State())
//        changeButton.addTarget(self, action: #selector(CBController.startColorBlinds), for: .touchUpInside)
        changeButton.addTarget(self, action: #selector(httpConvert), for: .touchUpInside)
        changeButton.layer.cornerRadius = 10
        
        let nextViewButton = UIButton()
        self.view.addSubview(nextViewButton)
        nextViewButton.snp.makeConstraints { (make) in
            make.width.equalTo(testImage)
            make.centerX.equalToSuperview()
            make.top.equalTo(changeButton.snp.bottom).offset(10)
            make.height.equalTo(50)
        }
//        nextViewButton.frame = CGRect(x: 20, y: testImage.frame.size.height + testImage.frame.origin.y + 20, width: self.view.bounds.size.width - 40, height: 50)
//        nextViewButton.backgroundColor = #colorLiteral(red: 0.8417847157, green: 0.8507048488, blue: 0.8811554909, alpha: 1)
        nextViewButton.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.8470588235)
        nextViewButton.setTitle("返回菜单", for: UIControl.State())
        nextViewButton.addTarget(self, action: #selector(self.nextView), for: .touchUpInside)
        nextViewButton.layer.cornerRadius = 10
        
        
    }
    
    @objc func nextView() {
        dismiss(animated: true, completion: nil)
    }
    @objc func httpConvert() {
        
        let urls:String = "http://121.40.64.188:5100/iosTest/"
        //参数
//        let parameters:Dictionary = ["type":"1","name":"customer","password":"123456"]

//        let imgData = getStrFromImage("DSC_0775")
        let imgData = getStrFromImage(testImage.image!)
//        let imgData = testImage.image?.pngData()?.base64EncodedString()
        
        let parameters: [String: [String]] = [
            "imgData": ["\(imgData))"],
            "baz": ["a", "b"],
            "qux": ["x", "y", "z"]
        ]
        //Alamofire 请求实例
        AF.request(URL(string: urls)!, method: .post, parameters: parameters, encoder: JSONParameterEncoder.sortedKeys)
                        .responseString { (responses) in
                            print(responses)
                            let data = responses.data
                            let data_error:Data! = UIImage(named: "DSC_0775")?.pngData()
//                            let
                            let res: UIImage! = UIImage(data: data ?? data_error)
                            self.testImage.image = res
//                            self.testImage.contentMode = .scaleAspectFit
                            
        }
                            }
    //MARK:- 🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟
    @objc func demoCameera(){
        openCamera()
    }
    
    @objc func demoClicked(){
        openAlbum()
    }
    
    //打开相册
    
    func openAlbum(){
        //判断设置是否支持图片库
        
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary){
            //初始化图片控制器
            let picker = UIImagePickerController()
            //设置代理
            picker.delegate = self
            //指定图片控制器类型
            picker.sourceType = UIImagePickerController.SourceType.photoLibrary
            //设置是否允许编辑
            
            picker.allowsEditing = true
            
            
            //弹出控制器，显示界面
            self.present(picker, animated:true, completion: {
                () -> Void in
            })
        }else{
            print("读取相册错误")
        }
        
    }
    
    
    
    func openCamera(){
        if UIImagePickerController.isSourceTypeAvailable(.camera){
            
            //创建图片控制器
            let picker = UIImagePickerController()
            //设置代理
            picker.delegate = self
            //设置来源
            picker.sourceType = UIImagePickerController.SourceType.camera
            //允许编辑
            picker.allowsEditing = true
            
//            picker.mediaTypes
            //打开相机
            self.present(picker, animated:true, completion: { () -> Void in})
            
        }else{
            debugPrint("找不到相机")
            
        }
        
    }
    //MARK:- 🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            self.testImage.image = image


        } else if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            self.testImage.image = image

        }
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    //保存图片
    @objc func savedPhotosAlbum(image: UIImage, didFinishSavingWithError error: NSError?, contextInfo: AnyObject) {
        
        if error != nil {
            print("save failed")
        } else {
            print("save succeed")

        }
    }
    //MARK:- ✨手势长按
    func addLongPressGes() {
        //添加长按手势
        let longPressGes = UILongPressGestureRecognizer(target: self, action: #selector(longPressedGesture(recognizer:)))
        longPressGes.minimumPressDuration = 1
        //一定要遵循代理
        longPressGes.delegate = self
//        longpressGes.minimumPressDuration = 1
        self.view.addGestureRecognizer(longPressGes)


    }
    
    @objc func longPressedGesture(recognizer: UILongPressGestureRecognizer) {
        let alertV = UIAlertController()
        let saveAction = UIAlertAction(title: "保存图片", style: .default) { (alertV) in
            UIImageWriteToSavedPhotosAlbum(self.testImage.image!, self, #selector(self.savedPhotosAlbum), nil)
        }
        //取消保存不作处理
        let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        
        alertV.addAction(saveAction)
        alertV.addAction(cancelAction)
        self.present(alertV, animated: true, completion: nil)
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    



}

//不实现该代理方法,长按无效
//MARK: 手势代理方法
extension colorRestoreVC : UIGestureRecognizerDelegate{
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}

 
extension UIImage {
    // 修复图片旋转
    func fixOrientation() -> UIImage {
        if self.imageOrientation == .up {
            return self
        }
         
        var transform = CGAffineTransform.identity
         
        switch self.imageOrientation {
        case .down, .downMirrored:
            transform = transform.translatedBy(x: self.size.width, y: self.size.height)
            transform = transform.rotated(by: .pi)
            break
             
        case .left, .leftMirrored:
            transform = transform.translatedBy(x: self.size.width, y: 0)
            transform = transform.rotated(by: .pi / 2)
            break
             
        case .right, .rightMirrored:
            transform = transform.translatedBy(x: 0, y: self.size.height)
            transform = transform.rotated(by: -.pi / 2)
            break
             
        default:
            break
        }
         
        switch self.imageOrientation {
        case .upMirrored, .downMirrored:
            transform = transform.translatedBy(x: self.size.width, y: 0)
            transform = transform.scaledBy(x: -1, y: 1)
            break
             
        case .leftMirrored, .rightMirrored:
            transform = transform.translatedBy(x: self.size.height, y: 0);
            transform = transform.scaledBy(x: -1, y: 1)
            break
             
        default:
            break
        }
         
        let ctx = CGContext(data: nil, width: Int(self.size.width), height: Int(self.size.height), bitsPerComponent: self.cgImage!.bitsPerComponent, bytesPerRow: 0, space: self.cgImage!.colorSpace!, bitmapInfo: self.cgImage!.bitmapInfo.rawValue)
        ctx?.concatenate(transform)
         
        switch self.imageOrientation {
        case .left, .leftMirrored, .right, .rightMirrored:
            ctx?.draw(self.cgImage!, in: CGRect(x: CGFloat(0), y: CGFloat(0), width: CGFloat(size.height), height: CGFloat(size.width)))
            break
             
        default:
            ctx?.draw(self.cgImage!, in: CGRect(x: CGFloat(0), y: CGFloat(0), width: CGFloat(size.width), height: CGFloat(size.height)))
            break
        }
         
        let cgimg: CGImage = (ctx?.makeImage())!
        let img = UIImage(cgImage: cgimg)
         
        return img
    }
}
//
//  colorRestoreVC.swift
//  Colorful
//
//  Created by fox on 2021/10/4.
//  Copyright © 2021 fox. All rights reserved.
//

import Foundation
import UIKit
import CoreGraphics
import QuartzCore
import AVFoundation
import Alamofire
import SnapKit

typealias CGGammaValue = Float
typealias CGDirectDisplayID = UInt32

@available(iOS 11.0, *)
class colorRestoreVC: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate,UIActionSheetDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    var screenshot: UIImage!
    var imageOverlay: UIImageView!
    var timer: Timer!
    var mainWindow: UIWindow!
    var colorMode: ColorBlindType!
    
    var testImage: UIImageView!
    
    
    override func viewDidAppear(_ animated: Bool) {
        mainWindow = self.view.window

    }
    
    override func viewDidLoad() {
        
//        let longpressGesutre = UILongPressGestureRecognizer(target: self, action: Selector(("handleLongpressGesture:")))
//        //长按时间为1秒
//        longpressGesutre.minimumPressDuration = 1
//        //允许15秒运动
//        longpressGesutre.allowableMovement = 15
//        //所需触摸1次
//        longpressGesutre.numberOfTouchesRequired = 1
//        self.view.addGestureRecognizer(longpressGesutre)
        addLongPressGes()
        
        
        view.backgroundColor = .white
        super.viewDidLoad()
        
        
        
        testImage = UIImageView()
        self.view.addSubview(testImage);
        testImage.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview().offset(-100)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.9)
            make.height.equalToSuperview().multipliedBy(0.7)
        }
//        testImage.image = UIImage(named: "DSC_0775")
        testImage.clipsToBounds = true
        testImage.contentMode = .scaleAspectFit
        testImage.layer.cornerRadius = 10
        
        
        let albumButton = UIButton()
        self.view.addSubview(albumButton)
        albumButton.snp.makeConstraints { (make) in
            make.width.equalTo(testImage).dividedBy(2).offset(-5)
//            make.centerX.equalToSuperview()
            make.left.equalTo(testImage)
            make.top.equalTo(testImage.snp.bottom).offset(10)
            make.height.equalTo(50)
        }

//        albumButton.backgroundColor = #colorLiteral(red: 0.8417847157, green: 0.8507048488, blue: 0.8811554909, alpha: 1)
        albumButton.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.8470588235)
        albumButton.setTitle("相册", for: UIControl.State())
        albumButton.addTarget(self, action: #selector(self.demoClicked), for: .touchUpInside)
        albumButton.layer.cornerRadius = 10
        
        let camButton = UIButton()
        self.view.addSubview(camButton)
        camButton.snp.makeConstraints { (make) in
            make.width.equalTo(testImage).dividedBy(2).offset(-5)
            make.right.equalTo(testImage)
            make.top.equalTo(testImage.snp.bottom).offset(10)
            make.height.equalTo(50)
        }

//        camButton.backgroundColor = #colorLiteral(red: 0.8417847157, green: 0.8507048488, blue: 0.8811554909, alpha: 1)
        camButton.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.8470588235)
        camButton.setTitle("拍照", for: UIControl.State())
        camButton.addTarget(self, action: #selector(self.demoCameera), for: .touchUpInside)
        camButton.layer.cornerRadius = 10
        
        
        let changeButton = UIButton.init(type: .custom)
        self.view.addSubview(changeButton)
        changeButton.snp.makeConstraints { (make) in
            make.width.equalTo(testImage)
            make.centerX.equalToSuperview()
            make.top.equalTo(camButton.snp.bottom).offset(10)
            make.height.equalTo(50)
        }
//        changeButton.frame = CGRect(x: 20, y: nextViewButton.frame.size.height + nextViewButton.frame.origin.y + 20, width: self.view.bounds.size.width - 40, height: 50)
//        changeButton.backgroundColor =  #colorLiteral(red: 0.8417847157, green: 0.8507048488, blue: 0.8811554909, alpha: 1)
        changeButton.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.8470588235)
        changeButton.setTitle("切换", for: UIControl.State())
//        changeButton.addTarget(self, action: #selector(CBController.startColorBlinds), for: .touchUpInside)
        changeButton.addTarget(self, action: #selector(httpConvert), for: .touchUpInside)
        changeButton.layer.cornerRadius = 10
        
        let nextViewButton = UIButton()
        self.view.addSubview(nextViewButton)
        nextViewButton.snp.makeConstraints { (make) in
            make.width.equalTo(testImage)
            make.centerX.equalToSuperview()
            make.top.equalTo(changeButton.snp.bottom).offset(10)
            make.height.equalTo(50)
        }
//        nextViewButton.frame = CGRect(x: 20, y: testImage.frame.size.height + testImage.frame.origin.y + 20, width: self.view.bounds.size.width - 40, height: 50)
//        nextViewButton.backgroundColor = #colorLiteral(red: 0.8417847157, green: 0.8507048488, blue: 0.8811554909, alpha: 1)
        nextViewButton.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.8470588235)
        nextViewButton.setTitle("返回菜单", for: UIControl.State())
        nextViewButton.addTarget(self, action: #selector(self.nextView), for: .touchUpInside)
        nextViewButton.layer.cornerRadius = 10
        
        
    }
    
    @objc func nextView() {
        dismiss(animated: true, completion: nil)
    }
    @objc func httpConvert() {
        
        let urls:String = "http://121.40.64.188:5100/iosTest/"
        //参数
//        let parameters:Dictionary = ["type":"1","name":"customer","password":"123456"]

//        let imgData = getStrFromImage("DSC_0775")
        let imgData = getStrFromImage(testImage.image!)
//        let imgData = testImage.image?.pngData()?.base64EncodedString()
        
        let parameters: [String: [String]] = [
            "imgData": ["\(imgData))"],
            "baz": ["a", "b"],
            "qux": ["x", "y", "z"]
        ]
        //Alamofire 请求实例
        AF.request(URL(string: urls)!, method: .post, parameters: parameters, encoder: JSONParameterEncoder.sortedKeys)
                        .responseString { (responses) in
                            print(responses)
                            let data = responses.data
                            let data_error:Data! = UIImage(named: "DSC_0775")?.pngData()
//                            let
                            let res: UIImage! = UIImage(data: data ?? data_error)
                            self.testImage.image = res
//                            self.testImage.contentMode = .scaleAspectFit
                            
        }
                            }
    //MARK:- 🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟
    @objc func demoCameera(){
        openCamera()
    }
    
    @objc func demoClicked(){
        openAlbum()
    }
    
    //打开相册
    
    func openAlbum(){
        //判断设置是否支持图片库
        
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary){
            //初始化图片控制器
            let picker = UIImagePickerController()
            //设置代理
            picker.delegate = self
            //指定图片控制器类型
            picker.sourceType = UIImagePickerController.SourceType.photoLibrary
            //设置是否允许编辑
            
            picker.allowsEditing = true
            
            
            //弹出控制器，显示界面
            self.present(picker, animated:true, completion: {
                () -> Void in
            })
        }else{
            print("读取相册错误")
        }
        
    }
    
    
    
    func openCamera(){
        if UIImagePickerController.isSourceTypeAvailable(.camera){
            
            //创建图片控制器
            let picker = UIImagePickerController()
            //设置代理
            picker.delegate = self
            //设置来源
            picker.sourceType = UIImagePickerController.SourceType.camera
            //允许编辑
            picker.allowsEditing = true
            
//            picker.mediaTypes
            //打开相机
            self.present(picker, animated:true, completion: { () -> Void in})
            
        }else{
            debugPrint("找不到相机")
            
        }
        
    }
    //MARK:- 🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            self.testImage.image = image


        } else if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            self.testImage.image = image

        }
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    //保存图片
    @objc func savedPhotosAlbum(image: UIImage, didFinishSavingWithError error: NSError?, contextInfo: AnyObject) {
        
        if error != nil {
            print("save failed")
        } else {
            print("save succeed")

        }
    }
    //MARK:- ✨手势长按
    func addLongPressGes() {
        //添加长按手势
        let longPressGes = UILongPressGestureRecognizer(target: self, action: #selector(longPressedGesture(recognizer:)))
        longPressGes.minimumPressDuration = 1
        //一定要遵循代理
        longPressGes.delegate = self
//        longpressGes.minimumPressDuration = 1
        self.view.addGestureRecognizer(longPressGes)


    }
    
    @objc func longPressedGesture(recognizer: UILongPressGestureRecognizer) {
        let alertV = UIAlertController()
        let saveAction = UIAlertAction(title: "保存图片", style: .default) { (alertV) in
            UIImageWriteToSavedPhotosAlbum(self.testImage.image!, self, #selector(self.savedPhotosAlbum), nil)
        }
        //取消保存不作处理
        let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        
        alertV.addAction(saveAction)
        alertV.addAction(cancelAction)
        self.present(alertV, animated: true, completion: nil)
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    



}

//不实现该代理方法,长按无效
//MARK: 手势代理方法
extension colorRestoreVC : UIGestureRecognizerDelegate{
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}

 
extension UIImage {
    // 修复图片旋转
    func fixOrientation() -> UIImage {
        if self.imageOrientation == .up {
            return self
        }
         
        var transform = CGAffineTransform.identity
         
        switch self.imageOrientation {
        case .down, .downMirrored:
            transform = transform.translatedBy(x: self.size.width, y: self.size.height)
            transform = transform.rotated(by: .pi)
            break
             
        case .left, .leftMirrored:
            transform = transform.translatedBy(x: self.size.width, y: 0)
            transform = transform.rotated(by: .pi / 2)
            break
             
        case .right, .rightMirrored:
            transform = transform.translatedBy(x: 0, y: self.size.height)
            transform = transform.rotated(by: -.pi / 2)
            break
             
        default:
            break
        }
         
        switch self.imageOrientation {
        case .upMirrored, .downMirrored:
            transform = transform.translatedBy(x: self.size.width, y: 0)
            transform = transform.scaledBy(x: -1, y: 1)
            break
             
        case .leftMirrored, .rightMirrored:
            transform = transform.translatedBy(x: self.size.height, y: 0);
            transform = transform.scaledBy(x: -1, y: 1)
            break
             
        default:
            break
        }
         
        let ctx = CGContext(data: nil, width: Int(self.size.width), height: Int(self.size.height), bitsPerComponent: self.cgImage!.bitsPerComponent, bytesPerRow: 0, space: self.cgImage!.colorSpace!, bitmapInfo: self.cgImage!.bitmapInfo.rawValue)
        ctx?.concatenate(transform)
         
        switch self.imageOrientation {
        case .left, .leftMirrored, .right, .rightMirrored:
            ctx?.draw(self.cgImage!, in: CGRect(x: CGFloat(0), y: CGFloat(0), width: CGFloat(size.height), height: CGFloat(size.width)))
            break
             
        default:
            ctx?.draw(self.cgImage!, in: CGRect(x: CGFloat(0), y: CGFloat(0), width: CGFloat(size.width), height: CGFloat(size.height)))
            break
        }
         
        let cgimg: CGImage = (ctx?.makeImage())!
        let img = UIImage(cgImage: cgimg)
         
        return img
    }
}
//
//  colorRestoreVC.swift
//  Colorful
//
//  Created by fox on 2021/10/4.
//  Copyright © 2021 fox. All rights reserved.
//

import Foundation
import UIKit
import CoreGraphics
import QuartzCore
import AVFoundation
import Alamofire
import SnapKit

typealias CGGammaValue = Float
typealias CGDirectDisplayID = UInt32

@available(iOS 11.0, *)
class colorRestoreVC: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate,UIActionSheetDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    var screenshot: UIImage!
    var imageOverlay: UIImageView!
    var timer: Timer!
    var mainWindow: UIWindow!
    var colorMode: ColorBlindType!
    
    var testImage: UIImageView!
    
    
    override func viewDidAppear(_ animated: Bool) {
        mainWindow = self.view.window

    }
    
    override func viewDidLoad() {
        
//        let longpressGesutre = UILongPressGestureRecognizer(target: self, action: Selector(("handleLongpressGesture:")))
//        //长按时间为1秒
//        longpressGesutre.minimumPressDuration = 1
//        //允许15秒运动
//        longpressGesutre.allowableMovement = 15
//        //所需触摸1次
//        longpressGesutre.numberOfTouchesRequired = 1
//        self.view.addGestureRecognizer(longpressGesutre)
        addLongPressGes()
        
        
        view.backgroundColor = .white
        super.viewDidLoad()
        
        
        
        testImage = UIImageView()
        self.view.addSubview(testImage);
        testImage.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview().offset(-100)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.9)
            make.height.equalToSuperview().multipliedBy(0.7)
        }
//        testImage.image = UIImage(named: "DSC_0775")
        testImage.clipsToBounds = true
        testImage.contentMode = .scaleAspectFit
        testImage.layer.cornerRadius = 10
        
        
        let albumButton = UIButton()
        self.view.addSubview(albumButton)
        albumButton.snp.makeConstraints { (make) in
            make.width.equalTo(testImage).dividedBy(2).offset(-5)
//            make.centerX.equalToSuperview()
            make.left.equalTo(testImage)
            make.top.equalTo(testImage.snp.bottom).offset(10)
            make.height.equalTo(50)
        }

//        albumButton.backgroundColor = #colorLiteral(red: 0.8417847157, green: 0.8507048488, blue: 0.8811554909, alpha: 1)
        albumButton.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.8470588235)
        albumButton.setTitle("相册", for: UIControl.State())
        albumButton.addTarget(self, action: #selector(self.demoClicked), for: .touchUpInside)
        albumButton.layer.cornerRadius = 10
        
        let camButton = UIButton()
        self.view.addSubview(camButton)
        camButton.snp.makeConstraints { (make) in
            make.width.equalTo(testImage).dividedBy(2).offset(-5)
            make.right.equalTo(testImage)
            make.top.equalTo(testImage.snp.bottom).offset(10)
            make.height.equalTo(50)
        }

//        camButton.backgroundColor = #colorLiteral(red: 0.8417847157, green: 0.8507048488, blue: 0.8811554909, alpha: 1)
        camButton.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.8470588235)
        camButton.setTitle("拍照", for: UIControl.State())
        camButton.addTarget(self, action: #selector(self.demoCameera), for: .touchUpInside)
        camButton.layer.cornerRadius = 10
        
        
        let changeButton = UIButton.init(type: .custom)
        self.view.addSubview(changeButton)
        changeButton.snp.makeConstraints { (make) in
            make.width.equalTo(testImage)
            make.centerX.equalToSuperview()
            make.top.equalTo(camButton.snp.bottom).offset(10)
            make.height.equalTo(50)
        }
//        changeButton.frame = CGRect(x: 20, y: nextViewButton.frame.size.height + nextViewButton.frame.origin.y + 20, width: self.view.bounds.size.width - 40, height: 50)
//        changeButton.backgroundColor =  #colorLiteral(red: 0.8417847157, green: 0.8507048488, blue: 0.8811554909, alpha: 1)
        changeButton.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.8470588235)
        changeButton.setTitle("切换", for: UIControl.State())
//        changeButton.addTarget(self, action: #selector(CBController.startColorBlinds), for: .touchUpInside)
        changeButton.addTarget(self, action: #selector(httpConvert), for: .touchUpInside)
        changeButton.layer.cornerRadius = 10
        
        let nextViewButton = UIButton()
        self.view.addSubview(nextViewButton)
        nextViewButton.snp.makeConstraints { (make) in
            make.width.equalTo(testImage)
            make.centerX.equalToSuperview()
            make.top.equalTo(changeButton.snp.bottom).offset(10)
            make.height.equalTo(50)
        }
//        nextViewButton.frame = CGRect(x: 20, y: testImage.frame.size.height + testImage.frame.origin.y + 20, width: self.view.bounds.size.width - 40, height: 50)
//        nextViewButton.backgroundColor = #colorLiteral(red: 0.8417847157, green: 0.8507048488, blue: 0.8811554909, alpha: 1)
        nextViewButton.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.8470588235)
        nextViewButton.setTitle("返回菜单", for: UIControl.State())
        nextViewButton.addTarget(self, action: #selector(self.nextView), for: .touchUpInside)
        nextViewButton.layer.cornerRadius = 10
        
        
    }
    
    @objc func nextView() {
        dismiss(animated: true, completion: nil)
    }
    @objc func httpConvert() {
        
        let urls:String = "http://121.40.64.188:5100/iosTest/"
        //参数
//        let parameters:Dictionary = ["type":"1","name":"customer","password":"123456"]

//        let imgData = getStrFromImage("DSC_0775")
        let imgData = getStrFromImage(testImage.image!)
//        let imgData = testImage.image?.pngData()?.base64EncodedString()
        
        let parameters: [String: [String]] = [
            "imgData": ["\(imgData))"],
            "baz": ["a", "b"],
            "qux": ["x", "y", "z"]
        ]
        //Alamofire 请求实例
        AF.request(URL(string: urls)!, method: .post, parameters: parameters, encoder: JSONParameterEncoder.sortedKeys)
                        .responseString { (responses) in
                            print(responses)
                            let data = responses.data
                            let data_error:Data! = UIImage(named: "DSC_0775")?.pngData()
//                            let
                            let res: UIImage! = UIImage(data: data ?? data_error)
                            self.testImage.image = res
//                            self.testImage.contentMode = .scaleAspectFit
                            
        }
                            }
    //MARK:- 🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟
    @objc func demoCameera(){
        openCamera()
    }
    
    @objc func demoClicked(){
        openAlbum()
    }
    
    //打开相册
    
    func openAlbum(){
        //判断设置是否支持图片库
        
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary){
            //初始化图片控制器
            let picker = UIImagePickerController()
            //设置代理
            picker.delegate = self
            //指定图片控制器类型
            picker.sourceType = UIImagePickerController.SourceType.photoLibrary
            //设置是否允许编辑
            
            picker.allowsEditing = true
            
            
            //弹出控制器，显示界面
            self.present(picker, animated:true, completion: {
                () -> Void in
            })
        }else{
            print("读取相册错误")
        }
        
    }
    
    
    
    func openCamera(){
        if UIImagePickerController.isSourceTypeAvailable(.camera){
            
            //创建图片控制器
            let picker = UIImagePickerController()
            //设置代理
            picker.delegate = self
            //设置来源
            picker.sourceType = UIImagePickerController.SourceType.camera
            //允许编辑
            picker.allowsEditing = true
            
//            picker.mediaTypes
            //打开相机
            self.present(picker, animated:true, completion: { () -> Void in})
            
        }else{
            debugPrint("找不到相机")
            
        }
        
    }
    //MARK:- 🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            self.testImage.image = image


        } else if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            self.testImage.image = image

        }
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    //保存图片
    @objc func savedPhotosAlbum(image: UIImage, didFinishSavingWithError error: NSError?, contextInfo: AnyObject) {
        
        if error != nil {
            print("save failed")
        } else {
            print("save succeed")

        }
    }
    //MARK:- ✨手势长按
    func addLongPressGes() {
        //添加长按手势
        let longPressGes = UILongPressGestureRecognizer(target: self, action: #selector(longPressedGesture(recognizer:)))
        longPressGes.minimumPressDuration = 1
        //一定要遵循代理
        longPressGes.delegate = self
//        longpressGes.minimumPressDuration = 1
        self.view.addGestureRecognizer(longPressGes)


    }
    
    @objc func longPressedGesture(recognizer: UILongPressGestureRecognizer) {
        let alertV = UIAlertController()
        let saveAction = UIAlertAction(title: "保存图片", style: .default) { (alertV) in
            UIImageWriteToSavedPhotosAlbum(self.testImage.image!, self, #selector(self.savedPhotosAlbum), nil)
        }
        //取消保存不作处理
        let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        
        alertV.addAction(saveAction)
        alertV.addAction(cancelAction)
        self.present(alertV, animated: true, completion: nil)
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    



}

//不实现该代理方法,长按无效
//MARK: 手势代理方法
extension colorRestoreVC : UIGestureRecognizerDelegate{
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}

 
extension UIImage {
    // 修复图片旋转
    func fixOrientation() -> UIImage {
        if self.imageOrientation == .up {
            return self
        }
         
        var transform = CGAffineTransform.identity
         
        switch self.imageOrientation {
        case .down, .downMirrored:
            transform = transform.translatedBy(x: self.size.width, y: self.size.height)
            transform = transform.rotated(by: .pi)
            break
             
        case .left, .leftMirrored:
            transform = transform.translatedBy(x: self.size.width, y: 0)
            transform = transform.rotated(by: .pi / 2)
            break
             
        case .right, .rightMirrored:
            transform = transform.translatedBy(x: 0, y: self.size.height)
            transform = transform.rotated(by: -.pi / 2)
            break
             
        default:
            break
        }
         
        switch self.imageOrientation {
        case .upMirrored, .downMirrored:
            transform = transform.translatedBy(x: self.size.width, y: 0)
            transform = transform.scaledBy(x: -1, y: 1)
            break
             
        case .leftMirrored, .rightMirrored:
            transform = transform.translatedBy(x: self.size.height, y: 0);
            transform = transform.scaledBy(x: -1, y: 1)
            break
             
        default:
            break
        }
         
        let ctx = CGContext(data: nil, width: Int(self.size.width), height: Int(self.size.height), bitsPerComponent: self.cgImage!.bitsPerComponent, bytesPerRow: 0, space: self.cgImage!.colorSpace!, bitmapInfo: self.cgImage!.bitmapInfo.rawValue)
        ctx?.concatenate(transform)
         
        switch self.imageOrientation {
        case .left, .leftMirrored, .right, .rightMirrored:
            ctx?.draw(self.cgImage!, in: CGRect(x: CGFloat(0), y: CGFloat(0), width: CGFloat(size.height), height: CGFloat(size.width)))
            break
             
        default:
            ctx?.draw(self.cgImage!, in: CGRect(x: CGFloat(0), y: CGFloat(0), width: CGFloat(size.width), height: CGFloat(size.height)))
            break
        }
         
        let cgimg: CGImage = (ctx?.makeImage())!
        let img = UIImage(cgImage: cgimg)
         
        return img
    }
}
//
//  colorRestoreVC.swift
//  Colorful
//
//  Created by fox on 2021/10/4.
//  Copyright © 2021 fox. All rights reserved.
//

import Foundation
import UIKit
import CoreGraphics
import QuartzCore
import AVFoundation
import Alamofire
import SnapKit

typealias CGGammaValue = Float
typealias CGDirectDisplayID = UInt32

@available(iOS 11.0, *)
class colorRestoreVC: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate,UIActionSheetDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    var screenshot: UIImage!
    var imageOverlay: UIImageView!
    var timer: Timer!
    var mainWindow: UIWindow!
    var colorMode: ColorBlindType!
    
    var testImage: UIImageView!
    
    
    override func viewDidAppear(_ animated: Bool) {
        mainWindow = self.view.window

    }
    
    override func viewDidLoad() {
        
//        let longpressGesutre = UILongPressGestureRecognizer(target: self, action: Selector(("handleLongpressGesture:")))
//        //长按时间为1秒
//        longpressGesutre.minimumPressDuration = 1
//        //允许15秒运动
//        longpressGesutre.allowableMovement = 15
//        //所需触摸1次
//        longpressGesutre.numberOfTouchesRequired = 1
//        self.view.addGestureRecognizer(longpressGesutre)
        addLongPressGes()
        
        
        view.backgroundColor = .white
        super.viewDidLoad()
        
        
        
        testImage = UIImageView()
        self.view.addSubview(testImage);
        testImage.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview().offset(-100)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.9)
            make.height.equalToSuperview().multipliedBy(0.7)
        }
//        testImage.image = UIImage(named: "DSC_0775")
        testImage.clipsToBounds = true
        testImage.contentMode = .scaleAspectFit
        testImage.layer.cornerRadius = 10
        
        
        let albumButton = UIButton()
        self.view.addSubview(albumButton)
        albumButton.snp.makeConstraints { (make) in
            make.width.equalTo(testImage).dividedBy(2).offset(-5)
//            make.centerX.equalToSuperview()
            make.left.equalTo(testImage)
            make.top.equalTo(testImage.snp.bottom).offset(10)
            make.height.equalTo(50)
        }

//        albumButton.backgroundColor = #colorLiteral(red: 0.8417847157, green: 0.8507048488, blue: 0.8811554909, alpha: 1)
        albumButton.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.8470588235)
        albumButton.setTitle("相册", for: UIControl.State())
        albumButton.addTarget(self, action: #selector(self.demoClicked), for: .touchUpInside)
        albumButton.layer.cornerRadius = 10
        
        let camButton = UIButton()
        self.view.addSubview(camButton)
        camButton.snp.makeConstraints { (make) in
            make.width.equalTo(testImage).dividedBy(2).offset(-5)
            make.right.equalTo(testImage)
            make.top.equalTo(testImage.snp.bottom).offset(10)
            make.height.equalTo(50)
        }

//        camButton.backgroundColor = #colorLiteral(red: 0.8417847157, green: 0.8507048488, blue: 0.8811554909, alpha: 1)
        camButton.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.8470588235)
        camButton.setTitle("拍照", for: UIControl.State())
        camButton.addTarget(self, action: #selector(self.demoCameera), for: .touchUpInside)
        camButton.layer.cornerRadius = 10
        
        
        let changeButton = UIButton.init(type: .custom)
        self.view.addSubview(changeButton)
        changeButton.snp.makeConstraints { (make) in
            make.width.equalTo(testImage)
            make.centerX.equalToSuperview()
            make.top.equalTo(camButton.snp.bottom).offset(10)
            make.height.equalTo(50)
        }
//        changeButton.frame = CGRect(x: 20, y: nextViewButton.frame.size.height + nextViewButton.frame.origin.y + 20, width: self.view.bounds.size.width - 40, height: 50)
//        changeButton.backgroundColor =  #colorLiteral(red: 0.8417847157, green: 0.8507048488, blue: 0.8811554909, alpha: 1)
        changeButton.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.8470588235)
        changeButton.setTitle("切换", for: UIControl.State())
//        changeButton.addTarget(self, action: #selector(CBController.startColorBlinds), for: .touchUpInside)
        changeButton.addTarget(self, action: #selector(httpConvert), for: .touchUpInside)
        changeButton.layer.cornerRadius = 10
        
        let nextViewButton = UIButton()
        self.view.addSubview(nextViewButton)
        nextViewButton.snp.makeConstraints { (make) in
            make.width.equalTo(testImage)
            make.centerX.equalToSuperview()
            make.top.equalTo(changeButton.snp.bottom).offset(10)
            make.height.equalTo(50)
        }
//        nextViewButton.frame = CGRect(x: 20, y: testImage.frame.size.height + testImage.frame.origin.y + 20, width: self.view.bounds.size.width - 40, height: 50)
//        nextViewButton.backgroundColor = #colorLiteral(red: 0.8417847157, green: 0.8507048488, blue: 0.8811554909, alpha: 1)
        nextViewButton.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.8470588235)
        nextViewButton.setTitle("返回菜单", for: UIControl.State())
        nextViewButton.addTarget(self, action: #selector(self.nextView), for: .touchUpInside)
        nextViewButton.layer.cornerRadius = 10
        
        
    }
    
    @objc func nextView() {
        dismiss(animated: true, completion: nil)
    }
    @objc func httpConvert() {
        
        let urls:String = "http://121.40.64.188:5100/iosTest/"
        //参数
//        let parameters:Dictionary = ["type":"1","name":"customer","password":"123456"]

//        let imgData = getStrFromImage("DSC_0775")
        let imgData = getStrFromImage(testImage.image!)
//        let imgData = testImage.image?.pngData()?.base64EncodedString()
        
        let parameters: [String: [String]] = [
            "imgData": ["\(imgData))"],
            "baz": ["a", "b"],
            "qux": ["x", "y", "z"]
        ]
        //Alamofire 请求实例
        AF.request(URL(string: urls)!, method: .post, parameters: parameters, encoder: JSONParameterEncoder.sortedKeys)
                        .responseString { (responses) in
                            print(responses)
                            let data = responses.data
                            let data_error:Data! = UIImage(named: "DSC_0775")?.pngData()
//                            let
                            let res: UIImage! = UIImage(data: data ?? data_error)
                            self.testImage.image = res
//                            self.testImage.contentMode = .scaleAspectFit
                            
        }
                            }
    //MARK:- 🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟
    @objc func demoCameera(){
        openCamera()
    }
    
    @objc func demoClicked(){
        openAlbum()
    }
    
    //打开相册
    
    func openAlbum(){
        //判断设置是否支持图片库
        
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary){
            //初始化图片控制器
            let picker = UIImagePickerController()
            //设置代理
            picker.delegate = self
            //指定图片控制器类型
            picker.sourceType = UIImagePickerController.SourceType.photoLibrary
            //设置是否允许编辑
            
            picker.allowsEditing = true
            
            
            //弹出控制器，显示界面
            self.present(picker, animated:true, completion: {
                () -> Void in
            })
        }else{
            print("读取相册错误")
        }
        
    }
    
    
    
    func openCamera(){
        if UIImagePickerController.isSourceTypeAvailable(.camera){
            
            //创建图片控制器
            let picker = UIImagePickerController()
            //设置代理
            picker.delegate = self
            //设置来源
            picker.sourceType = UIImagePickerController.SourceType.camera
            //允许编辑
            picker.allowsEditing = true
            
//            picker.mediaTypes
            //打开相机
            self.present(picker, animated:true, completion: { () -> Void in})
            
        }else{
            debugPrint("找不到相机")
            
        }
        
    }
    //MARK:- 🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            self.testImage.image = image


        } else if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            self.testImage.image = image

        }
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    //保存图片
    @objc func savedPhotosAlbum(image: UIImage, didFinishSavingWithError error: NSError?, contextInfo: AnyObject) {
        
        if error != nil {
            print("save failed")
        } else {
            print("save succeed")

        }
    }
    //MARK:- ✨手势长按
    func addLongPressGes() {
        //添加长按手势
        let longPressGes = UILongPressGestureRecognizer(target: self, action: #selector(longPressedGesture(recognizer:)))
        longPressGes.minimumPressDuration = 1
        //一定要遵循代理
        longPressGes.delegate = self
//        longpressGes.minimumPressDuration = 1
        self.view.addGestureRecognizer(longPressGes)


    }
    
    @objc func longPressedGesture(recognizer: UILongPressGestureRecognizer) {
        let alertV = UIAlertController()
        let saveAction = UIAlertAction(title: "保存图片", style: .default) { (alertV) in
            UIImageWriteToSavedPhotosAlbum(self.testImage.image!, self, #selector(self.savedPhotosAlbum), nil)
        }
        //取消保存不作处理
        let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        
        alertV.addAction(saveAction)
        alertV.addAction(cancelAction)
        self.present(alertV, animated: true, completion: nil)
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    



}

//不实现该代理方法,长按无效
//MARK: 手势代理方法
extension colorRestoreVC : UIGestureRecognizerDelegate{
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}

 
extension UIImage {
    // 修复图片旋转
    func fixOrientation() -> UIImage {
        if self.imageOrientation == .up {
            return self
        }
         
        var transform = CGAffineTransform.identity
         
        switch self.imageOrientation {
        case .down, .downMirrored:
            transform = transform.translatedBy(x: self.size.width, y: self.size.height)
            transform = transform.rotated(by: .pi)
            break
             
        case .left, .leftMirrored:
            transform = transform.translatedBy(x: self.size.width, y: 0)
            transform = transform.rotated(by: .pi / 2)
            break
             
        case .right, .rightMirrored:
            transform = transform.translatedBy(x: 0, y: self.size.height)
            transform = transform.rotated(by: -.pi / 2)
            break
             
        default:
            break
        }
         
        switch self.imageOrientation {
        case .upMirrored, .downMirrored:
            transform = transform.translatedBy(x: self.size.width, y: 0)
            transform = transform.scaledBy(x: -1, y: 1)
            break
             
        case .leftMirrored, .rightMirrored:
            transform = transform.translatedBy(x: self.size.height, y: 0);
            transform = transform.scaledBy(x: -1, y: 1)
            break
             
        default:
            break
        }
         
        let ctx = CGContext(data: nil, width: Int(self.size.width), height: Int(self.size.height), bitsPerComponent: self.cgImage!.bitsPerComponent, bytesPerRow: 0, space: self.cgImage!.colorSpace!, bitmapInfo: self.cgImage!.bitmapInfo.rawValue)
        ctx?.concatenate(transform)
         
        switch self.imageOrientation {
        case .left, .leftMirrored, .right, .rightMirrored:
            ctx?.draw(self.cgImage!, in: CGRect(x: CGFloat(0), y: CGFloat(0), width: CGFloat(size.height), height: CGFloat(size.width)))
            break
             
        default:
            ctx?.draw(self.cgImage!, in: CGRect(x: CGFloat(0), y: CGFloat(0), width: CGFloat(size.width), height: CGFloat(size.height)))
            break
        }
         
        let cgimg: CGImage = (ctx?.makeImage())!
        let img = UIImage(cgImage: cgimg)
         
        return img
    }
}
//
//  colorRestoreVC.swift
//  Colorful
//
//  Created by fox on 2021/10/4.
//  Copyright © 2021 fox. All rights reserved.
//

import Foundation
import UIKit
import CoreGraphics
import QuartzCore
import AVFoundation
import Alamofire
import SnapKit

typealias CGGammaValue = Float
typealias CGDirectDisplayID = UInt32

@available(iOS 11.0, *)
class colorRestoreVC: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate,UIActionSheetDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    var screenshot: UIImage!
    var imageOverlay: UIImageView!
    var timer: Timer!
    var mainWindow: UIWindow!
    var colorMode: ColorBlindType!
    
    var testImage: UIImageView!
    
    
    override func viewDidAppear(_ animated: Bool) {
        mainWindow = self.view.window

    }
    
    override func viewDidLoad() {
        
//        let longpressGesutre = UILongPressGestureRecognizer(target: self, action: Selector(("handleLongpressGesture:")))
//        //长按时间为1秒
//        longpressGesutre.minimumPressDuration = 1
//        //允许15秒运动
//        longpressGesutre.allowableMovement = 15
//        //所需触摸1次
//        longpressGesutre.numberOfTouchesRequired = 1
//        self.view.addGestureRecognizer(longpressGesutre)
        addLongPressGes()
        
        
        view.backgroundColor = .white
        super.viewDidLoad()
        
        
        
        testImage = UIImageView()
        self.view.addSubview(testImage);
        testImage.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview().offset(-100)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.9)
            make.height.equalToSuperview().multipliedBy(0.7)
        }
//        testImage.image = UIImage(named: "DSC_0775")
        testImage.clipsToBounds = true
        testImage.contentMode = .scaleAspectFit
        testImage.layer.cornerRadius = 10
        
        
        let albumButton = UIButton()
        self.view.addSubview(albumButton)
        albumButton.snp.makeConstraints { (make) in
            make.width.equalTo(testImage).dividedBy(2).offset(-5)
//            make.centerX.equalToSuperview()
            make.left.equalTo(testImage)
            make.top.equalTo(testImage.snp.bottom).offset(10)
            make.height.equalTo(50)
        }

//        albumButton.backgroundColor = #colorLiteral(red: 0.8417847157, green: 0.8507048488, blue: 0.8811554909, alpha: 1)
        albumButton.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.8470588235)
        albumButton.setTitle("相册", for: UIControl.State())
        albumButton.addTarget(self, action: #selector(self.demoClicked), for: .touchUpInside)
        albumButton.layer.cornerRadius = 10
        
        let camButton = UIButton()
        self.view.addSubview(camButton)
        camButton.snp.makeConstraints { (make) in
            make.width.equalTo(testImage).dividedBy(2).offset(-5)
            make.right.equalTo(testImage)
            make.top.equalTo(testImage.snp.bottom).offset(10)
            make.height.equalTo(50)
        }

//        camButton.backgroundColor = #colorLiteral(red: 0.8417847157, green: 0.8507048488, blue: 0.8811554909, alpha: 1)
        camButton.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.8470588235)
        camButton.setTitle("拍照", for: UIControl.State())
        camButton.addTarget(self, action: #selector(self.demoCameera), for: .touchUpInside)
        camButton.layer.cornerRadius = 10
        
        
        let changeButton = UIButton.init(type: .custom)
        self.view.addSubview(changeButton)
        changeButton.snp.makeConstraints { (make) in
            make.width.equalTo(testImage)
            make.centerX.equalToSuperview()
            make.top.equalTo(camButton.snp.bottom).offset(10)
            make.height.equalTo(50)
        }
//        changeButton.frame = CGRect(x: 20, y: nextViewButton.frame.size.height + nextViewButton.frame.origin.y + 20, width: self.view.bounds.size.width - 40, height: 50)
//        changeButton.backgroundColor =  #colorLiteral(red: 0.8417847157, green: 0.8507048488, blue: 0.8811554909, alpha: 1)
        changeButton.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.8470588235)
        changeButton.setTitle("切换", for: UIControl.State())
//        changeButton.addTarget(self, action: #selector(CBController.startColorBlinds), for: .touchUpInside)
        changeButton.addTarget(self, action: #selector(httpConvert), for: .touchUpInside)
        changeButton.layer.cornerRadius = 10
        
        let nextViewButton = UIButton()
        self.view.addSubview(nextViewButton)
        nextViewButton.snp.makeConstraints { (make) in
            make.width.equalTo(testImage)
            make.centerX.equalToSuperview()
            make.top.equalTo(changeButton.snp.bottom).offset(10)
            make.height.equalTo(50)
        }
//        nextViewButton.frame = CGRect(x: 20, y: testImage.frame.size.height + testImage.frame.origin.y + 20, width: self.view.bounds.size.width - 40, height: 50)
//        nextViewButton.backgroundColor = #colorLiteral(red: 0.8417847157, green: 0.8507048488, blue: 0.8811554909, alpha: 1)
        nextViewButton.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.8470588235)
        nextViewButton.setTitle("返回菜单", for: UIControl.State())
        nextViewButton.addTarget(self, action: #selector(self.nextView), for: .touchUpInside)
        nextViewButton.layer.cornerRadius = 10
        
        
    }
    
    @objc func nextView() {
        dismiss(animated: true, completion: nil)
    }
    @objc func httpConvert() {
        
        let urls:String = "http://121.40.64.188:5100/iosTest/"
        //参数
//        let parameters:Dictionary = ["type":"1","name":"customer","password":"123456"]

//        let imgData = getStrFromImage("DSC_0775")
        let imgData = getStrFromImage(testImage.image!)
//        let imgData = testImage.image?.pngData()?.base64EncodedString()
        
        let parameters: [String: [String]] = [
            "imgData": ["\(imgData))"],
            "baz": ["a", "b"],
            "qux": ["x", "y", "z"]
        ]
        //Alamofire 请求实例
        AF.request(URL(string: urls)!, method: .post, parameters: parameters, encoder: JSONParameterEncoder.sortedKeys)
                        .responseString { (responses) in
                            print(responses)
                            let data = responses.data
                            let data_error:Data! = UIImage(named: "DSC_0775")?.pngData()
//                            let
                            let res: UIImage! = UIImage(data: data ?? data_error)
                            self.testImage.image = res
//                            self.testImage.contentMode = .scaleAspectFit
                            
        }
                            }
    //MARK:- 🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟
    @objc func demoCameera(){
        openCamera()
    }
    
    @objc func demoClicked(){
        openAlbum()
    }
    
    //打开相册
    
    func openAlbum(){
        //判断设置是否支持图片库
        
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary){
            //初始化图片控制器
            let picker = UIImagePickerController()
            //设置代理
            picker.delegate = self
            //指定图片控制器类型
            picker.sourceType = UIImagePickerController.SourceType.photoLibrary
            //设置是否允许编辑
            
            picker.allowsEditing = true
            
            
            //弹出控制器，显示界面
            self.present(picker, animated:true, completion: {
                () -> Void in
            })
        }else{
            print("读取相册错误")
        }
        
    }
    
    
    
    func openCamera(){
        if UIImagePickerController.isSourceTypeAvailable(.camera){
            
            //创建图片控制器
            let picker = UIImagePickerController()
            //设置代理
            picker.delegate = self
            //设置来源
            picker.sourceType = UIImagePickerController.SourceType.camera
            //允许编辑
            picker.allowsEditing = true
            
//            picker.mediaTypes
            //打开相机
            self.present(picker, animated:true, completion: { () -> Void in})
            
        }else{
            debugPrint("找不到相机")
            
        }
        
    }
    //MARK:- 🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            self.testImage.image = image


        } else if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            self.testImage.image = image

        }
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    //保存图片
    @objc func savedPhotosAlbum(image: UIImage, didFinishSavingWithError error: NSError?, contextInfo: AnyObject) {
        
        if error != nil {
            print("save failed")
        } else {
            print("save succeed")

        }
    }
    //MARK:- ✨手势长按
    func addLongPressGes() {
        //添加长按手势
        let longPressGes = UILongPressGestureRecognizer(target: self, action: #selector(longPressedGesture(recognizer:)))
        longPressGes.minimumPressDuration = 1
        //一定要遵循代理
        longPressGes.delegate = self
//        longpressGes.minimumPressDuration = 1
        self.view.addGestureRecognizer(longPressGes)


    }
    
    @objc func longPressedGesture(recognizer: UILongPressGestureRecognizer) {
        let alertV = UIAlertController()
        let saveAction = UIAlertAction(title: "保存图片", style: .default) { (alertV) in
            UIImageWriteToSavedPhotosAlbum(self.testImage.image!, self, #selector(self.savedPhotosAlbum), nil)
        }
        //取消保存不作处理
        let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        
        alertV.addAction(saveAction)
        alertV.addAction(cancelAction)
        self.present(alertV, animated: true, completion: nil)
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    



}

//不实现该代理方法,长按无效
//MARK: 手势代理方法
extension colorRestoreVC : UIGestureRecognizerDelegate{
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}

 
extension UIImage {
    // 修复图片旋转
    func fixOrientation() -> UIImage {
        if self.imageOrientation == .up {
            return self
        }
         
        var transform = CGAffineTransform.identity
         
        switch self.imageOrientation {
        case .down, .downMirrored:
            transform = transform.translatedBy(x: self.size.width, y: self.size.height)
            transform = transform.rotated(by: .pi)
            break
             
        case .left, .leftMirrored:
            transform = transform.translatedBy(x: self.size.width, y: 0)
            transform = transform.rotated(by: .pi / 2)
            break
             
        case .right, .rightMirrored:
            transform = transform.translatedBy(x: 0, y: self.size.height)
            transform = transform.rotated(by: -.pi / 2)
            break
             
        default:
            break
        }
         
        switch self.imageOrientation {
        case .upMirrored, .downMirrored:
            transform = transform.translatedBy(x: self.size.width, y: 0)
            transform = transform.scaledBy(x: -1, y: 1)
            break
             
        case .leftMirrored, .rightMirrored:
            transform = transform.translatedBy(x: self.size.height, y: 0);
            transform = transform.scaledBy(x: -1, y: 1)
            break
             
        default:
            break
        }
         
        let ctx = CGContext(data: nil, width: Int(self.size.width), height: Int(self.size.height), bitsPerComponent: self.cgImage!.bitsPerComponent, bytesPerRow: 0, space: self.cgImage!.colorSpace!, bitmapInfo: self.cgImage!.bitmapInfo.rawValue)
        ctx?.concatenate(transform)
         
        switch self.imageOrientation {
        case .left, .leftMirrored, .right, .rightMirrored:
            ctx?.draw(self.cgImage!, in: CGRect(x: CGFloat(0), y: CGFloat(0), width: CGFloat(size.height), height: CGFloat(size.width)))
            break
             
        default:
            ctx?.draw(self.cgImage!, in: CGRect(x: CGFloat(0), y: CGFloat(0), width: CGFloat(size.width), height: CGFloat(size.height)))
            break
        }
         
        let cgimg: CGImage = (ctx?.makeImage())!
        let img = UIImage(cgImage: cgimg)
         
        return img
    }
}
//
//  colorRestoreVC.swift
//  Colorful
//
//  Created by fox on 2021/10/4.
//  Copyright © 2021 fox. All rights reserved.
//

import Foundation
import UIKit
import CoreGraphics
import QuartzCore
import AVFoundation
import Alamofire
import SnapKit

typealias CGGammaValue = Float
typealias CGDirectDisplayID = UInt32

@available(iOS 11.0, *)
class colorRestoreVC: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate,UIActionSheetDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    var screenshot: UIImage!
    var imageOverlay: UIImageView!
    var timer: Timer!
    var mainWindow: UIWindow!
    var colorMode: ColorBlindType!
    
    var testImage: UIImageView!
    
    
    override func viewDidAppear(_ animated: Bool) {
        mainWindow = self.view.window

    }
    
    override func viewDidLoad() {
        
//        let longpressGesutre = UILongPressGestureRecognizer(target: self, action: Selector(("handleLongpressGesture:")))
//        //长按时间为1秒
//        longpressGesutre.minimumPressDuration = 1
//        //允许15秒运动
//        longpressGesutre.allowableMovement = 15
//        //所需触摸1次
//        longpressGesutre.numberOfTouchesRequired = 1
//        self.view.addGestureRecognizer(longpressGesutre)
        addLongPressGes()
        
        
        view.backgroundColor = .white
        super.viewDidLoad()
        
        
        
        testImage = UIImageView()
        self.view.addSubview(testImage);
        testImage.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview().offset(-100)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.9)
            make.height.equalToSuperview().multipliedBy(0.7)
        }
//        testImage.image = UIImage(named: "DSC_0775")
        testImage.clipsToBounds = true
        testImage.contentMode = .scaleAspectFit
        testImage.layer.cornerRadius = 10
        
        
        let albumButton = UIButton()
        self.view.addSubview(albumButton)
        albumButton.snp.makeConstraints { (make) in
            make.width.equalTo(testImage).dividedBy(2).offset(-5)
//            make.centerX.equalToSuperview()
            make.left.equalTo(testImage)
            make.top.equalTo(testImage.snp.bottom).offset(10)
            make.height.equalTo(50)
        }

//        albumButton.backgroundColor = #colorLiteral(red: 0.8417847157, green: 0.8507048488, blue: 0.8811554909, alpha: 1)
        albumButton.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.8470588235)
        albumButton.setTitle("相册", for: UIControl.State())
        albumButton.addTarget(self, action: #selector(self.demoClicked), for: .touchUpInside)
        albumButton.layer.cornerRadius = 10
        
        let camButton = UIButton()
        self.view.addSubview(camButton)
        camButton.snp.makeConstraints { (make) in
            make.width.equalTo(testImage).dividedBy(2).offset(-5)
            make.right.equalTo(testImage)
            make.top.equalTo(testImage.snp.bottom).offset(10)
            make.height.equalTo(50)
        }

//        camButton.backgroundColor = #colorLiteral(red: 0.8417847157, green: 0.8507048488, blue: 0.8811554909, alpha: 1)
        camButton.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.8470588235)
        camButton.setTitle("拍照", for: UIControl.State())
        camButton.addTarget(self, action: #selector(self.demoCameera), for: .touchUpInside)
        camButton.layer.cornerRadius = 10
        
        
        let changeButton = UIButton.init(type: .custom)
        self.view.addSubview(changeButton)
        changeButton.snp.makeConstraints { (make) in
            make.width.equalTo(testImage)
            make.centerX.equalToSuperview()
            make.top.equalTo(camButton.snp.bottom).offset(10)
            make.height.equalTo(50)
        }
//        changeButton.frame = CGRect(x: 20, y: nextViewButton.frame.size.height + nextViewButton.frame.origin.y + 20, width: self.view.bounds.size.width - 40, height: 50)
//        changeButton.backgroundColor =  #colorLiteral(red: 0.8417847157, green: 0.8507048488, blue: 0.8811554909, alpha: 1)
        changeButton.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.8470588235)
        changeButton.setTitle("切换", for: UIControl.State())
//        changeButton.addTarget(self, action: #selector(CBController.startColorBlinds), for: .touchUpInside)
        changeButton.addTarget(self, action: #selector(httpConvert), for: .touchUpInside)
        changeButton.layer.cornerRadius = 10
        
        let nextViewButton = UIButton()
        self.view.addSubview(nextViewButton)
        nextViewButton.snp.makeConstraints { (make) in
            make.width.equalTo(testImage)
            make.centerX.equalToSuperview()
            make.top.equalTo(changeButton.snp.bottom).offset(10)
            make.height.equalTo(50)
        }
//        nextViewButton.frame = CGRect(x: 20, y: testImage.frame.size.height + testImage.frame.origin.y + 20, width: self.view.bounds.size.width - 40, height: 50)
//        nextViewButton.backgroundColor = #colorLiteral(red: 0.8417847157, green: 0.8507048488, blue: 0.8811554909, alpha: 1)
        nextViewButton.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.8470588235)
        nextViewButton.setTitle("返回菜单", for: UIControl.State())
        nextViewButton.addTarget(self, action: #selector(self.nextView), for: .touchUpInside)
        nextViewButton.layer.cornerRadius = 10
        
        
    }
    
    @objc func nextView() {
        dismiss(animated: true, completion: nil)
    }
    @objc func httpConvert() {
        
        let urls:String = "http://121.40.64.188:5100/iosTest/"
        //参数
//        let parameters:Dictionary = ["type":"1","name":"customer","password":"123456"]

//        let imgData = getStrFromImage("DSC_0775")
        let imgData = getStrFromImage(testImage.image!)
//        let imgData = testImage.image?.pngData()?.base64EncodedString()
        
        let parameters: [String: [String]] = [
            "imgData": ["\(imgData))"],
            "baz": ["a", "b"],
            "qux": ["x", "y", "z"]
        ]
        //Alamofire 请求实例
        AF.request(URL(string: urls)!, method: .post, parameters: parameters, encoder: JSONParameterEncoder.sortedKeys)
                        .responseString { (responses) in
                            print(responses)
                            let data = responses.data
                            let data_error:Data! = UIImage(named: "DSC_0775")?.pngData()
//                            let
                            let res: UIImage! = UIImage(data: data ?? data_error)
                            self.testImage.image = res
//                            self.testImage.contentMode = .scaleAspectFit
                            
        }
                            }
    //MARK:- 🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟
    @objc func demoCameera(){
        openCamera()
    }
    
    @objc func demoClicked(){
        openAlbum()
    }
    
    //打开相册
    
    func openAlbum(){
        //判断设置是否支持图片库
        
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary){
            //初始化图片控制器
            let picker = UIImagePickerController()
            //设置代理
            picker.delegate = self
            //指定图片控制器类型
            picker.sourceType = UIImagePickerController.SourceType.photoLibrary
            //设置是否允许编辑
            
            picker.allowsEditing = true
            
            
            //弹出控制器，显示界面
            self.present(picker, animated:true, completion: {
                () -> Void in
            })
        }else{
            print("读取相册错误")
        }
        
    }
    
    
    
    func openCamera(){
        if UIImagePickerController.isSourceTypeAvailable(.camera){
            
            //创建图片控制器
            let picker = UIImagePickerController()
            //设置代理
            picker.delegate = self
            //设置来源
            picker.sourceType = UIImagePickerController.SourceType.camera
            //允许编辑
            picker.allowsEditing = true
            
//            picker.mediaTypes
            //打开相机
            self.present(picker, animated:true, completion: { () -> Void in})
            
        }else{
            debugPrint("找不到相机")
            
        }
        
    }
    //MARK:- 🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            self.testImage.image = image


        } else if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            self.testImage.image = image

        }
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    //保存图片
    @objc func savedPhotosAlbum(image: UIImage, didFinishSavingWithError error: NSError?, contextInfo: AnyObject) {
        
        if error != nil {
            print("save failed")
        } else {
            print("save succeed")

        }
    }
    //MARK:- ✨手势长按
    func addLongPressGes() {
        //添加长按手势
        let longPressGes = UILongPressGestureRecognizer(target: self, action: #selector(longPressedGesture(recognizer:)))
        longPressGes.minimumPressDuration = 1
        //一定要遵循代理
        longPressGes.delegate = self
//        longpressGes.minimumPressDuration = 1
        self.view.addGestureRecognizer(longPressGes)


    }
    
    @objc func longPressedGesture(recognizer: UILongPressGestureRecognizer) {
        let alertV = UIAlertController()
        let saveAction = UIAlertAction(title: "保存图片", style: .default) { (alertV) in
            UIImageWriteToSavedPhotosAlbum(self.testImage.image!, self, #selector(self.savedPhotosAlbum), nil)
        }
        //取消保存不作处理
        let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        
        alertV.addAction(saveAction)
        alertV.addAction(cancelAction)
        self.present(alertV, animated: true, completion: nil)
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    



}

//不实现该代理方法,长按无效
//MARK: 手势代理方法
extension colorRestoreVC : UIGestureRecognizerDelegate{
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}

 
extension UIImage {
    // 修复图片旋转
    func fixOrientation() -> UIImage {
        if self.imageOrientation == .up {
            return self
        }
         
        var transform = CGAffineTransform.identity
         
        switch self.imageOrientation {
        case .down, .downMirrored:
            transform = transform.translatedBy(x: self.size.width, y: self.size.height)
            transform = transform.rotated(by: .pi)
            break
             
        case .left, .leftMirrored:
            transform = transform.translatedBy(x: self.size.width, y: 0)
            transform = transform.rotated(by: .pi / 2)
            break
             
        case .right, .rightMirrored:
            transform = transform.translatedBy(x: 0, y: self.size.height)
            transform = transform.rotated(by: -.pi / 2)
            break
             
        default:
            break
        }
         
        switch self.imageOrientation {
        case .upMirrored, .downMirrored:
            transform = transform.translatedBy(x: self.size.width, y: 0)
            transform = transform.scaledBy(x: -1, y: 1)
            break
             
        case .leftMirrored, .rightMirrored:
            transform = transform.translatedBy(x: self.size.height, y: 0);
            transform = transform.scaledBy(x: -1, y: 1)
            break
             
        default:
            break
        }
         
        let ctx = CGContext(data: nil, width: Int(self.size.width), height: Int(self.size.height), bitsPerComponent: self.cgImage!.bitsPerComponent, bytesPerRow: 0, space: self.cgImage!.colorSpace!, bitmapInfo: self.cgImage!.bitmapInfo.rawValue)
        ctx?.concatenate(transform)
         
        switch self.imageOrientation {
        case .left, .leftMirrored, .right, .rightMirrored:
            ctx?.draw(self.cgImage!, in: CGRect(x: CGFloat(0), y: CGFloat(0), width: CGFloat(size.height), height: CGFloat(size.width)))
            break
             
        default:
            ctx?.draw(self.cgImage!, in: CGRect(x: CGFloat(0), y: CGFloat(0), width: CGFloat(size.width), height: CGFloat(size.height)))
            break
        }
         
        let cgimg: CGImage = (ctx?.makeImage())!
        let img = UIImage(cgImage: cgimg)
         
        return img
    }
}
//
//  colorRestoreVC.swift
//  Colorful
//
//  Created by fox on 2021/10/4.
//  Copyright © 2021 fox. All rights reserved.
//

import Foundation
import UIKit
import CoreGraphics
import QuartzCore
import AVFoundation
import Alamofire
import SnapKit

typealias CGGammaValue = Float
typealias CGDirectDisplayID = UInt32

@available(iOS 11.0, *)
class colorRestoreVC: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate,UIActionSheetDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    var screenshot: UIImage!
    var imageOverlay: UIImageView!
    var timer: Timer!
    var mainWindow: UIWindow!
    var colorMode: ColorBlindType!
    
    var testImage: UIImageView!
    
    
    override func viewDidAppear(_ animated: Bool) {
        mainWindow = self.view.window

    }
    
    override func viewDidLoad() {
        
//        let longpressGesutre = UILongPressGestureRecognizer(target: self, action: Selector(("handleLongpressGesture:")))
//        //长按时间为1秒
//        longpressGesutre.minimumPressDuration = 1
//        //允许15秒运动
//        longpressGesutre.allowableMovement = 15
//        //所需触摸1次
//        longpressGesutre.numberOfTouchesRequired = 1
//        self.view.addGestureRecognizer(longpressGesutre)
        addLongPressGes()
        
        
        view.backgroundColor = .white
        super.viewDidLoad()
        
        
        
        testImage = UIImageView()
        self.view.addSubview(testImage);
        testImage.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview().offset(-100)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.9)
            make.height.equalToSuperview().multipliedBy(0.7)
        }
//        testImage.image = UIImage(named: "DSC_0775")
        testImage.clipsToBounds = true
        testImage.contentMode = .scaleAspectFit
        testImage.layer.cornerRadius = 10
        
        
        let albumButton = UIButton()
        self.view.addSubview(albumButton)
        albumButton.snp.makeConstraints { (make) in
            make.width.equalTo(testImage).dividedBy(2).offset(-5)
//            make.centerX.equalToSuperview()
            make.left.equalTo(testImage)
            make.top.equalTo(testImage.snp.bottom).offset(10)
            make.height.equalTo(50)
        }

//        albumButton.backgroundColor = #colorLiteral(red: 0.8417847157, green: 0.8507048488, blue: 0.8811554909, alpha: 1)
        albumButton.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.8470588235)
        albumButton.setTitle("相册", for: UIControl.State())
        albumButton.addTarget(self, action: #selector(self.demoClicked), for: .touchUpInside)
        albumButton.layer.cornerRadius = 10
        
        let camButton = UIButton()
        self.view.addSubview(camButton)
        camButton.snp.makeConstraints { (make) in
            make.width.equalTo(testImage).dividedBy(2).offset(-5)
            make.right.equalTo(testImage)
            make.top.equalTo(testImage.snp.bottom).offset(10)
            make.height.equalTo(50)
        }

//        camButton.backgroundColor = #colorLiteral(red: 0.8417847157, green: 0.8507048488, blue: 0.8811554909, alpha: 1)
        camButton.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.8470588235)
        camButton.setTitle("拍照", for: UIControl.State())
        camButton.addTarget(self, action: #selector(self.demoCameera), for: .touchUpInside)
        camButton.layer.cornerRadius = 10
        
        
        let changeButton = UIButton.init(type: .custom)
        self.view.addSubview(changeButton)
        changeButton.snp.makeConstraints { (make) in
            make.width.equalTo(testImage)
            make.centerX.equalToSuperview()
            make.top.equalTo(camButton.snp.bottom).offset(10)
            make.height.equalTo(50)
        }
//        changeButton.frame = CGRect(x: 20, y: nextViewButton.frame.size.height + nextViewButton.frame.origin.y + 20, width: self.view.bounds.size.width - 40, height: 50)
//        changeButton.backgroundColor =  #colorLiteral(red: 0.8417847157, green: 0.8507048488, blue: 0.8811554909, alpha: 1)
        changeButton.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.8470588235)
        changeButton.setTitle("切换", for: UIControl.State())
//        changeButton.addTarget(self, action: #selector(CBController.startColorBlinds), for: .touchUpInside)
        changeButton.addTarget(self, action: #selector(httpConvert), for: .touchUpInside)
        changeButton.layer.cornerRadius = 10
        
        let nextViewButton = UIButton()
        self.view.addSubview(nextViewButton)
        nextViewButton.snp.makeConstraints { (make) in
            make.width.equalTo(testImage)
            make.centerX.equalToSuperview()
            make.top.equalTo(changeButton.snp.bottom).offset(10)
            make.height.equalTo(50)
        }
//        nextViewButton.frame = CGRect(x: 20, y: testImage.frame.size.height + testImage.frame.origin.y + 20, width: self.view.bounds.size.width - 40, height: 50)
//        nextViewButton.backgroundColor = #colorLiteral(red: 0.8417847157, green: 0.8507048488, blue: 0.8811554909, alpha: 1)
        nextViewButton.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.8470588235)
        nextViewButton.setTitle("返回菜单", for: UIControl.State())
        nextViewButton.addTarget(self, action: #selector(self.nextView), for: .touchUpInside)
        nextViewButton.layer.cornerRadius = 10
        
        
    }
    
    @objc func nextView() {
        dismiss(animated: true, completion: nil)
    }
    @objc func httpConvert() {
        
        let urls:String = "http://121.40.64.188:5100/iosTest/"
        //参数
//        let parameters:Dictionary = ["type":"1","name":"customer","password":"123456"]

//        let imgData = getStrFromImage("DSC_0775")
        let imgData = getStrFromImage(testImage.image!)
//        let imgData = testImage.image?.pngData()?.base64EncodedString()
        
        let parameters: [String: [String]] = [
            "imgData": ["\(imgData))"],
            "baz": ["a", "b"],
            "qux": ["x", "y", "z"]
        ]
        //Alamofire 请求实例
        AF.request(URL(string: urls)!, method: .post, parameters: parameters, encoder: JSONParameterEncoder.sortedKeys)
                        .responseString { (responses) in
                            print(responses)
                            let data = responses.data
                            let data_error:Data! = UIImage(named: "DSC_0775")?.pngData()
//                            let
                            let res: UIImage! = UIImage(data: data ?? data_error)
                            self.testImage.image = res
//                            self.testImage.contentMode = .scaleAspectFit
                            
        }
                            }
    //MARK:- 🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟
    @objc func demoCameera(){
        openCamera()
    }
    
    @objc func demoClicked(){
        openAlbum()
    }
    
    //打开相册
    
    func openAlbum(){
        //判断设置是否支持图片库
        
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary){
            //初始化图片控制器
            let picker = UIImagePickerController()
            //设置代理
            picker.delegate = self
            //指定图片控制器类型
            picker.sourceType = UIImagePickerController.SourceType.photoLibrary
            //设置是否允许编辑
            
            picker.allowsEditing = true
            
            
            //弹出控制器，显示界面
            self.present(picker, animated:true, completion: {
                () -> Void in
            })
        }else{
            print("读取相册错误")
        }
        
    }
    
    
    
    func openCamera(){
        if UIImagePickerController.isSourceTypeAvailable(.camera){
            
            //创建图片控制器
            let picker = UIImagePickerController()
            //设置代理
            picker.delegate = self
            //设置来源
            picker.sourceType = UIImagePickerController.SourceType.camera
            //允许编辑
            picker.allowsEditing = true
            
//            picker.mediaTypes
            //打开相机
            self.present(picker, animated:true, completion: { () -> Void in})
            
        }else{
            debugPrint("找不到相机")
            
        }
        
    }
    //MARK:- 🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            self.testImage.image = image


        } else if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            self.testImage.image = image

        }
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    //保存图片
    @objc func savedPhotosAlbum(image: UIImage, didFinishSavingWithError error: NSError?, contextInfo: AnyObject) {
        
        if error != nil {
            print("save failed")
        } else {
            print("save succeed")

        }
    }
    //MARK:- ✨手势长按
    func addLongPressGes() {
        //添加长按手势
        let longPressGes = UILongPressGestureRecognizer(target: self, action: #selector(longPressedGesture(recognizer:)))
        longPressGes.minimumPressDuration = 1
        //一定要遵循代理
        longPressGes.delegate = self
//        longpressGes.minimumPressDuration = 1
        self.view.addGestureRecognizer(longPressGes)


    }
    
    @objc func longPressedGesture(recognizer: UILongPressGestureRecognizer) {
        let alertV = UIAlertController()
        let saveAction = UIAlertAction(title: "保存图片", style: .default) { (alertV) in
            UIImageWriteToSavedPhotosAlbum(self.testImage.image!, self, #selector(self.savedPhotosAlbum), nil)
        }
        //取消保存不作处理
        let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        
        alertV.addAction(saveAction)
        alertV.addAction(cancelAction)
        self.present(alertV, animated: true, completion: nil)
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    



}

//不实现该代理方法,长按无效
//MARK: 手势代理方法
extension colorRestoreVC : UIGestureRecognizerDelegate{
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}

 
extension UIImage {
    // 修复图片旋转
    func fixOrientation() -> UIImage {
        if self.imageOrientation == .up {
            return self
        }
         
        var transform = CGAffineTransform.identity
         
        switch self.imageOrientation {
        case .down, .downMirrored:
            transform = transform.translatedBy(x: self.size.width, y: self.size.height)
            transform = transform.rotated(by: .pi)
            break
             
        case .left, .leftMirrored:
            transform = transform.translatedBy(x: self.size.width, y: 0)
            transform = transform.rotated(by: .pi / 2)
            break
             
        case .right, .rightMirrored:
            transform = transform.translatedBy(x: 0, y: self.size.height)
            transform = transform.rotated(by: -.pi / 2)
            break
             
        default:
            break
        }
         
        switch self.imageOrientation {
        case .upMirrored, .downMirrored:
            transform = transform.translatedBy(x: self.size.width, y: 0)
            transform = transform.scaledBy(x: -1, y: 1)
            break
             
        case .leftMirrored, .rightMirrored:
            transform = transform.translatedBy(x: self.size.height, y: 0);
            transform = transform.scaledBy(x: -1, y: 1)
            break
             
        default:
            break
        }
         
        let ctx = CGContext(data: nil, width: Int(self.size.width), height: Int(self.size.height), bitsPerComponent: self.cgImage!.bitsPerComponent, bytesPerRow: 0, space: self.cgImage!.colorSpace!, bitmapInfo: self.cgImage!.bitmapInfo.rawValue)
        ctx?.concatenate(transform)
         
        switch self.imageOrientation {
        case .left, .leftMirrored, .right, .rightMirrored:
            ctx?.draw(self.cgImage!, in: CGRect(x: CGFloat(0), y: CGFloat(0), width: CGFloat(size.height), height: CGFloat(size.width)))
            break
             
        default:
            ctx?.draw(self.cgImage!, in: CGRect(x: CGFloat(0), y: CGFloat(0), width: CGFloat(size.width), height: CGFloat(size.height)))
            break
        }
         
        let cgimg: CGImage = (ctx?.makeImage())!
        let img = UIImage(cgImage: cgimg)
         
        return img
    }
}
//
//  colorRestoreVC.swift
//  Colorful
//
//  Created by fox on 2021/10/4.
//  Copyright © 2021 fox. All rights reserved.
//

import Foundation
import UIKit
import CoreGraphics
import QuartzCore
import AVFoundation
import Alamofire
import SnapKit

typealias CGGammaValue = Float
typealias CGDirectDisplayID = UInt32

@available(iOS 11.0, *)
class colorRestoreVC: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate,UIActionSheetDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    var screenshot: UIImage!
    var imageOverlay: UIImageView!
    var timer: Timer!
    var mainWindow: UIWindow!
    var colorMode: ColorBlindType!
    
    var testImage: UIImageView!
    
    
    override func viewDidAppear(_ animated: Bool) {
        mainWindow = self.view.window

    }
    
    override func viewDidLoad() {
        
//        let longpressGesutre = UILongPressGestureRecognizer(target: self, action: Selector(("handleLongpressGesture:")))
//        //长按时间为1秒
//        longpressGesutre.minimumPressDuration = 1
//        //允许15秒运动
//        longpressGesutre.allowableMovement = 15
//        //所需触摸1次
//        longpressGesutre.numberOfTouchesRequired = 1
//        self.view.addGestureRecognizer(longpressGesutre)
        addLongPressGes()
        
        
        view.backgroundColor = .white
        super.viewDidLoad()
        
        
        
        testImage = UIImageView()
        self.view.addSubview(testImage);
        testImage.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview().offset(-100)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.9)
            make.height.equalToSuperview().multipliedBy(0.7)
        }
//        testImage.image = UIImage(named: "DSC_0775")
        testImage.clipsToBounds = true
        testImage.contentMode = .scaleAspectFit
        testImage.layer.cornerRadius = 10
        
        
        let albumButton = UIButton()
        self.view.addSubview(albumButton)
        albumButton.snp.makeConstraints { (make) in
            make.width.equalTo(testImage).dividedBy(2).offset(-5)
//            make.centerX.equalToSuperview()
            make.left.equalTo(testImage)
            make.top.equalTo(testImage.snp.bottom).offset(10)
            make.height.equalTo(50)
        }

//        albumButton.backgroundColor = #colorLiteral(red: 0.8417847157, green: 0.8507048488, blue: 0.8811554909, alpha: 1)
        albumButton.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.8470588235)
        albumButton.setTitle("相册", for: UIControl.State())
        albumButton.addTarget(self, action: #selector(self.demoClicked), for: .touchUpInside)
        albumButton.layer.cornerRadius = 10
        
        let camButton = UIButton()
        self.view.addSubview(camButton)
        camButton.snp.makeConstraints { (make) in
            make.width.equalTo(testImage).dividedBy(2).offset(-5)
            make.right.equalTo(testImage)
            make.top.equalTo(testImage.snp.bottom).offset(10)
            make.height.equalTo(50)
        }

//        camButton.backgroundColor = #colorLiteral(red: 0.8417847157, green: 0.8507048488, blue: 0.8811554909, alpha: 1)
        camButton.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.8470588235)
        camButton.setTitle("拍照", for: UIControl.State())
        camButton.addTarget(self, action: #selector(self.demoCameera), for: .touchUpInside)
        camButton.layer.cornerRadius = 10
        
        
        let changeButton = UIButton.init(type: .custom)
        self.view.addSubview(changeButton)
        changeButton.snp.makeConstraints { (make) in
            make.width.equalTo(testImage)
            make.centerX.equalToSuperview()
            make.top.equalTo(camButton.snp.bottom).offset(10)
            make.height.equalTo(50)
        }
//        changeButton.frame = CGRect(x: 20, y: nextViewButton.frame.size.height + nextViewButton.frame.origin.y + 20, width: self.view.bounds.size.width - 40, height: 50)
//        changeButton.backgroundColor =  #colorLiteral(red: 0.8417847157, green: 0.8507048488, blue: 0.8811554909, alpha: 1)
        changeButton.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.8470588235)
        changeButton.setTitle("切换", for: UIControl.State())
//        changeButton.addTarget(self, action: #selector(CBController.startColorBlinds), for: .touchUpInside)
        changeButton.addTarget(self, action: #selector(httpConvert), for: .touchUpInside)
        changeButton.layer.cornerRadius = 10
        
        let nextViewButton = UIButton()
        self.view.addSubview(nextViewButton)
        nextViewButton.snp.makeConstraints { (make) in
            make.width.equalTo(testImage)
            make.centerX.equalToSuperview()
            make.top.equalTo(changeButton.snp.bottom).offset(10)
            make.height.equalTo(50)
        }
//        nextViewButton.frame = CGRect(x: 20, y: testImage.frame.size.height + testImage.frame.origin.y + 20, width: self.view.bounds.size.width - 40, height: 50)
//        nextViewButton.backgroundColor = #colorLiteral(red: 0.8417847157, green: 0.8507048488, blue: 0.8811554909, alpha: 1)
        nextViewButton.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.8470588235)
        nextViewButton.setTitle("返回菜单", for: UIControl.State())
        nextViewButton.addTarget(self, action: #selector(self.nextView), for: .touchUpInside)
        nextViewButton.layer.cornerRadius = 10
        
        
    }
    
    @objc func nextView() {
        dismiss(animated: true, completion: nil)
    }
    @objc func httpConvert() {
        
        let urls:String = "http://121.40.64.188:5100/iosTest/"
        //参数
//        let parameters:Dictionary = ["type":"1","name":"customer","password":"123456"]

//        let imgData = getStrFromImage("DSC_0775")
        let imgData = getStrFromImage(testImage.image!)
//        let imgData = testImage.image?.pngData()?.base64EncodedString()
        
        let parameters: [String: [String]] = [
            "imgData": ["\(imgData))"],
            "baz": ["a", "b"],
            "qux": ["x", "y", "z"]
        ]
        //Alamofire 请求实例
        AF.request(URL(string: urls)!, method: .post, parameters: parameters, encoder: JSONParameterEncoder.sortedKeys)
                        .responseString { (responses) in
                            print(responses)
                            let data = responses.data
                            let data_error:Data! = UIImage(named: "DSC_0775")?.pngData()
//                            let
                            let res: UIImage! = UIImage(data: data ?? data_error)
                            self.testImage.image = res
//                            self.testImage.contentMode = .scaleAspectFit
                            
        }
                            }
    //MARK:- 🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟
    @objc func demoCameera(){
        openCamera()
    }
    
    @objc func demoClicked(){
        openAlbum()
    }
    
    //打开相册
    
    func openAlbum(){
        //判断设置是否支持图片库
        
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary){
            //初始化图片控制器
            let picker = UIImagePickerController()
            //设置代理
            picker.delegate = self
            //指定图片控制器类型
            picker.sourceType = UIImagePickerController.SourceType.photoLibrary
            //设置是否允许编辑
            
            picker.allowsEditing = true
            
            
            //弹出控制器，显示界面
            self.present(picker, animated:true, completion: {
                () -> Void in
            })
        }else{
            print("读取相册错误")
        }
        
    }
    
    
    
    func openCamera(){
        if UIImagePickerController.isSourceTypeAvailable(.camera){
            
            //创建图片控制器
            let picker = UIImagePickerController()
            //设置代理
            picker.delegate = self
            //设置来源
            picker.sourceType = UIImagePickerController.SourceType.camera
            //允许编辑
            picker.allowsEditing = true
            
//            picker.mediaTypes
            //打开相机
            self.present(picker, animated:true, completion: { () -> Void in})
            
        }else{
            debugPrint("找不到相机")
            
        }
        
    }
    //MARK:- 🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            self.testImage.image = image


        } else if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            self.testImage.image = image

        }
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    //保存图片
    @objc func savedPhotosAlbum(image: UIImage, didFinishSavingWithError error: NSError?, contextInfo: AnyObject) {
        
        if error != nil {
            print("save failed")
        } else {
            print("save succeed")

        }
    }
    //MARK:- ✨手势长按
    func addLongPressGes() {
        //添加长按手势
        let longPressGes = UILongPressGestureRecognizer(target: self, action: #selector(longPressedGesture(recognizer:)))
        longPressGes.minimumPressDuration = 1
        //一定要遵循代理
        longPressGes.delegate = self
//        longpressGes.minimumPressDuration = 1
        self.view.addGestureRecognizer(longPressGes)


    }
    
    @objc func longPressedGesture(recognizer: UILongPressGestureRecognizer) {
        let alertV = UIAlertController()
        let saveAction = UIAlertAction(title: "保存图片", style: .default) { (alertV) in
            UIImageWriteToSavedPhotosAlbum(self.testImage.image!, self, #selector(self.savedPhotosAlbum), nil)
        }
        //取消保存不作处理
        let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        
        alertV.addAction(saveAction)
        alertV.addAction(cancelAction)
        self.present(alertV, animated: true, completion: nil)
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    



}

//不实现该代理方法,长按无效
//MARK: 手势代理方法
extension colorRestoreVC : UIGestureRecognizerDelegate{
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}

 
extension UIImage {
    // 修复图片旋转
    func fixOrientation() -> UIImage {
        if self.imageOrientation == .up {
            return self
        }
         
        var transform = CGAffineTransform.identity
         
        switch self.imageOrientation {
        case .down, .downMirrored:
            transform = transform.translatedBy(x: self.size.width, y: self.size.height)
            transform = transform.rotated(by: .pi)
            break
             
        case .left, .leftMirrored:
            transform = transform.translatedBy(x: self.size.width, y: 0)
            transform = transform.rotated(by: .pi / 2)
            break
             
        case .right, .rightMirrored:
            transform = transform.translatedBy(x: 0, y: self.size.height)
            transform = transform.rotated(by: -.pi / 2)
            break
             
        default:
            break
        }
         
        switch self.imageOrientation {
        case .upMirrored, .downMirrored:
            transform = transform.translatedBy(x: self.size.width, y: 0)
            transform = transform.scaledBy(x: -1, y: 1)
            break
             
        case .leftMirrored, .rightMirrored:
            transform = transform.translatedBy(x: self.size.height, y: 0);
            transform = transform.scaledBy(x: -1, y: 1)
            break
             
        default:
            break
        }
         
        let ctx = CGContext(data: nil, width: Int(self.size.width), height: Int(self.size.height), bitsPerComponent: self.cgImage!.bitsPerComponent, bytesPerRow: 0, space: self.cgImage!.colorSpace!, bitmapInfo: self.cgImage!.bitmapInfo.rawValue)
        ctx?.concatenate(transform)
         
        switch self.imageOrientation {
        case .left, .leftMirrored, .right, .rightMirrored:
            ctx?.draw(self.cgImage!, in: CGRect(x: CGFloat(0), y: CGFloat(0), width: CGFloat(size.height), height: CGFloat(size.width)))
            break
             
        default:
            ctx?.draw(self.cgImage!, in: CGRect(x: CGFloat(0), y: CGFloat(0), width: CGFloat(size.width), height: CGFloat(size.height)))
            break
        }
         
        let cgimg: CGImage = (ctx?.makeImage())!
        let img = UIImage(cgImage: cgimg)
         
        return img
    }
}
//
//  colorRestoreVC.swift
//  Colorful
//
//  Created by fox on 2021/10/4.
//  Copyright © 2021 fox. All rights reserved.
//

import Foundation
import UIKit
import CoreGraphics
import QuartzCore
import AVFoundation
import Alamofire
import SnapKit

typealias CGGammaValue = Float
typealias CGDirectDisplayID = UInt32

@available(iOS 11.0, *)
class colorRestoreVC: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate,UIActionSheetDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    var screenshot: UIImage!
    var imageOverlay: UIImageView!
    var timer: Timer!
    var mainWindow: UIWindow!
    var colorMode: ColorBlindType!
    
    var testImage: UIImageView!
    
    
    override func viewDidAppear(_ animated: Bool) {
        mainWindow = self.view.window

    }
    
    override func viewDidLoad() {
        
//        let longpressGesutre = UILongPressGestureRecognizer(target: self, action: Selector(("handleLongpressGesture:")))
//        //长按时间为1秒
//        longpressGesutre.minimumPressDuration = 1
//        //允许15秒运动
//        longpressGesutre.allowableMovement = 15
//        //所需触摸1次
//        longpressGesutre.numberOfTouchesRequired = 1
//        self.view.addGestureRecognizer(longpressGesutre)
        addLongPressGes()
        
        
        view.backgroundColor = .white
        super.viewDidLoad()
        
        
        
        testImage = UIImageView()
        self.view.addSubview(testImage);
        testImage.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview().offset(-100)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.9)
            make.height.equalToSuperview().multipliedBy(0.7)
        }
//        testImage.image = UIImage(named: "DSC_0775")
        testImage.clipsToBounds = true
        testImage.contentMode = .scaleAspectFit
        testImage.layer.cornerRadius = 10
        
        
        let albumButton = UIButton()
        self.view.addSubview(albumButton)
        albumButton.snp.makeConstraints { (make) in
            make.width.equalTo(testImage).dividedBy(2).offset(-5)
//            make.centerX.equalToSuperview()
            make.left.equalTo(testImage)
            make.top.equalTo(testImage.snp.bottom).offset(10)
            make.height.equalTo(50)
        }

//        albumButton.backgroundColor = #colorLiteral(red: 0.8417847157, green: 0.8507048488, blue: 0.8811554909, alpha: 1)
        albumButton.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.8470588235)
        albumButton.setTitle("相册", for: UIControl.State())
        albumButton.addTarget(self, action: #selector(self.demoClicked), for: .touchUpInside)
        albumButton.layer.cornerRadius = 10
        
        let camButton = UIButton()
        self.view.addSubview(camButton)
        camButton.snp.makeConstraints { (make) in
            make.width.equalTo(testImage).dividedBy(2).offset(-5)
            make.right.equalTo(testImage)
            make.top.equalTo(testImage.snp.bottom).offset(10)
            make.height.equalTo(50)
        }

//        camButton.backgroundColor = #colorLiteral(red: 0.8417847157, green: 0.8507048488, blue: 0.8811554909, alpha: 1)
        camButton.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.8470588235)
        camButton.setTitle("拍照", for: UIControl.State())
        camButton.addTarget(self, action: #selector(self.demoCameera), for: .touchUpInside)
        camButton.layer.cornerRadius = 10
        
        
        let changeButton = UIButton.init(type: .custom)
        self.view.addSubview(changeButton)
        changeButton.snp.makeConstraints { (make) in
            make.width.equalTo(testImage)
            make.centerX.equalToSuperview()
            make.top.equalTo(camButton.snp.bottom).offset(10)
            make.height.equalTo(50)
        }
//        changeButton.frame = CGRect(x: 20, y: nextViewButton.frame.size.height + nextViewButton.frame.origin.y + 20, width: self.view.bounds.size.width - 40, height: 50)
//        changeButton.backgroundColor =  #colorLiteral(red: 0.8417847157, green: 0.8507048488, blue: 0.8811554909, alpha: 1)
        changeButton.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.8470588235)
        changeButton.setTitle("切换", for: UIControl.State())
//        changeButton.addTarget(self, action: #selector(CBController.startColorBlinds), for: .touchUpInside)
        changeButton.addTarget(self, action: #selector(httpConvert), for: .touchUpInside)
        changeButton.layer.cornerRadius = 10
        
        let nextViewButton = UIButton()
        self.view.addSubview(nextViewButton)
        nextViewButton.snp.makeConstraints { (make) in
            make.width.equalTo(testImage)
            make.centerX.equalToSuperview()
            make.top.equalTo(changeButton.snp.bottom).offset(10)
            make.height.equalTo(50)
        }
//        nextViewButton.frame = CGRect(x: 20, y: testImage.frame.size.height + testImage.frame.origin.y + 20, width: self.view.bounds.size.width - 40, height: 50)
//        nextViewButton.backgroundColor = #colorLiteral(red: 0.8417847157, green: 0.8507048488, blue: 0.8811554909, alpha: 1)
        nextViewButton.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.8470588235)
        nextViewButton.setTitle("返回菜单", for: UIControl.State())
        nextViewButton.addTarget(self, action: #selector(self.nextView), for: .touchUpInside)
        nextViewButton.layer.cornerRadius = 10
        
        
    }
    
    @objc func nextView() {
        dismiss(animated: true, completion: nil)
    }
    @objc func httpConvert() {
        
        let urls:String = "http://121.40.64.188:5100/iosTest/"
        //参数
//        let parameters:Dictionary = ["type":"1","name":"customer","password":"123456"]

//        let imgData = getStrFromImage("DSC_0775")
        let imgData = getStrFromImage(testImage.image!)
//        let imgData = testImage.image?.pngData()?.base64EncodedString()
        
        let parameters: [String: [String]] = [
            "imgData": ["\(imgData))"],
            "baz": ["a", "b"],
            "qux": ["x", "y", "z"]
        ]
        //Alamofire 请求实例
        AF.request(URL(string: urls)!, method: .post, parameters: parameters, encoder: JSONParameterEncoder.sortedKeys)
                        .responseString { (responses) in
                            print(responses)
                            let data = responses.data
                            let data_error:Data! = UIImage(named: "DSC_0775")?.pngData()
//                            let
                            let res: UIImage! = UIImage(data: data ?? data_error)
                            self.testImage.image = res
//                            self.testImage.contentMode = .scaleAspectFit
                            
        }
                            }
    //MARK:- 🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟
    @objc func demoCameera(){
        openCamera()
    }
    
    @objc func demoClicked(){
        openAlbum()
    }
    
    //打开相册
    
    func openAlbum(){
        //判断设置是否支持图片库
        
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary){
            //初始化图片控制器
            let picker = UIImagePickerController()
            //设置代理
            picker.delegate = self
            //指定图片控制器类型
            picker.sourceType = UIImagePickerController.SourceType.photoLibrary
            //设置是否允许编辑
            
            picker.allowsEditing = true
            
            
            //弹出控制器，显示界面
            self.present(picker, animated:true, completion: {
                () -> Void in
            })
        }else{
            print("读取相册错误")
        }
        
    }
    
    
    
    func openCamera(){
        if UIImagePickerController.isSourceTypeAvailable(.camera){
            
            //创建图片控制器
            let picker = UIImagePickerController()
            //设置代理
            picker.delegate = self
            //设置来源
            picker.sourceType = UIImagePickerController.SourceType.camera
            //允许编辑
            picker.allowsEditing = true
            
//            picker.mediaTypes
            //打开相机
            self.present(picker, animated:true, completion: { () -> Void in})
            
        }else{
            debugPrint("找不到相机")
            
        }
        
    }
    //MARK:- 🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            self.testImage.image = image


        } else if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            self.testImage.image = image

        }
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    //保存图片
    @objc func savedPhotosAlbum(image: UIImage, didFinishSavingWithError error: NSError?, contextInfo: AnyObject) {
        
        if error != nil {
            print("save failed")
        } else {
            print("save succeed")

        }
    }
    //MARK:- ✨手势长按
    func addLongPressGes() {
        //添加长按手势
        let longPressGes = UILongPressGestureRecognizer(target: self, action: #selector(longPressedGesture(recognizer:)))
        longPressGes.minimumPressDuration = 1
        //一定要遵循代理
        longPressGes.delegate = self
//        longpressGes.minimumPressDuration = 1
        self.view.addGestureRecognizer(longPressGes)


    }
    
    @objc func longPressedGesture(recognizer: UILongPressGestureRecognizer) {
        let alertV = UIAlertController()
        let saveAction = UIAlertAction(title: "保存图片", style: .default) { (alertV) in
            UIImageWriteToSavedPhotosAlbum(self.testImage.image!, self, #selector(self.savedPhotosAlbum), nil)
        }
        //取消保存不作处理
        let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        
        alertV.addAction(saveAction)
        alertV.addAction(cancelAction)
        self.present(alertV, animated: true, completion: nil)
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    



}

//不实现该代理方法,长按无效
//MARK: 手势代理方法
extension colorRestoreVC : UIGestureRecognizerDelegate{
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}

 
extension UIImage {
    // 修复图片旋转
    func fixOrientation() -> UIImage {
        if self.imageOrientation == .up {
            return self
        }
         
        var transform = CGAffineTransform.identity
         
        switch self.imageOrientation {
        case .down, .downMirrored:
            transform = transform.translatedBy(x: self.size.width, y: self.size.height)
            transform = transform.rotated(by: .pi)
            break
             
        case .left, .leftMirrored:
            transform = transform.translatedBy(x: self.size.width, y: 0)
            transform = transform.rotated(by: .pi / 2)
            break
             
        case .right, .rightMirrored:
            transform = transform.translatedBy(x: 0, y: self.size.height)
            transform = transform.rotated(by: -.pi / 2)
            break
             
        default:
            break
        }
         
        switch self.imageOrientation {
        case .upMirrored, .downMirrored:
            transform = transform.translatedBy(x: self.size.width, y: 0)
            transform = transform.scaledBy(x: -1, y: 1)
            break
             
        case .leftMirrored, .rightMirrored:
            transform = transform.translatedBy(x: self.size.height, y: 0);
            transform = transform.scaledBy(x: -1, y: 1)
            break
             
        default:
            break
        }
         
        let ctx = CGContext(data: nil, width: Int(self.size.width), height: Int(self.size.height), bitsPerComponent: self.cgImage!.bitsPerComponent, bytesPerRow: 0, space: self.cgImage!.colorSpace!, bitmapInfo: self.cgImage!.bitmapInfo.rawValue)
        ctx?.concatenate(transform)
         
        switch self.imageOrientation {
        case .left, .leftMirrored, .right, .rightMirrored:
            ctx?.draw(self.cgImage!, in: CGRect(x: CGFloat(0), y: CGFloat(0), width: CGFloat(size.height), height: CGFloat(size.width)))
            break
             
        default:
            ctx?.draw(self.cgImage!, in: CGRect(x: CGFloat(0), y: CGFloat(0), width: CGFloat(size.width), height: CGFloat(size.height)))
            break
        }
         
        let cgimg: CGImage = (ctx?.makeImage())!
        let img = UIImage(cgImage: cgimg)
         
        return img
    }
}
//
//  colorRestoreVC.swift
//  Colorful
//
//  Created by fox on 2021/10/4.
//  Copyright © 2021 fox. All rights reserved.
//

import Foundation
import UIKit
import CoreGraphics
import QuartzCore
import AVFoundation
import Alamofire
import SnapKit

typealias CGGammaValue = Float
typealias CGDirectDisplayID = UInt32

@available(iOS 11.0, *)
class colorRestoreVC: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate,UIActionSheetDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    var screenshot: UIImage!
    var imageOverlay: UIImageView!
    var timer: Timer!
    var mainWindow: UIWindow!
    var colorMode: ColorBlindType!
    
    var testImage: UIImageView!
    
    
    override func viewDidAppear(_ animated: Bool) {
        mainWindow = self.view.window

    }
    
    override func viewDidLoad() {
        
//        let longpressGesutre = UILongPressGestureRecognizer(target: self, action: Selector(("handleLongpressGesture:")))
//        //长按时间为1秒
//        longpressGesutre.minimumPressDuration = 1
//        //允许15秒运动
//        longpressGesutre.allowableMovement = 15
//        //所需触摸1次
//        longpressGesutre.numberOfTouchesRequired = 1
//        self.view.addGestureRecognizer(longpressGesutre)
        addLongPressGes()
        
        
        view.backgroundColor = .white
        super.viewDidLoad()
        
        
        
        testImage = UIImageView()
        self.view.addSubview(testImage);
        testImage.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview().offset(-100)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.9)
            make.height.equalToSuperview().multipliedBy(0.7)
        }
//        testImage.image = UIImage(named: "DSC_0775")
        testImage.clipsToBounds = true
        testImage.contentMode = .scaleAspectFit
        testImage.layer.cornerRadius = 10
        
        
        let albumButton = UIButton()
        self.view.addSubview(albumButton)
        albumButton.snp.makeConstraints { (make) in
            make.width.equalTo(testImage).dividedBy(2).offset(-5)
//            make.centerX.equalToSuperview()
            make.left.equalTo(testImage)
            make.top.equalTo(testImage.snp.bottom).offset(10)
            make.height.equalTo(50)
        }

//        albumButton.backgroundColor = #colorLiteral(red: 0.8417847157, green: 0.8507048488, blue: 0.8811554909, alpha: 1)
        albumButton.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.8470588235)
        albumButton.setTitle("相册", for: UIControl.State())
        albumButton.addTarget(self, action: #selector(self.demoClicked), for: .touchUpInside)
        albumButton.layer.cornerRadius = 10
        
        let camButton = UIButton()
        self.view.addSubview(camButton)
        camButton.snp.makeConstraints { (make) in
            make.width.equalTo(testImage).dividedBy(2).offset(-5)
            make.right.equalTo(testImage)
            make.top.equalTo(testImage.snp.bottom).offset(10)
            make.height.equalTo(50)
        }

//        camButton.backgroundColor = #colorLiteral(red: 0.8417847157, green: 0.8507048488, blue: 0.8811554909, alpha: 1)
        camButton.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.8470588235)
        camButton.setTitle("拍照", for: UIControl.State())
        camButton.addTarget(self, action: #selector(self.demoCameera), for: .touchUpInside)
        camButton.layer.cornerRadius = 10
        
        
        let changeButton = UIButton.init(type: .custom)
        self.view.addSubview(changeButton)
        changeButton.snp.makeConstraints { (make) in
            make.width.equalTo(testImage)
            make.centerX.equalToSuperview()
            make.top.equalTo(camButton.snp.bottom).offset(10)
            make.height.equalTo(50)
        }
//        changeButton.frame = CGRect(x: 20, y: nextViewButton.frame.size.height + nextViewButton.frame.origin.y + 20, width: self.view.bounds.size.width - 40, height: 50)
//        changeButton.backgroundColor =  #colorLiteral(red: 0.8417847157, green: 0.8507048488, blue: 0.8811554909, alpha: 1)
        changeButton.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.8470588235)
        changeButton.setTitle("切换", for: UIControl.State())
//        changeButton.addTarget(self, action: #selector(CBController.startColorBlinds), for: .touchUpInside)
        changeButton.addTarget(self, action: #selector(httpConvert), for: .touchUpInside)
        changeButton.layer.cornerRadius = 10
        
        let nextViewButton = UIButton()
        self.view.addSubview(nextViewButton)
        nextViewButton.snp.makeConstraints { (make) in
            make.width.equalTo(testImage)
            make.centerX.equalToSuperview()
            make.top.equalTo(changeButton.snp.bottom).offset(10)
            make.height.equalTo(50)
        }
//        nextViewButton.frame = CGRect(x: 20, y: testImage.frame.size.height + testImage.frame.origin.y + 20, width: self.view.bounds.size.width - 40, height: 50)
//        nextViewButton.backgroundColor = #colorLiteral(red: 0.8417847157, green: 0.8507048488, blue: 0.8811554909, alpha: 1)
        nextViewButton.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.8470588235)
        nextViewButton.setTitle("返回菜单", for: UIControl.State())
        nextViewButton.addTarget(self, action: #selector(self.nextView), for: .touchUpInside)
        nextViewButton.layer.cornerRadius = 10
        
        
    }
    
    @objc func nextView() {
        dismiss(animated: true, completion: nil)
    }
    @objc func httpConvert() {
        
        let urls:String = "http://121.40.64.188:5100/iosTest/"
        //参数
//        let parameters:Dictionary = ["type":"1","name":"customer","password":"123456"]

//        let imgData = getStrFromImage("DSC_0775")
        let imgData = getStrFromImage(testImage.image!)
//        let imgData = testImage.image?.pngData()?.base64EncodedString()
        
        let parameters: [String: [String]] = [
            "imgData": ["\(imgData))"],
            "baz": ["a", "b"],
            "qux": ["x", "y", "z"]
        ]
        //Alamofire 请求实例
        AF.request(URL(string: urls)!, method: .post, parameters: parameters, encoder: JSONParameterEncoder.sortedKeys)
                        .responseString { (responses) in
                            print(responses)
                            let data = responses.data
                            let data_error:Data! = UIImage(named: "DSC_0775")?.pngData()
//                            let
                            let res: UIImage! = UIImage(data: data ?? data_error)
                            self.testImage.image = res
//                            self.testImage.contentMode = .scaleAspectFit
                            
        }
                            }
    //MARK:- 🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟
    @objc func demoCameera(){
        openCamera()
    }
    
    @objc func demoClicked(){
        openAlbum()
    }
    
    //打开相册
    
    func openAlbum(){
        //判断设置是否支持图片库
        
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary){
            //初始化图片控制器
            let picker = UIImagePickerController()
            //设置代理
            picker.delegate = self
            //指定图片控制器类型
            picker.sourceType = UIImagePickerController.SourceType.photoLibrary
            //设置是否允许编辑
            
            picker.allowsEditing = true
            
            
            //弹出控制器，显示界面
            self.present(picker, animated:true, completion: {
                () -> Void in
            })
        }else{
            print("读取相册错误")
        }
        
    }
    
    
    
    func openCamera(){
        if UIImagePickerController.isSourceTypeAvailable(.camera){
            
            //创建图片控制器
            let picker = UIImagePickerController()
            //设置代理
            picker.delegate = self
            //设置来源
            picker.sourceType = UIImagePickerController.SourceType.camera
            //允许编辑
            picker.allowsEditing = true
            
//            picker.mediaTypes
            //打开相机
            self.present(picker, animated:true, completion: { () -> Void in})
            
        }else{
            debugPrint("找不到相机")
            
        }
        
    }
    //MARK:- 🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            self.testImage.image = image


        } else if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            self.testImage.image = image

        }
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    //保存图片
    @objc func savedPhotosAlbum(image: UIImage, didFinishSavingWithError error: NSError?, contextInfo: AnyObject) {
        
        if error != nil {
            print("save failed")
        } else {
            print("save succeed")

        }
    }
    //MARK:- ✨手势长按
    func addLongPressGes() {
        //添加长按手势
        let longPressGes = UILongPressGestureRecognizer(target: self, action: #selector(longPressedGesture(recognizer:)))
        longPressGes.minimumPressDuration = 1
        //一定要遵循代理
        longPressGes.delegate = self
//        longpressGes.minimumPressDuration = 1
        self.view.addGestureRecognizer(longPressGes)


    }
    
    @objc func longPressedGesture(recognizer: UILongPressGestureRecognizer) {
        let alertV = UIAlertController()
        let saveAction = UIAlertAction(title: "保存图片", style: .default) { (alertV) in
            UIImageWriteToSavedPhotosAlbum(self.testImage.image!, self, #selector(self.savedPhotosAlbum), nil)
        }
        //取消保存不作处理
        let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        
        alertV.addAction(saveAction)
        alertV.addAction(cancelAction)
        self.present(alertV, animated: true, completion: nil)
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    



}

//不实现该代理方法,长按无效
//MARK: 手势代理方法
extension colorRestoreVC : UIGestureRecognizerDelegate{
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}

 
extension UIImage {
    // 修复图片旋转
    func fixOrientation() -> UIImage {
        if self.imageOrientation == .up {
            return self
        }
         
        var transform = CGAffineTransform.identity
         
        switch self.imageOrientation {
        case .down, .downMirrored:
            transform = transform.translatedBy(x: self.size.width, y: self.size.height)
            transform = transform.rotated(by: .pi)
            break
             
        case .left, .leftMirrored:
            transform = transform.translatedBy(x: self.size.width, y: 0)
            transform = transform.rotated(by: .pi / 2)
            break
             
        case .right, .rightMirrored:
            transform = transform.translatedBy(x: 0, y: self.size.height)
            transform = transform.rotated(by: -.pi / 2)
            break
             
        default:
            break
        }
         
        switch self.imageOrientation {
        case .upMirrored, .downMirrored:
            transform = transform.translatedBy(x: self.size.width, y: 0)
            transform = transform.scaledBy(x: -1, y: 1)
            break
             
        case .leftMirrored, .rightMirrored:
            transform = transform.translatedBy(x: self.size.height, y: 0);
            transform = transform.scaledBy(x: -1, y: 1)
            break
             
        default:
            break
        }
         
        let ctx = CGContext(data: nil, width: Int(self.size.width), height: Int(self.size.height), bitsPerComponent: self.cgImage!.bitsPerComponent, bytesPerRow: 0, space: self.cgImage!.colorSpace!, bitmapInfo: self.cgImage!.bitmapInfo.rawValue)
        ctx?.concatenate(transform)
         
        switch self.imageOrientation {
        case .left, .leftMirrored, .right, .rightMirrored:
            ctx?.draw(self.cgImage!, in: CGRect(x: CGFloat(0), y: CGFloat(0), width: CGFloat(size.height), height: CGFloat(size.width)))
            break
             
        default:
            ctx?.draw(self.cgImage!, in: CGRect(x: CGFloat(0), y: CGFloat(0), width: CGFloat(size.width), height: CGFloat(size.height)))
            break
        }
         
        let cgimg: CGImage = (ctx?.makeImage())!
        let img = UIImage(cgImage: cgimg)
         
        return img
    }
}
//
//  colorRestoreVC.swift
//  Colorful
//
//  Created by fox on 2021/10/4.
//  Copyright © 2021 fox. All rights reserved.
//

import Foundation
import UIKit
import CoreGraphics
import QuartzCore
import AVFoundation
import Alamofire
import SnapKit

typealias CGGammaValue = Float
typealias CGDirectDisplayID = UInt32

@available(iOS 11.0, *)
class colorRestoreVC: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate,UIActionSheetDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    var screenshot: UIImage!
    var imageOverlay: UIImageView!
    var timer: Timer!
    var mainWindow: UIWindow!
    var colorMode: ColorBlindType!
    
    var testImage: UIImageView!
    
    
    override func viewDidAppear(_ animated: Bool) {
        mainWindow = self.view.window

    }
    
    override func viewDidLoad() {
        
//        let longpressGesutre = UILongPressGestureRecognizer(target: self, action: Selector(("handleLongpressGesture:")))
//        //长按时间为1秒
//        longpressGesutre.minimumPressDuration = 1
//        //允许15秒运动
//        longpressGesutre.allowableMovement = 15
//        //所需触摸1次
//        longpressGesutre.numberOfTouchesRequired = 1
//        self.view.addGestureRecognizer(longpressGesutre)
        addLongPressGes()
        
        
        view.backgroundColor = .white
        super.viewDidLoad()
        
        
        
        testImage = UIImageView()
        self.view.addSubview(testImage);
        testImage.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview().offset(-100)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.9)
            make.height.equalToSuperview().multipliedBy(0.7)
        }
//        testImage.image = UIImage(named: "DSC_0775")
        testImage.clipsToBounds = true
        testImage.contentMode = .scaleAspectFit
        testImage.layer.cornerRadius = 10
        
        
        let albumButton = UIButton()
        self.view.addSubview(albumButton)
        albumButton.snp.makeConstraints { (make) in
            make.width.equalTo(testImage).dividedBy(2).offset(-5)
//            make.centerX.equalToSuperview()
            make.left.equalTo(testImage)
            make.top.equalTo(testImage.snp.bottom).offset(10)
            make.height.equalTo(50)
        }

//        albumButton.backgroundColor = #colorLiteral(red: 0.8417847157, green: 0.8507048488, blue: 0.8811554909, alpha: 1)
        albumButton.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.8470588235)
        albumButton.setTitle("相册", for: UIControl.State())
        albumButton.addTarget(self, action: #selector(self.demoClicked), for: .touchUpInside)
        albumButton.layer.cornerRadius = 10
        
        let camButton = UIButton()
        self.view.addSubview(camButton)
        camButton.snp.makeConstraints { (make) in
            make.width.equalTo(testImage).dividedBy(2).offset(-5)
            make.right.equalTo(testImage)
            make.top.equalTo(testImage.snp.bottom).offset(10)
            make.height.equalTo(50)
        }

//        camButton.backgroundColor = #colorLiteral(red: 0.8417847157, green: 0.8507048488, blue: 0.8811554909, alpha: 1)
        camButton.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.8470588235)
        camButton.setTitle("拍照", for: UIControl.State())
        camButton.addTarget(self, action: #selector(self.demoCameera), for: .touchUpInside)
        camButton.layer.cornerRadius = 10
        
        
        let changeButton = UIButton.init(type: .custom)
        self.view.addSubview(changeButton)
        changeButton.snp.makeConstraints { (make) in
            make.width.equalTo(testImage)
            make.centerX.equalToSuperview()
            make.top.equalTo(camButton.snp.bottom).offset(10)
            make.height.equalTo(50)
        }
//        changeButton.frame = CGRect(x: 20, y: nextViewButton.frame.size.height + nextViewButton.frame.origin.y + 20, width: self.view.bounds.size.width - 40, height: 50)
//        changeButton.backgroundColor =  #colorLiteral(red: 0.8417847157, green: 0.8507048488, blue: 0.8811554909, alpha: 1)
        changeButton.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.8470588235)
        changeButton.setTitle("切换", for: UIControl.State())
//        changeButton.addTarget(self, action: #selector(CBController.startColorBlinds), for: .touchUpInside)
        changeButton.addTarget(self, action: #selector(httpConvert), for: .touchUpInside)
        changeButton.layer.cornerRadius = 10
        
        let nextViewButton = UIButton()
        self.view.addSubview(nextViewButton)
        nextViewButton.snp.makeConstraints { (make) in
            make.width.equalTo(testImage)
            make.centerX.equalToSuperview()
            make.top.equalTo(changeButton.snp.bottom).offset(10)
            make.height.equalTo(50)
        }
//        nextViewButton.frame = CGRect(x: 20, y: testImage.frame.size.height + testImage.frame.origin.y + 20, width: self.view.bounds.size.width - 40, height: 50)
//        nextViewButton.backgroundColor = #colorLiteral(red: 0.8417847157, green: 0.8507048488, blue: 0.8811554909, alpha: 1)
        nextViewButton.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.8470588235)
        nextViewButton.setTitle("返回菜单", for: UIControl.State())
        nextViewButton.addTarget(self, action: #selector(self.nextView), for: .touchUpInside)
        nextViewButton.layer.cornerRadius = 10
        
        
    }
    
    @objc func nextView() {
        dismiss(animated: true, completion: nil)
    }
    @objc func httpConvert() {
        
        let urls:String = "http://121.40.64.188:5100/iosTest/"
        //参数
//        let parameters:Dictionary = ["type":"1","name":"customer","password":"123456"]

//        let imgData = getStrFromImage("DSC_0775")
        let imgData = getStrFromImage(testImage.image!)
//        let imgData = testImage.image?.pngData()?.base64EncodedString()
        
        let parameters: [String: [String]] = [
            "imgData": ["\(imgData))"],
            "baz": ["a", "b"],
            "qux": ["x", "y", "z"]
        ]
        //Alamofire 请求实例
        AF.request(URL(string: urls)!, method: .post, parameters: parameters, encoder: JSONParameterEncoder.sortedKeys)
                        .responseString { (responses) in
                            print(responses)
                            let data = responses.data
                            let data_error:Data! = UIImage(named: "DSC_0775")?.pngData()
//                            let
                            let res: UIImage! = UIImage(data: data ?? data_error)
                            self.testImage.image = res
//                            self.testImage.contentMode = .scaleAspectFit
                            
        }
                            }
    //MARK:- 🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟
    @objc func demoCameera(){
        openCamera()
    }
    
    @objc func demoClicked(){
        openAlbum()
    }
    
    //打开相册
    
    func openAlbum(){
        //判断设置是否支持图片库
        
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary){
            //初始化图片控制器
            let picker = UIImagePickerController()
            //设置代理
            picker.delegate = self
            //指定图片控制器类型
            picker.sourceType = UIImagePickerController.SourceType.photoLibrary
            //设置是否允许编辑
            
            picker.allowsEditing = true
            
            
            //弹出控制器，显示界面
            self.present(picker, animated:true, completion: {
                () -> Void in
            })
        }else{
            print("读取相册错误")
        }
        
    }
    
    
    
    func openCamera(){
        if UIImagePickerController.isSourceTypeAvailable(.camera){
            
            //创建图片控制器
            let picker = UIImagePickerController()
            //设置代理
            picker.delegate = self
            //设置来源
            picker.sourceType = UIImagePickerController.SourceType.camera
            //允许编辑
            picker.allowsEditing = true
            
//            picker.mediaTypes
            //打开相机
            self.present(picker, animated:true, completion: { () -> Void in})
            
        }else{
            debugPrint("找不到相机")
            
        }
        
    }
    //MARK:- 🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            self.testImage.image = image


        } else if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            self.testImage.image = image

        }
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    //保存图片
    @objc func savedPhotosAlbum(image: UIImage, didFinishSavingWithError error: NSError?, contextInfo: AnyObject) {
        
        if error != nil {
            print("save failed")
        } else {
            print("save succeed")

        }
    }
    //MARK:- ✨手势长按
    func addLongPressGes() {
        //添加长按手势
        let longPressGes = UILongPressGestureRecognizer(target: self, action: #selector(longPressedGesture(recognizer:)))
        longPressGes.minimumPressDuration = 1
        //一定要遵循代理
        longPressGes.delegate = self
//        longpressGes.minimumPressDuration = 1
        self.view.addGestureRecognizer(longPressGes)


    }
    
    @objc func longPressedGesture(recognizer: UILongPressGestureRecognizer) {
        let alertV = UIAlertController()
        let saveAction = UIAlertAction(title: "保存图片", style: .default) { (alertV) in
            UIImageWriteToSavedPhotosAlbum(self.testImage.image!, self, #selector(self.savedPhotosAlbum), nil)
        }
        //取消保存不作处理
        let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        
        alertV.addAction(saveAction)
        alertV.addAction(cancelAction)
        self.present(alertV, animated: true, completion: nil)
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    



}

//不实现该代理方法,长按无效
//MARK: 手势代理方法
extension colorRestoreVC : UIGestureRecognizerDelegate{
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}

 
extension UIImage {
    // 修复图片旋转
    func fixOrientation() -> UIImage {
        if self.imageOrientation == .up {
            return self
        }
         
        var transform = CGAffineTransform.identity
         
        switch self.imageOrientation {
        case .down, .downMirrored:
            transform = transform.translatedBy(x: self.size.width, y: self.size.height)
            transform = transform.rotated(by: .pi)
            break
             
        case .left, .leftMirrored:
            transform = transform.translatedBy(x: self.size.width, y: 0)
            transform = transform.rotated(by: .pi / 2)
            break
             
        case .right, .rightMirrored:
            transform = transform.translatedBy(x: 0, y: self.size.height)
            transform = transform.rotated(by: -.pi / 2)
            break
             
        default:
            break
        }
         
        switch self.imageOrientation {
        case .upMirrored, .downMirrored:
            transform = transform.translatedBy(x: self.size.width, y: 0)
            transform = transform.scaledBy(x: -1, y: 1)
            break
             
        case .leftMirrored, .rightMirrored:
            transform = transform.translatedBy(x: self.size.height, y: 0);
            transform = transform.scaledBy(x: -1, y: 1)
            break
             
        default:
            break
        }
         
        let ctx = CGContext(data: nil, width: Int(self.size.width), height: Int(self.size.height), bitsPerComponent: self.cgImage!.bitsPerComponent, bytesPerRow: 0, space: self.cgImage!.colorSpace!, bitmapInfo: self.cgImage!.bitmapInfo.rawValue)
        ctx?.concatenate(transform)
         
        switch self.imageOrientation {
        case .left, .leftMirrored, .right, .rightMirrored:
            ctx?.draw(self.cgImage!, in: CGRect(x: CGFloat(0), y: CGFloat(0), width: CGFloat(size.height), height: CGFloat(size.width)))
            break
             
        default:
            ctx?.draw(self.cgImage!, in: CGRect(x: CGFloat(0), y: CGFloat(0), width: CGFloat(size.width), height: CGFloat(size.height)))
            break
        }
         
        let cgimg: CGImage = (ctx?.makeImage())!
        let img = UIImage(cgImage: cgimg)
         
        return img
    }
}
//
//  colorRestoreVC.swift
//  Colorful
//
//  Created by fox on 2021/10/4.
//  Copyright © 2021 fox. All rights reserved.
//

import Foundation
import UIKit
import CoreGraphics
import QuartzCore
import AVFoundation
import Alamofire
import SnapKit

typealias CGGammaValue = Float
typealias CGDirectDisplayID = UInt32

@available(iOS 11.0, *)
class colorRestoreVC: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate,UIActionSheetDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    var screenshot: UIImage!
    var imageOverlay: UIImageView!
    var timer: Timer!
    var mainWindow: UIWindow!
    var colorMode: ColorBlindType!
    
    var testImage: UIImageView!
    
    
    override func viewDidAppear(_ animated: Bool) {
        mainWindow = self.view.window

    }
    
    override func viewDidLoad() {
        
//        let longpressGesutre = UILongPressGestureRecognizer(target: self, action: Selector(("handleLongpressGesture:")))
//        //长按时间为1秒
//        longpressGesutre.minimumPressDuration = 1
//        //允许15秒运动
//        longpressGesutre.allowableMovement = 15
//        //所需触摸1次
//        longpressGesutre.numberOfTouchesRequired = 1
//        self.view.addGestureRecognizer(longpressGesutre)
        addLongPressGes()
        
        
        view.backgroundColor = .white
        super.viewDidLoad()
        
        
        
        testImage = UIImageView()
        self.view.addSubview(testImage);
        testImage.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview().offset(-100)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.9)
            make.height.equalToSuperview().multipliedBy(0.7)
        }
//        testImage.image = UIImage(named: "DSC_0775")
        testImage.clipsToBounds = true
        testImage.contentMode = .scaleAspectFit
        testImage.layer.cornerRadius = 10
        
        
        let albumButton = UIButton()
        self.view.addSubview(albumButton)
        albumButton.snp.makeConstraints { (make) in
            make.width.equalTo(testImage).dividedBy(2).offset(-5)
//            make.centerX.equalToSuperview()
            make.left.equalTo(testImage)
            make.top.equalTo(testImage.snp.bottom).offset(10)
            make.height.equalTo(50)
        }

//        albumButton.backgroundColor = #colorLiteral(red: 0.8417847157, green: 0.8507048488, blue: 0.8811554909, alpha: 1)
        albumButton.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.8470588235)
        albumButton.setTitle("相册", for: UIControl.State())
        albumButton.addTarget(self, action: #selector(self.demoClicked), for: .touchUpInside)
        albumButton.layer.cornerRadius = 10
        
        let camButton = UIButton()
        self.view.addSubview(camButton)
        camButton.snp.makeConstraints { (make) in
            make.width.equalTo(testImage).dividedBy(2).offset(-5)
            make.right.equalTo(testImage)
            make.top.equalTo(testImage.snp.bottom).offset(10)
            make.height.equalTo(50)
        }

//        camButton.backgroundColor = #colorLiteral(red: 0.8417847157, green: 0.8507048488, blue: 0.8811554909, alpha: 1)
        camButton.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.8470588235)
        camButton.setTitle("拍照", for: UIControl.State())
        camButton.addTarget(self, action: #selector(self.demoCameera), for: .touchUpInside)
        camButton.layer.cornerRadius = 10
        
        
        let changeButton = UIButton.init(type: .custom)
        self.view.addSubview(changeButton)
        changeButton.snp.makeConstraints { (make) in
            make.width.equalTo(testImage)
            make.centerX.equalToSuperview()
            make.top.equalTo(camButton.snp.bottom).offset(10)
            make.height.equalTo(50)
        }
//        changeButton.frame = CGRect(x: 20, y: nextViewButton.frame.size.height + nextViewButton.frame.origin.y + 20, width: self.view.bounds.size.width - 40, height: 50)
//        changeButton.backgroundColor =  #colorLiteral(red: 0.8417847157, green: 0.8507048488, blue: 0.8811554909, alpha: 1)
        changeButton.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.8470588235)
        changeButton.setTitle("切换", for: UIControl.State())
//        changeButton.addTarget(self, action: #selector(CBController.startColorBlinds), for: .touchUpInside)
        changeButton.addTarget(self, action: #selector(httpConvert), for: .touchUpInside)
        changeButton.layer.cornerRadius = 10
        
        let nextViewButton = UIButton()
        self.view.addSubview(nextViewButton)
        nextViewButton.snp.makeConstraints { (make) in
            make.width.equalTo(testImage)
            make.centerX.equalToSuperview()
            make.top.equalTo(changeButton.snp.bottom).offset(10)
            make.height.equalTo(50)
        }
//        nextViewButton.frame = CGRect(x: 20, y: testImage.frame.size.height + testImage.frame.origin.y + 20, width: self.view.bounds.size.width - 40, height: 50)
//        nextViewButton.backgroundColor = #colorLiteral(red: 0.8417847157, green: 0.8507048488, blue: 0.8811554909, alpha: 1)
        nextViewButton.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.8470588235)
        nextViewButton.setTitle("返回菜单", for: UIControl.State())
        nextViewButton.addTarget(self, action: #selector(self.nextView), for: .touchUpInside)
        nextViewButton.layer.cornerRadius = 10
        
        
    }
    
    @objc func nextView() {
        dismiss(animated: true, completion: nil)
    }
    @objc func httpConvert() {
        
        let urls:String = "http://121.40.64.188:5100/iosTest/"
        //参数
//        let parameters:Dictionary = ["type":"1","name":"customer","password":"123456"]

//        let imgData = getStrFromImage("DSC_0775")
        let imgData = getStrFromImage(testImage.image!)
//        let imgData = testImage.image?.pngData()?.base64EncodedString()
        
        let parameters: [String: [String]] = [
            "imgData": ["\(imgData))"],
            "baz": ["a", "b"],
            "qux": ["x", "y", "z"]
        ]
        //Alamofire 请求实例
        AF.request(URL(string: urls)!, method: .post, parameters: parameters, encoder: JSONParameterEncoder.sortedKeys)
                        .responseString { (responses) in
                            print(responses)
                            let data = responses.data
                            let data_error:Data! = UIImage(named: "DSC_0775")?.pngData()
//                            let
                            let res: UIImage! = UIImage(data: data ?? data_error)
                            self.testImage.image = res
//                            self.testImage.contentMode = .scaleAspectFit
                            
        }
                            }
    //MARK:- 🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟
    @objc func demoCameera(){
        openCamera()
    }
    
    @objc func demoClicked(){
        openAlbum()
    }
    
    //打开相册
    
    func openAlbum(){
        //判断设置是否支持图片库
        
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary){
            //初始化图片控制器
            let picker = UIImagePickerController()
            //设置代理
            picker.delegate = self
            //指定图片控制器类型
            picker.sourceType = UIImagePickerController.SourceType.photoLibrary
            //设置是否允许编辑
            
            picker.allowsEditing = true
            
            
            //弹出控制器，显示界面
            self.present(picker, animated:true, completion: {
                () -> Void in
            })
        }else{
            print("读取相册错误")
        }
        
    }
    
    
    
    func openCamera(){
        if UIImagePickerController.isSourceTypeAvailable(.camera){
            
            //创建图片控制器
            let picker = UIImagePickerController()
            //设置代理
            picker.delegate = self
            //设置来源
            picker.sourceType = UIImagePickerController.SourceType.camera
            //允许编辑
            picker.allowsEditing = true
            
//            picker.mediaTypes
            //打开相机
            self.present(picker, animated:true, completion: { () -> Void in})
            
        }else{
            debugPrint("找不到相机")
            
        }
        
    }
    //MARK:- 🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            self.testImage.image = image


        } else if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            self.testImage.image = image

        }
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    //保存图片
    @objc func savedPhotosAlbum(image: UIImage, didFinishSavingWithError error: NSError?, contextInfo: AnyObject) {
        
        if error != nil {
            print("save failed")
        } else {
            print("save succeed")

        }
    }
    //MARK:- ✨手势长按
    func addLongPressGes() {
        //添加长按手势
        let longPressGes = UILongPressGestureRecognizer(target: self, action: #selector(longPressedGesture(recognizer:)))
        longPressGes.minimumPressDuration = 1
        //一定要遵循代理
        longPressGes.delegate = self
//        longpressGes.minimumPressDuration = 1
        self.view.addGestureRecognizer(longPressGes)


    }
    
    @objc func longPressedGesture(recognizer: UILongPressGestureRecognizer) {
        let alertV = UIAlertController()
        let saveAction = UIAlertAction(title: "保存图片", style: .default) { (alertV) in
            UIImageWriteToSavedPhotosAlbum(self.testImage.image!, self, #selector(self.savedPhotosAlbum), nil)
        }
        //取消保存不作处理
        let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        
        alertV.addAction(saveAction)
        alertV.addAction(cancelAction)
        self.present(alertV, animated: true, completion: nil)
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    



}

//不实现该代理方法,长按无效
//MARK: 手势代理方法
extension colorRestoreVC : UIGestureRecognizerDelegate{
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}

 
extension UIImage {
    // 修复图片旋转
    func fixOrientation() -> UIImage {
        if self.imageOrientation == .up {
            return self
        }
         
        var transform = CGAffineTransform.identity
         
        switch self.imageOrientation {
        case .down, .downMirrored:
            transform = transform.translatedBy(x: self.size.width, y: self.size.height)
            transform = transform.rotated(by: .pi)
            break
             
        case .left, .leftMirrored:
            transform = transform.translatedBy(x: self.size.width, y: 0)
            transform = transform.rotated(by: .pi / 2)
            break
             
        case .right, .rightMirrored:
            transform = transform.translatedBy(x: 0, y: self.size.height)
            transform = transform.rotated(by: -.pi / 2)
            break
             
        default:
            break
        }
         
        switch self.imageOrientation {
        case .upMirrored, .downMirrored:
            transform = transform.translatedBy(x: self.size.width, y: 0)
            transform = transform.scaledBy(x: -1, y: 1)
            break
             
        case .leftMirrored, .rightMirrored:
            transform = transform.translatedBy(x: self.size.height, y: 0);
            transform = transform.scaledBy(x: -1, y: 1)
            break
             
        default:
            break
        }
         
        let ctx = CGContext(data: nil, width: Int(self.size.width), height: Int(self.size.height), bitsPerComponent: self.cgImage!.bitsPerComponent, bytesPerRow: 0, space: self.cgImage!.colorSpace!, bitmapInfo: self.cgImage!.bitmapInfo.rawValue)
        ctx?.concatenate(transform)
         
        switch self.imageOrientation {
        case .left, .leftMirrored, .right, .rightMirrored:
            ctx?.draw(self.cgImage!, in: CGRect(x: CGFloat(0), y: CGFloat(0), width: CGFloat(size.height), height: CGFloat(size.width)))
            break
             
        default:
            ctx?.draw(self.cgImage!, in: CGRect(x: CGFloat(0), y: CGFloat(0), width: CGFloat(size.width), height: CGFloat(size.height)))
            break
        }
         
        let cgimg: CGImage = (ctx?.makeImage())!
        let img = UIImage(cgImage: cgimg)
         
        return img
    }
}
//
//  colorRestoreVC.swift
//  Colorful
//
//  Created by fox on 2021/10/4.
//  Copyright © 2021 fox. All rights reserved.
//

import Foundation
import UIKit
import CoreGraphics
import QuartzCore
import AVFoundation
import Alamofire
import SnapKit

typealias CGGammaValue = Float
typealias CGDirectDisplayID = UInt32

@available(iOS 11.0, *)
class colorRestoreVC: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate,UIActionSheetDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    var screenshot: UIImage!
    var imageOverlay: UIImageView!
    var timer: Timer!
    var mainWindow: UIWindow!
    var colorMode: ColorBlindType!
    
    var testImage: UIImageView!
    
    
    override func viewDidAppear(_ animated: Bool) {
        mainWindow = self.view.window

    }
    
    override func viewDidLoad() {
        
//        let longpressGesutre = UILongPressGestureRecognizer(target: self, action: Selector(("handleLongpressGesture:")))
//        //长按时间为1秒
//        longpressGesutre.minimumPressDuration = 1
//        //允许15秒运动
//        longpressGesutre.allowableMovement = 15
//        //所需触摸1次
//        longpressGesutre.numberOfTouchesRequired = 1
//        self.view.addGestureRecognizer(longpressGesutre)
        addLongPressGes()
        
        
        view.backgroundColor = .white
        super.viewDidLoad()
        
        
        
        testImage = UIImageView()
        self.view.addSubview(testImage);
        testImage.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview().offset(-100)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.9)
            make.height.equalToSuperview().multipliedBy(0.7)
        }
//        testImage.image = UIImage(named: "DSC_0775")
        testImage.clipsToBounds = true
        testImage.contentMode = .scaleAspectFit
        testImage.layer.cornerRadius = 10
        
        
        let albumButton = UIButton()
        self.view.addSubview(albumButton)
        albumButton.snp.makeConstraints { (make) in
            make.width.equalTo(testImage).dividedBy(2).offset(-5)
//            make.centerX.equalToSuperview()
            make.left.equalTo(testImage)
            make.top.equalTo(testImage.snp.bottom).offset(10)
            make.height.equalTo(50)
        }

//        albumButton.backgroundColor = #colorLiteral(red: 0.8417847157, green: 0.8507048488, blue: 0.8811554909, alpha: 1)
        albumButton.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.8470588235)
        albumButton.setTitle("相册", for: UIControl.State())
        albumButton.addTarget(self, action: #selector(self.demoClicked), for: .touchUpInside)
        albumButton.layer.cornerRadius = 10
        
        let camButton = UIButton()
        self.view.addSubview(camButton)
        camButton.snp.makeConstraints { (make) in
            make.width.equalTo(testImage).dividedBy(2).offset(-5)
            make.right.equalTo(testImage)
            make.top.equalTo(testImage.snp.bottom).offset(10)
            make.height.equalTo(50)
        }

//        camButton.backgroundColor = #colorLiteral(red: 0.8417847157, green: 0.8507048488, blue: 0.8811554909, alpha: 1)
        camButton.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.8470588235)
        camButton.setTitle("拍照", for: UIControl.State())
        camButton.addTarget(self, action: #selector(self.demoCameera), for: .touchUpInside)
        camButton.layer.cornerRadius = 10
        
        
        let changeButton = UIButton.init(type: .custom)
        self.view.addSubview(changeButton)
        changeButton.snp.makeConstraints { (make) in
            make.width.equalTo(testImage)
            make.centerX.equalToSuperview()
            make.top.equalTo(camButton.snp.bottom).offset(10)
            make.height.equalTo(50)
        }
//        changeButton.frame = CGRect(x: 20, y: nextViewButton.frame.size.height + nextViewButton.frame.origin.y + 20, width: self.view.bounds.size.width - 40, height: 50)
//        changeButton.backgroundColor =  #colorLiteral(red: 0.8417847157, green: 0.8507048488, blue: 0.8811554909, alpha: 1)
        changeButton.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.8470588235)
        changeButton.setTitle("切换", for: UIControl.State())
//        changeButton.addTarget(self, action: #selector(CBController.startColorBlinds), for: .touchUpInside)
        changeButton.addTarget(self, action: #selector(httpConvert), for: .touchUpInside)
        changeButton.layer.cornerRadius = 10
        
        let nextViewButton = UIButton()
        self.view.addSubview(nextViewButton)
        nextViewButton.snp.makeConstraints { (make) in
            make.width.equalTo(testImage)
            make.centerX.equalToSuperview()
            make.top.equalTo(changeButton.snp.bottom).offset(10)
            make.height.equalTo(50)
        }
//        nextViewButton.frame = CGRect(x: 20, y: testImage.frame.size.height + testImage.frame.origin.y + 20, width: self.view.bounds.size.width - 40, height: 50)
//        nextViewButton.backgroundColor = #colorLiteral(red: 0.8417847157, green: 0.8507048488, blue: 0.8811554909, alpha: 1)
        nextViewButton.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.8470588235)
        nextViewButton.setTitle("返回菜单", for: UIControl.State())
        nextViewButton.addTarget(self, action: #selector(self.nextView), for: .touchUpInside)
        nextViewButton.layer.cornerRadius = 10
        
        
    }
    
    @objc func nextView() {
        dismiss(animated: true, completion: nil)
    }
    @objc func httpConvert() {
        
        let urls:String = "http://121.40.64.188:5100/iosTest/"
        //参数
//        let parameters:Dictionary = ["type":"1","name":"customer","password":"123456"]

//        let imgData = getStrFromImage("DSC_0775")
        let imgData = getStrFromImage(testImage.image!)
//        let imgData = testImage.image?.pngData()?.base64EncodedString()
        
        let parameters: [String: [String]] = [
            "imgData": ["\(imgData))"],
            "baz": ["a", "b"],
            "qux": ["x", "y", "z"]
        ]
        //Alamofire 请求实例
        AF.request(URL(string: urls)!, method: .post, parameters: parameters, encoder: JSONParameterEncoder.sortedKeys)
                        .responseString { (responses) in
                            print(responses)
                            let data = responses.data
                            let data_error:Data! = UIImage(named: "DSC_0775")?.pngData()
//                            let
                            let res: UIImage! = UIImage(data: data ?? data_error)
                            self.testImage.image = res
//                            self.testImage.contentMode = .scaleAspectFit
                            
        }
                            }
    //MARK:- 🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟
    @objc func demoCameera(){
        openCamera()
    }
    
    @objc func demoClicked(){
        openAlbum()
    }
    
    //打开相册
    
    func openAlbum(){
        //判断设置是否支持图片库
        
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary){
            //初始化图片控制器
            let picker = UIImagePickerController()
            //设置代理
            picker.delegate = self
            //指定图片控制器类型
            picker.sourceType = UIImagePickerController.SourceType.photoLibrary
            //设置是否允许编辑
            
            picker.allowsEditing = true
            
            
            //弹出控制器，显示界面
            self.present(picker, animated:true, completion: {
                () -> Void in
            })
        }else{
            print("读取相册错误")
        }
        
    }
    
    
    
    func openCamera(){
        if UIImagePickerController.isSourceTypeAvailable(.camera){
            
            //创建图片控制器
            let picker = UIImagePickerController()
            //设置代理
            picker.delegate = self
            //设置来源
            picker.sourceType = UIImagePickerController.SourceType.camera
            //允许编辑
            picker.allowsEditing = true
            
//            picker.mediaTypes
            //打开相机
            self.present(picker, animated:true, completion: { () -> Void in})
            
        }else{
            debugPrint("找不到相机")
            
        }
        
    }
    //MARK:- 🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟
    
 