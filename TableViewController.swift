//
//  TableViewController.swift
//  Alarm
//
//  Created by Lasha Efremidze on 2/8/17.
//  Copyright © 2017 Lasha Efremidze. All rights reserved.
//

import UIKit
import CoreLocation

class TableViewController: UITableViewController,CLLocationManagerDelegate {
    
    let locationManager = CLLocationManager()
    var location: CLLocation?
    var Weather2D: CLLocationCoordinate2D?
    let items = Item.all()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.backgroundColor = UIColor(patternImage: UIImage(named: "pattern")!)
        self.tableView.tableHeaderView = {
            let view = UIView()
            view.frame.size.height = 150
            let imageView = UIImageView(image: UIImage(named: "weed"))
            imageView.tintColor = .weedGreen
            view.addSubview(imageView)
            imageView.constrain {[
                $0.centerXAnchor.constraint(equalTo: $0.superview!.centerXAnchor),
                $0.centerYAnchor.constraint(equalTo: $0.superview!.centerYAnchor, constant: 25)
            ]}
            return view
        }()
        self.tableView.tableFooterView = UIView()
        self.tableView.keyboardDismissMode = .interactive
        getCurrentCityLoaction()
        NC.addObserver(forName: .alarmsChanged, object: nil, queue: nil) { [weak self] notification in
            self?.tableView.reloadData()
        }
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

// MARK: - UITableViewDataSource
extension TableViewController {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return items.count+1
        default:
            return 1
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            if(indexPath.row <= 2)
            {
            let reuseIdentifier = String(describing: SwitchTableViewCell.self)
            let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier) as? SwitchTableViewCell ?? SwitchTableViewCell(style: .default, reuseIdentifier: reuseIdentifier)
            let item = items[indexPath.row]
            cell.selectionStyle = .none
            cell.imageView?.image = UIImage(named: item.type.rawValue)
            cell.imageView?.contentMode = .center
            cell.imageView?.tintColor = .weedGreen
            cell.textLabel?.text = item.title
            cell.textLabel?.textColor = .dark
            cell.textLabel?.font = .preferredFont(forTextStyle: .body)
            cell.detailTextLabel?.text = item.subtitle
            item.type.isScheduled { [weak cell] scheduled in
                cell?.switchView.isOn = scheduled
            }
            cell.valueChanged = { switchView in
                if switchView.isOn {
                    item.type.schedule { error in }
                } else {
                    item.type.unschedule()
                }
            }
            return cell
            }else
            {
                let reuseIdentifier = String(describing: SwitchTableViewCell.self)
                let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier) as? SwitchTableViewCell ?? SwitchTableViewCell(style: .default, reuseIdentifier: reuseIdentifier)
                let item = items[1]
                cell.selectionStyle = .none
                cell.imageView?.image = UIImage(named: item.type.rawValue)
                cell.imageView?.contentMode = .center
                cell.imageView?.tintColor = .weedGreen
                cell.textLabel?.text = "Current Weather"
                cell.textLabel?.textColor = .dark
                cell.textLabel?.font = .preferredFont(forTextStyle: .body)
                cell.detailTextLabel?.text = ""
                cell.switchView.isHidden = true
                return cell
                /*
                let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
                cell.textLabel?.text = "☁️ Current Weather"
                return cell*/
            }
        default:
            let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
            cell.textLabel?.text = "Send Feedback"
            return cell
        }
    }
    
}

// MARK: - UITableViewDelegate
extension TableViewController {
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case 0:
            cell.separatorInset.left = 54
            cell.preservesSuperviewLayoutMargins = false
            cell.layoutMargins = UIEdgeInsets()
        default:
            break
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return "Scheduled Alarms"
        default:
            return nil
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        switch indexPath.section {
        case 0:
            do {
            if(indexPath.row == 0)
            { return }
            else if(indexPath.row == 1)
                {return}else if(indexPath.row == 2)
                {return}else
            {
                self.GotoWeatherAction()
            }
        }
        case 1:
            HelpshiftSupport.showFAQs(self.parent!, with: nil)
        default:
            break
        }
    }
    
}
