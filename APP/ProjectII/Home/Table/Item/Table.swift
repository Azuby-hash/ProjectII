//
//  Table.swift
//  ProjectII
//
//  Created by Azuby on 05/02/2023.
//

import UIKit

class Table: UIView, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    @IBOutlet weak var col: UICollectionView!
    @IBOutlet weak var currentValue: UILabel!
    
    weak var model: StorageValueCollection!
    
    private var firstFetch = false
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        let nib = UINib(nibName: "Table", bundle: nil)
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
        
        if let id = restorationIdentifier {
            model = ModelManager.shared.getStorage().getStorage(of: id)
        }
        
        col.register(UINib(nibName: "TableCell", bundle: nil), forCellWithReuseIdentifier: "cell")
        
        col.delegate = self
        col.dataSource = self
        
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
        if let value = model.getValue() {
            let date = value.getDate()
            let formatter = DateFormatter()
            formatter.dateFormat = "HH:mm:ss"
            
            let formatter2 = DateFormatter()
            formatter2.dateFormat = "dd-MM-yyyy"
            
            currentValue.text = "\(model.getName()): \(value.getValue())\(model.getUnit()) at \(formatter.string(from: date)) \(formatter2.string(from: date))"
        }
        col.reloadData()
    }
    
    override func layoutSubviews() {
        col.reloadData()
    }
}

//COLLECTIONVIEW FUNCTION
extension Table {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return model.getUnloopValues().count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as? TableCell
        else { return UICollectionViewCell() }
        
        let value = model.getUnloopValues()[indexPath.row]
        let date = value.getDate()
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        
        let formatter2 = DateFormatter()
        formatter2.dateFormat = "dd-MM-yyyy"
        
        cell.setT("\(model.getName()): \(value.getValue())\(model.getUnit()) at \(formatter.string(from: date)) \(formatter2.string(from: date))")
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: col.bounds.width, height: 36)
    }
}

class TableCell: UICollectionViewCell {
    @IBOutlet weak var valueT: UILabel!

    private var didLoad = false
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        if didLoad { return }
        didLoad = true
    }
    
    func setT(_ text: String) {
        valueT.text = text
    }
}
