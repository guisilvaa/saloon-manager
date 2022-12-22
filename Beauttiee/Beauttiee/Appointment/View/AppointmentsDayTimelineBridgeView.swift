//
//  AppointmentsDayTimelineBridgeView.swift
//  Beauttiee
//
//  Created by Guilherme Silva on 21/12/22.
//

import Foundation
import SwiftUI

struct AppointmentsDayTimelineBridgeView: UIViewControllerRepresentable {
    @Environment(\.managedObjectContext) private var viewContext
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context){
    }
    
    func makeUIViewController(context: Context) -> UIViewController {
        let viewController = AppointmentsDayTimelineViewController()
        viewController.viewContext = self.viewContext
        return UINavigationController(rootViewController: viewController)
    }
}
