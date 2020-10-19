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
    
    static func incrementID() -> Int {
        return (realm.objects(Place.self).max(ofProperty: "id") as Int? ?? 0) + 1
    }
    
    static func getObject(_ id: Int) -> Place? {
        return realm.objects(Place.self).filter("id == \(id)").first
    }
    
    static func getAll() -> Results<Place>? {
        return realm.objects(Place.self)
    }

    static func updateOrCreate(_ place: Place) {
        try! realm.write {
            realm.add(place, update: .modified)
        }
    }
    
    static func deleteObject(_ place: Place) {
        try! realm.write {
            realm.delete(place)
        }
    }
    
}
