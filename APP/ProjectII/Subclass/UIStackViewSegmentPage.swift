//
//  UIStackViewSegmentPage.swift
//  AIArtGenerator
//
//  Created by Tap Dev5 on 21/09/2022.
//

import UIKit

class UIStackViewSegmentPage: UIStackView {

    private var didLoad = false
    
    var index: Int = 0 {
        didSet {
            let index = min(max(index, 0), subviews.count - 1)
            
            leading?.constant = (bounds.width / CGFloat(subviews.count)) * CGFloat(index)
        }
    }
    
    weak var leading: NSLayoutConstraint!
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        if didLoad {
            return
        }
        didLoad = true
        
        layoutIfNeeded()
        
        for contraint in constraints {
            if (contraint.firstAnchor == leadingAnchor || contraint.secondAnchor == leadingAnchor) {
                leading = contraint
            }
        }
    }

}
