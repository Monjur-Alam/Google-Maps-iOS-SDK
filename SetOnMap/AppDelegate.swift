//
//  AppDelegate.swift
//  SetOnMap
//
//  Created by MacBook Pro on 15/5/22.
//

import UIKit
import GoogleMaps

let googleApiKey = "AIzaSyAJnceVASls_tIv4MiZFkzY1ZrVgu6GmW4"

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
  var window: UIWindow?
  
  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    GMSServices.provideAPIKey(googleApiKey)
    return true
  }
}


