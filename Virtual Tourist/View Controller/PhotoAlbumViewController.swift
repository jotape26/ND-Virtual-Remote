//
//  PhotoAlbumViewController.swift
//  Virtual Tourist
//
//  Created by João Leite on 28/01/19.
//  Copyright © 2019 João Leite. All rights reserved.
//

import UIKit
import MapKit

class PhotoAlbumViewController: UIViewController {
    
    var currentPin: MKAnnotation!
    @IBOutlet weak var detailMap: MKMapView!
    @IBOutlet weak var photosCollection: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        detailMap.delegate = self
        detailMap.camera.altitude = CLLocationDistance(exactly: 5000.0)!
        title = currentPin.title!!
        populateMap()
    }

}

extension PhotoAlbumViewController: MKMapViewDelegate {
    
    func populateMap(){
        self.detailMap.addAnnotation(currentPin)
        self.detailMap.setCenter(currentPin.coordinate, animated: true)
        self.detailMap.camera.altitude = CLLocationDistance(exactly: 7500.0)!
    }
    
}

//extension PhotoAlbumViewController: UICollectionViewDelegate, UICollectionViewDataSource {
//    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        <#code#>
//    }
//
//    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        <#code#>
//    }
//
//}
