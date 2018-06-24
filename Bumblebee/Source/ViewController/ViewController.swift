//
//  ViewController.swift
//  Bumblebee
//
//  Created by Naver on 2018. 6. 24..
//  Copyright © 2018년 benpark. All rights reserved.
//

import UIKit
import BPStatusBarAlert

class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func showStatusBarNotification(message: String) {
        BPStatusBarAlert(duration: 0.3, delay: 2, position: .statusBar)
            .message(message: message)
            .messageColor(color: #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0))
            .bgColor(color: #colorLiteral(red: 0.1777849495, green: 0.1777901053, blue: 0.1777873635, alpha: 1))
            .show()
    }
}
