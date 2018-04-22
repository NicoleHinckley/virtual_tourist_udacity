//
//  AlbumCell.swift
//  VirtualTourist-Udacity
//
//  Created by E Nicole Hinckley on 3/20/18.
//  Copyright © 2018 E Nicole Hinckley. All rights reserved.
//

import UIKit

class AlbumCell: UICollectionViewCell {
    
    // MARK: - Outlets
    @IBOutlet weak var picture : UIImageView!
    @IBOutlet weak var spinner : UIActivityIndicatorView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        spinner.hidesWhenStopped = true
        picture.image = #imageLiteral(resourceName: "placeholder")
    }
}
