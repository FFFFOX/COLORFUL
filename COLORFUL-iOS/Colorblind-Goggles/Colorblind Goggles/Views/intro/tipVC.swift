//
//  tipVC.swift
//  fakeUI
//
//  Created by fox on 2021/9/23.
//

import Foundation
import UIKit
import Alamofire

class tipVC: UIViewController {
    let upperLabel = UILabel()
    let detailLabel = UILabel()
    let continueBtn = UIButton()
    
    let testPic = UIImageView()
    
    let textAttributes = [NSAttributedString.Key.font:UIFont.systemFont(ofSize: 36, weight: .bold),NSAttributedString.Key.foregroundColor:UIColor.black]
    let detailAttributes = [NSAttributedString.Key.font:UIFont.systemFont(ofSize: 18, weight: .light),NSAttributedString.Key.foregroundColor:UIColor.gray]

    
    override func viewDidLoad() {
        view.backgroundColor = .white
        super.viewDidLoad()
        
        view.addSubview(testPic)
        view.addSubview(upperLabel)
        view.addSubview(detailLabel)
        view.addSubview(continueBtn)

        //MARK:- upperLabel约束
        upperLabel.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(100)
            make.centerX.equalToSuperview()
        }
        upperLabel.attributedText = NSAttributedString(string: "温馨提示", attributes: textAttributes)
        
        //MARK:- detailLabel约束
        detailLabel.snp.makeConstraints { (make) in
            make.top.equalTo(upperLabel.snp.bottom).offset(50)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().dividedBy(1.5)
        }
        
        detailLabel.attributedText = NSAttributedString(string: "\"为了应用的使用能够更贴切您的使用情况，我们邀请您参与视觉测试。\"", attributes: detailAttributes)
        detailLabel.lineBreakMode = .byCharWrapping
        detailLabel.numberOfLines = 0
        
        //MARK:- continueBtn约束
        continueBtn.snp.makeConstraints { (make) in
            make.top.equalTo(view.snp.bottom).offset(-150)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().dividedBy(1.5)
            make.height.equalTo(50)
        }
//        let continueAttributes = [NSAttributedString.Key.font:UIFont.systemFont(ofSize: 18, weight: .light),NSAttributedString.Key.foregroundColor:UIColor.gray]
        continueBtn.setTitle("继续", for: .normal)
        continueBtn.addTarget(self, action: #selector(nextVC), for: .touchUpInside)
        continueBtn.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.8470588235)
        continueBtn.layer.cornerRadius = 10
        
    }
    @objc func nextVC(){
        let menu = menuVC()
        menu.modalPresentationStyle = .fullScreen
        menu.modalTransitionStyle = .flipHorizontal
        self.present(menu, animated: true, completion: nil)
        
        //MARK:- Http
        //接口地址
//        let urls:String = "http://192.168.3.98:5100/iosTest/"
//        //参数
////        let parameters:Dictionary = ["type":"1","name":"customer","password":"123456"]
//
//        let imgData = getStrFromImage("send")
//
//        let parameters: [String: [String]] = [
//            "imgData": ["\(imgData)"],
//            "baz": ["a", "b"],
//            "qux": ["x", "y", "z"]
//        ]
//        //Alamofire 请求实例
//        AF.request(URL(string: urls)!, method: .post, parameters: parameters, encoder: JSONParameterEncoder.sortedKeys)
//                        .responseString { (responses) in
////                            let ste:String = responses.value ?? ""
////
////                            let dic = getDictionaryFromJSONString(jsonString: ste)
////                            let str:String = dic["img"]! as! String
//                            print(responses)
//
//
////                            let base64Data = NSData(base64Encoded:responses.value ?? "", options:NSData.Base64DecodingOptions(rawValue: 0))
//                            let res: UIImage = UIImage(data: responses.data!)!
//                            self.testPic.image = res
//                            self.testPic.contentMode = .scaleAspectFit
//                            self.testPic.snp.makeConstraints{(make) in
//                                make.top.equalTo(self.upperLabel.snp.bottom).offset(50)
//                                make.centerX.equalToSuperview()
//                                make.width.equalToSuperview().dividedBy(1.2)
//                                make.height.equalToSuperview().dividedBy(2)
//                            }
//
//                            self.detailLabel.attributedText = NSAttributedString(string: "\(ste)", attributes: self.detailAttributes)
//        }
        // Do any additional setup after loading the view.
//MARK:- 🌟🌟原始
//        upperLabel.attributedText = NSAttributedString(string: "视觉测试", attributes: textAttributes)
//        //MARK:- 动画样本，临时，前后两个动画
//        UIView.animate(withDuration: 0.1, delay: 0, options: .curveLinear, animations: {
//            self.detailLabel.alpha = 0
//        }, completion: { (true) in
//            UIView.animate(withDuration: 0.1, delay: 0, options: .curveLinear, animations: {
//                self.testPic.image = UIImage(named: "DSC_0775")
//                self.testPic.contentMode = .scaleAspectFit
//                self.testPic.snp.makeConstraints{(make) in
//                    make.top.equalTo(self.upperLabel.snp.bottom).offset(50)
//                    make.centerX.equalToSuperview()
//                    make.width.equalToSuperview().dividedBy(1.2)
//                    make.height.equalToSuperview().dividedBy(2)
//                }
//            }, completion: nil)
//        })
//
//
//
//        continueBtn.addTarget(self, action: #selector(toMenu), for: .touchUpInside)
        
    }
    @objc func toMenu(){
        let menu = menuVC()
        menu.modalPresentationStyle = .fullScreen
        menu.modalTransitionStyle = .flipHorizontal
        self.present(menu, animated: true, completion: nil)
        
    }
    
        
        
        
        
}
