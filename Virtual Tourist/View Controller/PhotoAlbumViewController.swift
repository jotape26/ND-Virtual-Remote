//
//  PhotoAlbumViewController.swift
//  Virtual Tourist
//
//  Created by João Leite on 28/01/19.
//  Copyright © 2019 João Leite. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class PhotoAlbumViewController: UIViewController {
    
    var currentPin: MKAnnotation!
    var pin: Pin!
    @IBOutlet weak var detailMap: MKMapView!
    @IBOutlet weak var photosCollection: UICollectionView!
    @IBOutlet weak var lbInfo: UILabel!
    var dataController: CoreDataController!
    var photos: [Photo] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        photosCollection.delegate = self
        photosCollection.dataSource = self
        
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        let test = view.frame.width/3 - 3
        layout.itemSize = CGSize(width: test, height: test)
        layout.minimumInteritemSpacing = 0.1
        layout.minimumLineSpacing = 3
        
        photosCollection.collectionViewLayout = layout
        detailMap.delegate = self
        detailMap.camera.altitude = CLLocationDistance(exactly: 5000.0)!
        title = currentPin.title!!
        findPin()
        populateMap()
    }
    
    @IBAction func refreshButtonClicked(_ sender: Any) {
        resetPin()
    }
    
    func findPin(){
        let request: NSFetchRequest<Pin> = Pin.fetchRequest()
        let latitudePredicate = NSPredicate(format: "latitude = \(currentPin.coordinate.latitude)")
        let longitudePredicate = NSPredicate(format: "latitude = \(currentPin.coordinate.longitude)")
        
        let predicates = [latitudePredicate, longitudePredicate]
        request.predicate = NSCompoundPredicate(orPredicateWithSubpredicates: predicates)
        if let result = try? dataController.viewContext.fetch(request).first {
            if let pin = result {
                self.pin = pin
                searchPhotos()
            }
        }
    }
    
    func searchPhotos(){
        //CHECK FIRST CORE DATA
        //IF PIN FOUND, FIND PHOTOS
        DispatchQueue.main.async {
            self.lbInfo.text = "Loading photos..."
        }
        let request: NSFetchRequest<Photo> = Photo.fetchRequest()
        request.predicate = NSPredicate(format: "pin = %@", pin)
        request.sortDescriptors = [NSSortDescriptor(key: "position", ascending: true)]
        if let result = try? dataController.viewContext.fetch(request) {
            if !result.isEmpty{
                self.photos = result
                DispatchQueue.main.async {
                    self.photosCollection.reloadData()
                }
            } else {
                let location = CLLocation(latitude: currentPin.coordinate.latitude, longitude: currentPin.coordinate.longitude)
                PhotosService().requestPhotos(location: location, completion: { flickrArray in
                    
                    for index in 0..<flickrArray.count {
                        let photo = Photo(context: self.dataController.viewContext)
                        let flick = flickrArray[index]
                        photo.flickrUrl = URL(string: flick.getImageURL())!
                        photo.position = Int16(index)
                        photo.pin = self.pin
                        self.photos.append(photo)
                    }
                    try? self.dataController.viewContext.save()
                    print("DEBUG: Photos metadata downloaded. Reloading collection view to download the files.")
                    DispatchQueue.main.async {
                        self.photosCollection.reloadData()
                    }
                }, failure: {
                    DispatchQueue.main.async {
                        self.lbInfo.text = "There was an error requesting images to Flickr. Please verify your connection and try again later."
                        
                    }
                })
            }
        }
    }
    
    func savePhotoToCoreData(photo: Photo) {
        try? self.dataController.viewContext.save()
        self.photosCollection.reloadData()
        print("DEBUG: Photo saved in Core Data")
    }
}

extension PhotoAlbumViewController: MKMapViewDelegate {
    
    func populateMap(){
        self.detailMap.addAnnotation(currentPin)
        self.detailMap.setCenter(currentPin.coordinate, animated: true)
        self.detailMap.camera.altitude = CLLocationDistance(exactly: 7500.0)!
    }
    
}

extension PhotoAlbumViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        lbInfo.isHidden = photos.isEmpty ? false : true
        return photos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageCell", for: indexPath) as! ImageCollectionViewCell
        cell.setPhoto(photo: photos[indexPath.row])
        return cell
    }
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height/3)
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selected = photos[indexPath.row]
        photos.remove(at: indexPath.row)
        saveDelete(photo: selected)
        DispatchQueue.main.async {
            self.photosCollection.reloadData()
        }
    }
    
    func saveDelete(photo: Photo){
        dataController.viewContext.delete(photo)
        
        try? dataController.viewContext.save()
        print("DEBUG: Photo deleted from Core Data")
    }
    
    func resetPin(){
        for p in photos{
            dataController.viewContext.delete(p)
        }
        photos.removeAll()
        self.photosCollection.reloadData()
        
        try? dataController.viewContext.save()
        print("DEBUG: Pin reset complete. Downloading new pictures.")
        
        searchPhotos()
        
    }
}
