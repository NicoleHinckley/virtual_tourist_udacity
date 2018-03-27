//
//  Extensions.swift
//  VirtualTourist-Final
//
//  Created by E Nicole Hinckley on 3/26/18.
//  Copyright © 2018 E Nicole Hinckley. All rights reserved.
//

import UIKit
import GameKit


extension UIColor {
    static func appGreenColor() -> UIColor {
        let color = UIColor(red: 38/255, green: 223/255, blue: 125/255, alpha: 1.0)
        return color
    }
}

class Shuffler {
    static let shared = Shuffler()
    
     func shufflePhotosFor(pin : Pin) -> [Photo]? {
        var n = 30
        guard let photoCount = pin.photos?.allObjects.count else { return nil}
        guard let photos = pin.photos?.allObjects as? [Photo] else { return nil}
        let shuffledPhotos = GKRandomSource.sharedRandom().arrayByShufflingObjects(in: photos)
        
        
        if photoCount < n {
            n = photoCount
        }
        
        let shortenedShuffledArray = shuffledPhotos[0..<n]
        let postsArray = Array(shortenedShuffledArray) as! [Photo]
        print(postsArray.count)
        return postsArray
}

}
