//
//  SetPoint.swift
//  WSN
//
//  Created by Azuby on 11/02/2023.
//

import UIKit

// Tạo bảng set ngưỡng
class SetPoint: UIView {
    
    private var didLoad = false
    
    weak var model: StorageSetPoint!
    @IBOutlet weak var line1: UILabel!
    @IBOutlet weak var line2: UILabel!
    @IBOutlet weak var curSP: UILabel!
    @IBOutlet weak var spT: UITextField!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        let nib = UINib(nibName: "SetPoint", bundle: nil)
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
        
        transform = .identity.scaledBy(x: 0.3, y: 0.3)
        alpha = 0
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        if didLoad { return }
        didLoad = true
        
        if let id = restorationIdentifier {
            model = ModelManager.shared.getStorage().getSetPoint(of: id)
        }
        
        layoutIfNeeded()
        
        NotificationCenter.default.addObserver(self, selector: #selector(transformer), name: Notification.Name("stackview.hightlight."), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(update), name: Notification.Name("storage.update"), object: nil)
    }
    @objc func transformer(_ noti: Notification) {
        guard let index = noti.object as? Int else { return }
        
        UIView.animate(withDuration: 0.25, delay: index == 1 ? 0.25 : 0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: .allowUserInteraction) { [self] in
            transform = index == 1 ? .identity : .identity.scaledBy(x: 0.3, y: 0.3)
            alpha = index == 1 ? 1 : 0
            
            superview?.layoutIfNeeded()
        }
    }
    
    @objc func update() {
        if let id = restorationIdentifier,
           let temp = ModelManager.shared.getStorage().getStorage(of: id)?.getValue() {
            let value = model.getValue()
            isHidden = false
            
            let date = temp.getDate()
            let formatter = DateFormatter()
            formatter.dateFormat = "HH:mm:ss"
            
            let formatter2 = DateFormatter()
            formatter2.dateFormat = "dd-MM-yyyy"
            
            line1.text = "ESP\(Int(id)! + 1): \(temp.getValue())\(temp.getCol().getUnit()) at \(formatter.string(from: date)) \(formatter2.string(from: date))"
            line2.text = "Threshold cross: \(temp.getValue() > value)"
            
            curSP.text = "\(value)"
        } else {
            isHidden = true
        }
    }
    @IBAction func set(_ sender: Any) {
        if let id = restorationIdentifier,
           let tex = spT.text,
           let dou = Double(tex)
        {
            ModelManager.shared.getStorage().setSetPoint(of: id, CGFloat(dou))
        }
    }
}
