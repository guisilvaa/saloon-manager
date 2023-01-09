//
//  ServiceDetailView.swift
//  Beauttiee
//
//  Created by Guilherme Silva on 01/12/22.
//

import SwiftUI
import CurrencyTextField
import CurrencyFormatter

struct ServiceDetailView: View {
    
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) var dismiss
    
    @State var name: String = ""
    @State var price: Double? = 0.0
    @State var priceText: String = ""
    @State var cost: Double? = 0.0
    @State var costText: String = ""
    @State private var currencyFormatter = CurrencyFormatter.init {
        $0.currency = .brazilianReal
        $0.locale = CurrencyLocale.portugueseBrazil
    }
    @State private var serviceDuration: ServiceDuration?
    private let serviceDurations = ServiceDuration.allCases
    
    private var service: Service?
    
    init(service: Service? = nil) {
        self.service = service
        
        if let service {
            _name = State(initialValue: service.name ?? "")
            _priceText = State(initialValue: currencyFormatter.string(from: service.price) ?? "")
            if service.duration > 0,
               let serviceDuration = ServiceDuration(rawValue: Int(service.duration)) {
                _serviceDuration = State(initialValue: serviceDuration)
            }
        } else {
            _priceText = State(initialValue: currencyFormatter.string(from: 0) ?? "")
        }
    }
    
    var body: some View {
        NavigationView{
            VStack {
                Form {
                    Section("Nome") {
                        TextField("Informe o nome", text: $name)
                    }
                    Section("Preço") {
                        CurrencyTextField(
                            configuration: CurrencyTextFieldConfiguration(placeholder: "Informe o preço",
                                                                          text: $priceText,
                                                                          inputAmount: $price,
                                                                          formatter: $currencyFormatter,
                                                                          textFieldConfiguration: nil))
                    }
                    Section {
                        Picker("Duração", selection: $serviceDuration) {
                            Text(" ").tag(nil as ServiceDuration?)
                            ForEach(serviceDurations, id: \.self) { duration in
                                Text(duration.description)
                                    .tag(duration as ServiceDuration?)
                            }
                        }
                    }
                }
                .scrollContentBackground(.hidden)
                .foregroundColor(Color("greyDark"))
                
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
            .background(Color("greyLight"))
        }
    }
    
    private func save() {
        withAnimation {
            var serviceData: Service?
            
            if let service = self.service {
                serviceData = service
            } else {
                serviceData = Service(context: viewContext)
                serviceData?.id = UUID()
            }
            
            serviceData?.name = self.name
            serviceData?.price = self.price ?? 0
            serviceData?.cost = self.cost ?? 0
            if let serviceDuration = serviceDuration {
                serviceData?.duration = Int16(serviceDuration.rawValue)
            }
            
            try? self.viewContext.save()
            
            dismiss()
        }
    }
}

struct ServiceDetailView_Previews: PreviewProvider {
    static var previews: some View {
        ServiceDetailView()
    }
}
