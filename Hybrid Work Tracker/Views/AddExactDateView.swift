//
//  AddExactDateView.swift
//  Hybrid Work Tracker
//
//  Created by Cameron Baffuto on 7/2/23.
//

import SwiftUI

struct AddExactDateView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) var dismiss
    
    @State private var selectedDate = Date()
    
    var body: some View {
        VStack {
            DatePicker("Select Exact Date", selection: $selectedDate, displayedComponents: [.date, .hourAndMinute])
                    .datePickerStyle(.compact)
                    .padding()
            
            Button(action: addItem) {
                Label("Add Item", systemImage: "plus")
            }
            .buttonStyle(.bordered)
            .frame(maxWidth: .infinity)
        }
    }
    
    private func addItem() {
        withAnimation {
            let newItem = Item(context: viewContext)
            newItem.timestamp = selectedDate
            do {
                try viewContext.save()
                dismiss()
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
}


struct AddExactDateView_Previews: PreviewProvider {
    static var previews: some View {
        AddExactDateView()
    }
}
