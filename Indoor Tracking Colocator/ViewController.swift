//
//  ViewController.swift
//  Indoor Tracking Colocator
//
//  Created by Mobile Developer on 13/09/2019.
//  Copyright © 2019 Mobile Developer. All rights reserved.
//

import UIKit
import MapwizeUI

class ViewController: UIViewController {
    
    let venueID = "5daf325c4ddf80001615f1e3" // ETL 2019
    let accessKey = "HbsGVi689ybLvPr5"
    
    var locationManager: CLLocationManager!
    var manualLocationProvider: ILIndoorLocationProvider!
    var map: MWZMapwizeView!
    var mapwizeView: MWZMapView?
    var mapwizeApi: MWZMapwizeApi?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager = CLLocationManager()
        locationManager.requestAlwaysAuthorization()
        
        configureAPIandMapView()
//        configureMap()
//        configureAccess()
        configureDirection()
    }
    
    private func configureAPIandMapView() {
        let mapwizeConfiguration = MWZMapwizeConfiguration(apiKey: "7b63e66f6a5bebaea25fc5a0e276d5ec")
        mapwizeApi = MWZMapwizeApiFactory.getApi(mapwizeConfiguration:mapwizeConfiguration)
 
        let options = MWZOptions()
        options.centerOnVenueId = venueID
        
        mapwizeView = MWZMapView(frame: self.view.frame, options: options, mapwizeConfiguration: mapwizeConfiguration)
        mapwizeView?.delegate = self
        mapwizeView?.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.view.addSubview(mapwizeView!)
    }
    
    private func configureMap() {
        let fr = view.frame
        let op = MWZUIOptions()
        op.centerOnVenueId = venueID
        
        let ui = MWZMapwizeViewUISettings()
        ui.compassIsHidden = false
        ui.floorControllerIsHidden = true
        ui.menuButtonIsHidden = false
        ui.followUserButtonIsHidden = true
        
        map = MWZMapwizeView(frame: fr, mapwizeOptions: op, uiSettings: ui)
        map.delegate = self
        view.addSubview(map)
    }
    
    private func configureAccess() {
        map.grantAccess(accessKey, success:
            {
                print("Access granted")
            }) { (error) in
                print("Access denied with error")
                print(error.localizedDescription)
            }
    
        MWZMapwizeApiFactory.getApi().getAccess(accessKey: accessKey, success:
            {
                print("Access granted in API")
            }) { (err) in
                print("Access denied in API")
                print(err.localizedDescription)
            }
    }
    
    private func configureDirection() {
//        let pointA = MWZDirectionWrapper(latitude: 2, longitude: 4, floor: 5, placeId: "placeId", venueId: "venueId", placeListId: "PlaceListId")
//        let pointB = MWZDirectionWrapper(latitude: 22, longitude: 42, floor: 5, placeId: "placeId2", venueId: "venueId2", placeListId: "PlaceListId2")
//
//        MWZMapwizeApiFactory.getApi().getDirection(from: pointA, to: pointB, isAccessible: true, success: { newDirection in
//            print("Got direction between 2 points: \(String(describing: newDirection))")
//            self.map.setDirection(newDirection, from: pointA, to: pointB, isAccessible: true)
//        }) { (err) in
//            print("Failed to get direction between 2 points \(err)")
//        }
    }
}

extension ViewController: MWZMapViewDelegate {
    func mapViewDidLoad(_ mapView: MWZMapView) {
        print("Mapwize is ready to be used")
    }
}

extension ViewController: MWZMapwizeViewDelegate {
    func mapwizeViewDidLoad(_ mapwizeView: MWZMapwizeView!) {
        print("MapWize did load")
    }
    
    func mapwizeView(_ mapwizeView: MWZMapwizeView!, didTapOnPlaceInformationButton place: MWZPlace!) {
        print("MapWize did tap on place")
        print(place ?? "place")
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
