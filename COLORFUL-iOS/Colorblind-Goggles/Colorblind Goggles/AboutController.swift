//
//  AboutController.swift
//  Colorblind Goggles
//
//  Created by Edmund Dipple on 01/12/2015.
//  Copyright © 2015 Edmund Dipple. All rights reserved.
//

import UIKit
import WebKit

class AboutController: UIViewController, WKNavigationDelegate  {
    
    @IBOutlet weak var webView: WKWebView!
    @IBOutlet weak var closeButton: UIBarButtonItem!
    @IBAction func clickedCloseButton(sender: Any) {
        self.dismiss(animated: true, completion: {})
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        webView.navigationDelegate = self
        loadAddressURL()
    }
    
    func loadAddressURL(){
        if let url = Bundle.main.url(forResource: "info", withExtension: "html") {
            webView.load(NSURLRequest(url: url) as URLRequest)
        }
    }
    
    public func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
            let url = navigationAction.request.url
            guard url != nil else {
                decisionHandler(.allow)
                return
            }

            if url!.description.lowercased().starts(with: "http://") ||
                url!.description.lowercased().starts(with: "https://")  {
                decisionHandler(.cancel)
                UIApplication.shared.open(url!, options: [:], completionHandler: nil)
            } else {
                decisionHandler(.allow)
            }
    }
    
}
