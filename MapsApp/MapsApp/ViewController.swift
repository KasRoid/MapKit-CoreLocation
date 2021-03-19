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
    
    fileprivate let locationManager = CLLocationManager()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setBasics()
        setupMapView()
        setupLocationManager()
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
}

// MARK: - CLLocationManagerDelegate
extension ViewController: CLLocationManagerDelegate {
    
}

// MARK: - MKMapViewDelegate
extension ViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        let region = MKCoordinateRegion(center: mapView.userLocation.coordinate,
                                        latitudinalMeters: 10,
                                        longitudinalMeters: 10)
        mapView.setRegion(region, animated: true)
    }
}

// MARK: - Basics
extension ViewController {
    private func setBasics() {
        segmentedControl.addTarget(self, action: #selector(didTapSegmentedControl(_:)), for: .valueChanged)
    }
}
