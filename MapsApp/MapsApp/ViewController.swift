//
//  ViewController.swift
//  MapsApp
//
//  Created by Kas Song on 2021/03/19.
//

import MapKit
import UIKit

class ViewController: UIViewController {

    // MARK: - Properties
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    private let locationManager = CLLocationManager()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setBasics()
        setupMapView()
        setupLocationManager()
//        addAnnotationToMap()
    }
}

// MARK: - Selectors
extension ViewController {
    @objc
    func didTapSegmentedControl(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            mapView.mapType = .standard
        case 1:
            mapView.mapType = .satellite
        case 2:
            mapView.mapType = .hybrid
        default:
            return
        }
    }
}

// MARK: - Helpers
extension ViewController {
    private func createImageViewForAnnotation(annotationView: MKMarkerAnnotationView, imageName: String) -> UIImageView {
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: annotationView.frame.height, height: annotationView.frame.height))
        imageView.image = UIImage(named: imageName)
        imageView.contentMode = .scaleAspectFit
        return imageView
    }
}

// MARK: - Map Related
extension ViewController {
    private func setupMapView() {
        mapView.showsUserLocation = true
        mapView.delegate = self
    }
    private func setupLocationManager() {
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = kCLDistanceFilterNone
        locationManager.startUpdatingLocation()
    }
    private func setUserRegion(userLocation: MKUserLocation) {
        let region = MKCoordinateRegion(center: mapView.userLocation.coordinate,
                                        latitudinalMeters: 10,
                                        longitudinalMeters: 10)
        mapView.setRegion(region, animated: true)
    }
    private func addAnnotationToMap() {
        let annotation = MKPointAnnotation()
//        annotation.coordinate = CLLocationCoordinate2D(latitude: 37.85, longitude: -122.4194)
        annotation.coordinate = mapView.userLocation.coordinate
        annotation.title = "Kas Song"
        annotation.subtitle = "I'm here"
        print(mapView.userLocation.coordinate)
        mapView.addAnnotation(annotation)
    }
}

// MARK: - CLLocationManagerDelegate
extension ViewController: CLLocationManagerDelegate {
    
}

// MARK: - MKMapViewDelegate
extension ViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
//        setUserRegion(userLocation: userLocation)
        addAnnotationToMap()
    }
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation { return nil }
//        var marker = mapView.dequeueReusableAnnotationView(withIdentifier: "annotation") as? MKAnnotationView
        let annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: "annotation")
        annotationView.glyphText = "Coffee"
        annotationView.canShowCallout = true
        annotationView.leftCalloutAccessoryView = createImageViewForAnnotation(annotationView: annotationView, imageName: "coffee")
        annotationView.rightCalloutAccessoryView = createImageViewForAnnotation(annotationView: annotationView, imageName: "coffee2")
        return annotationView
    }
}

// MARK: - Basics
extension ViewController {
    private func setBasics() {
        segmentedControl.addTarget(self, action: #selector(didTapSegmentedControl(_:)), for: .valueChanged)
    }
}
