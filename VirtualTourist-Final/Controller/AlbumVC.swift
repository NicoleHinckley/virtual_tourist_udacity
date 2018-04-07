//
//  AlbumVC.swift
//  VirtualTourist-Final
//
//  Created by E Nicole Hinckley on 3/26/18.
//  Copyright © 2018 E Nicole Hinckley. All rights reserved.
//

import UIKit
import MapKit
import SDWebImage
import GameKit


class AlbumVC: UIViewController, UICollectionViewDelegateFlowLayout {
    
    // MARK: - Global
    
    var photos = [Photo]()
    var pin : Pin!
    
    // MARK: - Outlets
    
    @IBOutlet weak var collectionView : UICollectionView!
    @IBOutlet weak var map : MKMapView!
    @IBOutlet weak var newCollectionButton : UIButton!
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    @IBOutlet weak var noImagesFoundLabel : UILabel!

    
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView.delegate = self
        collectionView.dataSource = self
        
        map.isScrollEnabled = false
        map.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        newCollectionButton.isEnabled = false
        noImagesFoundLabel.isHidden = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        /* Sets map to be zoomed in on the passed pin */
        
        let spanAmount  = 1.0
        let center = CLLocationCoordinate2D(latitude: pin!.latitude , longitude: pin!.longitude)
        let span = MKCoordinateSpan(latitudeDelta: spanAmount, longitudeDelta: spanAmount)
        
        let region = MKCoordinateRegionMake(center, span)
        map.setRegion(region, animated: false)
        map.addAnnotation(pin!)
        
        if pin?.photos?.allObjects.count == 0 {
            noImagesFoundLabel.isHidden = false
        } else {
            setExistingPhotos()
            noImagesFoundLabel.isHidden = true
        }
        if pin.totalPages > 1 {
            newCollectionButton.isEnabled = true
        }
    }
    
    // MARK: - Actions
        
    @IBAction func newCollectionButtonTapped() {
        
        /* Clears out pin's saved photos, clears out photos array and fetches new photos from Flickr */
        pin.photos = nil
        photos = []
        let totalPages = pin.totalPages
        let currentPage = pin.currentPage
        
        if currentPage < totalPages {
            pin.currentPage = pin.currentPage + 1
        } else {
            pin.currentPage = 1
        }
        
        FlickrClient.shared.fetchPhotosFor(pin: pin) { (photos) in
            if photos != nil {
            self.photos = photos!
            }
            self.reloadDataWithAnimation()
        }
       
    }

    // MARK: - Methods
    
    func setExistingPhotos(){
        
        self.photos = (pin?.photos?.allObjects)! as! [Photo]
        let shortPhotos  = photos.prefix(30)
        photos = Array(shortPhotos)
        reloadDataWithAnimation()
    }
    func reloadDataWithAnimation(){
        DispatchQueue.main.async {
        UIView.transition(with: self.collectionView,
                          duration: 0.35,
                          options: .transitionCrossDissolve,
                          animations: { self.collectionView.reloadData() })
        }
    }
}

// MARK: - Extensions
extension AlbumVC : UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AlbumCell", for: indexPath) as! AlbumCell
        let photo = photos[indexPath.row]
        cell.spinner.startAnimating()
        
        if photo.imageData != nil {
            print("WITH DATA")
            cell.picture.image = UIImage(data: photo.imageData! as Data)
            cell.spinner.stopAnimating()
        } else {
            print("WITH DOWNLOAD")
            cell.picture.sd_setImage(with: URL(string: photo.downloadURL!)!, placeholderImage: #imageLiteral(resourceName: "placeholder"), options: [], completed: { (image, error, cache, url) in
                 cell.spinner.stopAnimating()
            })
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let alert = UIAlertController(title: "Remove picture?", message: "Remove picture from this collection?", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Remove", style: .destructive, handler: { (action) in
            let photo = self.photos[indexPath.row]
            CoreDataService.shared.viewContext.delete(photo)
            CoreDataService.shared.save()
            self.photos.remove(at: indexPath.row)
            self.reloadDataWithAnimation()
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
        
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.bounds.width / 3.0 - 2
        let height = width
        
        return CGSize(width: width, height: height)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 1, left: 1.5, bottom: 1, right: 1.5)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1.0
    }
}

extension AlbumVC : MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        let annotationView = MKPinAnnotationView()
        annotationView.pinTintColor = UIColor.appGreenColor()
        annotationView.animatesDrop = false
        return annotationView
    }
}

