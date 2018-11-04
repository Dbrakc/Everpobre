//
//  MapViewController.swift
//  Everpobre
//
//  Created by David Braga  on 03/11/2018.
//  Copyright © 2018 Charles Moncada. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController {
    
    
    let locationManager = CLLocationManager()
    
    @IBOutlet weak var mapView: MKMapView!
    
    let notebook: Notebook
    //let managedContext: NSManagedObjectContext
    let coreDataStack: CoreDataStack!
    
    var notes: [Note] = [] {
        didSet {
            mapView.removeAnnotations(mapView.annotations)
            mapView.addAnnotations(self.notes.filter{$0.coordinates != nil}.map{($0 as MKAnnotation)})
        }
    }
    
    init(notebook: Notebook, coreDataStack: CoreDataStack) {
        self.notebook = notebook
        self.notes = (notebook.notes?.array as? [Note]) ?? []
        self.coreDataStack = coreDataStack
        super.init(nibName: nil, bundle: nil)
        self.title = "Mapa de Notas"
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        let center = notebook.center
        let radius = notebook.radius
        mapView.delegate = self
        if  radius != nil {
            let region = MKCoordinateRegion(center: center.coordinate, latitudinalMeters: radius!, longitudinalMeters: 1000)
            if region.IsValid{
                mapView.setRegion(region, animated: true)
            }
           
        }
    }
    
   
}

extension MapViewController: MKMapViewDelegate {
    
    func mapViewWillStartRenderingMap(_ mapView: MKMapView) {
        print("rendering")
    }
    
    func mapViewDidFinishRenderingMap(_ mapView: MKMapView, fullyRendered: Bool) {
     
        mapView.addAnnotations(self.notes.filter{$0.coordinates != nil}.map{($0 as MKAnnotation)})
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation {
            return nil
        }
        
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "notes") as? MKMarkerAnnotationView
        
        if annotationView == nil {
            annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: "notes")
        } else {
            annotationView?.annotation = annotation
        }
        
        annotationView?.markerTintColor = .green
        annotationView?.titleVisibility = .visible
        annotationView?.subtitleVisibility = .adaptive
        
        return annotationView
    }

}
