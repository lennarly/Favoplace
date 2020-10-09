//
//  StorageManager.swift
//  Favoplace
//
//  Created by Lenar Valeev on 09.10.2020.
//  Copyright © 2020 Lenar Valeev. All rights reserved.
//

import RealmSwift

// Get the default Realm
let realm = try! Realm()

class StorageManager {
    
    static func saveObject(_ place: Place) {
        try! realm.write {
            realm.add(place)
        }
    }
    
    static func deleteObject(_ place: Place) {
        try! realm.write {
            realm.delete(place)
        }
    }
    
}
