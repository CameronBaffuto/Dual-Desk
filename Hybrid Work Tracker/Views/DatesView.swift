//
//  DatesView.swift
//  Hybrid Work Tracker
//
//  Created by Cameron Baffuto on 4/16/23.
//

import SwiftUI
import CoreData
import Foundation

struct WorkPeriod: Hashable {
    let startDate: Date
    let endDate: Date

    init(startDate: Date, endDate: Date) {
        self.startDate = startDate
        self.endDate = endDate
    }
}

struct DatesView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Item.timestamp, ascending: true)],
        animation: .default)
    private var items: FetchedResults<Item>
    
    @State private var showingAddExactDateSheet = false

    var body: some View {
        NavigationView {
            List {
                ForEach(groupItemsByPeriods(), id: \.key) { period, periodItems in
                        Section(header: Text("\(period.startDate, formatter: dateFormatter) - \(period.endDate, formatter: dateFormatter)")) {
                        ForEach(periodItems, id: \.self) { item in
                                Text(item.timestamp!, formatter: itemFormatter)
                            }
                            .onDelete { indexSet in
                                deleteItems(period: period, offsets: indexSet)
                            }
                    }
                }
            }
            .listStyle(InsetGroupedListStyle())
            .navigationTitle("History")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    EditButton()
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingAddExactDateSheet = true
                    }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddExactDateSheet) {
                    AddExactDateView()
                    .presentationDetents([.medium, .large])
            }
            Text("Select an item")
        }
    }

    private func addItem() {
        withAnimation {
            let newItem = Item(context: viewContext)
            newItem.timestamp = Date()
            do {
                try viewContext.save()
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
    
    private func deleteItems(period: WorkPeriod, offsets: IndexSet) {
            withAnimation {
                offsets.forEach { index in
                    let periodItems = itemsForPeriod(period)
                    if let itemIndex = indexInItems(of: periodItems[index]) {
                        viewContext.delete(items[itemIndex])
                    }
                }
                
                do {
                    try viewContext.save()
                } catch {
                    let nsError = error as NSError
                    fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
                }
            }
        }

        private func indexInItems(of item: Item) -> Int? {
            items.firstIndex(where: { $0.objectID == item.objectID })
        }

        private func itemsForPeriod(_ period: WorkPeriod) -> [Item] {
            return groupItemsByPeriods().first(where: { $0.key == period })?.value ?? []
        }

    private func groupItemsByPeriods() -> [(key: WorkPeriod, value: [Item])] {
        var periods: [WorkPeriod: [Item]] = [:]

        for item in items {
            let workPeriod = period(for: item.timestamp!)
            if periods[workPeriod] == nil {
                periods[workPeriod] = []
            }
            periods[workPeriod]?.append(item)
        }

        return periods.sorted { $0.key.startDate > $1.key.startDate }
    }

    private func period(for date: Date) -> WorkPeriod {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .weekOfYear, .weekday], from: date)

        let weekOfYear = components.weekOfYear!
        let adjustedWeekOfYear = (weekOfYear - 1) / 2 * 2 + 1

        let startComponents = DateComponents(weekday: 2, weekOfYear: adjustedWeekOfYear, yearForWeekOfYear: components.year)
        let startDate = calendar.date(from: startComponents)!
        let startDateBeginning = calendar.startOfDay(for: startDate)

        let endDate = calendar.date(byAdding: .day, value: 11, to: startDateBeginning)!
        let endDateBeginning = calendar.startOfDay(for: endDate)

        return WorkPeriod(startDate: startDateBeginning, endDate: endDateBeginning)
    }

}

private let itemFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .medium
    return formatter
}()

private let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .none
    return formatter
}()

struct DatesView_Previews: PreviewProvider {
    static var previews: some View {
        DatesView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
