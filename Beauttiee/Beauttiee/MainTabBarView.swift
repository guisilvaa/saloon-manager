//
//  MainTabBarView.swift
//  Beauttiee
//
//  Created by Guilherme Silva on 26/12/22.
//

import SwiftUI

struct MainTabBarView: View {
    
    @Environment(\.managedObjectContext) private var viewContext
    
    var body: some View {
        NavigationView {
            TabView {
                AppointmentsDayTimelineBridgeView()
                    .environment(\.managedObjectContext, viewContext)
                    .tabItem {
                        Image(systemName: "phone.fill")
                        Text("Agenda")
                    }
                ServicesView()
                    .environment(\.managedObjectContext, viewContext)
                    .tabItem {
                        Image(systemName: "tv.fill")
                        Text("Serviços")
                    }
            }
        }
    }
}

struct MainTabBarView_Previews: PreviewProvider {
    static var previews: some View {
        MainTabBarView()
    }
}
