//
//  TravelLocationViewController.swift
//  Virtual Tourist
//
//  Created by João Leite on 28/01/19.
//  Copyright © 2019 João Leite. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class TravelLocationViewController: UIViewController {
    
    @IBOutlet weak var lbHeight: NSLayoutConstraint!
    @IBOutlet weak var galeriesMap: MKMapView!
    @IBOutlet var longPressGesture: UILongPressGestureRecognizer!
    @IBOutlet weak var lbEdit: UILabel!
    
    var deleteLabelShowing = false
    var dataController: CoreDataController!
    var selectedAnnotation: MKAnnotation?
    var pinsArray: [Pin] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        galeriesMap.delegate = self
        longPressGesture.delegate = self
        galeriesMap.addGestureRecognizer(longPressGesture)
        
        loadSavedPins()
    }

    @IBAction func editButtonClicked(_ sender: Any) {
        
        if deleteLabelShowing {
            animateDeleteLabel()
        } else {
            if galeriesMap.annotations.isEmpty {
                let alert = UIAlertController(title: "Oops.",
                                              message: "Please add a pin to the map before trying to edit it.",
                                              preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
                self.present(alert, animated: true, completion: nil)
            } else {
                animateDeleteLabel()
            }
        }
    }
    
    func loadSavedPins(){
        let request: NSFetchRequest<Pin> = Pin.fetchRequest()
        if let result = try? dataController.viewContext.fetch(request) {
            self.pinsArray = result
            populateMap()
        }
    }
    
    func deleteSavedPin(pin: Pin) {
        dataController.viewContext.delete(pin)
        try? dataController.viewContext.save()

    }
    
    func populateMap() {
        for p in pinsArray {
            geocodeLocation(location: CLLocation(latitude: p.latitude, longitude: p.longitude)) { mark in
                
                let mapAnotation = MKPointAnnotation()
                mapAnotation.coordinate = CLLocationCoordinate2D(latitude: p.latitude, longitude: p.longitude)
                mapAnotation.title = mark.locality ?? "City Unknown"
                
                DispatchQueue.main.async {
                    self.galeriesMap.addAnnotation(mapAnotation)
                }
            }
        }
    }
    
    func animateDeleteLabel(){
        deleteLabelShowing = !deleteLabelShowing
        DispatchQueue.main.async {
            self.view.layoutIfNeeded()
            UIView.animate(withDuration: 0.2, animations: {
                self.lbHeight.constant = self.deleteLabelShowing ? 50 : 0
                self.view.layoutIfNeeded()
            })
        }
    }
    
    func geocodeLocation(location: CLLocation,
                         completion: @escaping (CLPlacemark) -> Void) {
        let coder = CLGeocoder()
        coder.reverseGeocodeLocation(location) { placemarks, err in
            
            if err != nil {
                let alert = UIAlertController(title: "Unknown Location",
                                              message: "Sorry, we couldn't find a location for the region you selected. Please choose another region", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
                self.present(alert, animated: true, completion: nil)
                return
            }
            
            guard let arrPlaces = placemarks, let place = arrPlaces.first else { return }
            completion(place)
        }
    }
    
    func savePinFromLocation(_ placemark: CLPlacemark){
        if let location = placemark.location {
            let pin = Pin(context: self.dataController.viewContext)
            pin.city = placemark.locality ?? "City Unknown"
            pin.latitude = location.coordinate.latitude
            pin.longitude = location.coordinate.longitude
            
            try? self.dataController.viewContext.save()
            print("DEBUG: New pin saved in Core Data")
        }
    }
    
    func addLocationToMap(_ placemark: CLPlacemark){
        if let location = placemark.location {
            let mapAnotation = MKPointAnnotation()
            mapAnotation.coordinate = location.coordinate
            mapAnotation.title = placemark.locality ?? "City Unknown"
            
            DispatchQueue.main.async {
                self.galeriesMap.addAnnotation(mapAnotation)
            }
        }
    }
}

extension TravelLocationViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        let reuseId = "pin"
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView?.animatesDrop = true
            pinView?.pinTintColor = .red
            //pinView?.canShowCallout = true
            //pinView?.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        }
        else {
            pinView?.annotation = annotation
        }
        return pinView
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        mapView.deselectAnnotation(view.annotation!, animated: true)
        if !deleteLabelShowing {
            self.selectedAnnotation = view.annotation!
            
            let vc = storyboard?.instantiateViewController(withIdentifier: "PhotoAlbumViewController") as! PhotoAlbumViewController
            vc.currentPin = selectedAnnotation
            vc.dataController = dataController
            navigationController?.pushViewController(vc, animated: true)
        } else {
            
            guard let dLocation = view.annotation?.coordinate else { return }
            
            let request: NSFetchRequest<Pin> = Pin.fetchRequest()
            let latitudePredicate = NSPredicate(format: "latitude = \(dLocation.latitude)")
            let longitudePredicate = NSPredicate(format: "latitude = \(dLocation.longitude)")
            
            let predicates = [latitudePredicate, longitudePredicate]
            request.predicate = NSCompoundPredicate(orPredicateWithSubpredicates: predicates)
            if let result = try? dataController.viewContext.fetch(request).first {
                if let resultPin = result {
                    deleteSavedPin(pin: resultPin)
                    DispatchQueue.main.async {
                        mapView.removeAnnotation(view.annotation!)
                    }
                }
            }
        }
    }
}

extension TravelLocationViewController: UIGestureRecognizerDelegate {
    
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        let pressLocation = gestureRecognizer.location(in: galeriesMap)
        let pinCoordinates = galeriesMap.convert(pressLocation, toCoordinateFrom: galeriesMap)
        let location = CLLocation(latitude: pinCoordinates.latitude, longitude: pinCoordinates.longitude)
        
        geocodeLocation(location: location) { placemark in
            self.savePinFromLocation(placemark)
            self.addLocationToMap(placemark)
        }
        
        return true
    }
}

