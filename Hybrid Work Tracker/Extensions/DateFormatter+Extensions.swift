//
//  DateFormatter+Extensions.swift
//  Hybrid Work Tracker
//
//  Created by Cameron Baffuto on 8/17/24.
//

import Foundation

extension DateFormatter {
    static let fullDate: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .medium
        return formatter
    }()
    
    static let shortDate: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .none
        return formatter
    }()
}

