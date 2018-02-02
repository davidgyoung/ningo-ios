//
//  BeaconListViewController.swift
//  BeaconScanner
//
//  Created by David G. Young on 1/12/18.
//  Copyright © 2018 Altbeacon. All rights reserved.
//

import UIKit

class BeaconListViewController: UITableViewController {
    let beaconTracker = BeaconTracker.shared
    let permissionRequester = PermissionRequester()
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        beaconTracker.start()
        NotificationCenter.default.addObserver(self, selector: #selector(beaconsUpdated), name: NSNotification.Name("beacons_updated"), object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        permissionRequester.ensureForegroundPermission()
    }
    
    @objc func beaconsUpdated() {
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return beaconTracker.trackedBeacons.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "cell") as! BeaconCell
        let beacon = beaconTracker.sorted()[indexPath.row]
        cell.identifierLabel.text = "\(beacon.beacon.proximityUUID.uuidString)"
        let ningoIndicator = ningoDataForBeaconExists(identifier: beacon.key) ? "(N)" : ""
        cell.secondLabel.text = "\(beacon.beacon.major) \(beacon.beacon.minor) \(ningoIndicator)"
        return cell
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        if beaconTracker.trackedBeacons.count == 0 {
            return "No beacons found (\(beaconTracker.rangedUuidCount()) UUIDs)"
        }
        else {
            return "\(beaconTracker.trackedBeacons.count) beacons found (\(beaconTracker.rangedUuidCount()) UUIDs)"
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let vc = storyboard.instantiateViewController(withIdentifier: "NingoShowBeaconViewController") as? NingoShowBeaconViewController {
            vc.trackedBeacon =  beaconTracker.sorted()[indexPath.row]
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func ningoDataForBeaconExists(identifier: String) -> Bool {
        let ningoBeacons = (UIApplication.shared.delegate as! AppDelegate).nearbyNingoBeacons
        // TODO: This should be optimized
        for beacon in ningoBeacons {
            if beacon.identifier
                == identifier.lowercased() {
                return true
            }
        }
        return false
    }
    
}


