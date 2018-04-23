//
//  FlickrClient.swift
//  VirtualTourist-Final
//
//  Created by E Nicole Hinckley on 3/26/18.
//  Copyright © 2018 E Nicole Hinckley. All rights reserved.
//

import Foundation
import Alamofire
import GameKit


enum FlickrKeys : String {
    case photosDict = "photos"
    case totalPages = "pages"
    case photoArray = "photo"
    case photoURL = "url_m"
}

class FlickrClient {
   
    static let shared = FlickrClient()
    
    private let API_KEY = "cbc9df918d4b165b90e5a22d9b1fab91"
    private let API_SECRET = "cf8b7f9920c51b1b"
    private let PER_PAGE = 30

    func fetchPhotosFor(pin : Pin, completion : @escaping (_ photos : [Photo]?) -> ()) {
     
       let searchURL = "https://api.flickr.com/services/rest/?method=flickr.photos.search&api_key=\(API_KEY)&lat=\(pin.latitude)&lon=\(pin.longitude)&extras=url_m&per_page=\(PER_PAGE)&page=\(pin.currentPage)&format=json&nojsoncallback=1"
        
        guard let url = URL(string: searchURL) else { return }
        let dispatchGroup = DispatchGroup()
        Alamofire.request(url).responseJSON { (response) in
            if let json = response.result.value as? [String : Any] {
                guard let photosDict = json[FlickrKeys.photosDict.rawValue] as? [String : Any] else { return }
                guard let totalPages = photosDict[FlickrKeys.totalPages.rawValue] as? Int else { return }
                guard let photoArray = photosDict[FlickrKeys.photoArray.rawValue] as? [[String : Any]] else { return }
               
                pin.totalPages = (Int16(totalPages))
              
                var photos = [Photo]()
                
                for photo in photoArray {
                    dispatchGroup.enter()
                    if let url = photo[FlickrKeys.photoURL.rawValue] as? String {
                      let photo = Photo(context: CoreDataService.shared.viewContext)
                      photo.downloadURL = url
                      photo.pin = pin
                        self.downloadImageDataFor(photo: photo, completion: {
                            dispatchGroup.leave()
                        })
                      photos.append(photo)
                    }
                }
                CoreDataService.shared.save()
                completion(photos)
            }
        }
        dispatchGroup.notify(queue: .main) {
            print("All data is saved 👍")
            CoreDataService.shared.save()
        }
    }
    
    func downloadImageDataFor(photo : Photo, completion : @escaping () -> ()){
        guard let photoURL = photo.downloadURL else { return }
        guard let url = URL(string : photoURL) else { return }
        DispatchQueue.global().async {
            guard let imageData = NSData(contentsOf: url) else { return }
            photo.imageData = imageData
            completion()
        }
    }
}

