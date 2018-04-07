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
                guard let photosDict = json["photos"] as? [String : Any] else { return }
                guard let totalPages = photosDict["pages"] as? Int else { return }
                guard let photoArray = photosDict["photo"] as? [[String : Any]] else { return }
               
                pin.totalPages = (Int16(totalPages))
                print(pin.totalPages)
                var photos = [Photo]()
                
                for photo in photoArray {
                    dispatchGroup.enter()
                    
                    
                    if let url = photo["url_m"] as? String {
             
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
            CoreDataService.shared.save() // CoreData: error: Serious application error.  Exception was caught during Core Data change processing.  This is usually a bug within an observer of NSManagedObjectContextObjectsDidChangeNotification.  -[__NSCFSet addObject:]: attempt to insert nil with userInfo (null)
            
            // Cannot find the source of this error as I'm doing a do/try for all saving. This crash is VERY rarely happening and I can't reproduce it.
            
        }
    }
    
    func downloadImageDataFor(photo : Photo, completion : @escaping () -> ()){
        
        guard let url = URL(string : photo.downloadURL!) else { return }
        DispatchQueue.global().async {
            guard let imageData = NSData(contentsOf: url) else { return }
            photo.imageData = imageData
            completion()
        }
    }
}

