//
//  Storage.swift
//  ProjectII
//
//  Created by Azuby on 01/02/2023.
//

import UIKit

class Storage {
    
    enum ValueType: String {
        case temp = "Temp"
        case air = "Air"
        case humi = "Humi"
        case light = "Light"
    }
    
    private var temp: StorageValueCollection = .init(name: "Temperature", unit: "ºC", type: .temp)
    private var air: StorageValueCollection = .init(name: "Air", unit: "%", type: .air)
    private var humi: StorageValueCollection = .init(name: "Humidity", unit: "%", type: .humi)
    private var light: StorageValueCollection = .init(name: "Light", unit: "Lux", type: .light)
    
    private var tempSP: StorageSetPoint = .init(type: .temp)
    private var airSP: StorageSetPoint = .init(type: .air)
    private var humiSP: StorageSetPoint = .init(type: .humi)
    private var lightSP: StorageSetPoint = .init(type: .light)
    
    // Tách dữ liệu vào các biến chứa
    func descriptObject(_ object: [String: [Feed]]) {
        for key in object.keys {
            if (!key.contains("SP")) {
                getStorage(of: key).setValues(object[key]!.map({ feed in
                    return StorageValue(value: feed.value, date: Date(timeIntervalSince1970: feed.date), col: getStorage(of: key))
                }))
            } else {
                if let values = object[key] {
                    let sortValues = values.sorted { f1, f2 in
                        return f1.date < f2.date
                    }
                    
                    if let value = sortValues.last?.value {
                        getSetPoint(of: String(key.dropLast(2))).setValue(value)
                    }
                }
            }
        }
    }
    
    func getAllStorage() -> [StorageValueCollection] {
        return [temp, air, humi, light]
    }
    
    func getAllSetPoint() -> [StorageSetPoint] {
        return [tempSP, airSP, humiSP, lightSP]
    }
    
    func getStorage(of type: String) -> StorageValueCollection {
        return [temp, air, humi, light].first { col in
            return col.getType() == .init(rawValue: type)!
        } ?? temp
    }
    
    func getSetPoint(of type: String) -> StorageSetPoint {
        return [tempSP, airSP, humiSP, lightSP].first { col in
            return col.getType() == .init(rawValue: type)!
        } ?? tempSP
    }
    
    func getCount() -> Int {
        return 4
    }
    
    func setSetPoint(of type: String, _ sp: CGFloat) {
        ModelManager.shared.post((type, sp))
    }
}

class StorageValueCollection {
    private var values: [StorageValue] = []
    private var name: String
    private var unit: String
    private var type: Storage.ValueType
    
    init(name: String, unit: String, type: Storage.ValueType) {
        self.name = name
        self.unit = unit
        self.type = type
    }

    func getName() -> String {
        return name
    }
    
    func getUnit() -> String {
        return unit
    }
    
    func getType() -> Storage.ValueType {
        return type
    }
    
    func setValues(_ values: [StorageValue]) {
        var isChange = false
        
        for value in values {
            if !self.values.contains(value) {
                self.values.append(value)
                isChange = true
            }
        }
        
        // Cập nhật UI khi thay đổi giá trị
        if isChange {
            NotificationCenter.default.post(name: Notification.Name("storage.update"), object: nil)
        }
    }
    
    func getValue(at index: Int? = nil) -> StorageValue? {
        if let index = index {
            return values[index]
        }
        return values.last
    }
    
    func getValues(timeRange: ClosedRange<CGFloat>) -> [StorageValue] {
        return values.filter { e in
            return timeRange.contains(e.getDate().timeIntervalSince1970)
        }
    }
    
    func getValues(valueRange: ClosedRange<CGFloat>) -> [StorageValue] {
        return values.filter { e in
            return valueRange.contains(e.getValue())
        }
    }
    
    func getAllValues() -> [StorageValue] {
        return values
    }
    
    func getUnloopValues() -> [StorageValue] {
        var values = [StorageValue]()
        
        for value in self.values.enumerated() {
            if value.offset > 0 {
                if abs(value.element.getValue() - self.values[value.offset - 1].getValue()) < 0.01 {
                    continue
                }
                values.append(value.element)
            } else {
                values.append(value.element)
            }
        }
        
        return values
    }
    
    func getTimeRangeToLast(in time: CGFloat = .greatestFiniteMagnitude) -> ClosedRange<CGFloat> {
        if let l = values.last?.getDate(),
           let f = values.first(where: { value in
            return value.getDate().distance(to: l) < time
           })?.getDate() {
            
            return f.timeIntervalSince1970...l.timeIntervalSince1970
        }
        if let l = values.last?.getDate().timeIntervalSince1970 {
            return l...l
        }
        return 0.0...0.0
    }
    func getTimeRangeToNow(in time: CGFloat = .greatestFiniteMagnitude) -> ClosedRange<CGFloat> {
        if let f = values.first(where: { value in
            return value.getDate().distance(to: Date()) < time
           })?.getDate() {
            
            return f.timeIntervalSince1970...Date().timeIntervalSince1970
        }
        return Date().timeIntervalSince1970...Date().timeIntervalSince1970
    }
    
    func getValueRange() -> ClosedRange<CGFloat> {
        let vs = values.sorted { a, b in
            return a.getValue() < b.getValue()
        }
        return (vs.first?.getValue() ?? 0.0)...(vs.last?.getValue() ?? 0.0)
    }
}

class StorageValue: Equatable {
    private var value: CGFloat
    private var date: Date
    
    weak var col: StorageValueCollection!
    
    init(value: CGFloat, date: Date, col: StorageValueCollection) {
        self.value = value
        self.date = date
        self.col = col
    }
    
    func getDate() -> Date {
        return date
    }
    
    func getValue() -> CGFloat {
        return value
    }
    
    func getCol() -> StorageValueCollection {
        return col
    }
    
    static func == (lhs: StorageValue, rhs: StorageValue) -> Bool {
        return lhs.value == rhs.value && lhs.date == rhs.date
    }
}

class StorageSetPoint: Equatable {
    private var value: CGFloat
    private var type: Storage.ValueType
    
    init(value: CGFloat = 0, type: Storage.ValueType) {
        self.value = value
        self.type = type
    }
    
    func getValue() -> CGFloat {
        return value
    }
    
    func getType() -> Storage.ValueType {
        return type
    }
    
    func setValue(_ value: CGFloat) {
        let isChange = abs(value - self.value) > 0.9
        
        self.value = value
        
        // Cập nhật UI khi thay đổi giá trị
        if isChange {
            NotificationCenter.default.post(name: Notification.Name("storage.update"), object: nil)
        }
    }
    
    static func == (lhs: StorageSetPoint, rhs: StorageSetPoint) -> Bool {
        return lhs.value == rhs.value
    }
}
