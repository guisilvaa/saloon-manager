//
//  ServiceDuration.swift
//  Beauttiee
//
//  Created by Guilherme Silva on 01/12/22.
//

import Foundation

enum ServiceDuration: Int, CaseIterable {
    case halfHour = 30
    case hour = 60
    case hourHalf = 90
    case twoHours = 120
    case twoHalfHours = 150
    case threeHours = 180
    case fourHours = 240
    case day = 1
    
    var description: String {
        switch self {
        case .halfHour:
            return "30 minutos"
        case .hour:
            return "1 hora"
        case .hourHalf:
            return "1 hora e 30 minutos"
        case .twoHours:
            return "2 horas"
        case .twoHalfHours:
            return "2 horas e 30 minutos"
        case .threeHours:
            return "3 horas"
        case .fourHours:
            return "4 horas"
        case .day:
            return "Dia todo"
        }
    }
}
