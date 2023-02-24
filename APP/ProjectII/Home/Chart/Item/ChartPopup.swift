//
//  ChartPopup.swift
//  ProjectII
//
//  Created by Azuby on 04/02/2023.
//

import UIKit

class ChartPopup: UIView {

    @IBOutlet weak var line1: UILabel!
    @IBOutlet weak var line2: UILabel!
    @IBOutlet weak var line3: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        let nib = UINib(nibName: "ChartPopup", bundle: nil)
        guard let view = nib.instantiate(withOwner: self, options: nil).first as? UIView else { return }
        
        view.translatesAutoresizingMaskIntoConstraints = false
        view.clipsToBounds = false
        addSubview(view)
        NSLayoutConstraint.activate([
            view.leadingAnchor.constraint(equalTo: leadingAnchor),
            view.trailingAnchor.constraint(equalTo: trailingAnchor),
            view.topAnchor.constraint(equalTo: topAnchor),
            view.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        
        alpha = 0
        frame.size = CGSize(width: 200, height: 130)
        
        for line in [line1, line2, line3] {
            line?.text = ""
        }
    }
    
    private var didLoad = false
    
    weak var value: StorageValue?
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        if didLoad { return }
        didLoad = true
        
        layoutIfNeeded()
    }

    func action(at point: CGPoint) {
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: .allowUserInteraction) { [self] in
            
            if let _ = value {
                alpha = 1
                frame.origin = point.applying(.init(translationX: -30, y: -bounds.height - 20))
            } else {
                alpha = 0
            }
            
            layoutIfNeeded()
        }
        
        if let value = value {
            line1.text = "\(value.getCol().getName()): \(value.getValue())\(value.getCol().getUnit())"
            
            let date = value.getDate()
            let formatter = DateFormatter()
            formatter.dateFormat = "HH:mm:ss"
            
            let formatter2 = DateFormatter()
            formatter2.dateFormat = "dd-MM-yyyy"
            
            line2.text = "\(formatter.string(from: date))"
            line3.text = "\(formatter2.string(from: date))"
        }
    }
}
