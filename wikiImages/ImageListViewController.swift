//
//  ViewController.swift
//  wikiImages
//
//  Created by Frost on 15.09.16.
//  Copyright © 2016 kozlovsky. All rights reserved.
//

import UIKit
import CoreLocation
import SCLAlertView

class ImageListViewController: UIViewController {

    private let controller = ArticleImageController()
    private var locationManager: CLLocationManager!
    private var progressLocationAlertViewResponder: SCLAlertViewResponder?
    private var progressImageLoadAlertViewResponder: SCLAlertViewResponder?
    private var errorAlertViewResponder: SCLAlertViewResponder?
    
    @IBOutlet weak var tableView: UITableView!
    private var refreshControl: UIRefreshControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initControls()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        subscribeForNotifications()
        updateScreenForCurrentControllerState()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        UIApplication.sharedApplication().keyWindow!
        startLocationManager()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscribeFromNotifications()
    }
    
    private func initControls() {
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 40
        addPullToRefreshControl()
    }
    
    private func addPullToRefreshControl() {
        refreshControl = UIRefreshControl()
        refreshControl.attributedTitle = NSAttributedString(string: "Refresh images".localized)
        refreshControl.addTarget(self, action: #selector(refresh), forControlEvents: .ValueChanged)
        tableView.addSubview(refreshControl)
    }
    
    private func resetScreen() {
        progressLocationAlertViewResponder?.close()
        progressLocationAlertViewResponder = nil
        
        progressImageLoadAlertViewResponder?.close()
        progressImageLoadAlertViewResponder = nil
        
        errorAlertViewResponder?.close()
        errorAlertViewResponder = nil
        
        refreshControl.endRefreshing()
    }
    
    private func updateScreenForCurrentControllerState() {
        resetScreen()
        
        guard UIApplication.sharedApplication().keyWindow != nil else { return }
        
        switch controller.loadingState {
        case .Loading:
            showImageLoadingAlert()
            tableView.reloadData()
        case .Loaded:
            tableView.reloadData()
        case .Error(let error):
            showControllerError(error)
        default: break
        }
    }
    
    //MARK: Data
    private func loadArticleImages(forCoordinates coordinates: CLLocationCoordinate2D) {
        controller.loadArticles(forCoordinates: coordinates)
    }

    //MARK: Location
    private func startLocationManager() {
        guard CLLocationManager.locationServicesEnabled() else {
            showLocationServiceError()
            return
        }

        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest

        if( CLLocationManager.authorizationStatus() == CLAuthorizationStatus.AuthorizedWhenInUse) {
            requestLocation()
        } else {
            locationManager.requestWhenInUseAuthorization()
        }
    }
    
    //MARK: Alerts
    private func modalAlert() -> SCLAlertView {
        let appearance = SCLAlertView.SCLAppearance(showCloseButton:false)
        return SCLAlertView(appearance: appearance)
    }
    
    private func showLocationDeterminError() {
        resetScreen()
        errorAlertViewResponder = SCLAlertView().showError("Location error".localized, subTitle: "Cannot determine Your current location".localized)
    }
    
    private func showLocationServiceError() {
        resetScreen()
        errorAlertViewResponder = SCLAlertView().showError("Location error".localized, subTitle: "Location service must be turned on".localized)
    }
    
    private func showImageLoadingAlert() {
        resetScreen()
        progressImageLoadAlertViewResponder = modalAlert().showWait("Please, wait".localized, subTitle: "Images loading...".localized, animationStyle: .NoAnimation)
    }
    
    private func showControllerError(error: NSError) {
        resetScreen()
        errorAlertViewResponder = SCLAlertView().showError("Error".localized, subTitle: error.localizedDescription)
    }
    
    //MARK: Notification
    private func subscribeForNotifications() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(handleControllerStatusDidChange), name: ArticleImageController.Notification.StateDidChange.rawValue, object: controller)
    }
    
    private func unsubscribeFromNotifications() {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    @objc func handleControllerStatusDidChange(notif: NSNotification) {
        updateScreenForCurrentControllerState()
    }
    
    //MARK: Actions
    @objc func refresh() {
        requestLocation()
    }
}

extension ImageListViewController: CLLocationManagerDelegate {
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        showLocationDeterminError()
        print(error)
    }

    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        locationManager.stopUpdatingLocation()

        if let location = locations.last {
            loadArticleImages(forCoordinates: location.coordinate)
        } else {
            showLocationDeterminError()
        }
    }

    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if( CLLocationManager.authorizationStatus() == CLAuthorizationStatus.AuthorizedWhenInUse) {
            requestLocation()
        } 
    }
    
    private func requestLocation() {
        guard progressLocationAlertViewResponder == nil else { return }
    
        progressLocationAlertViewResponder = modalAlert().showWait("Please, wait".localized, subTitle: "Location detecting...".localized, animationStyle: .NoAnimation)
        locationManager.requestLocation()
    }
    
    
}

extension ImageListViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return controller.groupList?.count ?? 0
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let group = controller.groupList![section]
        return group.imageList.count
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let group = controller.groupList![section]
        return group.title
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cellId = "imageCell"
        
        let group = controller.groupList![indexPath.section]
        let articleImage = group.imageList[indexPath.row]
        
        let cell = tableView.dequeueReusableCellWithIdentifier(cellId, forIndexPath: indexPath)
        cell.textLabel?.text = articleImage.title
        return cell
    }
}

