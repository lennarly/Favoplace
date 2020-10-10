//
//  PlaceModel.swift
//  Favoplace
//
//  Created by Lenar Valeev on 07.10.2020.
//  Copyright © 2020 Lenar Valeev. All rights reserved.
//

import RealmSwift

class Place: Object {
    
    @objc dynamic var id = -1
    @objc dynamic var title = ""
    @objc dynamic var locationAddress: String?
    @objc dynamic var type: String?
    @objc dynamic var imageOfPlace: Data?
    
    convenience init(title: String, locationAddress: String?, type: String?, imageOfPlace: Data?) {
        self.init()
        self.id = StorageManager.incrementID()
        self.title = title
        self.locationAddress = locationAddress
        self.type = type
        self.imageOfPlace = imageOfPlace
    }
    
    override static func primaryKey() -> String? {
        return "id"
    }
    
}
