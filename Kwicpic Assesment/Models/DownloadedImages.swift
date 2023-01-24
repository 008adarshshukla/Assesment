//
//  DownloadedImages.swift
//  Kwicpic Assesment
//
//  Created by Adarsh Shukla on 24/01/23.
//

import Foundation
import SwiftUI
import RealmSwift

final class DownloadedImages: Object, ObjectKeyIdentifiable {
    @objc dynamic var _id = ""
    @objc dynamic var url: String = ""
    @objc dynamic var uploadedBy: String = ""
    @objc dynamic var uploadedAt: String = ""
    
    override class func primaryKey() -> String? {
        "_id"
    }
}
