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
    
    let kMapwizeAPIKey = "YOUR_MAPWIZE_API_KEY"
    let kVenueID = "YOUR_VENUE_ID"
    let kFloorNumber = 1 // Please contact CrowdConnected if you're not sure about your floor number or have multiple floors

    var locationManager: CLLocationManager!
    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureMap()
        configureCCLocation()
        configureLocationProvider()
    }

    private func configureMap() {
        let mapwizeConfiguration = MWZMapwizeConfiguration(apiKey: kMapwizeAPIKey)
        mapwizeApi = MWZMapwizeApiFactory.getApi(mapwizeConfiguration:mapwizeConfiguration)
        
        let mapFrame = view.frame
        let mapUIOptions = MWZUIOptions()
        mapUIOptions.centerOnVenueId = kVenueID
        
        let mapUISettings = MWZMapwizeViewUISettings()
        mapUISettings.compassIsHidden = false
        mapUISettings.floorControllerIsHidden = false
        mapUISettings.menuButtonIsHidden = true
        mapUISettings.followUserButtonIsHidden = false
        
        map = MWZMapwizeView(frame: mapFrame,
                             mapwizeConfiguration: mapwizeConfiguration,
                             mapwizeOptions: mapUIOptions,
                             uiSettings: mapUISettings)
        map.delegate = self
        map.followUserButton.delegate = self
        
        // Disable followUser button until location is received from IndoorLocationProvider
        map.followUserButton.isEnabled = false
        
        view.addSubview(map)
    }
    
    private func configureCCLocation() {
        locationManager = CLLocationManager()
        locationManager.requestAlwaysAuthorization()
        
        let ccLocation = CCLocation.sharedInstance
        ccLocation.delegate = self
        ccLocation.registerLocationListener()
    }
    
    private func configureLocationProvider() {
        indoorLocationProvider?.addDelegate(self)
        indoorLocationProvider?.dispatchDidStart()
    }
}

extension ViewController: MWZMapwizeViewDelegate {
    func mapwizeViewDidLoad(_ mapwizeView: MWZMapwizeView!) {
        map.mapView.setIndoorLocationProvider(indoorLocationProvider!)
    }
    
    func mapwizeView(_ mapwizeView: MWZMapwizeView!, didTapOnPlaceInformationButton place: MWZPlace!) { }
    
    func mapwizeView(_ mapwizeView: MWZMapwizeView!, didTapOnPlaceListInformationButton placeList: MWZPlacelist!) { }

    func mapwizeViewDidTap(onFollowWithoutLocation mapwizeView: MWZMapwizeView!) { }

    func mapwizeViewDidTap(onMenu mapwizeView: MWZMapwizeView!) { }

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

extension ViewController: MWZComponentFollowUserButtonDelegate {
    func didTapWithoutLocation() { }
    
    func followUserButton(_ followUserButton: MWZComponentFollowUserButton!, didChange followUserMode: MWZFollowUserMode) {
        map.mapView.setFollowUserMode(followUserMode)
    }
    
    func followUserButtonRequiresUserLocation(_ followUserButton: MWZComponentFollowUserButton!) -> ILIndoorLocation! {
        return lastIndoorLocation
    }
    
    func followUserButtonRequiresFollowUserMode(_ followUserButton: MWZComponentFollowUserButton!) -> MWZFollowUserMode {
        return .followUserAndHeading
    }
}

extension ViewController: CCLocationDelegate {
    func ccLocationDidConnect() {
        // CCLocation library connected successfully
    }
    
    func ccLocationDidFailWithError(error: Error) {
        // CCLocation library failed to connect
    }
    
    func didReceiveCCLocation(_ location: LocationResponse) {
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

extension ViewController: ILIndoorLocationProviderDelegate {
    func provider(_ provider: ILIndoorLocationProvider!, didUpdate location: ILIndoorLocation!) {
        // Location did update
    }
    
    func provider(_ provider: ILIndoorLocationProvider!, didFailWithError error: Error!) {
        // Location failed with error
    }
    
    func providerDidStart(_ provider: ILIndoorLocationProvider!) {
        // Provider did start
    }
    
    func providerDidStop(_ provider: ILIndoorLocationProvider!) {
        // Provider did stop
    }
}
