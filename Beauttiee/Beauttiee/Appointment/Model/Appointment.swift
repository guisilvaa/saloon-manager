//
//  Appointment.swift
//  Beauttiee
//
//  Created by Guilherme Silva on 08/01/23.
//

import Foundation
import CoreData

extension Appointment {
    
    var duration: Int {
        var calendar = Calendar.current
        let timeZone = TimeZone(identifier: "America/Sao_Paulo")!
        calendar.timeZone = timeZone
        let startComponents = calendar.dateComponents([.hour, .minute], from: startDate ?? Date.now)
        let endComponents = calendar.dateComponents([.hour, .minute], from: endDate ?? Date.now)
        
        return (calendar.dateComponents([.minute], from: startComponents, to: endComponents).minute ?? 0) * 60
    }
}
