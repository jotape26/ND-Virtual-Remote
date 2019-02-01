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
    var dataController: CoreDataController!
    var photos: [Photo] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        photosCollection.delegate = self
        photosCollection.dataSource = self
        
        let flow = UICollectionViewFlowLayout()
        flow.minimumLineSpacing = 1.0
        flow.minimumInteritemSpacing = 1.0
        flow.itemSize = CGSize(width: 100, height: 100)
        photosCollection.collectionViewLayout = flow
        detailMap.delegate = self
        detailMap.camera.altitude = CLLocationDistance(exactly: 5000.0)!
        title = currentPin.title!!
        findPin()
        populateMap()
    }
    
    func findPin(){
        let request: NSFetchRequest<Pin> = Pin.fetchRequest()
        let latitudePredicate = NSPredicate(format: "latitude = \(currentPin.coordinate.latitude)")
        let longitudePredicate = NSPredicate(format: "latitude = \(currentPin.coordinate.longitude)")
        print(latitudePredicate)
        print(longitudePredicate)
        
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
                    print("saved photos on coredata")
                    DispatchQueue.main.async {
                        self.photosCollection.reloadData()
                    }
                })
            }
        }
    }
    
    func savePhotoToCoreData(photo: Photo) {
        try? self.dataController.viewContext.save()
        self.photosCollection.reloadData()
        print("SAVED")
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
        return photos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageCell", for: indexPath) as! ImageCollectionViewCell
        cell.setPhoto(photo: photos[indexPath.row])
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let noOfCellsInRow = 3
        
        let flowLayout = collectionViewLayout as! UICollectionViewFlowLayout
        
        let totalSpace = flowLayout.sectionInset.left
            + flowLayout.sectionInset.right
            + (flowLayout.minimumInteritemSpacing * CGFloat(noOfCellsInRow - 1))
        
        let size = Int((collectionView.bounds.width - totalSpace) / CGFloat(noOfCellsInRow))
        
        return CGSize(width: size, height: size)
    }
}
