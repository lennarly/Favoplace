//
//  MapManager.swift
//  Favoplace
//
//  Created by Lenar Valeev on 19.10.2020.
//  Copyright © 2020 Lenar Valeev. All rights reserved.
//

import UIKit
import MapKit

class MapManager {
    
    let locationManager = CLLocationManager()
    
    private let regionInMeters = 5_000.00
    private var placeCoordinate: CLLocationCoordinate2D?
    private var directionsArray: [MKDirections] = []
    
    // Place marker
    func setupPlacemark(placeData: Place, mapView: MKMapView) {
        
        let geocoder = CLGeocoder()
        
        geocoder.geocodeAddressString(placeData.locationAddress!) { (placemarks, error) in
            
            if let error = error {
                print(error)
                return
            }
            
            guard let placemark = placemarks?.first else { return }
            
            let annotation = MKPointAnnotation()
            annotation.title = placeData.title
            annotation.subtitle = placeData.type
            
            guard let placemarkLocation = placemark.location else { return }
            annotation.coordinate = placemarkLocation.coordinate
            self.placeCoordinate = placemarkLocation.coordinate
            
            mapView.showAnnotations([annotation], animated: true)
            mapView.selectAnnotation(annotation, animated: true)
        }
        
    }
    
    // Checking the availability of geolocation services
    func checkLocationServices(mapView: MKMapView, segueIdentifier: String, closure: () -> ()) {
        if CLLocationManager.locationServicesEnabled() {
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            checkLocationAuthorization(mapView: mapView, segueIdentifier: segueIdentifier)
            closure()
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.showAlert(title: nil,
                               message: "Turn On Location Services to Allow the App to Determine Your Location")
            }
        }
    }
    
    // Checking the authorization of the application to use geolocation services
    func checkLocationAuthorization(mapView: MKMapView, segueIdentifier: String) {
        switch CLLocationManager.authorizationStatus() {
            case .authorizedWhenInUse:
                mapView.showsUserLocation = true
                if segueIdentifier == "getAddress" { showUserLocation(mapView: mapView) }
                break
            case .denied:
                self.showAlert(title: nil,
                               message: "Turn On Location Services to Allow the App to Determine Your Location")
                break
            case .notDetermined:
                locationManager.requestWhenInUseAuthorization()
                break
            case .authorizedAlways, .restricted:
                break
            @unknown default:
                print("checkLocationAuthorization - you need to add a new case")
        }
        
    }
    
    // Map focus on user location
    func showUserLocation(mapView: MKMapView) {
        
        if let location = locationManager.location?.coordinate {
            let region = MKCoordinateRegion.init(center: location,
                                                 latitudinalMeters: regionInMeters,
                                                 longitudinalMeters: regionInMeters)
            
            mapView.setRegion(region, animated: true)
        }
        
    }
    
    // Building a route from location to location
    func getDirections(for mapView: MKMapView, previousLocation: (CLLocation) -> ()) {
        
        guard let location = locationManager.location?.coordinate else {
            showAlert(title: "Error", message: "Current location is not found")
            return
        }
        
        locationManager.startUpdatingLocation()
        previousLocation(CLLocation(latitude: location.latitude, longitude: location.longitude))
        
        guard let request = createDirectionsRequest(from: location) else {
            showAlert(title: "Error", message: "Destination is not found")
            return
        }
        
        let directions = MKDirections(request: request)
        resetMapView(withNew: directions, mapView: mapView)
        
        directions.calculate { (response, error) in
            
            if let error = error {
                print(error)
                return
            }
            
            guard let response = response else {
                self.showAlert(title: "Error", message: "Direction is not available")
                return
            }
            
            for route in response.routes {
                
                mapView.addOverlay(route.polyline)
                mapView.setVisibleMapRect(route.polyline.boundingMapRect, animated: true)
                
                let distance = String(format: "%.1f", route.distance / 1000)
                let timeInterval = route.expectedTravelTime
                
                print("Расстояние до места \(distance) км.")
                print("Время в пути \(timeInterval) сек.")
                
            }
            
        }
        
    }
    
    // Configuring a request for route calculation
    func createDirectionsRequest(from coordinate: CLLocationCoordinate2D) -> MKDirections.Request? {
        
        guard let destinationCoordinate = placeCoordinate else { return nil }
        
        let startingLocation = MKPlacemark(coordinate: coordinate)
        let destination = MKPlacemark(coordinate: destinationCoordinate)
        
        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: startingLocation)
        request.destination = MKMapItem(placemark: destination)
        request.transportType = .automobile
        request.requestsAlternateRoutes = true
        
        return request
        
    }
    
    // Change the displayed area of the map area according to user variables
    func startTrackingUserLocation(for mapView: MKMapView, and location: CLLocation?, closure: (_ currentLocation: CLLocation) -> ()) {
        
        guard let location = location else { return }
        let center = getCenterLocation(for: mapView)
        guard center.distance(from: location) > 50 else { return }
        
        closure(center)
        
    }
    
    // Resetting all previously built routes before building a new one
    func resetMapView(withNew directions: MKDirections, mapView: MKMapView) {
        mapView.removeOverlays(mapView.overlays)
        directionsArray.append(directions)
        let _ = directionsArray.map { $0.cancel() }
        directionsArray.removeAll()
    }
    
    // Determining the center of the displayed map area
    func getCenterLocation(for mapView: MKMapView) -> CLLocation {
        let latitude = mapView.centerCoordinate.latitude
        let longitude = mapView.centerCoordinate.longitude
        return CLLocation(latitude: latitude, longitude: longitude)
    }
    
    // Display notification
    func showAlert(title: String?, message: String) {
        
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
        
        let alertWindow = UIWindow(frame: UIScreen.main.bounds)
        alertWindow.rootViewController = UIViewController()
        alertWindow.windowLevel = UIWindow.Level.alert + 1
        alertWindow.makeKeyAndVisible()
        alertWindow.rootViewController?.present(alertController, animated: true)
    }
    
}
