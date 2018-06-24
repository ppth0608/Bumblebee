//
//  FloatingPoint+Bumblebee.swift
//  Bumblebee
//
//  Created by Naver on 2018. 6. 24..
//  Copyright © 2018년 benpark. All rights reserved.
//

import Foundation

extension FloatingPoint {
    
    func roundTo(places: Int) -> Self {
        let divisor = Self(Int(pow(10.0, Double(places))))
        return (self * divisor).rounded() / divisor
    }
}
