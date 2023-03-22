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

    // Địa chỉ server
    private var server = "127.0.0.1:3000"
    
    private let decoder = JSONDecoder()
    private let storage = Storage()
    
    weak var req: DataRequest?
    
    // Lấy dữ liệu tất cả các node từ server 5s 1 lần
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
            
            let headers: HTTPHeaders = [
//                "Authorization": "Bearer \(jwt)",
                "Content-type": "application/json",
            ]
            
            req = AF.upload(("{\"password\": \"9797964a-2f5c-41c6-91c1-44aa68308631\"}").data(using: .utf8)!, to: "http://\(server)/get", headers: headers)
            req?.responseData { [self] res in
                guard let data = res.data,
                      let object = try? decoder.decode([String:[Feed]].self, from: data)
                else {
                    // Failed
                    print("Fetch failed in \(date.distance(to: Date()))s")
                    fetch(date.distance(to: Date()))
                    return
                }
                
                // Success
                
                storage.descriptObject(object)
                
                print("Fetch success in \(date.distance(to: Date()))s")
                fetch(date.distance(to: Date()))
            }
        }
    }
    
    // POST ngưỡng lên server
    func post(_ data: (type: String, value: CGFloat)) {
        req?.cancel()

        let date = Date()
        
        let headers: HTTPHeaders = [
//                "Authorization": "Bearer \(jwt)",
            "Content-type": "application/json",
        ]
        
        req = AF.upload(("{\"password\": \"9797964a-2f5c-41c6-91c1-44aa68308631\", \"type\":\"\(data.type)\",\"value\":\(data.value),\"isSP\":true}").data(using: .utf8)!, to: "http://\(server)/post", headers: headers)

        req?.responseData { [self] res in
            guard let data = res.data,
                  let code = String(data: data, encoding: .utf8),
                  code != "0"
            else {
                // Failed
                print("Post failed in \(date.distance(to: Date()))s")
                post(data)
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

class Feed: Codable {
    var value: CGFloat
    var date: CGFloat
}
