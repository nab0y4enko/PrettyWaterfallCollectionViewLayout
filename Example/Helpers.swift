//
//  Helpers.swift
//  PrettyCollectionViewWaterfallLayout
//
//  Created by Oleksii Naboichenko on 12/7/16.
//  Copyright © 2016 Oleksii Naboichenko. All rights reserved.
//

import Foundation
import CoreGraphics
import UIKit

public extension UInt32 {
    
    public static func random(lower: UInt32 = min, upper: UInt32 = max) -> UInt32 {
        return arc4random_uniform(upper - lower) + lower
    }
}

public extension CGSize {
    
    public static func random(lower: UInt32 = 0, upper: UInt32 = UInt32.max) -> CGSize {
        let randomWeight = CGFloat(UInt32.random(lower: lower, upper: upper))
        let randomHeight = CGFloat(UInt32.random(lower: lower, upper: upper))
        return CGSize(width: randomWeight, height: randomHeight)
    }
}

public extension UIColor {
    
    public static func random() -> UIColor {
        let randomRed = CGFloat(UInt32.random(lower: 0, upper: 255)) / 255.0
        let randomGreen = CGFloat(UInt32.random(lower: 0, upper: 255)) / 255.0
        let randomBlue = CGFloat(UInt32.random(lower: 0, upper: 255)) / 255.0
        return UIColor(red: randomRed, green: randomGreen, blue: randomBlue, alpha: 1.0)
    }
}

