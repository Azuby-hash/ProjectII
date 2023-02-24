//
//  GetViewController.swift
//  BlurPhoto
//
//  Created by Tap Dev5 on 18/03/2022.
//

import UIKit

extension UIView {

    func findViewController() -> UIViewController? {
        if let nextResponder = self.next as? UIViewController {
            return nextResponder
        } else if let nextResponder = self.next as? UIView {
            return nextResponder.findViewController()
        } else {
            return nil
        }
    }

}
