//
//  InitialMapViewController.swift
//  Virtual Tourist
//
//  Created by João Leite on 28/01/19.
//  Copyright © 2019 João Leite. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class InitialMapViewController: UIViewController {

    @IBOutlet weak var mapViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var labelBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var galeriesMap: MKMapView!
    @IBOutlet var longPressGesture: UILongPressGestureRecognizer!
    
    var deleteLabelShowing = false
    var dataController: CoreDataController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        galeriesMap.delegate = self
        longPressGesture.delegate = self
        galeriesMap.addGestureRecognizer(longPressGesture)
        
        loadSavedPins()
    }

    @IBAction func editButtonClicked(_ sender: Any) {
        deleteLabelShowing = !deleteLabelShowing
            DispatchQueue.main.async {
                self.view.layoutIfNeeded()
                UIView.animate(withDuration: 0.2, animations: {
                    self.labelBottomConstraint.priority = UILayoutPriority(rawValue: self.deleteLabelShowing ? 751 : 251)
                    self.view.layoutIfNeeded()
                })
            }
    }
    
    func loadSavedPins(){
        let request: NSFetchRequest<Pin> = Pin.fetchRequest()
        if let result = try? dataController.viewContext.fetch(request) {
            for p in result{
             addLocationToMap(location: CLLocation(latitude: p.latitude, longitude: p.longitude))
            }
        }
    }
    
    func deleteSavedPin(){
        
    }
    
    func addLocationToMap(location: CLLocation){
        let coder = CLGeocoder()
        coder.reverseGeocodeLocation(location) { placemarks, err in
            
            guard let arrPlaces = placemarks, let currentPlace = arrPlaces.first else { return }
            
            let mapAnotation = MKPointAnnotation()
            mapAnotation.coordinate = location.coordinate
            mapAnotation.title = currentPlace.locality ?? "City Unknown"
            
            //TODO IMPROVE CORE DATA IMPLEMENTATION
            let pin = Pin(context: self.dataController.viewContext)
            pin.city = currentPlace.locality ?? "City Unknown"
            pin.latitude = location.coordinate.latitude
            pin.longitude = location.coordinate.longitude
            
            try? self.dataController.viewContext.save()
            print("SAVED")
            
            DispatchQueue.main.async {
                self.galeriesMap.addAnnotation(mapAnotation)
            }
        }
    }
    
}

extension InitialMapViewController: MKMapViewDelegate {
    
}

extension InitialMapViewController: UIGestureRecognizerDelegate {
    
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        let pressLocation = gestureRecognizer.location(in: galeriesMap)
        let pinCoordinates = galeriesMap.convert(pressLocation, toCoordinateFrom: galeriesMap)
        let location = CLLocation(latitude: pinCoordinates.latitude, longitude: pinCoordinates.longitude)
        
        addLocationToMap(location: location)
        
        return true
    }
    
}

