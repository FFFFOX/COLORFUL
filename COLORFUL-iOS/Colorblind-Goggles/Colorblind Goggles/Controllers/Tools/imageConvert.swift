//
//  imageConvert.swift
//  Colorful
//
//  Created by fox on 2021/10/24.
//  Copyright © 2021 fox. All rights reserved.
//

import Foundation
import UIKit
//Base64转UIImage
public func convertStrToImage(_ imageStr:String) ->UIImage?{
     if let data: NSData = NSData(base64Encoded: imageStr, options:NSData.Base64DecodingOptions.ignoreUnknownCharacters)
     {
         if let image: UIImage = UIImage(data: data as Data)
         {
             return image
         }
     }
     return nil
 }

 
 //UIImage转Base64
public func getStrFromImage(_ imageStr:UIImage) -> String{
    let img = imageStr
    let imageOrigin = UIImage.init(data: img.pngData()!)
    if let image = imageOrigin {
     let dataTmp = image.pngData()
     if let data = dataTmp {
         let imageStrTT = data.base64EncodedString()
         return imageStrTT
     }
    }
    return ""
 }


public func getDictionaryFromJSONString(jsonString:String) ->NSDictionary{
 
    let jsonData:Data = jsonString.data(using: .utf8)!
 
    let dict = try? JSONSerialization.jsonObject(with: jsonData, options: .mutableContainers)
    if dict != nil {
        return dict as! NSDictionary
    }
    return NSDictionary()
     
 
}
