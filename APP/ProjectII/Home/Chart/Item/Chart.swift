//
//  Chart.swift
//  ProjectII
//
//  Created by Azuby on 01/02/2023.
//

import UIKit

class Chart: UIView, UIScrollViewDelegate {
    
    private var didLoad = false
    
    private let chart = ChartDraw()
    
    private let scroll: UIScrollView = {
        let scroll = UIScrollView()

        scroll.showsVerticalScrollIndicator = false
        scroll.showsHorizontalScrollIndicator = false
        scroll.translatesAutoresizingMaskIntoConstraints = false
        
        let view = UIView()
        scroll.addSubview(view)
        
        view.addConstraintFitBoundsTo(scroll)
        
        NSLayoutConstraint.activate([
            view.widthAnchor.constraint(equalTo: scroll.widthAnchor),
            view.heightAnchor.constraint(equalTo: scroll.heightAnchor, multiplier: 5),
        ])
        
        return scroll
    }()
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        if didLoad { return }
        didLoad = true
        
        addSubview(chart)
        addSubview(scroll)
        scroll.delegate = self
        scroll.addConstraintFitBoundsTo(self)
        chart.addConstraintFitBoundsTo(self)
        
        if let id = restorationIdentifier {
            chart.model = ModelManager.shared.getStorage().getStorage(of: id)
        }
        
        chart.scroll = scroll
        chart.update()

        layoutIfNeeded()
        
        gestureRecognizers = [UIHoverGestureRecognizer(target: self, action: #selector(hover))]
        
        NotificationCenter.default.addObserver(self, selector: #selector(transformer), name: Notification.Name("stackview.hightlight."), object: nil)
    }
    
    @objc func transformer(_ noti: Notification) {
        guard let index = noti.object as? Int else { return }
        
        UIView.animate(withDuration: 0.25, delay: index == 0 ? 0.25 : 0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: .allowUserInteraction) { [self] in
            transform = index == 0 ? .identity : .identity.scaledBy(x: 0.3, y: 0.3)
            alpha = index == 0 ? 1 : 0
            
            superview?.layoutIfNeeded()
        }
    }
    
    @objc func hover(g: UIHoverGestureRecognizer) {
        chart.hover(g: g)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        chart.drawValue()
    }
}
