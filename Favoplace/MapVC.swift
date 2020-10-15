//
//  MapVC.swift
//  Favoplace
//
//  Created by Lenar Valeev on 13.10.2020.
//  Copyright © 2020 Lenar Valeev. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class MapVC: UIViewController {
    
    // Place Data Storage
    public var placeData = Place()
    
    // Annotation Identifier
    private let annotationIdentifier = "annotationIdentifier"
    
    // Location manager
    private let locationManager = CLLocationManager()
    
    // The radius of the centering
    let regionInMeters = 10_000.00
    
    // Managing the Map View
    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        // Init delegate for Map View
        mapView.delegate = self

        // Setup placemark
        setupPlacemark()
        
        // Checking geolocation services
        checkLocationServices()
        
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
    
    private func checkLocationServices() {
        if CLLocationManager.locationServicesEnabled() {
            setupLocationManager()
            checkLocationAuthorization()
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.showAlert(title: nil,
                               message: "Turn On Location Services to Allow the App to Determine Your Location")
            }
        }
    }
    
    private func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    private func checkLocationAuthorization() {
        switch CLLocationManager.authorizationStatus() {
        
            case .authorizedWhenInUse:
                mapView.showsUserLocation = true
                break
                
            case .denied, .restricted:
                self.showAlert(title: nil,
                               message: "Turn On Location Services to Allow the App to Determine Your Location")
                break
                
            case .notDetermined:
                locationManager.requestWhenInUseAuthorization()
                break
                
            case .authorizedAlways:
                break
                
            @unknown default:
                print("checkLocationAuthorization - you need to add a new case")
        }
        
    }
    
    private func showAlert(title: String?, message: String) {
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel)
        alertController.addAction(cancel)
        
        let settings = UIAlertAction(title: "Settings", style: .default) { (_) in
            let url = URL(string: UIApplication.openSettingsURLString)
            if UIApplication.shared.canOpenURL(url!) {
                UIApplication.shared.open(url!, options: [:], completionHandler: nil)
            }
        }
        alertController.addAction(settings)
        
        self.present(alertController, animated: true, completion: nil)
        
    }
    
    @IBAction func locationButtonTouched() {
        
        if let location = locationManager.location?.coordinate {
            let region = MKCoordinateRegion.init(center: location,
                                                 latitudinalMeters: regionInMeters,
                                                 longitudinalMeters: regionInMeters)
            
            mapView.setRegion(region, animated: true)
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

extension MapVC: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        checkLocationAuthorization()
    }
    
}
