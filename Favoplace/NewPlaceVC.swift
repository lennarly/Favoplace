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
    
    // Cell index for image selection
    let imageIndexCell = 0
    
    // Change mode
    var changeOfPlaceMode: Bool = false
    
    // Place ID to change
    var changeOfPlaceID = 0
    
    override func viewDidLoad() {

        // Disable separators for blank cells
        tableView.tableFooterView = UIView()
        
        // Disable save button by default
        saveButton.isEnabled = false
        
        // Text field change event
        inputName.addTarget(self, action: #selector(textFieldChanged), for: .editingChanged)
        
        // Screen initialization for change mode
        setupEditScreen()
        
    }
    
    // MARK: Table view delegate
    
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
    
    private func setupEditScreen() {
        if changeOfPlaceMode {
            guard let place = StorageManager.getObject(changeOfPlaceID) else { return }
            
            setupNavigationBar(place)
            setupInputsValue(place)
        }
    }
    
    private func setupNavigationBar(_ place: Place) {
        
        if let topItem = navigationController?.navigationBar.topItem {
            topItem.backBarButtonItem = UIBarButtonItem(title: "Back", style: .plain, target: nil, action: nil)
        }
        
        title = place.title
        navigationItem.leftBarButtonItem = nil
        
        // Enable save button by default
        saveButton.isEnabled = true
    }
    
    private func setupInputsValue(_ place: Place) {
        
        if let imageData = place.imageOfPlace {
            inputImage.image = UIImage(data: imageData)
            inputImage.contentMode = .scaleAspectFill
        }
        
        inputName.text = place.title
        inputAddress.text = place.locationAddress
        inputType.text = place.type
        
    }
        
    public func savePlace() {
        
        let place = Place(title: inputName.text!,
                          locationAddress: inputAddress.text,
                          type: inputType.text,
                          imageOfPlace: inputImage.image?.pngData())
        
        if changeOfPlaceMode {
            place.id = changeOfPlaceID
        }
        
        StorageManager.updateOrCreate(place)
        
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
        
        if changeOfPlaceMode {
            title = inputName.text!.isEmpty ? "Title" : inputName.text
        }
        
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
