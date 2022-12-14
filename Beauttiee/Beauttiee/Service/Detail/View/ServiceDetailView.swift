//
//  ServiceDetailView.swift
//  Beauttiee
//
//  Created by Guilherme Silva on 01/12/22.
//

import SwiftUI

struct ServiceDetailView: View {
    
    @Environment(\.managedObjectContext) private var viewContext
    
    @State var name: String = ""
    @State var price: Double = 0.0
    @State private var serviceDurationSelectedIndex = 0
    private let serviceDurations = ServiceDuration.allCases
    
    private let numberFormatter: NumberFormatter
        
        init() {
            numberFormatter = NumberFormatter()
            numberFormatter.numberStyle = .currency
            numberFormatter.currencyCode = "BRL"
            numberFormatter.maximumFractionDigits = 2
        }
    
    var body: some View {
        NavigationView{
            VStack {
                Form {
                    Section {
                        TextField("Nome", text: $name)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                    Section {
                        TextField("Preço", value: $price, formatter: numberFormatter)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .keyboardType(.numberPad)
                    }
                    Section {
                        Picker(selection: $serviceDurationSelectedIndex, label: Text("Duração")) {
                            ForEach(0 ..< serviceDurations.count) {
                                Text(self.serviceDurations[$0].description)
                            }
                        }
                    }
                }
                Button(action: save) {
                    Text("Salvar")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .padding(20)
            }
            .navigationTitle("Serviço")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    private func save() {
        withAnimation {
            let service = Service(context: viewContext)
            service.id = UUID()
            service.name = self.name
            service.price = 100
            service.cost = 10
            service.duration = Int16(self.serviceDurations[self.serviceDurationSelectedIndex].rawValue)
            try? self.viewContext.save()
        }
    }
}

struct ServiceDetailView_Previews: PreviewProvider {
    static var previews: some View {
        ServiceDetailView()
    }
}
