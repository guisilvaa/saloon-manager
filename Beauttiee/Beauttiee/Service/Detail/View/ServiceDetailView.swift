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
    
    @State var name: String = ""
    @State var price: Double? = 0.0
    @State var priceText: String = ""
    @State var cost: Double? = 0.0
    @State var costText: String = ""
    @State private var currencyFormatter = CurrencyFormatter.init {
        $0.currency = .brazilianReal
        $0.locale = CurrencyLocale.portugueseBrazil
    }
    @State private var serviceDurationSelectedIndex = 0
    private let serviceDurations = ServiceDuration.allCases
    
    var body: some View {
        NavigationView{
            VStack {
                Form {
                    Section {
                        TextField("Nome", text: $name)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                    Section {
                        CurrencyTextField(
                            configuration: CurrencyTextFieldConfiguration(placeholder: "Preço",
                                                                          text: $priceText,
                                                                          inputAmount: $price,
                                                                          formatter: $currencyFormatter,
                                                                          textFieldConfiguration: nil))
                    }
                    Section {
                        CurrencyTextField(
                            configuration: CurrencyTextFieldConfiguration(placeholder: "Custo",
                                                                          text: $costText,
                                                                          inputAmount: $cost,
                                                                          formatter: $currencyFormatter,
                                                                          textFieldConfiguration: nil))
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
            service.price = self.price ?? 0
            service.cost = self.cost ?? 0
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
