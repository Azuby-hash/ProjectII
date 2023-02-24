//
//  UIViewClicking.swift
//  AIArtGenerator2.0
//
//  Created by Hai Le on 30/11/2022.
//

import UIKit

extension UIView {

    func clickAnimation(toggleColor: UIColor = .white, titleOn: UIColor? = nil, titleOff: UIColor? = nil) {
        guard let previousColor = backgroundColor else { return }
        
        UIView.transition(with: self, duration: 0.2, options: .transitionCrossDissolve) { [self] in
            backgroundColor = toggleColor
        } completion: { _ in
            UIView.transition(with: self, duration: 0.2, options: .transitionCrossDissolve) { [self] in
                backgroundColor = previousColor
            }
        }
        
        if let label = subviews.last as? UILabel {
            UIView.transition(with: label, duration: 0.2, options: .transitionCrossDissolve) {
                label.textColor = titleOn
            } completion: { _ in
                UIView.transition(with: label, duration: 0.2, options: .transitionCrossDissolve) {
                    label.textColor = titleOff
                }
            }
        }
        if let label = subviews.last?.subviews.first(where: { view in
            if let _ = view as? UILabel { return true }
            return false
        }) as? UILabel {
            UIView.transition(with: label, duration: 0.2, options: .transitionCrossDissolve) {
                label.textColor = titleOn
            } completion: { _ in
                UIView.transition(with: label, duration: 0.2, options: .transitionCrossDissolve) {
                    label.textColor = titleOff
                }
            }
        }
    }

}
