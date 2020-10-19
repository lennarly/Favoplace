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

protocol MapVCD {
    func getAddress(_ address: String?)
}

class MapVC: UIViewController {
    
    // Map Manager
    public let mapManager = MapManager()
    
    // MapVC Delegate
    public var mapVCD: MapVCD?
    
    // Place Data Storage & Segue Identifier
    public var placeData = Place()
    
    // Segue Identifier
    public var incomingSegueIdentifier = ""
    
    // Annotation Identifier
    private let annotationIdentifier = "annotationIdentifier"
    
    var previousLocation: CLLocation? {
        didSet {
            mapManager.startTrackingUserLocation(for: mapView, and: previousLocation) { (currentLocation) in
                
                self.previousLocation = currentLocation
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    self.mapManager.showUserLocation(mapView: self.mapView)
                }
                
            }
        }
    }

    
    // Managing the Map View
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var centeredPin: UIImageView!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var closeButton: UIButton! {
        didSet {
            setupStyleButton(for: closeButton)
        }
    }
    @IBOutlet weak var routeButton: UIButton! {
        didSet {
            setupStyleButton(for: routeButton)
        }
    }
    @IBOutlet weak var navigateButton: UIButton! {
        didSet {
            setupStyleButton(for: navigateButton)
        }
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        // Init delegate for Map View
        mapView.delegate = self

        // Setup map view
        setupMapView()
        
    }
    
    private func setupStyleButton(for button: UIButton) {
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOpacity = 0.2
        button.layer.shadowRadius  = 2
        button.layer.shadowOffset  = CGSize(width :0, height :0)
        button.layer.masksToBounds = false
        button.layer.cornerRadius  =  button.frame.size.width / 2
        button.backgroundColor     = UIColor.white
    }
    
    private func setupMapView() {
        
        // Hide the compass
        mapView.showsCompass = false
        routeButton.isHidden = true
        
        // The default adresss is empty
        addressLabel.text = ""
        
        mapManager.checkLocationServices(mapView: mapView, segueIdentifier: incomingSegueIdentifier) {
            mapManager.locationManager.delegate = self
        }
        
        if incomingSegueIdentifier == "showPlace" {
            mapManager.setupPlacemark(placeData: placeData, mapView: mapView)
            centeredPin.isHidden = true
            addressLabel.isHidden = true
            doneButton.isHidden = true
            routeButton.isHidden = false
        }
        
    }

    @IBAction func routeButtonTouched() {
        mapManager.getDirections(for: mapView) { (location) in
            self.previousLocation = location
        }
    }
    
    @IBAction func locationButtonTouched() {
        mapManager.showUserLocation(mapView: mapView)
    }
    
    @IBAction func doneButtonTouched() {
        mapVCD?.getAddress(addressLabel.text)
        dismiss(animated: true, completion: nil)
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
            annotationView = MKPinAnnotationView(annotation: annotation,
                                                 reuseIdentifier: annotationIdentifier)
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
    
    func mapView(_ mapView: MKMapView, regionWillChangeAnimated animated: Bool) {
        DispatchQueue.main.async {
            self.addressLabel.text = "Getting an address..."
        }
    }
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        
        let center = mapManager.getCenterLocation(for: mapView)
        let geocoder = CLGeocoder()
        
        if incomingSegueIdentifier == "showPlace" && previousLocation != nil {
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                self.mapManager.showUserLocation(mapView: self.mapView)
            }
        }
        
        geocoder.cancelGeocode()
        geocoder.reverseGeocodeLocation(center) { (placemarks, error) in
            
            if let error = error {
                print(error)
                return
            }
            
            guard let placemark = placemarks?.first else { return }
            
            let streetName = placemark.thoroughfare
            let buildNumber = placemark.subThoroughfare
            
            DispatchQueue.main.async {
                if streetName != nil && buildNumber != nil {
                    self.addressLabel.text = "\(streetName!), \(buildNumber!)"
                } else if(streetName != nil) {
                    self.addressLabel.text = "\(streetName!)"
                } else {
                    self.addressLabel.text = ""
                }

            }
            
        }
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay as! MKPolyline)
        renderer.strokeColor = .green
        return renderer
    }
    
}

extension MapVC: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        
        mapManager.checkLocationAuthorization(mapView: mapView,
                                              segueIdentifier: incomingSegueIdentifier)
        
    }
    
}
