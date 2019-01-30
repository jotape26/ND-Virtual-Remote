//
//  PhotosService.swift
//  Virtual Tourist
//
//  Created by João Leite on 30/01/19.
//  Copyright © 2019 João Leite. All rights reserved.
//

import Foundation
import MapKit

class PhotosService: NSObject {
    
    struct Constant {
        static let flickrEndpoint = "https://api.flickr.com/services/rest/"
        static let flickrAPIKey = "2a2ad0534c538cea62c640e0d2520400"
        static let flickrSearch = "flickr.photos.search"
        static let dataFormat = "json"
        static let searchRangeKM = 3
    }
    
    func requestPhotos(location: CLLocation,
                       completion: @escaping ()->Void){
        
    }
    
    
}
