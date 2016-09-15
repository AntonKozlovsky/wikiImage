//
//  ViewController.swift
//  wikiImages
//
//  Created by Frost on 15.09.16.
//  Copyright © 2016 kozlovsky. All rights reserved.
//

import UIKit
import CoreLocation

class ImageListViewController: UIViewController {

    private let controller = ArticleImageController()
    private var locationManager: CLLocationManager!

    override func viewDidLoad() {
        super.viewDidLoad()
        startLocationManager()
    }

    //MARK: Data
    private func loadArticleImages(forCoordinates coordinates: CLLocationCoordinate2D) {
        controller.loadArticles(forCoordinates: coordinates)
    }

    //MARK: Location
    private func startLocationManager() {
        guard CLLocationManager.locationServicesEnabled() else {
            //TODO: show alert
            return
        }

        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest

        if( CLLocationManager.authorizationStatus() == CLAuthorizationStatus.AuthorizedWhenInUse) {
            locationManager.requestLocation()
        } else {
            locationManager.requestWhenInUseAuthorization()
        }
    }
}

extension ImageListViewController: CLLocationManagerDelegate {
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        //TODO: show alert
        print(error)
    }

    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        locationManager.stopUpdatingLocation()

        if let location = locations.last {
            loadArticleImages(forCoordinates: location.coordinate)
        } else {
            //TODO: show alert
        }
    }

    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if( CLLocationManager.authorizationStatus() == CLAuthorizationStatus.AuthorizedWhenInUse) {
            locationManager.requestLocation()
        } 
    }

}

