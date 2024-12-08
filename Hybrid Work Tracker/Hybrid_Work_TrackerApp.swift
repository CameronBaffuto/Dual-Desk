//
//  Hybrid_Work_TrackerApp.swift
//  Hybrid Work Tracker
//
//  Created by Cameron Baffuto on 4/16/23.
//

import SwiftUI
import UserNotifications

@main
struct Hybrid_Work_TrackerApp: App {
    let persistenceController = PersistenceController.shared
    @StateObject private var locationManager = LocationManager()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .environmentObject(locationManager)
                .onAppear {
                    trackInstallDate()
                    requestNotificationPermissions()
                    scheduleExpirationNotification()
                }
        }
    }

    private func trackInstallDate() {
        if UserDefaults.standard.object(forKey: "installDate") == nil {
            UserDefaults.standard.set(Date(), forKey: "installDate")
        }
    }

    private func requestNotificationPermissions() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                print("Failed to request notification permissions: \(error)")
            }
        }
    }

    private func scheduleExpirationNotification() {
        guard let installDate = UserDefaults.standard.object(forKey: "installDate") as? Date else { return }
        let calendar = Calendar.current
        let expirationDate = calendar.date(byAdding: .day, value: 6, to: installDate)!

        let content = UNMutableNotificationContent()
        content.title = "Re-sign Your App"
        content.body = "Your app will expire tomorrow. Please re-sign it."
        content.sound = UNNotificationSound.default

        let triggerDate = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: expirationDate)
        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)

        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
    }
}


