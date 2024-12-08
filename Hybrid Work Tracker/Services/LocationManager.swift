//
//  LocationManager.swift
//  Hybrid Work Tracker
//
//  Created by Cameron Baffuto on 8/17/24.
//

import Foundation
import CoreLocation
import UserNotifications

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let locationManager = CLLocationManager()
    
    @Published var currentLocation: CLLocation? = nil
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            currentLocation = location
            checkIfReachedTargetLocation(location: location)
        }
    }
    
    private func checkIfReachedTargetLocation(location: CLLocation) {
        guard let address = UserDefaults.standard.string(forKey: "address"), !address.isEmpty else {
            return
        }
        
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(address) { placemarks, error in
            if let placemark = placemarks?.first, let targetLocation = placemark.location {
                let distance = location.distance(from: targetLocation)
                if distance < 100 { // Check if within 100 meters
                    self.sendNotification()
                }
            }
        }
    }
    
    private func sendNotification() {
        let content = UNMutableNotificationContent()
        content.title = "You’ve Arrived!"
        content.body = "Log your day in the office"
        content.sound = UNNotificationSound.default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request)
    }
}

