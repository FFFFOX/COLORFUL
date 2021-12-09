//
//  AppDelegate.swift
//  Colorblind Goggles
//
//  Created by Edmund Dipple on 26/11/2015.
//  Copyright © 2015 Edmund Dipple. All rights reserved.
//

import UIKit
import AVFoundation

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    private func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        
        let status:AVAuthorizationStatus = AVCaptureDevice.authorizationStatus(for: AVMediaType.video)
        if(status == AVAuthorizationStatus.authorized) {
            
        } else if(status == AVAuthorizationStatus.denied){
            permissionDenied()
        } else if(status == AVAuthorizationStatus.restricted){
            // restricted
        } else if(status == AVAuthorizationStatus.notDetermined){
            // not determined
            AVCaptureDevice.requestAccess(for: AVMediaType.video, completionHandler: {
                granted in
                if(granted){
                   
                } else {
                    print("Not granted access")
                }
            })
        }

        
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

    func permissionDenied(){
        let alertVC = UIAlertController(title: "Permission to access camera was denied", message: "You need to allow Colorblind Goggles to use the camera in Settings to use it", preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "Open Settings", style: .default) {
            value in
            UIApplication.shared.open(NSURL(string: UIApplication.openSettingsURLString)! as URL)
            })
        
        var hostVC = self.window?.rootViewController
        
        hostVC!.dismiss(animated: true, completion: nil)
        
        while let next = hostVC?.presentedViewController {
            hostVC = next
        }
        
        hostVC?.present(alertVC, animated: true, completion: nil)
    }

}

