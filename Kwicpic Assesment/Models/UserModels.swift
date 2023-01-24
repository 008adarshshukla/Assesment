//
//  UserModels.swift
//  Kwicpic Assesment
//
//  Created by Adarsh Shukla on 23/01/23.
//

import Foundation
struct DataModel: Codable, Identifiable {
    let id = UUID().uuidString
    var data: Users
    private enum CodingKeys: String, CodingKey {
        case data = "data"
    }
}

struct Users: Codable, Identifiable {
    let id = UUID().uuidString
    var users: [UserInfo]
    
    private enum CodingKeys: String, CodingKey {
        case users = "users"
    }
}

struct UserInfo: Codable, Identifiable {
    let id = UUID().uuidString
    var _id: String
    var name: String
    var countryCode: String
    var phoneNumber: String
    var email: String?
    var avatar: String
    var groupListLastFetch: String
    
    private enum CodingKeys: String, CodingKey {
        case _id = "_id"
        case name = "name"
        case countryCode = "countryCode"
        case phoneNumber = "phoneNumber"
        case email = "email"
        case avatar = "avatar"
        case groupListLastFetch = "groupListLastFetch"
    }
}

