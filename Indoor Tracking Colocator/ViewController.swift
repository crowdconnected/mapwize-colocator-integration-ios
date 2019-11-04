//
//  ViewController.swift
//  Indoor Tracking Colocator
//
//  Created by Mobile Developer on 13/09/2019.
//  Copyright © 2019 Mobile Developer. All rights reserved.
//

import UIKit
import MapwizeUI
import CCLocation

class ViewController: UIViewController {
    let venueID = "5daf325c4ddf80001615f1e3" // ETL 2019
    let accessKey = "HbsGVi689ybLvPr5"

    var locationManager: CLLocationManager!
    var manualLocationProvider: ILIndoorLocationProvider!
    var map: MWZMapwizeView!
    var mapwizeApi: MWZMapwizeApi?

    let indoorLocationProvider = ILIndoorLocationProvider()
    var lastIndoorLocation: ILIndoorLocation? {
        didSet {
            if lastIndoorLocation != nil {
                map.followUserButton.isEnabled = true
            }
        }
    }
    var lastDirection: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager = CLLocationManager()
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
        locationManager.startUpdatingHeading()
        
        configureMap()
        
        configureCCLocation()
        
        configureLocationProvider()
    }

    private func configureMap() {
        let mapwizeConfiguration = MWZMapwizeConfiguration(apiKey: "7b63e66f6a5bebaea25fc5a0e276d5ec")
        mapwizeApi = MWZMapwizeApiFactory.getApi(mapwizeConfiguration:mapwizeConfiguration)
        
        let fr = view.frame
        let op = MWZUIOptions()
        op.centerOnVenueId = venueID
        
        let ui = MWZMapwizeViewUISettings()
        ui.compassIsHidden = false
        ui.floorControllerIsHidden = false
        ui.menuButtonIsHidden = true
        ui.followUserButtonIsHidden = false
        
        map = MWZMapwizeView(frame: fr, mapwizeConfiguration: mapwizeConfiguration, mapwizeOptions: op, uiSettings: ui)
        map.delegate = self
        map.followUserButton.delegate = self
        map.followUserButton.isEnabled = false
        view.addSubview(map)
    }
    
    private func configureCCLocation() {
        let ccLocation = CCLocation.sharedInstance
        ccLocation.delegate = self
        ccLocation.setLoggerLevels(verbose: false,
                                          info: true,
                                          debug: false,
                                          warning: true,
                                          error: true,
                                          severe: true)
        ccLocation.registerLocationListener()
    }
    
    private func configureLocationProvider() {
        indoorLocationProvider?.addDelegate(self)
        indoorLocationProvider?.dispatchDidStart()
    }
}

extension ViewController: ILIndoorLocationProviderDelegate {
    func provider(_ provider: ILIndoorLocationProvider!, didUpdate location: ILIndoorLocation!) {
        print("Location update")
    }
    
    func provider(_ provider: ILIndoorLocationProvider!, didFailWithError error: Error!) {
        print("location fail woth error")
    }
    
    func providerDidStart(_ provider: ILIndoorLocationProvider!) {
        print("provider started")
    }
    
    func providerDidStop(_ provider: ILIndoorLocationProvider!) {
        print("provider stopped")
    }
}

extension ViewController: MWZComponentFollowUserButtonDelegate {
    func didTapWithoutLocation() {
        print("Tapped without location")
    }
    
    func followUserButton(_ followUserButton: MWZComponentFollowUserButton!, didChange followUserMode: MWZFollowUserMode) {
        var mode = ""
        switch followUserMode {
        case .none:
            mode = "None"
        case .followUser:
            mode = "Follow User"
        case .followUserAndHeading:
            mode = "Follow User & Heading"
        @unknown default:
            mode = "Unknown"
        }
        print("Changed follow mode to \(mode)")
        map.mapView.setFollowUserMode(followUserMode)
    }
    
    func followUserButtonRequiresUserLocation(_ followUserButton: MWZComponentFollowUserButton!) -> ILIndoorLocation! {
        print("Required user location from provider. Location returned (\(lastIndoorLocation!.latitude) ; \(lastIndoorLocation!.longitude))")
        return lastIndoorLocation
    }
    
    func followUserButtonRequiresFollowUserMode(_ followUserButton: MWZComponentFollowUserButton!) -> MWZFollowUserMode {
        print("Asked for follow user mode. Mode returned Follow User & Heading")
        return .followUserAndHeading // this is weird. If you want to track heading, use .followUser only
    }
}

extension ViewController: MWZMapwizeViewDelegate {
    func mapwizeViewDidLoad(_ mapwizeView: MWZMapwizeView!) {
        print("MapWize did load")
        map.mapView.setIndoorLocationProvider(indoorLocationProvider!)
    }
    
    func mapwizeView(_ mapwizeView: MWZMapwizeView!, didTapOnPlaceInformationButton place: MWZPlace!) {
        print("MapWize did tap on place \(place?.alias ?? "unknown")")
    }
    
    func mapwizeView(_ mapwizeView: MWZMapwizeView!, didTapOnPlaceListInformationButton placeList: MWZPlacelist!) {
        print("MapWize did tap on place list")
        print(placeList ?? "list")
    }

    func mapwizeViewDidTap(onFollowWithoutLocation mapwizeView: MWZMapwizeView!) {
        print("MapWize following without location")
    }

    func mapwizeViewDidTap(onMenu mapwizeView: MWZMapwizeView!) {
        print("MapWize menu")
    }

    func mapwizeView(_ mapwizeView: MWZMapwizeView!, shouldShowInformationButtonFor mapwizeObject: MWZObject!) -> Bool {
        if (mapwizeObject is MWZPlace) {
            return true
        }
        return false
    }

    func mapwizeView(_ mapwizeView: MWZMapwizeView!, shouldShowFloorControllerFor floors: [MWZFloor]!) -> Bool {
        if (floors.count > 1) {
            return true
        }
        return false
    }
}

//extension ViewController: CLLocationManagerDelegate {
//    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
//        guard let last = locations.last else {
//            return
//        }
//        lastIndoorLocation = ILIndoorLocation(provider: indoorLocationProvider,
//                                              latitude: last.coordinate.latitude,
//                                              longitude: last.coordinate.longitude,
//                                              floor: 1)
//
//        indoorLocationProvider?.dispatchDidUpdate(lastIndoorLocation)
//    }
//}

extension ViewController: CCLocationDelegate {
    func ccLocationDidConnect() {
        // CCLocation library connected successfully
        print("CCLocation connected successfully")
    }
    
    func ccLocationDidFailWithError(error: Error) {
        // CCLocation library failed to connect
    }
    
    func didReceiveCCLocation(_ location: LocationResponse) {
        print("CCLocation returned location from server")
        lastIndoorLocation = ILIndoorLocation(provider: indoorLocationProvider,
                                              latitude: location.latitude,
                                              longitude: location.longitude,
                                              floor: 1)
        indoorLocationProvider?.dispatchDidUpdate(lastIndoorLocation)
    }
    
    func didFailToUpdateCCLocation() {
        // Failed to update location provider state for CCLocation
    }
}
