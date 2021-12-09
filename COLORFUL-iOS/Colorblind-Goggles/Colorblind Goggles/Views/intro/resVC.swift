//
//  resVC.swift
//  fakeUI
//
//  Created by fox on 2021/9/23.
//

import Foundation
import UIKit
import SnapKit


class resVC: UIViewController {
    
    @IBOutlet weak var toMenu: UIButton!

    
    override func viewDidLoad() {
        toMenu.addTarget(self, action: #selector(jump), for: .touchUpInside)
    }
    @objc func jump(){
        let nextVC = menuVC()
//        nextVC.modalPresentationStyle = .fullScreen
//        self.present(menuVC(), animated: true, completion: nil)
        self.present(nextVC, animated: true, completion: nil)
//        resVC.modalPresentationStyle = UIModalPresentationFullScreen
    }
}

