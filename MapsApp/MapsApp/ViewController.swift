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
    fileprivate let locationManager = CLLocationManager()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupMapView()
        setupLocationManager()
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
    
}
