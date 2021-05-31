//
//  MapViewController.swift
//  MyLocations
//
//  Created by Shahriar Nasim Nafi on 5/9/20.
//  Copyright © 2020 Shahriar Nasim Nafi. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class MapViewController: UIViewController {
    
    @IBOutlet weak var mapView: MKMapView!
    var context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
   
    var locations = [Location]()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(forName: Notification.Name.NSManagedObjectContextObjectsDidChange, object: context, queue: OperationQueue.main) { notification in
            self.updateLocations()
            if let dictionary = notification.userInfo {
                print(dictionary[NSInsertedObjectsKey])
                print(dictionary[NSUpdatedObjectsKey])
                print(dictionary[NSDeletedObjectsKey])
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        updateLocations()
        //        if !locations.isEmpty{
        //            showLocations()
        //
        //        }
        // Do any additional setup after loading the view.
    }
    
    @IBAction func showUser(){
        let region = MKCoordinateRegion(center: mapView.userLocation.coordinate, latitudinalMeters: 10000, longitudinalMeters: 10000) // more less more depper
        mapView.setRegion(region, animated: true)
    }
    
    @IBAction func showLocations(){
        let theRegion = region(for: locations)
        mapView.setRegion(theRegion, animated: true)
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
    
    //MARK: - Helper
    
    func updateLocations(){
        mapView.removeAnnotations(locations)
        let entity = Location.entity()
        let fetchRequest = NSFetchRequest<Location>()
        fetchRequest.entity = entity
        locations = try! context.fetch(fetchRequest)
        mapView.addAnnotations(locations)
    }
    
    
    func region(for annotations: [MKAnnotation]) -> MKCoordinateRegion{
        
        let region: MKCoordinateRegion
        
        
        switch annotations.count {
        case 0:
            region = MKCoordinateRegion(center: mapView.userLocation.coordinate, latitudinalMeters: 10000, longitudinalMeters: 10000)
        case 1:
            let annotation = annotations.last!
            region = MKCoordinateRegion(center: annotation.coordinate, latitudinalMeters: 10000, longitudinalMeters: 10000)
        default:
            var topLeft = CLLocationCoordinate2D(latitude: -90, longitude: 180)
            var bottomRight = CLLocationCoordinate2D(latitude: 90, longitude: -180)
            for annotation in annotations{
                topLeft.latitude = max(topLeft.latitude,annotation.coordinate.latitude)
                topLeft.longitude = min(topLeft.longitude,annotation.coordinate.longitude)
                bottomRight.latitude = min(bottomRight.latitude,annotation.coordinate.latitude)
                bottomRight.longitude = max(bottomRight.longitude,annotation.coordinate.longitude)
            }
            
            let center = CLLocationCoordinate2D( latitude: topLeft.latitude -
                (topLeft.latitude - bottomRight.latitude) / 2, longitude: topLeft.longitude - (topLeft.longitude - bottomRight.longitude) / 2)
            
            let extraSpace = 1.1
            let span = MKCoordinateSpan(latitudeDelta: abs(topLeft.latitude - bottomRight.latitude) * extraSpace, longitudeDelta: abs(topLeft.longitude - bottomRight.longitude) * extraSpace)
            
            region = MKCoordinateRegion(center: center, span: span)
            
        }
        
        return region
    }
    
    @objc func showLocationDetails(_ sender: UIButton){
           performSegue(withIdentifier: "EditLocation", sender: sender)
       }
    
    //MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "EditLocation"{
            let destination = segue.destination as! LocationDetailsViewController
            let button = sender as! UIButton
            let location = locations[button.tag]
            destination.locationToEdit = location
        }
    }
    
}


extension MapViewController: MKMapViewDelegate{
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard annotation is Location else {
            return nil
        }
        let identifier = "Location"
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
        
        if annotationView == nil{
            let pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            pinView.isEnabled = true
            pinView.canShowCallout = true
            pinView.animatesDrop = true
            pinView.pinTintColor = UIColor(red: 0.32, green: 0.82,blue: 0.4, alpha: 1)
            pinView.tintColor = UIColor(white: 0.0, alpha: 0.5)
            let rightButton =  UIButton(type: .detailDisclosure)
            rightButton.addTarget(self, action: #selector(showLocationDetails(_:)), for: .touchUpInside)
            pinView.rightCalloutAccessoryView = rightButton
            annotationView = pinView
            
        }
        
        if let annotationView = annotationView{
            annotationView.annotation = annotation
            let button = annotationView.rightCalloutAccessoryView as! UIButton
            if let index = locations.firstIndex(of: annotation as! Location){
                button.tag = index
            }
        }
        
        return annotationView
        
    }
    
   
}
