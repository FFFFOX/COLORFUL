//
//  ViewController.swift
//  Colorful
//
//  Created by fox on 2021/7/28.
//  Copyright © 2021 fox. All rights reserved.
//

import UIKit
import AVFoundation
import CoreImage
import SnapKit


class TestPicsViewController:UIViewController,UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addViews()
    }
    
    func addViews(){

        let photolibBtn = UIButton()
        self.view.addSubview(photolibBtn)
        photolibBtn.snp.makeConstraints{(make) in
            make.width.height.equalTo(150)
//            make.center.equalToSuperview()
            make.centerY.equalTo(view.snp.centerY)
            make.right.equalTo(view.snp.centerX).offset(-5)
        }
    
        photolibBtn.layer.cornerRadius = 20
        photolibBtn.setTitle("相册", for:UIControl.State.normal)
        photolibBtn.backgroundColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
//        photolibBtn.addTarget(self, action:Selector(demoClicked), for: UIControl.Event.touchUpInside)
        photolibBtn.addTarget(self, action: #selector(demoClicked), for: UIControl.Event.touchUpInside)
        
        
        
        let cameraBtn = UIButton()
        self.view .addSubview(cameraBtn)
        cameraBtn.snp.makeConstraints{(make) in
            make.width.height.equalTo(150)
//            make.center.equalToSuperview()
            make.centerY.equalTo(view.snp.centerY)
            make.left.equalTo(view.snp.centerX).offset(5)
        }
        
        cameraBtn.layer.cornerRadius = 20
        cameraBtn.setTitle("相机", for:UIControl.State.normal)
        cameraBtn.backgroundColor = #colorLiteral(red: 0.8549019694, green: 0.250980407, blue: 0.4784313738, alpha: 1)
        cameraBtn.addTarget(self, action:#selector(demoCameera), for: UIControl.Event.touchUpInside)
    }
    
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
            
            //            picker.allowsEditing = editSwitch.on
            
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
            //打开相机
            self.present(picker, animated:true, completion: { () -> Void in})
            
        }else{
            debugPrint("找不到相机")
            
        }
        
    }
    
    
    
    //选择图片成功后代理
    
    private func imagePickerController(picker: UIImagePickerController,didFinishPickingMediaWithInfo info: [String :AnyObject]) {
        //查看info对象
        print(info)
        //获取选择的原图
        let image = info[UIImagePickerController.InfoKey.originalImage.rawValue]as! UIImage
        
//        imageView.image = image
        
        //图片控制器退出
        picker.dismiss(animated: true, completion: {() -> Void in})
        
    }
    
}

