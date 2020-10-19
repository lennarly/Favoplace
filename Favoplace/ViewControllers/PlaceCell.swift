//
//  CustomTableViewCell.swift
//  Favoplace
//
//  Created by Lenar Valeev on 06.10.2020.
//  Copyright © 2020 Lenar Valeev. All rights reserved.
//

import UIKit

class PlaceCell: UITableViewCell {

    var id = -1
    
    @IBOutlet weak var imageOfPlace: UIImageView!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var locationAddress: UILabel!
    @IBOutlet weak var type: UILabel!
    
}
