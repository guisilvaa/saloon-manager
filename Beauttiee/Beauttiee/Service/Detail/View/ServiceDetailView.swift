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
    
    init() {
        _priceText = State(initialValue: currencyFormatter.string(from: 0) ?? "")
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
            let service = Service(context: viewContext)
            service.id = UUID()
            service.name = self.name
            service.price = self.price ?? 0
            service.cost = self.cost ?? 0
            if let serviceDuration = serviceDuration {
                service.duration = Int16(serviceDuration.rawValue)
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
