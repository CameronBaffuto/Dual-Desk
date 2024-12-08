//
//  ContentView.swift
//  Hybrid Work Tracker
//
//  Created by Cameron Baffuto on 4/16/23.
//

import SwiftUI
import CoreData

struct ContentView: View {
    var body: some View {
        TabView {
            ProgressView()
                .tabItem {
                    Label("Progress", systemImage: "arrow.up.right")
                }

            DatesView()
                .tabItem {
                    Label("History", systemImage: "list.bullet")
            }
            
            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gear")
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
