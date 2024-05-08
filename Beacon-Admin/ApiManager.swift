//
//  ApiManager.swift
//  Beacon-Admin
//
//  Created by Jaimin Raval on 08/05/24.
//

import Foundation
import Alamofire


class ApiManager {
    let apiKEY = "234617836746213pdy23uyd2udt1qwtdqwdu231r4231ryfpowf"
    let apiURL = "https://addthispass.com/api/admin-app/"
    let googleApiKey = "AIzaSyA-Yr7YPjO0iJUqIN2HGy7Tms9sLJFijI8"
    

    func fetchAllBeaconsInCard(a:String, c:String) {
//        var beacons: [IBeacon]
        AF.request("https://addthispass.com/api/admin-app/?key=234617836746213pdy23uyd2udt1qwtdqwdu231r4231ryfpowf&function=view&t=beacons&a=\(a)&c=\(c)").response() { response in
            switch response.result {
            case .success(let data):
//                let decoder = JSONDecoder()
//                let res = try decoder.decode([IBeacon].self, from: data!)
                debugPrint("beacon count\(data?.count)")
                debugPrint("API call sucess: \(data)")
                
            case .failure(let err):
                debugPrint("API call failed: \(err)")
            }
        }
    }
    
    
//    have to implelment google location thing before this
//    func addBeaconToCard() {
//
//    }
}
