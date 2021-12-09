//
//  Colorblind.swift
//  Colorblind Goggles
//
//  Created by Edmund Dipple on 26/11/2015.
//  Copyright © 2015 Edmund Dipple. All rights reserved.
//
// THIS IS SLOW, DO NOT USE.

import Foundation

class ColourblindFilter{

enum FilterType {
    case Protanopia
    case Deuteranopia
    case Tritanopia
    case Monochromatic
}

    func RGBAtoLMSA(R:Double,G:Double,B:Double,A:Double) -> (L:Double,M:Double,S:Double,A:Double){
    let L = (17.8824 * (R)) + (43.5161 * (G)) + (4.11935 * (B))
    let M = (3.45565 * (R)) + (27.1554 * (G)) + (3.86714 * (B))
    let S = (0.0299566 * (R)) + (0.184309 * (G)) + (1.46709 * (B))
    return (L,M,S,A)
}
    
    func minMaxRGBA(val:Double) -> Double{
        if(val < 0){
            return 0
        }
        if(val > 255){
            return 255
        }
        return val
    }
    
    func LMSAtoRGBA(L:Double,M:Double,S:Double,A:Double) -> (R:Double,G:Double,B:Double,A:Double){
    var R = (0.080944 * (L)) - (0.130504 * (M)) + (0.116721 * (S))
    var G = (-0.0102485 * (L)) + (0.0540194 * (M)) - (0.113615 * (S))
    var B = (-0.000365294 * (L)) - (0.00412163 * (M)) + (0.693513 * (S))
    
        R = minMaxRGBA(val: R)
        G = minMaxRGBA(val: G)
        B = minMaxRGBA(val: B)
    
    return (R,G,B,A)
}
    
    func FilterColour(R:Double,G:Double,B:Double,A:Double, f:FilterType) -> (R:Double,G:Double,B:Double,A:Double){
        var (L,M,S,A) = RGBAtoLMSA(R: R, G: G, B: B,A:A)
        
        switch f{
        case .Protanopia:
            L = (0 * (L)) + (2.02344 * (M)) - (2.52581 * (S))
        case .Deuteranopia:
            M = (0.494207 * (L)) + (0 * (M)) + (1.24827 * (S))
        case .Tritanopia:
            S = (0.05 * (M))
        case .Monochromatic:
            S = (0.05 * (M))
            M = (0.494207 * (L)) + (0 * (M)) + (1.24827 * (S))
            L = (0 * (L)) + (2.02344 * (M)) - (2.52581 * (S))
            S = (0.05 * (M))
            M = (0.494207 * (L)) + (0 * (M)) + (1.24827 * (S))
            L = (0 * (L)) + (2.02344 * (M)) - (2.52581 * (S))
        }
    
        return LMSAtoRGBA(L: L, M: M, S: S, A: A)
}
    
}
