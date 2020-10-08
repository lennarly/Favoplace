//
//  AddPlaceViewController.swift
//  Favoplace
//
//  Created by Lenar Valeev on 07.10.2020.
//  Copyright © 2020 Lenar Valeev. All rights reserved.
//

import UIKit

class NewPlaceVC: UITableViewController {
    
    // Cell index for image selection
    let imageIndexCell = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Disable separators for blank cells
        tableView.tableFooterView = UIView()
    }
    
    // MARK: TableView delegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.row == imageIndexCell {
            
            let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            
            // Button for import from camera
            let camera = UIAlertAction(title: "Import from camera", style: .default) { _ in
                self.chooseImagePicker(source: .camera)
            }
            actionSheet.addAction(camera)
            
            // Button for import from photos
            let photo = UIAlertAction(title: "Import from photos", style: .default) { _ in
                self.chooseImagePicker(source: .photoLibrary)
            }
            actionSheet.addAction(photo)
            
            // Button for cancel
            let cancel = UIAlertAction(title: "Cancel", style: .cancel)
            actionSheet.addAction(cancel)
            
            present(actionSheet, animated: true, completion: nil)
            
        } else {
            view.endEditing(true)
        }
        
    }
    
}

// MARK: Text field delegate
extension NewPlaceVC: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return textField.resignFirstResponder()
    }
    
}

// MARK: Work with image
extension NewPlaceVC {
    
    func chooseImagePicker(source: UIImagePickerController.SourceType) {
        
        if UIImagePickerController.isSourceTypeAvailable(source) {
            
            let imagePicker = UIImagePickerController()
            
            // Allow the user to edit the image
            imagePicker.allowsEditing = true
            
            // Init source type is self
            imagePicker.sourceType = source
            
            present(imagePicker, animated: true, completion: nil)
        }
        
    }
    
}
