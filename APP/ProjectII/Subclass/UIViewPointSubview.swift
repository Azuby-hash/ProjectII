//
//  UIViewPointSubview.swift
//  VideoCaption
//
//  Created by Tap Dev5 on 08/06/2022.
//

import UIKit

class UIViewPointSubview: UIView {

    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        var isTouch = false
        for subview in subviews {
            if subview.point(inside: convert(point, to: subview), with: event) && subview.alpha > 0.01 && subview.isUserInteractionEnabled {
                isTouch = true
                break
            }
        }
        return isTouch
    }

}

class UIStackViewForwardPointSubview: UIStackView {

    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        var isTouch = false
        for subview in arrangedSubviews {
            if subview.point(inside: convert(point, to: subview), with: event) && subview.alpha > 0.01 {
                isTouch = true
                break
            }
        }
        return isTouch
    }

}

class UIVisualPointSubview: UIVisualEffectView {
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        var isTouch = false
        for subview in contentView.subviews {
            if subview.point(inside: convert(point, to: subview), with: event) && subview.alpha > 0.01 {
                isTouch = true
                break
            }
        }
        return isTouch
    }
}
