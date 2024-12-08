//
//  ProgressView.swift
//  Hybrid Work Tracker
//
//  Created by Cameron Baffuto on 4/16/23.
//

import SwiftUI
import CoreData

struct MyWorkPeriod: Equatable {
    let startDate: Date
    let endDate: Date
}

func startOfWorkPeriod(for date: Date) -> Date {
    var calendar = Calendar.current
    calendar.locale = Locale(identifier: "en_US_POSIX")
    let components = calendar.dateComponents([.year, .month, .day, .weekday], from: date)
    let weekdayOffset = (components.weekday! - 2) % 7
    let weekOffset = ((calendar.component(.weekOfYear, from: date) - 1) % 2) * 7
    let totalOffset = -weekdayOffset - weekOffset
    let startDate = calendar.date(byAdding: .day, value: totalOffset, to: date)!
    return calendar.startOfDay(for: startDate)
}

func endOfWorkPeriod(for startDate: Date) -> Date {
    var calendar = Calendar.current
    calendar.locale = Locale(identifier: "en_US_POSIX")

    var endDateComponents = DateComponents()
    endDateComponents.day = 13
    endDateComponents.weekday = -((calendar.component(.weekday, from: startDate) + 13) % 7)
    let endDate = calendar.date(byAdding: endDateComponents, to: startDate)!
    return calendar.startOfDay(for: endDate)
}

struct ProgressView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Item.timestamp, ascending: true)],
        animation: .default)
    private var items: FetchedResults<Item>
    
    @State private var progress: Int = 0
    
    private var currentPeriod: MyWorkPeriod {
        let currentDate = Date()
        let startDate = startOfWorkPeriod(for: currentDate)
        let endDate = endOfWorkPeriod(for: startDate)
        return MyWorkPeriod(startDate: startDate, endDate: endDate)
    }
    
    private var itemsForCurrentPeriod: [Item] {
        items.filter { item in
            if let timestamp = item.timestamp {
                return timestamp >= currentPeriod.startDate && timestamp <= currentPeriod.endDate
            }
            return false
        }
    }
    
    var body: some View {
        NavigationView {
            VStack {
                ZStack {
                    Circle()
                        .stroke(Color.gray, lineWidth: 10)
                        .opacity(0.3)
                    Circle()
                        .trim(from: 0.0, to: CGFloat(itemsForCurrentPeriod.count)/5.0)
                        .stroke(Color.mint, lineWidth: 10)
                        .rotationEffect(.degrees(-90))
                        .animation(.linear, value: 1)
                        .onAppear {
                            self.progress = itemsForCurrentPeriod.count
                        }
                    
                  VStack {
                    Text("Days: \(itemsForCurrentPeriod.count)")
                        .foregroundColor(Color.accentColor)
                        .font(.largeTitle)
                    
                    weekdaysGrid()
                  }
                }
                .frame(width: 300, height: 300)
                .padding()
                
                Button(action: addItem) {
                    Label("Add Item", systemImage: "plus")
                }
                .buttonStyle(.bordered)
                .frame(maxWidth: .infinity)
                
            }
            .navigationTitle("Dual Desk")
            
            Spacer()
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
    
    private func weekdaysGrid() -> some View {
        let startDate = currentPeriod.startDate
        let calendar = Calendar.current

        return VStack {
            HStack {
                ForEach(["M", "T", "W", "Th", "F"], id: \.self) { dayLabel in
                    Text(dayLabel)
                        .frame(width: 20, height: 20)
                        .font(.footnote)
                }
            }

            ForEach(0..<2) { week in
                HStack {
                    ForEach(0..<5) { day in
                        let daysToAdd = week * 7 + day
                        let date = calendar.date(byAdding: .day, value: daysToAdd, to: startDate)!
                        let isItem = hasItem(for: date)
                        let circleColor = isItem ? Color.accentColor : Color.gray

                        Circle()
                            .fill(circleColor)
                            .frame(width: 20, height: 20)
                            .overlay(
                                Text("\(calendar.component(.day, from: date))")
                                    .foregroundColor(Color.white)
                                    .font(.footnote)
                            )
                    }
                }
            }
        }
    }


private func hasItem(for date: Date) -> Bool {
    let calendar = Calendar.current
        return items.contains { item in
            if let timestamp = item.timestamp {
                return calendar.isDate(timestamp, inSameDayAs: date)
            }
                return false
        }
    }
}

private let itemFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .medium
    return formatter
}()

struct ProgressView_Previews: PreviewProvider {
    static var previews: some View {
        ProgressView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
