//
//  PaymentType.swift
//  Beauttiee
//
//  Created by Guilherme Silva on 30/12/22.
//

import Foundation

enum PaymentType: Int, CaseIterable {
    case pix = 1
    case money
    case credit
    case debit
    
    var description: String {
        switch self {
        case .pix:
            return "Pix"
        case .money:
            return "Dinheiro"
        case .credit:
            return "Crédito"
        case .debit:
            return "Débito"
        }
    }
}
