//
//  AppointmentDetailView.swift
//  Beauttiee
//
//  Created by Guilherme Silva on 26/12/22.
//

import SwiftUI
import CurrencyTextField
import CurrencyFormatter

struct AppointmentDetailView: View {
    
    @Environment(\.managedObjectContext) private var viewContext
    
    @State var client: String = ""
    @State var price: Double? = 0.0
    @State var priceText: String = ""
    @State var cost: Double? = 0.0
    @State var costText: String = ""
    @State var date = Date.now
    @State private var currencyFormatter = CurrencyFormatter.init {
        $0.currency = .brazilianReal
        $0.locale = CurrencyLocale.portugueseBrazil
    }
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Service.name, ascending: true)],
        animation: .default)
    private var services: FetchedResults<Service>
    @State private var serviceSelectedIndex = 0
    
    var body: some View {
        NavigationView{
            VStack {
                Form {
                    Section {
                        Picker(selection: $serviceSelectedIndex, label: Text("Serviço")) {
                            ForEach(0 ..< services.count) {
                                Text(self.services[$0].name ?? "")
                            }
                        }
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
                        TextField("Cliente", text: $client)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                    Section {
                        DatePicker(selection: $date, in: Date.now..., displayedComponents: .date) {
                            Text("Selecione o dia")
                        }
                        DatePicker(selection: $date, displayedComponents: .hourAndMinute) {
                            Text("Início")
                        }
                        DatePicker(selection: $date, displayedComponents: .hourAndMinute) {
                            Text("Fim")
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
            .navigationTitle("Novo atendimento") //TODO titulo de acordo com tipo(novo ou edicao)
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    private func save() {
        withAnimation {
            
        }
    }
}

struct AppointmentDetailView_Previews: PreviewProvider {
    static var previews: some View {
        AppointmentDetailView()
    }
}
