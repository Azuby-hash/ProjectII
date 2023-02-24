//
//  UIImageViewBlur.swift
//  AIArtGenerator
//
//  Created by Tap Dev5 on 18/10/2022.
//

import UIKit

class UIImageViewBlur: UIImageView {

    @IBInspectable var blur: CGFloat = 0 {
        didSet {
            image = addBlurTo(value: blur)
        }
    }

    private func addBlurTo(value: CGFloat) -> UIImage? {
        guard let image = image,
              let ciImg = CIImage(image: image) ?? image.ciImage
        else { return nil }
        let blur = CIFilter(name: "CIGaussianBlur")
        blur?.setValue(ciImg, forKey: kCIInputImageKey)
        blur?.setValue(value, forKey: kCIInputRadiusKey)
        if let outputImg = blur?.outputImage {
            return UIImage(ciImage: outputImg.clampedToExtent().cropped(to: ciImg.extent.insetBy(dx: 10, dy: 10)))
        }
        return nil
    }
}
