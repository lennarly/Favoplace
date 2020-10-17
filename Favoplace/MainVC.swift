//
//  MainViewController.swift
//  Favoplace
//
//  Created by Lenar Valeev on 06.10.2020.
//  Copyright © 2020 Lenar Valeev. All rights reserved.
//

import UIKit
import RealmSwift

class MainVC: UITableViewController {
    
    // Search Controller
    private let searchController = UISearchController(searchResultsController: nil)
    
    // Query Realm for all places
    private var places = StorageManager.getAll()
    
    // Observe notification
    private var notificationToken: NotificationToken? = nil

    override func viewDidLoad() {
        
        super.viewDidLoad()

        // Disable separators for blank cells
        tableView.tableFooterView = UIView()

        // Observe Results Notifications
        setupObserveNotifications()
        
        // Installing the search controller
        setupSearchController()
        
    }
    
    // MARK: Custom reload data
    
    private func reloadData() {
        self.setupObserveNotifications()
        self.tableView.reloadData()
    }
    
    // MARK: Observe Results Notifications
    
    private func setupObserveNotifications() {
        notificationToken = places?.observe { [weak self] (changes: RealmCollectionChange) in
            
            guard let tableView = self?.tableView else { return }
            
            switch changes {
                case .initial:
                    tableView.reloadData()

                case .update(_, let deletions, let insertions, let modifications):
                    tableView.beginUpdates()
                    
                    tableView.deleteRows(at: deletions.map({ IndexPath(row: $0, section: 0)}),
                                         with: .automatic)
                    tableView.insertRows(at: insertions.map({ IndexPath(row: $0, section: 0) }),
                                         with: .automatic)
                    tableView.reloadRows(at: modifications.map({ IndexPath(row: $0, section: 0) }),
                                         with: .automatic)
                    
                    tableView.endUpdates()

                case .error(let error):
                    fatalError("\(error)")
            }
        }
    }
    
    // MARK: Search controller params
    
    private func setupSearchController() {
        
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search"
        
        navigationItem.searchController = searchController
        definesPresentationContext = true
        
    }

    // MARK: Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let count = places?.count as Int? else { return 0 }
        
        if count == 0 {
            self.tableView.setEmptyMessage("No data available yet")
        } else {
            self.tableView.restore()
        }
        
        return count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! PlaceCell
        guard let place = places?[indexPath.row] else { return cell }
  
        cell.id = place.id
        cell.title.text = place.title
        cell.locationAddress.text = place.locationAddress
        cell.type.text = place.type
        
        if let imageData = place.imageOfPlace {
            cell.imageOfPlace.image = UIImage(data: imageData)
        }
 
        cell.imageOfPlace.layer.cornerRadius = cell.imageOfPlace.frame.size.height / 2
        cell.imageOfPlace.clipsToBounds = true

        return cell
    }

    // MARK: Table view delegate
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        guard let place = places?[indexPath.row] else { return nil }
        
        let deleteItem = UIContextualAction(style: .destructive, title: "Delete") { (action, view, completionHandler)  in
            
            let alertController = UIAlertController(title: "Warning",
                                                    message: "Are you sure?",
                                                    preferredStyle: .alert)

            // Button to delete place
            let deleteAction = UIAlertAction(title: "Delete", style: .destructive, handler: { (_) in
                StorageManager.deleteObject(place)
            })
            alertController.addAction(deleteAction)
            
            // Button to cancel
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: { (_) in
                completionHandler(true)
            })
            alertController.addAction(cancelAction)

            self.present(alertController, animated: true, completion: nil)
        
        }
        
        let swipeActions = UISwipeActionsConfiguration(actions: [deleteItem])
        
        return swipeActions
    }
    
    @IBAction func sortTouched(_ sender: UIBarButtonItem) {
        
        let actionSheet = UIAlertController(title: "Sort by", message: nil, preferredStyle: .actionSheet)

        // Button to sort alphabetically
        let alphabet = UIAlertAction(title: "Alphabetical", style: .default) { (_) in
            self.places = self.places!.sorted(byKeyPath: "title", ascending: true)
            self.reloadData()
        }
        actionSheet.addAction(alphabet)
        
        // Button to sort by date
        let newest = UIAlertAction(title: "Newest", style: .default) { (_) in
            self.places = self.places!.sorted(byKeyPath: "date", ascending: true)
            self.reloadData()
        }
        actionSheet.addAction(newest)
        
        // Button to sort by date
        let oldest = UIAlertAction(title: "Oldest", style: .default) { (_) in
            self.places = self.places!.sorted(byKeyPath: "date", ascending: false)
            self.reloadData()
        }
        actionSheet.addAction(oldest)
        
        // Button for cancel
        let cancel = UIAlertAction(title: "Cancel", style: .cancel)
        actionSheet.addAction(cancel)
        
        self.present(actionSheet, animated: true, completion: nil)
        
    }
    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        if segue.identifier == "ShowDetail" {
            guard let indexPath = tableView.indexPathForSelectedRow else { return }
            guard let cell = tableView.cellForRow(at: indexPath) as? PlaceCell else { return }
 
            let newPlaceVC = segue.destination as! NewPlaceVC
            
            newPlaceVC.changeOfPlaceMode = true
            newPlaceVC.changeOfPlaceID = cell.id
        }
        
    }
    
    // MARK: Exit from New place modal
    
    @IBAction func unwindSegue(_ segue: UIStoryboardSegue) {
        
        guard let newPlaceVC = segue.source as? NewPlaceVC else { return }
        
        // Persist new place
        newPlaceVC.savePlace()
        
    }

}

extension MainVC: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text!)
    }
    
    private func filterContentForSearchText(_ searchText: String) {
        
        let places = StorageManager.getAll()!
        
        if searchText.isEmpty {
            self.places = places
        } else {
            self.places = places.filter("title CONTAINS[c] %@ OR locationAddress CONTAINS[c] %@", searchText, searchText)
        }
        
        self.reloadData()
    }
    
}

extension UITableView {

    func setEmptyMessage(_ message: String) {
        let messageLabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.bounds.size.width, height: self.bounds.size.height))
        
        messageLabel.text = message
        messageLabel.textColor = .darkGray
        messageLabel.numberOfLines = 0
        messageLabel.textAlignment = .center
        messageLabel.font = UIFont(name: "TrebuchetMS", size: 20)
        messageLabel.sizeToFit()

        self.backgroundView = messageLabel
        self.separatorStyle = .none
    }

    func restore() {
        self.backgroundView = nil
        self.separatorStyle = .singleLine
    }
    
}
