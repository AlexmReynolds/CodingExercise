//
//  OTTheme.swift
//  DiningMode
//
//  Created by Alex Reynolds on 2/4/21.
//  Copyright © 2021 OpenTable, Inc. All rights reserved.
//

import UIKit

class OTTheme {
    class func titleFont() -> UIFont {
        return UIFont.systemFont(ofSize: 16.0, weight: .medium)
    }
    
    class func subtitleFont() -> UIFont {
        return UIFont.systemFont(ofSize: 14.0, weight: .regular)
    }
    
    class func cardTitleColor() -> UIColor {
        return UIColor(white: 0.1, alpha: 1.0)
    }
    
    class func cardSubtitleColor() -> UIColor {
        return UIColor(white: 0.15, alpha: 1.0)
    }
}
