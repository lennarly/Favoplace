//
//  AddPlaceViewController.swift
//  Favoplace
//
//  Created by Lenar Valeev on 07.10.2020.
//  Copyright © 2020 Lenar Valeev. All rights reserved.
//

import UIKit

class NewPlaceVC: UITableViewController {
    
    @IBOutlet weak var inputImage: UIImageView!
    @IBOutlet weak var inputName: UITextField!
    @IBOutlet weak var inputAddress: UITextField!
    @IBOutlet weak var inputType: UITextField!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    // Place object (optional)
    var newPlace: Place?
    
    // Cell index for image selection
    let imageIndexCell = 0

    override func viewDidLoad() {

        // Disable separators for blank cells
        tableView.tableFooterView = UIView()
        
        // Disable save button by default
        saveButton.isEnabled = false
        
        inputName.addTarget(self, action: #selector(textFieldChanged), for: .editingChanged)
        
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
    
    func getNewPlace() -> Place {
        return Place(title: inputName.text!,
                         locationAddress: inputAddress.text,
                         type: inputType.text,
                         imageOfPlace: inputImage.image)
    }
    
    @IBAction func cancelButtonPressed(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
}

// MARK: Text field delegate
extension NewPlaceVC: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return textField.resignFirstResponder()
    }
    
    @objc private func textFieldChanged() {
        saveButton.isEnabled = !inputName.text!.isEmpty
    }
    
}

// MARK: Work with image
extension NewPlaceVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func chooseImagePicker(source: UIImagePickerController.SourceType) {
        
        if UIImagePickerController.isSourceTypeAvailable(source) {
            
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            
            // Allow the user to edit the image
            imagePicker.allowsEditing = true
            
            // Init source type is self
            imagePicker.sourceType = source
            
            present(imagePicker, animated: true, completion: nil)
        }
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        inputImage.image = info[.editedImage] as? UIImage
        inputImage.contentMode = .scaleAspectFill
        inputImage.clipsToBounds = true
        
        dismiss(animated: true, completion: nil)
        
    }
    
}
