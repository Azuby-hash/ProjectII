//
//  ViewController.swift
//  ProjectII
//
//  Created by Azuby on 31/01/2023.
//

import UIKit

extension CALayer {
    open override func setValue(_ value: Any?, forKey key: String) {
        guard key == "borderIBColor", let color = value as? UIColor else {
            super.setValue(value, forKey: key)
            return
        }
        
        self.borderColor = color.cgColor
    }
}

class Home: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }
}

