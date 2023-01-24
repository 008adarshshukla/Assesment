//
//  Migrator.swift
//  Kwicpic Assesment
//
//  Created by Adarsh Shukla on 24/01/23.
//

import Foundation
import RealmSwift

class Migrator {
    init() {
        updateSchema()
    }
    
    func updateSchema() {
        let config = Realm.Configuration(schemaVersion: 1) { migration, oldSchemaVersion in
            if oldSchemaVersion < 1 {
                migration.enumerateObjects(ofType: DownloadedImages.className()) { _, newObject in
                    newObject!["uploadedBy"] = String()
                    newObject!["uploadedAt"] = String()
                }
            }
        }
        
        Realm.Configuration.defaultConfiguration = config
        let _ = try! Realm()
    }
}
