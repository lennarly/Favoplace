//
//  PlaceModel.swift
//  Favoplace
//
//  Created by Lenar Valeev on 07.10.2020.
//  Copyright © 2020 Lenar Valeev. All rights reserved.
//

import Foundation

struct Place {
    
    var title: String
    var address: String
    var type: String
    var image: String
    
    static let publicSpacesArray = [
        "Burzhuyka",
        "Gastro Gallery",
        "Jagger bar",
        "Music Hall 27",
        "Rossinsky"
    ]
    
    static func getPlaces() -> [Place] {
        
        var places = [Place]()
        
        for place in publicSpacesArray {
            places.append(Place(title: place, address: "Location", type: "Club", image: place))
        }
        
        return places
    }
    
}
