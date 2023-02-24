//
//  UIViewRect.swift
//  BackgroundEraser2.0
//
//  Created by Tap Dev5 on 16/09/2022.
//

import UIKit

extension UIView {
    ///```
    ///Create a frame that aspect fit with this view or specify bounds - Preview
    ///```
    func aspectFitRect(size: CGSize, specifySize: CGSize? = nil) -> CGRect {
        let bounds = specifySize ?? self.bounds.size
        let percent = min(bounds.width / size.width, bounds.height / size.height)
        let trueSize = CGSize(width: size.width * percent, height: size.height * percent)
        
        return CGRect(origin: CGPoint(x: (bounds.width - trueSize.width) / 2, y: (bounds.height - trueSize.height) / 2), size: trueSize)
    }
    func addConstraintFitBounds(_ firstView: UIView?,_ secondView: UIView?) {
        guard let firstView = firstView,
              let secondView = secondView
        else { return }
        
        firstView.translatesAutoresizingMaskIntoConstraints = false
        secondView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            firstView.leadingAnchor.constraint(equalTo: secondView.leadingAnchor),
            firstView.trailingAnchor.constraint(equalTo: secondView.trailingAnchor),
            firstView.topAnchor.constraint(equalTo: secondView.topAnchor),
            firstView.bottomAnchor.constraint(equalTo: secondView.bottomAnchor),
        ])
    }
    func addConstraintFitBoundsTo(_ view: UIView?) {
        guard let view = view
        else { return }
        
        translatesAutoresizingMaskIntoConstraints = false
        view.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            leadingAnchor.constraint(equalTo: view.leadingAnchor),
            trailingAnchor.constraint(equalTo: view.trailingAnchor),
            topAnchor.constraint(equalTo: view.topAnchor),
            bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }
    static func addConstraintFitBounds(_ firstView: UIView?,_ secondView: UIView?) {
        guard let firstView = firstView,
              let secondView = secondView
        else { return }
        
        firstView.translatesAutoresizingMaskIntoConstraints = false
        secondView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            firstView.leadingAnchor.constraint(equalTo: secondView.leadingAnchor),
            firstView.trailingAnchor.constraint(equalTo: secondView.trailingAnchor),
            firstView.topAnchor.constraint(equalTo: secondView.topAnchor),
            firstView.bottomAnchor.constraint(equalTo: secondView.bottomAnchor),
        ])
    }
}
extension NSLayoutConstraint {
    
    ///```
    ///Constraint equal to 4 direction, constant = 0
    ///```
    static func _fitConstraint(v1: UIView, v2: UIView) {
        v1.translatesAutoresizingMaskIntoConstraints = false
        v2.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            v1.leadingAnchor.constraint(equalTo: v2.leadingAnchor),
            v1.trailingAnchor.constraint(equalTo: v2.trailingAnchor),
            v1.topAnchor.constraint(equalTo: v2.topAnchor),
            v1.bottomAnchor.constraint(equalTo: v2.bottomAnchor),
        ])
    }
}
