//
//  ViewController.swift
//  VirtualTourist-Final
//
//  Created by E Nicole Hinckley on 3/26/18.
//  Copyright © 2018 E Nicole Hinckley. All rights reserved.
//

import UIKit
import CoreData
import MapKit

class MapVC : UIViewController {
  
    // MARK: - Globals -
    var pins = [Pin]()
    var mapDidLoadForFirstTime = false
    var isInEditingMode = false
  
    // MARK: - Outlets -
    @IBOutlet weak var map : MKMapView!
    @IBOutlet weak var editButton: UIBarButtonItem!
    @IBOutlet weak var hintView: UIView!
    
    // MARK: - Life Cycle -
    override func viewDidLoad() {
        super.viewDidLoad()
        setupMap()
        fetchPins()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
     
        guard let mapCenter = UserDefaults.standard.value(forKey: "mapCenter") as? [String : Double] else { return }
        guard let mapRegion = UserDefaults.standard.value(forKey: "mapSpan") as? [String : Double] else { return }

        let center = CLLocationCoordinate2D(latitude: mapCenter["lat"]!, longitude: mapCenter["lon"]!)
        let span = MKCoordinateSpan(latitudeDelta: mapRegion["lat"]!, longitudeDelta: mapRegion["lon"]!)
        
        let region = MKCoordinateRegionMake(center, span)
        map.setRegion(region, animated: false)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        /* Passes the selected pin to the next View Controller */
        if segue.identifier == "toAlbum" {
            let destinationVC = segue.destination as! AlbumVC
            destinationVC.pin = (sender as! Pin)
        }
    }
    
    // MARK: - Methods -
    @IBAction func editButtonTapped(_ sender: UIBarButtonItem) {
        isInEditingMode = !isInEditingMode
        // Show the hint when controller in "editing" mode
        
        if isInEditingMode {
            editButton.title = "Done"
        } else {
            editButton.title = "Edit"
        }
        
        UIView.animate(withDuration: 0.3, animations: {
            self.view.frame.origin.y += self.hintView.frame.height * (self.isInEditingMode ? -1 : 1)
        })
    }
    
    func setupMap(){
        map.delegate = self
        map.showsUserLocation = true
        map.region.span = (MKCoordinateSpan(latitudeDelta: 45, longitudeDelta: 36))
        
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(createAndPlaceAnnotation(gestureRecognizer:)))
        longPressGesture.minimumPressDuration = 0.50
        self.view.addGestureRecognizer(longPressGesture)
    }
    
    func fetchPins(){
        let fetchRequest : NSFetchRequest<Pin> = Pin.fetchRequest()
        fetchRequest.sortDescriptors = []
        
        if let result = try? CoreDataService.shared.viewContext.fetch(fetchRequest) {
            self.pins = result
            for pin in pins {
                map.addAnnotation(pin)
            }
        }
    }
    
    @objc func createAndPlaceAnnotation(gestureRecognizer : UILongPressGestureRecognizer){
    
        if gestureRecognizer.state == .began {
            let touchPoint = gestureRecognizer.location(in: map)
            let newCoordinates = map.convert(touchPoint, toCoordinateFrom: map)
            let pin = Pin(context: CoreDataService.shared.viewContext)
            pin.latitude = newCoordinates.latitude
            pin.longitude = newCoordinates.longitude
            pin.currentPage = 1
            CoreDataService.shared.save()
            
            FlickrClient.shared.fetchPhotosFor(pin: pin, completion: { (photos) in
                self.map.addAnnotation(pin)
               // sucks on a slow connection. Going to see if yall are okay with how I went about doing this whole app in the review before fixing this problem. Might need to change a lot of stuff up so I'll handle this properly for the final version. Could just put an activity spinner while it loads? Alternatively place the pin immediately but then what if the user taps in immediately and then the photos are saved to the pin. Could do a delegate where the view controller reloads when this completion handler happens.
            })
        }
    }
}

// MARK: - mapView delegate -

extension MapVC : MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        let annotationView = MKPinAnnotationView()
        annotationView.pinTintColor = UIColor.appGreenColor()
        annotationView.animatesDrop = true
        return annotationView
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        guard let anno = view.annotation as? Pin else { return }
        if isInEditingMode {
            UIView.animate(withDuration: 0.1, animations: {
                view.alpha = 0
            }, completion: { (completed) in
                mapView.removeAnnotation(anno)
            })
     
        CoreDataService.shared.viewContext.delete(anno)
        CoreDataService.shared.save()
       
        } else {
       
        mapView.deselectAnnotation(anno, animated: false)
        self.performSegue(withIdentifier: "toAlbum", sender: anno)
        }
    }
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        
        if mapDidLoadForFirstTime == false {
            mapDidLoadForFirstTime = true
            return
        }
        
        var mapCenter = [String : Double]()
        var mapSpan = [String : Double]()
        
        mapCenter["lat"] = mapView.region.center.latitude
        mapCenter["lon"] = mapView.region.center.longitude
        
        mapSpan["lat"] = mapView.region.span.latitudeDelta
        mapSpan["lon"] = mapView.region.span.longitudeDelta
        
        UserDefaults.standard.set(mapCenter, forKey: "mapCenter")
        UserDefaults.standard.set(mapSpan, forKey: "mapSpan")
    }
}

