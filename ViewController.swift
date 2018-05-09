//
//  ViewController.swift
//  Alarm
//
//  Created by Lasha Efremidze on 1/9/17.
//  Copyright © 2017 Lasha Efremidze. All rights reserved.
//

import UIKit
import RevealingSplashView
import CoreLocation
import Fabric
import Crashlytics

class ViewController: UIViewController,CLLocationManagerDelegate {
    
    let locationManager = CLLocationManager()
    var location: CLLocation?
    var Weather2D: CLLocationCoordinate2D?
    
    lazy var splashView: RevealingSplashView = { [unowned self] in
        let image = UIImage(named: "weed")!
        let view = RevealingSplashView(iconImage: image, iconInitialSize: image.size, backgroundColor: .weedGreen)
        self.view.addSubview(view)
        return view
    }()
    
    lazy var tableView: TableViewController = { [unowned self] in
        let viewController = TableViewController(style: .grouped)
        viewController.willMove(toParentViewController: self)
        self.addChildViewController(viewController)
        self.view.addSubview(viewController.view)
        viewController.didMove(toParentViewController: self)
        viewController.view.constrainToEdges()
        return viewController
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        HelpshiftCore.initialize(with: HelpshiftAll.sharedInstance())
//        HelpshiftCore.install(forApiKey: "d2fb09a5aab5d78081bea7e3263f2965", domainName: "morevoltage.helpshift.com", appID: "morevoltage_platform_20170222092520006-a5b526294f4d663")
        
        Fabric.with([Crashlytics.self])
        
        UINavigationBar.appearance().setBackgroundImage(UIImage(color: .weedGreen), for: .default)
        UINavigationBar.appearance().shadowImage = UIImage()
        UINavigationBar.appearance().tintColor = .white
        UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
        UISwitch.appearance().onTintColor = .weedGreen
        
        Alarm.start { accepted, error in
            if accepted {
                Defaults.once(Constants.scheduledAlarm) {
                    AlarmType.pm.schedule { error in
                        NC.post(name: .alarmsChanged, object: nil)
                    }
                }
            }
        }
        
        getCurrentCityLoaction()
//        addWeatherButton()
        
        _ = tableView
        
//        splashView.startAnimation()
        
        
    }
    
    //MARK: - StartCurrentCity
    func getCurrentCityLoaction()
    {
        let authStatus = CLLocationManager.authorizationStatus()
        if authStatus == .notDetermined {
            locationManager.requestWhenInUseAuthorization()
            return
        }
        if authStatus == .denied || authStatus == .restricted {
            showLocationServicesDeniedAlert()
            return
        }
        startLocationManager()
    }
    
    func showLocationServicesDeniedAlert() {
        let alert = UIAlertController(title: "Location Services Disabled",message:"Please enable location services for this app in Settings.", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(okAction)
        present(alert, animated: true, completion: nil)
    }
    
    func startLocationManager() {
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
            locationManager.startUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print ("here")
        
        let newLocation = locations.last!
        if newLocation.timestamp.timeIntervalSinceNow < -5 {
            print("too old")
            return
        }
        
        if newLocation.horizontalAccuracy < 0 {
            print ("less than 0")
            return
        }
        if location == nil || location!.horizontalAccuracy > newLocation.horizontalAccuracy   {
            print ("improving")
            
            location = newLocation
            Weather2D = newLocation.coordinate
            locationManager.stopUpdatingLocation()
            return
            //            if newLocation.horizontalAccuracy <= locationManager.desiredAccuracy {
            //                search.cancelSearches()
            //                print("*** We're done!")
            //                let center = CLLocationCoordinate2D(latitude: newLocation.coordinate.latitude, longitude: newLocation.coordinate.longitude)
            //                let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
            //                self.mapView.setRegion(region, animated: true)
            //                stopLocationManager()
            //            }
        }
    }
    
    
    //MARK: - AddLeftButton
    
    func addWeatherButton(){
        let btnAction = UIButton(frame:CGRect(x:0, y:0, width:18, height:18))
        btnAction.setTitle("🌞", for: .normal)
        
//        btnAction.addTarget(self,action:#selector(GotoWeatherAction()),for:.touchUpInside)
        let itemAction=UIBarButtonItem(customView: btnAction)
        self.navigationItem.leftBarButtonItem=itemAction
    }
    
    func GotoWeatherAction()
    {
        if(location?.coordinate.latitude == 0.0 || location?.coordinate.longitude == 0.0 || location == nil || Weather2D == nil)
        {
            showLocationFauseAlert()
        }
        else
        {
            let WeatherView:WeatherViewController = WeatherViewController()
            WeatherView.loaction = location
            WeatherView.lat  = (Weather2D?.latitude)!
            WeatherView.lng = (Weather2D?.longitude)!
            
            present(WeatherView, animated: true, completion: nil)
        }
        
    }
    
    func showLocationFauseAlert() {
        let alert = UIAlertController(title: nil,message:"Failed to get the current location, please check if location permission is enabled,Or try clicking on the weather again after clicking ‘OK’", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default){ action in
            
            self.locationManager.delegate = self
            self.locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
            self.locationManager.startUpdatingLocation()
            
        }
        alert.addAction(okAction)
        present(alert, animated: true, completion: nil)
    }
}
