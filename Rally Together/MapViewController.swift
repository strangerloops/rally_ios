//
//  BroadcastViewController.swift
//  Rally Together
//
//  Created by Michael Hassin on 12/7/14.
//  Copyright (c) 2014 strangerware. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController, MKMapViewDelegate {
    
    var mapView: MKMapView!
    var annotationsToImages: [MKPointAnnotation : UIImage]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView = MKMapView(frame: self.view.frame)
        mapView.showsUserLocation = true
        mapView.delegate = self
        if let user = UserBucket.loggedInUser(){
            let center = user.location().coordinate
            let span = MKCoordinateSpanMake(0.2, 0.2)
            let mapRegion = MKCoordinateRegion(center: center, span: span)
            mapView.setRegion(mapRegion, animated: true)
        }
        self.view.addSubview(mapView)
        annotationsToImages = [:]
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("refreshMap"), name: "didRefreshLocation", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("refreshMap"), name: "didRefreshUsers", object: nil)
    }
    
    override func viewWillAppear(animated: Bool) {
        refreshMap()
    }
    
    func refreshMap() {
        mapView.removeAnnotations(mapView.annotations)
        for user in UserBucket.allUsers().filter({ $0.hasTag() && $0.hasLocation() }) {
            let tag = user.tag!
            let annotation = MKPointAnnotation()
            annotation.setCoordinate(user.location().coordinate)
            annotation.title = tag.name
            annotationsToImages[annotation] = tag.marker()
            mapView.addAnnotation(annotation)
        }
    }
    
    func mapView(mapView: MKMapView!, viewForAnnotation annotation: MKAnnotation!) -> MKAnnotationView! {
        if annotation.isKindOfClass(MKUserLocation) {
            return nil
        }
        let viewID = "MKAnnotationView"
        let annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: viewID)
        if let dot = UIImage(named: "Marker"){
            if let image = annotationsToImages[annotation as MKPointAnnotation] {
                annotationView.image = image
                annotationView.canShowCallout = true
                return annotationView
            }
        }
        return nil
    }
}