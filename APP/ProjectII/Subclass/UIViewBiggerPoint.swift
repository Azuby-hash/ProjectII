//
//  UIViewBiggerPoint.swift
//  VideoCaption
//
//  Created by Tap Dev5 on 25/05/2022.
//

import UIKit

class UIViewBiggerPoint: UIView {
    @IBInspectable var inset: CGPoint = .init(x: -10, y: -10)
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        let rect = self.bounds.insetBy(dx: inset.x, dy: inset.y)
        var isTouch = false
        for subview in subviews {
            if subview.point(inside: convert(point, to: subview), with: event) {
                isTouch = true
                break
            }
        }
        
        return rect.contains(point) || isTouch
    }
}
class UIViewPointOut: UIView {
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        return true
    }
}


class UIVisualBiggerPoint: UIVisualEffectView {
    @IBInspectable var inset: CGPoint = .init(x: -10, y: -10)
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        let rect = self.bounds.insetBy(dx: inset.x, dy: inset.y)
        var isTouch = false
        for subview in subviews {
            if subview.point(inside: convert(point, to: subview), with: event) {
                isTouch = true
                break
            }
        }
        
        return rect.contains(point) || isTouch
    }
}
