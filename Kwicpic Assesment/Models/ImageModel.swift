//
//  ImageModel.swift
//  Kwicpic Assesment
//
//  Created by Adarsh Shukla on 23/01/23.
//

import Foundation
import SwiftUI

struct ImageDataModel: Codable, Identifiable {
    let id = UUID().uuidString
    var data: Images
    private enum CodingKeys: String, CodingKey {
        case data = "data"
    }
}

struct Images: Codable, Identifiable {
    var id = UUID().uuidString
    var pics: [ImageInfo]
    private enum CodingKeys: String, CodingKey {
        case pics = "pics"
    }
}

struct ImageInfo: Codable, Identifiable, Hashable {
    var id = UUID().uuidString
    var _id: String
    var url: String
    var uploadedBy: String
    var uploadedAt: String
    private enum CodingKeys: String, CodingKey {
        case _id = "_id"
        case url = "url"
        case uploadedBy = "uploadedBy"
        case uploadedAt = "uploadedAt"
    }
}
