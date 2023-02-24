//
//  ModelManager.swift
//  ProjectII
//
//  Created by Azuby on 31/01/2023.
//

import UIKit
import Alamofire

class ModelManager {
    
    static let shared = ModelManager()
    
    private let decoder = JSONDecoder()
    private let storage = Storage()
    
    var isFetchEnable = true
    
    weak var req: DataRequest?
    
    func fetch(_ time: CGFloat = 5) {
        req?.cancel()
        if time < 4.8 {
            DispatchQueue.global(qos: .default).asyncAfter(deadline: .now() + 5 - time) {
                self.fetch()
            }
            return
        }
        DispatchQueue.global(qos: .default).async { [self] in
            let date = Date()
            
            req = AF.request("https://api.thingspeak.com/channels/2010355/feeds.json?api_key=Z44QT5NIMCCUG96X&results=1000")
            req?.responseData { [self] res in
                guard let data = res.data,
                      let object = try? decoder.decode(ModelJSON.self, from: data)
                else {
                    // Failed
                    print("Fetch failed in \(date.distance(to: Date()))s")
                    fetch(date.distance(to: Date()))
                    return
                }
                
                // Success
                
                if !isFetchEnable {
                    storage.setPointCheck(object)
                    print("Fetch change success in \(date.distance(to: Date()))s")
                    return
                }
                storage.descriptObject(object)
                
                print("Fetch success in \(date.distance(to: Date()))s")
                fetch(date.distance(to: Date()))
            }
        }
    }
    
    /// WARNING: Do not run outside model
    func post(_ a: CGFloat, _ b: CGFloat, _ c: CGFloat, _ d: CGFloat) {
        let date = Date()
        req?.cancel()
        req = AF.request("https://api.thingspeak.com/update?api_key=3SKAWGZH32NSTQ33&field5=\(a)&field6=\(b)&field7=\(c)&field8=\(d)")
        
        req?.responseData { [self] res in
            guard let data = res.data,
                  let code = String(data: data, encoding: .utf8),
                  code != "0"
            else {
                // Failed
                print("Post failed in \(date.distance(to: Date()))s")
                post(a, b, c, d)
                return
            }
            
            // Success
            
            print("Post success in \(date.distance(to: Date()))s")
        }
    }
    
    func getStorage() -> Storage {
        return storage
    }
}

class ModelJSON: Codable {
    var channel: ModelJSONChannel
    var feeds: [ModelJSONFeed]
}

class ModelJSONChannel: Codable {
    var field1: String
    var field2: String
    var field3: String
    var field4: String
    var field5: String
    var field6: String
    var field7: String
    var field8: String
    var last_entry_id: Int
}

class ModelJSONFeed: Codable {
    var created_at: String
    var entry_id: Int
    var field1: String?
    var field2: String?
    var field3: String?
    var field4: String?
    var field5: String?
    var field6: String?
    var field7: String?
    var field8: String?
}
