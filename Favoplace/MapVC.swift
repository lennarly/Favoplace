//
//  MapVC.swift
//  Favoplace
//
//  Created by Lenar Valeev on 13.10.2020.
//  Copyright © 2020 Lenar Valeev. All rights reserved.
//

import UIKit
import MapKit

class MapVC: UIViewController {
    
    // Place Data Storage
    public var placeData = Place()
    
    // Annotation Identifier
    private let annotationIdentifier = "annotationIdentifier"
    
    // Map View
    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        // Init delegate for Map View
        mapView.delegate = self

        // Setup placemark
        setupPlacemark()
        
    }
    
    private func setupPlacemark() {
        
        let geocoder = CLGeocoder()
        
        geocoder.geocodeAddressString(placeData.locationAddress!) { (placemarks, error) in
            
            if let error = error {
                print(error)
                return
            }
            
            guard let placemark = placemarks?.first else { return }
            
            let annotation = MKPointAnnotation()
            annotation.title = self.placeData.title
            annotation.subtitle = self.placeData.type
            
            guard let placemarkLocation = placemark.location else { return }
            annotation.coordinate = placemarkLocation.coordinate
            
            self.mapView.showAnnotations([annotation], animated: true)
            self.mapView.selectAnnotation(annotation, animated: true)
        }
        
    }
    
    @IBAction func closeButtonTouched() {
        dismiss(animated: true, completion: nil)
    }
    
}

extension MapVC: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        // If is the user's geolocation
        guard !(annotation is MKUserLocation) else { return nil }
        
        // Annotation View by Identifier
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: annotationIdentifier) as? MKPinAnnotationView
        
        if annotationView == nil {
            annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: annotationIdentifier)
            annotationView?.canShowCallout = true
        }
        
        // Image data exists
        if let imageData = placeData.imageOfPlace {
            let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
            imageView.layer.cornerRadius = imageView.frame.size.width / 2
            imageView.clipsToBounds = true
            imageView.image = UIImage(data: imageData)
            annotationView?.leftCalloutAccessoryView = imageView
        }

        return annotationView
        
    }
    
}
