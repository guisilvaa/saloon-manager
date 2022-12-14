//
//  ServicesView.swift
//  Beauttiee
//
//  Created by Guilherme Silva on 22/11/22.
//

import SwiftUI
import CoreData

struct ServicesView: View {
    
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Service.name, ascending: true)],
        animation: .default)
    private var services: FetchedResults<Service>
    
    var body: some View {
        NavigationView{
            List {
                ForEach(services, id: \.id) { service in
                    ServiceItemView(service: service)
                }
            }
            .emptyView(services.isEmpty) {
                NavigationLink(destination: ServiceDetailView().environment(\.managedObjectContext, viewContext)) {
                    VStack {
                        Image(systemName: "plus.circle")
                        Text("Nenhum serviço cadastrado!")
                        Text("Clique para adicionar")
                    }
                }
            }
            .navigationTitle("Serviços")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem {
                    Button(action: navigateToAddItem) {
                        Label("Adicionar", systemImage: "plus")
                    }
                }
            }
        }
    }
    
    private func navigateToAddItem() {
        withAnimation {
            
        }
    }
}

struct ServiceItemView: View {
    
    @ObservedObject var service: Service
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(service.name ?? "")
                .font(.title)
                .bold()
            Text("\(service.price)")
        }
        .padding(10)
        .lineLimit(1)
    }
}

struct ServicesView_Previews: PreviewProvider {
    static var previews: some View {
        ServicesView()
    }
}
