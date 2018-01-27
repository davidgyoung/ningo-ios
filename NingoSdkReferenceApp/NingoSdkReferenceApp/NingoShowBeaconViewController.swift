//
//  NingoShowBeaconViewController.swift
//  NingoSdkReferenceApp
//
//  Created by David G. Young on 1/24/18.
//  Copyright © 2018 Altbeacon. All rights reserved.
//

import UIKit
import NingoSdk

class NingoShowBeaconViewController: ViewController, UITextFieldDelegate, UITextViewDelegate {
    @IBOutlet weak var button: UIButton!
    @IBOutlet weak var metadataTextView: UITextView!
    @IBOutlet weak var longitudeTextField: UITextField!
    @IBOutlet weak var latitudeTextField: UITextField!
    let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.gray)
    @IBOutlet weak var beaconIdentifierLabel: UILabel!
    @IBOutlet weak var scrollView: UIScrollView!
    
    var trackedBeacon: TrackedBeacon?
    var ningoBeacon: Beacon?
    var originalViewFrame: CGRect?
    
    override func viewDidLoad() {
        metadataTextView.delegate = self
        latitudeTextField.delegate = self
        longitudeTextField.delegate = self
        metadataTextView.smartQuotesType = .no
        activityIndicator.frame = CGRect(x: view.bounds.size.width/2-50, y: view.bounds.size.height/2-50, width: 100, height: 100)
        activityIndicator.isHidden = true
        if let trackedBeacon = trackedBeacon {
            beaconIdentifierLabel.text = trackedBeacon.key.replacingOccurrences(of: "_", with: "\n")
        }
        view.addSubview(activityIndicator)
        loadDataFromServer()
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidShow), name: NSNotification.Name.UIKeyboardDidShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidHide), name: NSNotification.Name.UIKeyboardDidHide, object: nil)
    }
    @objc
    func keyboardDidShow(notification: Notification) {
        var height: CGFloat = 216.0
        if let info = notification.userInfo {
            if let kbSize = info[UIKeyboardFrameEndUserInfoKey] as? CGRect {
                height = kbSize.height
            }
        }
/*
        if originalViewFrame == nil {
            originalViewFrame = self.view.frame
        }
        let frame = originalViewFrame!
        
        let newFrame = CGRect(x: frame.origin.x, y: frame.origin.y, width: frame.width, height: frame.height-height)
        self.view.frame = newFrame
 */
        scrollView.contentInset.bottom = height
    }
    
    @objc
    func keyboardDidHide(notification: Notification) {
        //self.view.frame = originalViewFrame!
        scrollView.contentInset.bottom = 0
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateEditability()
    }
    
    func showActivityIndicator() {
        view.bringSubview(toFront: activityIndicator)
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
        view.alpha = 0.5
    }
    func hideActivityIndicator() {
        self.activityIndicator.isHidden = true
        self.view.alpha = 1.0
    }

    @IBAction func buttonTapped(_ sender: Any) {
        if loggedIn() {
            saveDataToServer()
        }
        else {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "LoginViewController")
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func loggedIn() -> Bool {
        var isLoggedIn = false
        if let loginMillisString = Settings().getSetting(key: Settings.ningoLoginTimeMillis) {
            let loginTimeSecs = (Double(loginMillisString) ?? 0.0)/1000.0
            if Date().timeIntervalSince1970 - loginTimeSecs < 24*3600 {
                isLoggedIn = true
            }
        }
        return isLoggedIn
    }
    func updateEditability() {

        if loggedIn() {
            button.setTitle("Save Changes", for: .normal)
            metadataTextView.isEditable = true
        }
        else {
            button.setTitle("Sign in to Save", for: .normal)
            metadataTextView.isEditable = false
            
        }
    }
    
    func saveDataToServer() {
        var jsonDict: [String:Any]?
        var newMetadata = MetadataV1()
        if metadataTextView.text.trimmingCharacters(in: CharacterSet.whitespaces) != "" {
            if let data = metadataTextView.text.data(using: .utf8) {
                do {
                    if let result = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableContainers) as? [String:Any] {
                        jsonDict = result
                    }
                }
                catch {
                    // cannot parse json.
                    DispatchQueue.main.async {
                        let alert = UIAlertController(title: "Cannot parse json", message: "The metadata entered is not valid json.", preferredStyle: UIAlertControllerStyle.alert)
                        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
                        }))
                        self.present(alert, animated: true, completion: nil)
                    }
                    return
                }
            }
        }
        
        if let jsonDict = jsonDict {
            newMetadata = MetadataV1.fromDict(dict: jsonDict)
        }
        if let latitude = Double(latitudeTextField.text ?? ""),
            let longitude = Double(longitudeTextField.text ?? "") {
            let location: Location = newMetadata.location ?? Location(latitude: latitude, longitude: longitude)
            location.latitude = latitude
            location.longitude = longitude
            newMetadata.location = location
        }
        ningoBeacon?.metadata = newMetadata

        showActivityIndicator()
        
        let authToken = Settings().getSetting(key: Settings.ningoReadwriteApiTokenKey)!
        let postBeaconClient = PostBeaconClient(authToken: authToken)
        postBeaconClient.post(beacon: ningoBeacon!, completionHandler: { (beacon, errorCode, errorDescription) in
            DispatchQueue.main.async {
                
                self.hideActivityIndicator()
                var title = "Beacon saved successfully"
                var message: String? = nil
                if let errorCode = errorCode {
                    title = "Save Failed"
                    message = errorDescription
                    if message == nil || message == "" {
                        message = errorCode
                    }
                    
                }
                var latitude = beacon?.metadata?.location?.latitude ?? beacon?.wikiBeaconLatitude
                var longitude = beacon?.metadata?.location?.longitude ?? beacon?.wikiBeaconLongitude
                if let location = beacon?.metadata?.location {
                    latitude = location.latitude
                    longitude = location.longitude
                }
                if let latitude = latitude {
                    self.latitudeTextField.text = String(latitude)
                }
                if let longitude = longitude {
                    self.longitudeTextField.text = String(longitude)
                }
                if let metadata = beacon?.metadata {
                    self.metadataTextView.text = metadata.toJson()
                }
                
                let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
                }))
                self.present(alert, animated: true, completion: nil)
            }
        })
    }
    
    func loadDataFromServer() {
        if let trackedBeacon = trackedBeacon {
            self.showActivityIndicator()
            
            let authToken = Settings().getSetting(key: Settings.ningoReadonlyApiTokenKey)!
            let getBeaconClient = GetBeaconClient(authToken: authToken)
            getBeaconClient.get(identifier: trackedBeacon.key, completionHandler: { (beacon, errorCode, errorDescription) in
                if let beacon = beacon {
                    self.ningoBeacon = beacon
                    NSLog("Got beacon: \(beacon.identifier)")
                }
                else {
                    NSLog("Error getting beacon: \(errorCode!)")
                }
                var latitude = beacon?.metadata?.location?.latitude ?? beacon?.wikiBeaconLatitude
                var longitude = beacon?.metadata?.location?.longitude ?? beacon?.wikiBeaconLongitude
                if let location = beacon?.metadata?.location {
                    latitude = location.latitude
                    longitude = location.longitude
                }
                DispatchQueue.main.async {
                    if let latitude = latitude {
                        self.latitudeTextField.text = String(latitude)
                    }
                    if let longitude = longitude {
                        self.longitudeTextField.text = String(longitude)
                    }
                    if let metadata = beacon?.metadata {
                        self.metadataTextView.text = metadata.toJson()
                    }
                    self.hideActivityIndicator()
                }

            })
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    func textViewDidEndEditing(_ textView: UITextView) {
        textView.resignFirstResponder()
    }
    
    
}
