//
//  SettingsView.swift
//  Hybrid Work Tracker
//
//  Created by Cameron Baffuto on 4/21/23.
//

import SwiftUI
import MapKit

struct SettingsView: View {
    @State private var savedAddress: String = "No address saved"
    
    @State private var isShowingEditAddressSheet = false
    
    var body: some View {
        VStack {
            Text("Saved Address:")
                .font(.headline)
                .font(.title)
                .padding(.top)
            
            Text(savedAddress)
                .font(.title)
                .padding()
            
            Button(action: {
                isShowingEditAddressSheet.toggle()
            }) {
                Text("Edit Address")
                    .padding()
                    .foregroundColor(.white)
                    .background(Color.blue)
                    .cornerRadius(8)
            }
            .padding()
            
            Map {
                Marker("Work", coordinate: .work)
                    .tint(.orange)
                Marker("BMS", coordinate: .bms)
                    .tint(.purple)
                }
        }
        .sheet(isPresented: $isShowingEditAddressSheet) {
            EditAddressView(savedAddress: $savedAddress)
        }
        .padding()
        .navigationTitle("Settings")
    }
}

struct EditAddressView: View {
    @Binding var savedAddress: String
    
    @State private var newAddress: String = ""
    
    var body: some View {
        NavigationView {
            VStack {
                TextField("Enter new address", text: $newAddress)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                
                Button(action: {
                    savedAddress = newAddress
                    newAddress = ""
                }) {
                    Text("Save Address")
                        .padding()
                        .foregroundColor(.white)
                        .background(Color.green)
                        .cornerRadius(8)
                }
                .padding()

                Spacer()
            }
            .navigationTitle("Edit Address")
            .navigationBarItems(leading: Button("Cancel") {
                savedAddress = savedAddress
            })
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}

extension CLLocationCoordinate2D {
    static let work = CLLocationCoordinate2D(latitude: 40.289884, longitude: -74.712101)
    static let bms = CLLocationCoordinate2D(latitude: 40.28949, longitude: -74.71444)
}
