//
//  MultitouchScrollView.swift
//  BG Remover
//
//  Created by Nam Le on 7/28/20.
//  Copyright © 2020 Nguyen Trang. All rights reserved.
//

import UIKit

///```
///
///```
class UIScrollViewMultitouch: UIScrollView, UIGestureRecognizerDelegate {

    var passView: UIView?

    override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if passView != nil,
           gestureRecognizer.numberOfTouches == 1,
           gestureRecognizer.location(in: passView).y > 0
        {
            setContentOffset(contentOffset, animated: false)
            setZoomScale(zoomScale, animated: false)
            if let d = delegate {
                d.scrollViewDidEndZooming?(self, with: nil, atScale: 0)
            }
            return false
        }
        return super.gestureRecognizerShouldBegin(gestureRecognizer)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let passView = passView,
              let point = touches.first?.location(in: passView),
              point.y > 0
        else { return }
        passView.touchesBegan(touches, with: event)
    }
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let passView = passView,
              let point = touches.first?.location(in: passView),
              point.y > 0
        else { return }
        passView.touchesMoved(touches, with: event)
    }
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let passView = passView,
              let point = touches.first?.location(in: passView),
              point.y > 0
        else { return }
        passView.touchesEnded(touches, with: event)
    }
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let passView = passView,
              let point = touches.first?.location(in: passView),
              point.y > 0
        else { return }
        passView.touchesCancelled(touches, with: event)
    }
    
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        return true
    }
}

class UIScrollViewForward: UIScrollView {
    weak var passView: UIView?
    
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        guard let passView = passView else { return super.point(inside: point, with: event) }
        
        return passView.point(inside: convert(point, to: passView), with: event)
    }
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        guard let passView = passView else { return super.hitTest(point, with: event) }
        
        return passView.hitTest(convert(point, to: passView), with: event)
    }
}

class UIScrollViewPointOut: UIScrollView {
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        return true
    }
}
