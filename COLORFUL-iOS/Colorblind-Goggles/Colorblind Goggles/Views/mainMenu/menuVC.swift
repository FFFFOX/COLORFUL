//
//  menuVC.swift
//  fakeUI
//
//  Created by fox on 2021/9/23.
//

import Foundation
import UIKit

class menuVC: UIViewController {
    let centerView = UIView()
    let upperLabel = UILabel()
    let colorEnhance = UIButton()
    let colorRestore = UIButton()
    let liveRestore = UIButton()
    let drawBoard = UIButton()
//    let view = UIScrollView()

    let textAttributes = [NSAttributedString.Key.font:UIFont.systemFont(ofSize: 36, weight: .bold),NSAttributedString.Key.foregroundColor:UIColor.black]
    
    override func viewDidLoad() {
        colorEnhance.addTarget(self, action: #selector(toColorRestoreVC), for: .touchUpInside)
        colorRestore.addTarget(self, action: #selector(toColorRestoreVC), for: .touchUpInside)
        liveRestore.addTarget(self, action: #selector(toLiveRestoreVC), for: .touchUpInside)
        drawBoard.addTarget(self, action: #selector(toDrawBoardVC), for: .touchUpInside)
        view.backgroundColor = .white
        view.addSubview(upperLabel)
        view.addSubview(centerView)
        centerView.addSubview(drawBoard)
        centerView.addSubview(colorRestore)
        centerView.addSubview(colorEnhance)
        centerView.addSubview(liveRestore)

        
        //MARK:- centerView中心视图约束
        centerView.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
//            make.width.equalToSuperview().multipliedBy(0.9)
            make.width.equalTo(UIScreen.main.bounds.width*0.8)
            make.height.equalTo(centerView.snp.width)
        }
//        centerView.backgroundColor = .red

        
        
        
        

        //MARK:- upperLabel约束
        upperLabel.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(UIScreen.main.bounds.maxY/10)
//            make.top.equalToSuperview()
//            make.topMargin.equalTo(50)
            make.left.equalToSuperview().offset(30)
        }
        upperLabel.attributedText = NSAttributedString(string: "COLORFUL", attributes: textAttributes)
        
        //MARK:- 按钮布局约束
        colorEnhance.snp.makeConstraints { (make) in
            make.top.equalToSuperview()
            make.left.equalToSuperview()
            make.width.equalToSuperview().dividedBy(2).offset(-10)
//            make.height.equalTo(UIScreen.main.bounds.width/2.5)
            make.height.equalTo(colorEnhance.snp.width)

            
        }
//        let raibow 
//        colorEnhance.backgroundColor = #colorLiteral(red: 0.6744468212, green: 0.5742740631, blue: 0.9218419194, alpha: 1)
//        colorEnhance.image(for: .normal) = UIImage(named: "DSC_0775")
        colorEnhance.setImage(UIImage(named: "colorEnhance(off)"), for: .normal)
        colorEnhance.contentMode = .scaleAspectFill
//        colorEnhance.backgroundImage(for: .normal)
        
        colorEnhance.setTitle("色彩增强", for: .normal)
        setShadow(btn: colorEnhance)
        
        
        //MARK:- 色彩还原
        colorRestore.snp.makeConstraints { (make) in
            make.bottom.equalToSuperview()
            make.left.equalToSuperview()
            make.width.equalToSuperview().dividedBy(2).offset(-10)
            make.height.equalTo(colorEnhance.snp.width)

            
        }
//        colorRestore.backgroundColor = #colorLiteral(red: 0.9714084268, green: 0.4418245256, blue: 0.32900244, alpha: 1)
        colorRestore.setImage(UIImage(named: "colorRestore(off)"), for: .normal)
        colorRestore.setTitle("色彩还原", for: .normal)
        setShadow(btn: colorRestore)
        
        //MARK:- 实时增强
        liveRestore.snp.makeConstraints { (make) in
            make.top.equalToSuperview()
            make.right.equalToSuperview()
            make.width.equalToSuperview().dividedBy(2).offset(-10)
            make.height.equalTo(colorEnhance.snp.width)
            
        }
//        liveRestore.backgroundColor = #colorLiteral(red: 0.4121542573, green: 0.6702446342, blue: 1, alpha: 1)
        liveRestore.setImage(UIImage(named: "liveRestore"), for: .normal)

        liveRestore.setTitle("实时增强", for: .normal)
        setShadow(btn: liveRestore)
        print(view.bounds.width)
        
        //MARK:- 多彩绘画
        drawBoard.snp.makeConstraints { (make) in
            make.bottom.equalToSuperview()
            make.right.equalToSuperview()
            make.width.equalToSuperview().dividedBy(2).offset(-10)
            make.height.equalTo(colorEnhance.snp.width)
//            make.height.equalTo()
            
        }
//        drawBoard.backgroundColor = #colorLiteral(red: 0.9773370624, green: 0.8418321013, blue: 0.2442636192, alpha: 1)
        drawBoard.setImage(UIImage(named: "draw(off)"), for: .normal)
        drawBoard.setTitle("多彩绘画", for: .normal)
        setShadow(btn: drawBoard)
        
        

    }//MARK:- viewDidLoad结束
    
    func setShadow(btn:UIButton) -> Void {
        btn.layer.cornerRadius = 20
        btn.layer.shadowColor = UIColor.gray.cgColor
        btn.layer.shadowOpacity = 0.7
        btn.layer.shadowOffset = CGSize(width: -5, height: 5)
    }
    
    @objc func toColorRestoreVC() {
        let nextVC = colorRestoreVC()
        nextVC.modalPresentationStyle = .fullScreen
        self.present(nextVC, animated: true, completion: nil)
    }
    @objc func toLiveRestoreVC() {
//        let nextVC = liveRestoreConfrimVC()
//        let nextVC = liveRestore()
        //从storyboard上创建vc
        let nextVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "confrimStoryboard") as! liveRestoreConfrimVC
//        nextVC.modalPresentationStyle = .fullScreen
        self.present(nextVC, animated: true, completion: nil)
    }
    @objc func toDrawBoardVC() {
        let controller = CanvasPrototypeViewController.instantiate(draws: [Draw()])
        self.present(controller, animated: true, completion: nil)
////
//        let nextVC = drawBoardVC()
//        nextVC.modalPresentationStyle = .fullScreen
//        self.present(nextVC, animated: true, completion: nil)
    }
}
