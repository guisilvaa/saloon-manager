//
//  ServicesView.swift
//  Beauttiee
//
//  Created by Guilherme Silva on 22/11/22.
//

import SwiftUI
import CoreData
import CurrencyFormatter

struct ServicesView: View {
    
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Service.name, ascending: true)],
        animation: .default)
    private var services: FetchedResults<Service>
    
    @State var showView = false
    
    var body: some View {
        NavigationView{
            List {
                ForEach(services, id: \.id) { service in
                    ServiceItemView(service: service)
                }
                .onDelete(perform: delete)
            }
            .background(Color("greyLight"))
            .scrollContentBackground(.hidden)
            .listRowSeparator(.hidden)
            .listRowSeparatorTint(Color("pinkLight"))
            .emptyView(services.isEmpty) {
                Button(action: {
                    self.showView.toggle()
                }, label: {
                    VStack {
                        Image(systemName: "plus.circle")
                            .font(.system(size: 60))
                        Text("Nenhum serviço cadastrado!")
                            .font(.title2)
                        Text("Clique para adicionar")
                            .font(.title2)
                    }
                })
            }
            .navigationTitle("Serviços")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(trailing: Button(action: {
                self.showView.toggle()
            }, label: {
                Label("Adicionar", systemImage: "plus")
            }))
            .sheet(isPresented: $showView) {
                ServiceDetailView()
                    .preferredColorScheme(.light)
                    .environment(\.managedObjectContext, viewContext)
            }
        }
    }
    
    func delete(offsets: IndexSet) {
        withAnimation {
            offsets.map { services[$0] }.forEach(viewContext.delete)
            try? viewContext.save()
        }
    }
}

struct ServiceItemView: View {
    
    @ObservedObject var service: Service
    
    var currencyFormatter = CurrencyFormatter.init {
        $0.currency = .brazilianReal
        $0.locale = CurrencyLocale.portugueseBrazil
    }
    
    var price: String { currencyFormatter.string(from: self.service.price) ?? "" }
    
    var duration: String { ServiceDuration(rawValue: Int(service.duration))?.description ?? "" }
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(service.name ?? "")
                .font(.title2)
                .bold()
            .   foregroundColor(Color("pinkDark"))
            
            Text("\(price) - \(duration)")
                .foregroundColor(Color("greyDark"))
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
