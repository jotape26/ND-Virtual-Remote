//
//  FlickrPhoto.swift
//  Virtual Tourist
//
//  Created by João Leite on 30/01/19.
//  Copyright © 2019 João Leite. All rights reserved.
//

import Foundation

class FlickrPhoto {
    let id: String
    let secret: String
    let server: String
    let farm: Int
    
    
    init(id: String, secret: String, server: String, farm: Int) {
        self.id = id
        self.secret = secret
        self.server = server
        self.farm = farm
    }
    
    func getImageURL() -> String {
        return "https://farm\(farm).staticflickr.com/\(server)/\(id)_\(secret)_q.jpg"
    }
}
