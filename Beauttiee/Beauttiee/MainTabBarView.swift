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
                        Image(systemName: "calendar")
                        Text("Agenda")
                    }
                    .ignoresSafeArea(.container, edges: .bottom)
                MonthFinancialView()
                    .environment(\.managedObjectContext, viewContext)
                    .tabItem {
                        Image(systemName: "chart.pie")
                        Text("Financeiro")
                    }
                ServicesView()
                    .environment(\.managedObjectContext, viewContext)
                    .tabItem {
                        Image(systemName: "list.bullet.clipboard")
                        Text("Serviços")
                    }
            }
            .toolbarColorScheme(.light, for: .tabBar)
        }
    }
}

struct MainTabBarView_Previews: PreviewProvider {
    static var previews: some View {
        MainTabBarView()
    }
}
