//
//  AutoDownloadList.swift
//  Kwicpic Assesment
//
//  Created by Adarsh Shukla on 22/01/23.
//

import Foundation
import SwiftUI
import RealmSwift

final class AutoDownloadList: Object, ObjectKeyIdentifiable {
    @objc dynamic var _id = ""
    @objc dynamic var name = ""
    @objc dynamic var countryCode = ""
    @objc dynamic var phoneNumber = ""
    @objc dynamic var email = ""
    @objc dynamic var avatar = ""
    @objc dynamic var beforeTStamp = ""
    @objc dynamic var afterTStamp = ""
    
    override class func primaryKey() -> String? {
        "_id"
    }
}

