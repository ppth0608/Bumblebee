//
//  String+Bumblebee.swift
//  Bumblebee
//
//  Created by Naver on 2018. 6. 24..
//  Copyright © 2018년 benpark. All rights reserved.
//

import Foundation

extension String {
    
    var specialCharacterEncoded: String {
        let allowedCharacterSet = CharacterSet(charactersIn: "!*'();:@&=+$,/?%#[] ").inverted
        return addingPercentEncoding(withAllowedCharacters: allowedCharacterSet) ?? ""
    }
}
