//
//  ImageCollectionViewCell.swift
//  Virtual Tourist
//
//  Created by João Leite on 28/01/19.
//  Copyright © 2019 João Leite. All rights reserved.
//

import UIKit

class ImageCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var imageOutlet: UIImageView!
    @IBOutlet weak var activity: UIActivityIndicatorView!
    
    func setPhoto(photo: Photo){
        imageOutlet.image = nil
        if photo.photoData != nil {
            DispatchQueue.main.async {
                self.imageOutlet.image = UIImage(data: photo.photoData!)
                self.activity.stopAnimating()
            }
        } else {
            PhotosService().downloadPhotoData(photo: photo, completion: { image in
                DispatchQueue.main.async {
                    photo.photoData = image.pngData()
                    try? photo.managedObjectContext?.save()
                    print("DEBUG: Photo data downloaded and saved into Photo Core Data Object")
                    self.imageOutlet.image = image
                    self.activity.stopAnimating()
                }
            }, failure: {
                
            })
        }
    }
}
