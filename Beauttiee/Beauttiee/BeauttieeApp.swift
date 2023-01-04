//
//  BeauttieeApp.swift
//  Beauttiee
//
//  Created by Guilherme Silva on 22/11/22.
//

import SwiftUI

@main
struct BeauttieeApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            MainTabBarView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .environment(\.colorScheme, .light)
        }
    }
}
