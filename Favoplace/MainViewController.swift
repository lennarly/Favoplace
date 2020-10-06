//
//  MainViewController.swift
//  Favoplace
//
//  Created by Lenar Valeev on 06.10.2020.
//  Copyright © 2020 Lenar Valeev. All rights reserved.
//

import UIKit

class MainViewController: UITableViewController {
    
    let publicSpacesArray = [
        "Burzhuyka",
        "Gastro Gallery",
        "Jagger bar",
        "Music Hall 27",
        "Rossinsky"
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return publicSpacesArray.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! CustomTableViewCell
        let publicSpaceTitle = publicSpacesArray[indexPath.row]
        
        cell.title.text = publicSpaceTitle
        cell.locationAddress.text = "Location"
        cell.type.text = "Club"
        cell.imageOfPlace.image = UIImage(named: publicSpaceTitle)
        cell.imageOfPlace.layer.cornerRadius = cell.imageOfPlace.frame.size.height / 2
        cell.imageOfPlace.clipsToBounds = true

        return cell
    }
    
    // MARK: Table view delegate
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
