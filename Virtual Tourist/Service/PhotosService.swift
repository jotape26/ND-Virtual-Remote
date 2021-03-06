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
    
    let const = Constants()
    
    func requestPhotos(location: CLLocation,
                       completion: @escaping ([FlickrPhoto])->Void,
                       failure: @escaping()->Void){
        
        let lat = location.coordinate.latitude
        let lon = location.coordinate.longitude
        
        let url = URL(string: const.BASEURL + const.METHOD + const.FORMAT + const.APIKEY + "&lat=\(lat)&lon=\(lon)" + const.SEARCHRADIUS)!
        
        let request = URLRequest(url: url)
        let session = URLSession.shared

        _ = session.dataTask(with: request) { (data, res, err) in
            if err != nil {
                failure()
                return
            }
            
            let newData = data?.subdata(in: Range(uncheckedBounds: (14, data!.count - 1)))
            
            if let responseJson = try? JSONSerialization.jsonObject(with: newData!) as? [String: Any] {
                if let rootObject = responseJson!["photos"] as? [String: Any] {
                    if let photosList = rootObject["photo"] as? [[String: Any]] {
                        
                        // IF ARRAY IS EMPTY
                        if photosList.isEmpty {
                            failure()
                            return
                        }
                        var selectedPhotos: [FlickrPhoto] = []
                        
                        repeat {
                            let photo = photosList[Int(arc4random_uniform(UInt32(photosList.count)))]
                            
                            selectedPhotos.append(FlickrPhoto(id: photo["id"] as? String ?? "",
                                                              secret: photo["secret"] as? String ?? "",
                                                              server: photo["server"] as? String ?? "",
                                                              farm: photo["farm"] as? Int ?? 0))
                        } while selectedPhotos.count < 21 || selectedPhotos.count == photosList.count
                        
                        completion(selectedPhotos)
                    } else { failure() }
                } else { failure () }
            } else { failure() }
        }.resume()
    }
    
    func downloadPhotoData(photo: Photo,
                           completion: @escaping(UIImage)->Void,
                           failure: @escaping()->()){
        
        if let url = photo.flickrUrl {
            let request = URLRequest(url: url)
            let session = URLSession.shared
            
            _ = session.dataTask(with: request, completionHandler: { (data, res, err) in
                if err != nil {
                    failure()
                    return
                }
                
                if let photoData = data {
                    let finalImage = UIImage(data: photoData)
                    completion(finalImage!)
                }
            }).resume()
        } else { failure() }
    }
    
    
}
