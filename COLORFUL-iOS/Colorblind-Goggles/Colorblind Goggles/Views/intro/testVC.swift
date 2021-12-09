//
//  testVC.swift
//  fakeUI
//
//  Created by fox on 2021/9/23.
//

import Foundation
import UIKit

class testVC: UIViewController{
    
    @IBOutlet weak var `continue`: UIButton!
    @IBOutlet weak var testRes: UITextField!
    override func viewDidLoad() {
        
        testRes.placeholder = "输入结果..."
        `continue`.layer.cornerRadius = 10

        super.viewDidLoad()
//        testRes.delegate = self
//        //键盘“return”变成“完成”
//        textField.returnKeyType = UIReturnKeyType.done
    }
 
    //textField点击return关闭键盘
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view?.endEditing(false)
        return true
    }
   
}


