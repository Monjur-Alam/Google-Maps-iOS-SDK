//
//  ViewController.swift
//  SetOnMap
//
//  Created by MacBook Pro on 15/5/22.
//

import UIKit
import GoogleMaps
import FittedSheets


class MapViewController: UIViewController {
    @IBOutlet private weak var addressLabel: UILabel!
    @IBOutlet private weak var mapView: GMSMapView!
    @IBOutlet private weak var mapCenterPinImage: UIImageView!
    @IBOutlet private weak var pinImageVerticalConstraint: NSLayoutConstraint!
    let locationManager = CLLocationManager()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        // 1
        locationManager.delegate = self
        // 2
        if CLLocationManager.locationServicesEnabled() {
            // 3
            locationManager.requestLocation()
            // 4
            mapView.isMyLocationEnabled = true
            mapView.settings.myLocationButton = true
        } else {
            // 5
            locationManager.requestWhenInUseAuthorization()
        }
        mapView.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let viewController:
        BottomSheetController = UIStoryboard(
            name: "Main", bundle: nil
        ).instantiateViewController(withIdentifier: "BottomSheetController") as! BottomSheetController
        
        let sheetController = SheetViewController(
            controller: viewController,
            sizes: [.fixed(250), .fullscreen])
        
        sheetController.gripSize = CGSize(width: 0, height: 0)
        sheetController.cornerRadius = 10
        sheetController.minimumSpaceAbovePullBar = 0
        
        sheetController.treatPullBarAsClear = false
        
        sheetController.dismissOnOverlayTap = true
        
        sheetController.dismissOnPull = false
        
        sheetController.allowPullingPastMaxHeight = false
        sheetController.allowPullingPastMinHeight = false
        
        sheetController.autoAdjustToKeyboard = true
        
        sheetController.overlayColor = UIColor.clear
        
        sheetController.didDismiss = { _ in
            self.dismiss(animated: true, completion: nil)
        }
        self.present(sheetController, animated: false, completion: nil)
    }
}

// MARK: - CLLocationManagerDelegate
//1
extension MapViewController: CLLocationManagerDelegate {
    // 2
    func locationManager(
        _ manager: CLLocationManager,
        didChangeAuthorization status: CLAuthorizationStatus
    ) {
        // 3
        guard status == .authorizedWhenInUse else {
            return
        }
        // 4
        locationManager.requestLocation()
        
        //5
        mapView.isMyLocationEnabled = true
        mapView.settings.myLocationButton = true
    }
    
    // 6
    func locationManager(
        _ manager: CLLocationManager,
        didUpdateLocations locations: [CLLocation]) {
            guard let location = locations.first else {
                return
            }
            
            // 7
            mapView.camera = GMSCameraPosition(
                target: location.coordinate,
                zoom: 15,
                bearing: 0,
                viewingAngle: 0)
        }
    
    // 8
    func locationManager(
        _ manager: CLLocationManager,
        didFailWithError error: Error
    ) {
        print(error)
    }
}


extension MapViewController {
    func reverseGeocode(coordinate: CLLocationCoordinate2D) {
        //    Creates a GMSGeocoder object to turn a latitude and longitude coordinate into a street address.
        let geocoder = GMSGeocoder()
        //    Asks the geocoder to reverse geocode the coordinate passed to the method. It then verifies there is an address in the response of type GMSAddress. This is a model class for addresses returned by the GMSGeocoder.
        geocoder.reverseGeocodeCoordinate(coordinate) { response, error in
            self.addressLabel.unlock()
            
            guard
                let address = response?.firstResult(),
                let lines = address.lines
            else {
                return
            }
            //      Sets the text of the addressLabel to the address returned by the geocoder.
            self.addressLabel.text = lines.joined(separator: "\n")
            //      Adds padding to the top and bottom of the map before the animation block. The top padding equals the view’s top safe area inset, while the bottom padding equals the label’s height.
            let labelHeight = self.addressLabel.intrinsicContentSize.height
            let topInset = self.view.safeAreaInsets.top
            self.mapView.padding = UIEdgeInsets(
                top: topInset,
                left: 0,
                bottom: labelHeight,
                right: 0)
            //      Once the address is set, animates the changes in the label’s intrinsic content size.
            UIView.animate(withDuration: 0.25) {
                self.pinImageVerticalConstraint.constant = (labelHeight - topInset) * 0.5
                self.view.layoutIfNeeded()
            }
        }
    }
}

extension MapViewController: GMSMapViewDelegate {
    func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition) {
        let image = UIImage(named: "dropIconIdle")
        mapCenterPinImage.image = image
        reverseGeocode(coordinate: position.target)
    }
    
    func mapView(_ mapView: GMSMapView, willMove gesture: Bool) {
        self.addressLabel.lock()
        let image = UIImage(named: "dropIconMove")
        mapCenterPinImage.image = image
    }
    
}

