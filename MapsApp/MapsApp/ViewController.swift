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
                  let coordinate = placemark.location?.coordinate else { print(error!); return }
            //            self.annotate(coordinate: coordinate)
            //            self.openInMaps(coordinate: coordinate)
            self.getDirection(coordinate: coordinate)
        })
    }
    private func annotate(coordinate: CLLocationCoordinate2D) {
        let newAnnotation = MKPointAnnotation()
        newAnnotation.coordinate = coordinate
        self.mapView.addAnnotation(newAnnotation)
    }
    private func openInMaps(coordinate: CLLocationCoordinate2D) {
        let destinationPlacemark = MKPlacemark(coordinate: coordinate)
        let mapItem = MKMapItem(placemark: destinationPlacemark)
        MKMapItem.openMaps(with: [mapItem], launchOptions: nil)
    }
    private func getDirection(coordinate: CLLocationCoordinate2D) {
        let destinationPlacemark = MKPlacemark(coordinate: coordinate)
        let sourcePoint = MKMapItem.forCurrentLocation()
        let destinationPoint = MKMapItem(placemark: destinationPlacemark)
        let request = MKDirections.Request()
        request.transportType = .automobile
        request.source = sourcePoint
        request.destination = destinationPoint
        let directions = MKDirections(request: request)
        directions.calculate(completionHandler: { response, error in
            guard error == nil,
                  let response = response,
                  let route = response.routes.first else { return }
            let steps = route.steps
            guard !steps.isEmpty else { return }
            for step in steps {
                print(step.instructions)
            }
            self.mapView.addOverlay(route.polyline, level: .aboveRoads)
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
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay)
        renderer.strokeColor = UIColor.blue.withAlphaComponent(0.8)
        renderer.lineWidth = 4
        return renderer
    }
}

// MARK: - Basics
extension ViewController {
    private func setBasics() {
        segmentedControl.addTarget(self, action: #selector(didTapSegmentedControl(_:)), for: .valueChanged)
    }
}
