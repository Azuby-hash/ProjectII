//
//  TabSegment.swift
//  ProjectII
//
//  Created by Azuby on 01/02/2023.
//

import UIKit

class TabSegment: UIStackViewHighlight {

    private var didLoad = false
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        if didLoad { return }
        didLoad = true
        
        
    }
    
    override func switchType(g: UITapGestureRecognizer) {
        super.switchType(g: g)
    }
}
