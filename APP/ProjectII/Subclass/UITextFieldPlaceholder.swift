//
//  UITextFieldPlaceholder.swift
//  AIArtGenerator
//
//  Created by Tap Dev5 on 05/10/2022.
//

import UIKit

class UITextFieldPlaceholder: UITextField {

    func setPlaceHolder(text: String) {
        attributedPlaceholder = NSAttributedString(string: text)
    }

}

class UITextViewPlaceholder: UITextView {
    @IBInspectable var placeHolder: String = ""
    @IBInspectable var placeHolderColor: UIColor = UIColor(white: 1, alpha: 0.5)
    
    let label: UILabel = {
        let label = UILabel()
       
        label.isUserInteractionEnabled = false
        
        return label
    }()
    
    private var didLoad = false
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        if didLoad { return }
        didLoad = true
        
        addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        
        label.font = font
        label.text = placeHolder
        label.textColor = placeHolderColor
        
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 5),
            label.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 5),
            label.centerYAnchor.constraint(equalTo: centerYAnchor),
        ])
    }

    override var text: String! {
        didSet {
            label.text = text.isEmpty ? placeHolder : ""
        }
    }
    
//    override func becomeFirstResponder() -> Bool {
//        label.text = ""
//        
//        return super.becomeFirstResponder()
//    }
//    
//    override func resignFirstResponder() -> Bool {
//        if let text = text {
//            label.text = text.isEmpty ? placeHolder : ""
//        } else {
//            label.text = ""
//        }
//        
//        return super.resignFirstResponder()
//    }
}
