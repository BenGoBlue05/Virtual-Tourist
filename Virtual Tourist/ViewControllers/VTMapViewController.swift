//
//  ViewController.swift
//  Virtual Tourist
//
//  Created by Ben Lewis on 10/11/19.
//  Copyright © 2019 Ben Lewis. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class VTMapViewController: UIViewController {

    @IBOutlet weak var mapView: MKMapView!
    
    var dataController = (UIApplication.shared.delegate as! AppDelegate).dataController
    
    var fetchedResultsController:NSFetchedResultsController<Pin>!
    
    var pins = [Pin]()
    
    fileprivate func setupFetchedResultsController() {
        let request: NSFetchRequest<Pin> = Pin.fetchRequest()
        if let pins = try? dataController.viewContext.fetch(request) {
            self.pins = pins
            for pin in pins {
                addAnnotation(CLLocationCoordinate2D(latitude: pin.latitude, longitude: pin.longitude))
            }
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        let longPressRecogniser = UILongPressGestureRecognizer(target: self, action: #selector(self.handleLongPress(_:)))
        mapView.addGestureRecognizer(longPressRecogniser)
        setupFetchedResultsController()
    }
    
    @objc func handleLongPress(_ gestureRecognizer : UIGestureRecognizer){
        if gestureRecognizer.state != .began { return }
        let touchPoint = gestureRecognizer.location(in: mapView)
        let touchMapCoordinate = mapView.convert(touchPoint, toCoordinateFrom: mapView)
        savePin(touchMapCoordinate)
        addAnnotation(touchMapCoordinate)
    }
    
    func addAnnotation(_ coord: CLLocationCoordinate2D) {
        let annotation = MKPointAnnotation()
        annotation.coordinate = coord
        mapView.addAnnotation(annotation)
    }
    
    func savePin(_ coord: CLLocationCoordinate2D) {
        let pin = Pin(context: dataController.viewContext)
        pin.latitude = coord.latitude
        pin.longitude = coord.longitude
        pins.append(pin)
        try? dataController.viewContext.save()
    }
}

extension VTMapViewController : MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.pinTintColor = .red
            pinView!.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        }
        else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        let coord = view.annotation!.coordinate
        let pin = pins.first { p in
            p.latitude == coord.latitude && p.longitude == coord.longitude
        }
        let vc = storyboard?.instantiateViewController(identifier: "VTPhotoViewController") as! VTPhotoViewController
        vc.pin = pin!
        vc.dataController = dataController
        navigationController?.pushViewController(vc, animated: true)
    }
}

