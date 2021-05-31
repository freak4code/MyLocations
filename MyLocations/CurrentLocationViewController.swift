//
//  FirstViewController.swift
//  MyLocations
//
//  Created by Shahriar Nasim Nafi on 2/9/20.
//  Copyright © 2020 Shahriar Nasim Nafi. All rights reserved.
//

import UIKit
import  CoreLocation
import AudioToolbox

class CurrentLocationViewController: UIViewController, CLLocationManagerDelegate {
    
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var latitudeLabel: UILabel!
    @IBOutlet weak var longitudeLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var tagButton: UIButton!
    @IBOutlet weak var getButton: UIButton!
    @IBOutlet weak var latitudeTextLabel: UILabel!
    @IBOutlet weak var longitudeTextLabel: UILabel!
    
    var updatingLocation = false
    var lastLocationError: Error?
    
    let locationManager = CLLocationManager()
    var location: CLLocation?
    let geocoder = CLGeocoder()
    var placemark: CLPlacemark?
    var performingReverseGeocoding = false
    var lastGeocodingError: Error?
    var timer: Timer?
    
    
    var logoVisible = false
    lazy var logoButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setBackgroundImage(UIImage(named: "Logo"), for: .normal)
        button.sizeToFit()
        button.addTarget(self, action: #selector(getLocation), for: .touchUpInside)
        button.center.x = self.view.bounds.midX
        button.center.y = 220
        
        return button
        
    }()
    
    var soundId: SystemSoundID = 0
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool)
    { super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = false }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadSoundEffect("Sound.caf")
        updateLabels()
        // Do any additional setup after loading the view.
        
        
    }
    
    @IBAction func getLocation() {
        
        let authStatus = CLLocationManager.authorizationStatus()
        if authStatus == .notDetermined{
            locationManager.requestWhenInUseAuthorization()
            return
        }
        if authStatus == .denied || authStatus == .restricted  {
            permissionDenied()
        }
        
        if logoVisible{
            hideLogoView()
        }
        
        if updatingLocation{
            stopLocationManager()
        } else {
            location = nil
            lastLocationError = nil
            placemark = nil
            lastGeocodingError = nil
            startLocationManager()
        }
        
        updateLabels()
        
        
    }
    
    
    //MARK: - CLLocationManagerDelegate
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error: \(error.localizedDescription)")
        if (error as NSError).code == CLError.locationUnknown.rawValue{
            return
        }
        lastLocationError = error
        stopLocationManager()
        updateLabels()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let newLocation = locations.last!
        print("Location: \(newLocation)")
        if newLocation.timestamp.timeIntervalSinceNow < -5 {
            return
        }
        
        if newLocation.horizontalAccuracy < 0{
            return
        }
        
        var distance = CLLocationDistance( Double.greatestFiniteMagnitude)
        if let location = location {
            distance = newLocation.distance(from: location) }
        
        if location == nil || location!.horizontalAccuracy > newLocation.horizontalAccuracy{
            location = newLocation
            lastLocationError = nil
            if  newLocation.horizontalAccuracy <= locationManager.desiredAccuracy{
                if distance > 0 {
                    performingReverseGeocoding = false
                }
                
                
                
                print("We are done!")
                //    print(updatingLocation)
                stopLocationManager()
                //    print(updatingLocation)
            }
            
            updateLabels()
            if !performingReverseGeocoding{
                print("Geocoding.....")
                
                performingReverseGeocoding = true
                geocoder.reverseGeocodeLocation(newLocation) { (placemarks, error) in
                    self.lastGeocodingError = error
                    if error == nil, let p = placemarks, !p.isEmpty{
                        if self.placemark == nil {
                            print("FIRST TIME!")
                            self.playSoundEffect()
                            
                        }
                        self.placemark = p.last
                    }else{
                        self.placemark = nil
                    }
                    self.performingReverseGeocoding = false
                    self.updateLabels()
                }
            } else if distance < 1{
                let timeInterval = newLocation.timestamp.timeIntervalSince(location!.timestamp)
                if timeInterval > 10 {
                    print("*** Force done!")
                    stopLocationManager()
                    updateLabels()
                }
            }
            
        }
        
    }
    //MARK: - IF Permission Don't Allow
    
    func permissionDenied(){
        let alert = UIAlertController(title: "Location Services Disabled", message: "Please enable location services for this app in Settings.", preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
        alert.addAction(okAction)
        present(alert, animated: true, completion: nil)
    }
    
    
    
    
    
    
    func updateLabels(){
        if let location = location{
            latitudeLabel.text = String(format: "%.8f",location.coordinate.latitude)
            longitudeLabel.text = String(format: "%.8f",location.coordinate.longitude)
            tagButton.isHidden = false
            latitudeTextLabel.isHidden = false
            longitudeTextLabel.isHidden = false
            messageLabel.text = ""
            //placemark = nil
            if let placemark = placemark{
                addressLabel.text = _String(from: placemark)
            }else if performingReverseGeocoding {
                addressLabel.text = "Searching for Address..."
            }else if lastGeocodingError != nil{
                addressLabel.text = "Error Finding Address"
            }else{
                addressLabel.text = "No Address Found"
            }
            
        }else{
            latitudeLabel.text = ""
            longitudeLabel.text = ""
            addressLabel.text = ""
            tagButton.isHidden = true
            latitudeTextLabel.isHidden = true
            longitudeTextLabel.isHidden = true
            let statusMessage: String
            if let error = lastLocationError as NSError? {
                if error.domain == kCLErrorDomain && error.code == CLError.denied.rawValue {
                    statusMessage = "Location Services Disabled"
                } else {
                    statusMessage = "Error Getting Location"
                }
            } else if !CLLocationManager.locationServicesEnabled() {
                statusMessage = "Location Services Disabled"
            } else if updatingLocation {
                statusMessage = "Searching..."
            } else {
                statusMessage = ""
                showLogoView()
                
            }
            messageLabel.text = statusMessage
            
            
        }
        configureGetButton()
    }
    
    //MARK: - Start / Stop : CLLocationManager
    
    func startLocationManager(){
        if CLLocationManager.locationServicesEnabled(){
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
            updatingLocation = true
            timer = Timer.scheduledTimer(timeInterval: 60, target: self, selector: #selector(didTimeOut), userInfo: nil, repeats: false)
        }
        
        
    }
    
    func stopLocationManager(){
        if updatingLocation{
            locationManager.stopUpdatingLocation()
            locationManager.delegate = nil
            updatingLocation = false
            if let timer = timer{
                timer.invalidate()
            }
            
        }
    }
    
    func configureGetButton(){
        let spinnerTag = 10000
        
        if updatingLocation {
            getButton.setTitle("Stop", for: .normal)
            if view.viewWithTag(spinnerTag) == nil {
                let spinner = UIActivityIndicatorView(style: .white)
                spinner.center = messageLabel.center
                spinner.center.y += spinner.bounds.size.height/2 + 25
                spinner.startAnimating()
                spinner.tag = spinnerTag
                containerView.addSubview(spinner)
            }else{
                getButton.setTitle("Get My Location", for: .normal)
                if let spinner = view.viewWithTag(spinnerTag) {
                    spinner.removeFromSuperview() }
            }
        }
    }
    
    func _String(from placemark: CLPlacemark) -> String{
        var line1 = ""
        
        line1.add(text: placemark.subThoroughfare)
        line1.add(text: placemark.thoroughfare, separatedBy: " ")
        
        
        var line2 = ""
        line2.add(text: placemark.locality)
        line2.add(text: placemark.administrativeArea, separatedBy: " ")
        line2.add(text: placemark.postalCode, separatedBy: " ")
        
        line1.add(text: line2, separatedBy: "\n")
        return line1
    }
    
    @objc func didTimeOut(){
        print("*** Time out")
        if location == nil{
            stopLocationManager()
            lastLocationError = NSError(domain: "MyLocationsErrorDomain", code: 1, userInfo: nil)
            updateLabels()
        }
    }
    
    func showLogoView(){
        if !logoVisible{
            logoVisible = true
            containerView.isHidden = true
            view.addSubview(logoButton)
        }
    }
    
    func hideLogoView(){
        if !logoVisible { return }
        logoVisible = false
        containerView.isHidden = false
        containerView.center.x = view.bounds.size.width * 2
        containerView.center.y = 40 +
            containerView.bounds.size.height / 2
        let centerX = view.bounds.midX
        let panelMover = CABasicAnimation(keyPath: "position")
        panelMover.isRemovedOnCompletion = false
        panelMover.fillMode = CAMediaTimingFillMode.forwards
        panelMover.duration = 0.6
        panelMover.fromValue = NSValue(cgPoint: containerView.center)
        panelMover.toValue = NSValue(cgPoint:
            CGPoint(x: centerX, y: containerView.center.y))
        panelMover.timingFunction = CAMediaTimingFunction(
            name: CAMediaTimingFunctionName.easeOut)
        panelMover.delegate = self
        containerView.layer.add(panelMover, forKey: "panelMover")
        let logoMover = CABasicAnimation(keyPath: "position")
        logoMover.isRemovedOnCompletion = false
        logoMover.fillMode = CAMediaTimingFillMode.forwards
        logoMover.duration = 0.5
        logoMover.fromValue = NSValue(cgPoint: logoButton.center)
        logoMover.toValue = NSValue(cgPoint:
            CGPoint(x: -centerX, y: logoButton.center.y))
        logoMover.timingFunction = CAMediaTimingFunction(
            name: CAMediaTimingFunctionName.easeIn)
        logoButton.layer.add(logoMover, forKey: "logoMover")
        let logoRotator = CABasicAnimation(keyPath: "transform.rotation.z")
        logoRotator.isRemovedOnCompletion = false
        logoRotator.fillMode = CAMediaTimingFillMode.forwards
        logoRotator.duration = 0.5
        logoRotator.fromValue = 0.0
        logoRotator.toValue = -2 * Double.pi
        logoRotator.timingFunction = CAMediaTimingFunction(
            name: CAMediaTimingFunctionName.easeIn)
        logoButton.layer.add(logoRotator, forKey: "logoRotator")
    }
    
    
   
   
    
    //MARK: - Prepare For Next Controller(s)
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier ==  "TagLocation"{
            let destination = segue.destination as! LocationDetailsViewController
            destination.coordinate = location!.coordinate
            destination.placemark = placemark
            
            
        }
    }
    
    //MARK: - SoundEffect
    
    func loadSoundEffect(_ name: String){
        if let path = Bundle.main.path(forResource: name, ofType: nil){
            let fileURL = URL(fileURLWithPath: path, isDirectory: false)
            let error = AudioServicesCreateSystemSoundID(fileURL as CFURL, &soundId)
            if error != kAudioServicesNoError{
                print("Error code \(error) loading sound: \(path)")
            }
        }
        
    }
    
    func unloadSoundEffect(){
        AudioServicesDisposeSystemSoundID(soundId)
        soundId = 0
    }
    
    func playSoundEffect(){
        AudioServicesPlaySystemSound(soundId)
    }
}


extension CurrentLocationViewController: CAAnimationDelegate{
    
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        containerView.layer.removeAllAnimations()
        containerView.center.x = view.bounds.size.width / 2
        containerView.center.y = 40 +
            containerView.bounds.size.height / 2
        logoButton.layer.removeAllAnimations()
        logoButton.removeFromSuperview()
    }
}

