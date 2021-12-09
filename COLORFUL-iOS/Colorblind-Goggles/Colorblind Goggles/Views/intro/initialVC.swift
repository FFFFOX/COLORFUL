//
//  ViewController.swift
//  fakeUI
//
//  Created by fox on 2021/9/23.
//

import UIKit
import SnapKit

class initialVC: UIViewController {
//    var lb =
//    let lb = U
//    var label:UILabel

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        let colorfulLabel = UIButton()
        
        self.view.addSubview(colorfulLabel)
        colorfulLabel.snp.makeConstraints{(make) in
//            make.width.height.equalTo(150)®
            make.center.equalToSuperview()
//            make.centerY.equalTo(view.snp.centerY)
//            make.right.equalTo(view.snp.centerX).offset(-5)
        }
        colorfulLabel.setTitle("COLORFUL", for: .normal)
        colorfulLabel.setTitleColor(.black, for: .normal)
        colorfulLabel.setAttributedTitle(NSAttributedString(string: "COLORFUL", attributes: [NSAttributedString.Key.font:UIFont.systemFont(ofSize: 36)]), for: .normal)
        colorfulLabel.addTarget(self, action: #selector(intoTipVC), for: .touchUpInside)
        
        
    }
    
    @objc func intoTipVC() {
        let nextVC = tipVC()
//        nextVC.modalPresentationStyle = .fullScreen
//        self.present(menuVC(), animated: true, completion: nil)
        self.present(nextVC, animated: true, completion: nil)
    }


}

