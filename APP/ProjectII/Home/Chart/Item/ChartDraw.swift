//
//  ChartDraw.swift
//  ProjectII
//
//  Created by Azuby on 02/02/2023.
//

import UIKit

class ChartDraw: UIView {
    private let INSET: CGFloat = 35
    
    weak var model: StorageValueCollection!
    weak var scroll: UIScrollView!
    weak var popupV: ChartPopup!
    
    private var didLoad = false
    
    private let xyLine = CAShapeLayer()
    private let arrowLine = CAShapeLayer()
    private let chartLine = CAShapeLayer()
    private let chartPoint = CAShapeLayer()
    private let chartDot = CAShapeLayer()
    private let path = UIBezierPath()
    
    private var timeRange: ClosedRange<CGFloat> = 0.0...0.0
    private var valueRange: ClosedRange<CGFloat> = 0.0...0.0
    private var values = [StorageValue]()
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        if didLoad { return }
        didLoad = true
        
        let popup = ChartPopup()
        popup.gestureRecognizers = [UIHoverGestureRecognizer(target: self, action: #selector(hover))]
        findViewController()?.view.addSubview(popup)
            
        popupV = popup
        
        layer.addSublayer(xyLine)
        layer.addSublayer(arrowLine)
        layer.addSublayer(chartLine)
        layer.addSublayer(chartPoint)
        layer.addSublayer(chartDot)
        
        NotificationCenter.default.addObserver(self, selector: #selector(update), name: Notification.Name("storage.update"), object: nil)
    }
    
    override func layoutSubviews() {
        update()
    }
    
    @objc func hover(g: UIHoverGestureRecognizer) {
        if g.state == .changed {
            dotHover(g.location(in: self))
        }
        if g.state == .ended || g.state == .cancelled {
            dotHover()
            popup(value: nil, souceP: .zero)
        }
    }
    
    @objc func update() {
        drawOxy()
        drawValue()
    }

    private func drawOxy() {
        // Oxy
        
        if !didLoad { return }
        
        path.removeAllPoints()
        
        path.move(to: CGPoint(x: INSET, y: INSET))
        path.addLine(to: CGPoint(x: INSET, y: bounds.height - INSET))
        path.addLine(to: CGPoint(x: bounds.width - INSET, y: bounds.height - INSET))
        
        xyLine.path = path.cgPath.copy(strokingWithWidth: 2, lineCap: .round, lineJoin: .round, miterLimit: 0)
        xyLine.fillColor = UIColor.white.cgColor
        
        path.removeAllPoints()
        
        path.move(to: CGPoint(x: INSET - 5, y: INSET + 10))
        path.addLine(to: CGPoint(x: INSET + 5, y: INSET + 10))
        path.addLine(to: CGPoint(x: INSET + 1, y: INSET))
        path.addLine(to: CGPoint(x: INSET - 1, y: INSET))
        path.addLine(to: CGPoint(x: INSET - 5, y: INSET + 10))
        
        path.move(to: CGPoint(x: bounds.width - (INSET + 10), y: bounds.height - (INSET - 5)))
        path.addLine(to: CGPoint(x: bounds.width - (INSET + 10), y: bounds.height - (INSET + 5)))
        path.addLine(to: CGPoint(x: bounds.width - INSET, y: bounds.height - (INSET + 1)))
        path.addLine(to: CGPoint(x: bounds.width - INSET, y: bounds.height - (INSET - 1)))
        path.addLine(to: CGPoint(x: bounds.width - (INSET + 10), y: bounds.height - (INSET - 5)))

        arrowLine.path = path.cgPath
        arrowLine.fillColor = UIColor.white.cgColor
    }
    
    func drawValue() {
        // Value
        if !didLoad { return }
        
        // Style 1: 1, 3, 5, 7, ∞ day --------------------
        
        let index = scroll.frame.height > 100 ? Int(scroll.contentOffset.y / scroll.frame.height) : 0
        timeRange = [
            0: model.getTimeRangeToLast(), // full time
            1: model.getTimeRangeToLast(in: 864/*00*/ * 7), // 1 week
            2: model.getTimeRangeToLast(in: 864/*00*/ * 5), // 5 day
            3: model.getTimeRangeToLast(in: 864/*00*/ * 3), // 3 day
            4: model.getTimeRangeToLast(in: 864/*00*/), // 1 day
        ][index] ?? 0.0...0.0
        
        // -----------------------------------------------
        
        // Style 2: % day --------------------------------

//        let percent = scroll.frame.height > 100 ? (scroll.contentOffset.y / (scroll.frame.height * 5)) : 0
//        let trangeMax = model.getTimeRangeToLast()
//        let timeRange: ClosedRange<CGFloat> = ((trangeMax.upperBound - trangeMax.lowerBound) * percent + trangeMax.lowerBound)...trangeMax.upperBound
        
        // -----------------------------------------------

        valueRange = model.getValueRange()
        values = model.getValues(timeRange: timeRange)
        
        if values.count == 1 {
            path.removeAllPoints()
            
            chartLine.path = path.cgPath
            
            path.append(UIBezierPath(arcCenter: CGPoint(x: getX(0.5, 0...1), y: getY(0.5, 0...1)),
                                     radius: 4, startAngle: 0, endAngle: .pi * 2, clockwise: true))
            
            chartPoint.path = path.cgPath
            chartPoint.fillColor = UIColor._red.cgColor
            
            return
        }
        
        path.removeAllPoints()
        
        if let value = values.first {
            path.move(to: CGPoint(x: getX(value.getDate().timeIntervalSince1970, timeRange),
                                  y: getY(value.getValue(), valueRange)))
        }
        
        for value in values {
            path.addLine(to: CGPoint(x: getX(value.getDate().timeIntervalSince1970, timeRange),
                                     y: getY(value.getValue(), valueRange)))
        }
        
        chartLine.path = path.cgPath.copy(strokingWithWidth: 2, lineCap: .round, lineJoin: .round, miterLimit: 0)
        chartLine.fillColor = UIColor._red.cgColor
        
        path.removeAllPoints()
        
        for value in values {
            path.append(UIBezierPath(arcCenter: CGPoint(x: getX(value.getDate().timeIntervalSince1970, timeRange),
                                                        y: getY(value.getValue(), valueRange)),
                                     radius: 4, startAngle: 0, endAngle: .pi * 2, clockwise: true))
        }
        
        chartPoint.path = path.cgPath
        chartPoint.fillColor = UIColor._red.cgColor
    }
    
    func dotHover(_ point: CGPoint? = nil) {
        path.removeAllPoints()
        
        var sourceP = CGPoint.zero
        
        if values.count == 1 {
            sourceP = CGPoint(x: getX(0.5, 0...1), y: getY(0.5, 0...1))
            path.append(UIBezierPath(arcCenter: sourceP, radius: point == nil ? 0 : 7,
                                     startAngle: 0, endAngle: .pi * 2, clockwise: true))
            popup(value: values.first, souceP: sourceP)
        } else if let point = point {
            for value in values {
                if value == getValueBy(point, timeRange: timeRange) {
                    sourceP = CGPoint(x: getX(value.getDate().timeIntervalSince1970, timeRange),
                                      y: getY(value.getValue(), valueRange))
                    path.append(UIBezierPath(arcCenter: sourceP, radius: 7,
                                             startAngle: 0, endAngle: .pi * 2, clockwise: true))
                    popup(value: value, souceP: sourceP)
                }
            }
        }
        
        chartDot.path = path.cgPath.copy(strokingWithWidth: 2, lineCap: .round, lineJoin: .round, miterLimit: 0)
        chartDot.fillColor = UIColor._white.cgColor
    }
    
    private func getX(_ value: CGFloat, _ range: ClosedRange<CGFloat>) -> CGFloat {
        if range.upperBound - range.lowerBound < 0.00001 {
            return range.lowerBound
        }
        let percent = (value - range.lowerBound) / (range.upperBound - range.lowerBound)
        return (bounds.width - INSET * 2 - 10) * percent + INSET
    }
    
    private func getY(_ value: CGFloat, _ range: ClosedRange<CGFloat>) -> CGFloat {
        if range.upperBound - range.lowerBound < 0.00001 {
            return range.lowerBound
        }
        let percent = (value - range.lowerBound) / (range.upperBound - range.lowerBound)
        return (bounds.height - INSET * 2 - 10) * (1 - percent) + INSET + 10
    }
    
    private func getValueBy(_ point: CGPoint, timeRange: ClosedRange<CGFloat>) -> StorageValue? {
        let percent = (point.x - INSET) / (bounds.width - INSET * 2 - 10)
        let time = percent * (timeRange.upperBound - timeRange.lowerBound) + timeRange.lowerBound
        var value = values.first
        for v in values {
            if let curr = value?.getDate().timeIntervalSince1970,
               (abs(v.getDate().timeIntervalSince1970 - time) < abs(curr - time)) {
                value = v
            }
        }
        
        return value
    }
}

extension ChartDraw {
    private func popup(value: StorageValue?, souceP: CGPoint) {
        popupV.value = value
        if let vc = findViewController() {
            popupV.action(at: convert(souceP, to: vc.view))
        }
    }
}
