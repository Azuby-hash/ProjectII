//
//  UIViewPointDetect.swift
//  AIArtGenerator
//
//  Created by Tap Dev5 on 22/09/2022.
//

import UIKit

extension UIView {
    func applyTextViewSettings(forcusView: [UIView]) {
        if let view = self as? UIViewPointDetect {
            view.viewToDetect = forcusView
            view.completion = { [self] isPointInside in
                if !isPointInside {
                    DispatchQueue.main.async {
                        self.endEditing(true)
                    }
                }
            }
        }
    }
    func applyAnAction(forcusView: [UIView], completion: ((Bool)->Void)? = nil) {
        if let view = self as? UIViewPointDetect {
            view.viewToDetect = forcusView
            view.completion = completion
        }
    }
}

class UIViewPointDetect: UIView {
    var viewToDetect: [UIView] = []
    var completion: ((Bool)->Void)?
    
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        var check = false
        for view in viewToDetect {
            if view.point(inside: convert(point, to: view), with: event) {
                check = true
                break
            }
        }
        for view in subviews {
            if view.restorationIdentifier == "toolBar",
               view.point(inside: convert(point, to: view), with: event) {
                
                check = true
                break
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
            self.completion?(check)
        }
        
        return super.point(inside: point, with: event)
    }

}
