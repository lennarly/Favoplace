//
//  MainViewController.swift
//  Favoplace
//
//  Created by Lenar Valeev on 06.10.2020.
//  Copyright © 2020 Lenar Valeev. All rights reserved.
//

import UIKit

class MainVC: UITableViewController {
    
    var places = [Place]()

    override func viewDidLoad() {

        // Disable separators for blank cells
        tableView.tableFooterView = UIView()
        
    }

    // MARK: Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return places.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! PlaceCell
        let place = places[indexPath.row]
        
        cell.title.text = place.title
        cell.locationAddress.text = place.locationAddress
        cell.type.text = place.type
        
        cell.imageOfPlace.image = place.imageOfPlace
        cell.imageOfPlace.layer.cornerRadius = cell.imageOfPlace.frame.size.height / 2
        cell.imageOfPlace.clipsToBounds = true

        return cell
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    // MARK: Exit from New place modal
    
    @IBAction func unwindSegue(_ segue: UIStoryboardSegue) {
        
        guard let newPlaceVC = segue.source as? NewPlaceVC else { return }
        let newPlaceObject = newPlaceVC.getNewPlace()
        
        // Add a new place element to the array
        places.append(newPlaceObject)
        
        // Update the table init's
        tableView.reloadData()
        
    }

}
