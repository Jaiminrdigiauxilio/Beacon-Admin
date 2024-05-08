//
//  IBeacon.swift
//  Beacon-Admin
//
//  Created by Kiyaan M Singh on 08/05/24.
//

import Foundation


struct IBeaconData: Codable {
    let data: [IBeacon]
}
struct IBeacon: Codable {
    
    let uuid: String
    let major: String
    let minor: String
    let location: String
    let lat: String
    let long: String
    let msg: String
    let status: String
    let supression: String
    let redirect: String
    let redirectUrl: String?
    let views: Int
    let uniqueViews: Int
    
    enum IBeaconKeys: String, CodingKey {
        case uuid = "UUID"
        case major = "MAJOR"
        case minor = "MINOR"
        case location = "LOCATION"
        case lat = "LOCATION LATITUDE"
        case long = "LOCATION LONGITUDE"
        case msg = "MESSAGE"
        case status = "STATUS"
        case supression = "SUPPRESSION"
        case redirect = "REDIRECT"
        case redirectUrl = "REDIRECT URL"
        case views = "TOTAL VIEWS"
        case uniqueViews = "UNIQUE VIEWS"
    }
}
