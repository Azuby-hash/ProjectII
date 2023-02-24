//
//  UIVisualOpacity.swift
//  AIArtGenerator
//
//  Created by Tap Dev5 on 14/10/2022.
//

import UIKit

class UIVisualOpacity: UIVisualEffectView {

    @IBInspectable var opac: CGFloat = 100 {
        didSet {
            alpha = opac / 100
        }
    }

}
