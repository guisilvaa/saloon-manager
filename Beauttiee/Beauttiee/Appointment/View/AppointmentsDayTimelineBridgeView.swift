//
//  AppointmentsDayTimelineBridgeView.swift
//  Beauttiee
//
//  Created by Guilherme Silva on 21/12/22.
//

import Foundation
import SwiftUI

struct AppointmentsDayTimelineBridgeView: UIViewControllerRepresentable {
    func updateUIViewController(_ uiViewController: UIViewController, context: Context){
    }
    
    func makeUIViewController(context: Context) -> UIViewController {
        return AppointmentsDayTimelineViewController()
    }
}
