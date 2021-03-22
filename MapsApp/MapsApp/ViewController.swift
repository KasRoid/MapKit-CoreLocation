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
    }
    
    @IBAction func didTapButton(_ sender: UIButton) {
        let alertController = UIAlertController(title: "Enter Address", message: "We need your address for geocoding", preferredStyle: .alert)
        alertController.addTextField(configurationHandler: { textfield in })
        let confirmAction = UIAlertAction(title: "Pin Address", style: .default, handler: { _ in
            guard let address = alertController.textFields?.first?.text else { return }
            self.geocodeAndAnnotate(address: address)
        })
        alertController.addAction(confirmAction)
        present(alertController, animated: true, completion: nil)
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
    private func setupMapSnapShot(annotationView: MKAnnotationView) {
        let options = MKMapSnapshotter.Options()
        options.size = CGSize(width: 200, height: 200)
        options.mapType = .satellite
        guard let center = annotationView.annotation?.coordinate else { return }
        options.camera = MKMapCamera(lookingAtCenter: center,
                                     fromDistance: 150,
                                     pitch: 60,
                                     heading: 0)
        let snapShotter = MKMapSnapshotter(options: options)
        snapShotter.start(completionHandler: { snapshot, error in
            guard error == nil, let snapshot = snapshot else { print(error!); return }
            let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 200, height: 200))
            imageView.image = snapshot.image
            annotationView.detailCalloutAccessoryView = imageView
        })
    }
    private func geocodeAndAnnotate(address: String) {
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(address, completionHandler: { placemarks, error in
            guard error == nil,
                  let placemarks = placemarks,
                  let placemark = placemarks.first,
                  let coordinates = placemark.location?.coordinate else { print(error!); return }
            let newAnnotation = MKPointAnnotation()
            newAnnotation.coordinate = coordinates
            self.mapView.addAnnotation(newAnnotation)
        })
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
//        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "annotation") as? MKAnnotationView
        let annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: "annotation")
        annotationView.clusteringIdentifier = "coffee "
        annotationView.glyphText = "Coffee"
        annotationView.canShowCallout = true
        annotationView.leftCalloutAccessoryView = createImageViewForAnnotation(annotationView: annotationView, imageName: "coffee")
        annotationView.rightCalloutAccessoryView = createImageViewForAnnotation(annotationView: annotationView, imageName: "coffee2")
        setupMapSnapShot(annotationView: annotationView)
        return annotationView
    }
    func mapView(_ mapView: MKMapView, clusterAnnotationForMemberAnnotations memberAnnotations: [MKAnnotation]) -> MKClusterAnnotation {
        let cluster = MKClusterAnnotation(memberAnnotations: memberAnnotations)
        cluster.title = "Coffee, Games and Clothes"
        cluster.subtitle = "a group of cool places."
        return cluster
    }
}

// MARK: - Basics
extension ViewController {
    private func setBasics() {
        segmentedControl.addTarget(self, action: #selector(didTapSegmentedControl(_:)), for: .valueChanged)
    }
}
