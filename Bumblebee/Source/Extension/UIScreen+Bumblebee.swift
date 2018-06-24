//
//  UIScreen+Bumblebee.swift
//  Bumblebee
//
//  Created by Naver on 2018. 6. 24..
//  Copyright © 2018년 benpark. All rights reserved.
//

import UIKit

extension UIScreen {
    
    var iPhone10: Bool {
        let width = min(bounds.width, bounds.height)
        let height = max(bounds.width, bounds.height)
        return width > 320 && width <= 400 && height > 800
    }
}
