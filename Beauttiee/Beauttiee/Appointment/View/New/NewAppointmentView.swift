//
//  NewAppointmentView.swift
//  Beauttiee
//
//  Created by Guilherme Silva on 30/12/22.
//

import SwiftUI
import CurrencyTextField
import CurrencyFormatter

struct NewAppointmentView: View {
    
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) var dismiss
    
    @State var client: String = ""
    @State var price: Double? = 0.0
    @State var priceText: String = "R$ 0,00"
    @State var startDate = Date.now
    @State var endDate = Date.now
    @State private var currencyFormatter = CurrencyFormatter.init {
        $0.currency = .brazilianReal
        $0.locale = CurrencyLocale.portugueseBrazil
    }
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Service.name, ascending: true)],
        animation: .default)
    private var services: FetchedResults<Service>
    @State private var service: Service?
    
    
    private let timeZone = TimeZone(identifier: "America/Sao_Paulo")!
    private var calendar = Calendar.current
    
    var onNewAppoitment: (() -> Void)?
    
    init() {
        calendar.timeZone = self.timeZone
    }
    
    var body: some View {
        NavigationView{
            VStack {
                Form {
                    Section {
                        Picker("Serviço", selection: $service) {
                            Text(" ").tag(nil as Service?)
                            ForEach(services) { s in
                                Text(s.name ?? "")
                                    .tag(s as Service?)
                            }
                        }.onChange(of: service) { newValue in
                            if let service = newValue {
                                price = service.price
                                priceText = currencyFormatter.string(from: service.price) ?? ""
                                calculateEndDate()
                            }
                        }
                    }
                    Section("Valor") {
                        CurrencyTextField(
                            configuration: CurrencyTextFieldConfiguration(placeholder: "Informe o valor",
                                                                          text: $priceText,
                                                                          inputAmount: $price,
                                                                          formatter: $currencyFormatter,
                                                                          textFieldConfiguration: nil))
                    }
                    Section("Cliente") {
                        TextField("Informe o nome", text: $client)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                    Section("Data do atendimento") {
                        DatePicker(selection: $startDate, in: Date.now..., displayedComponents: .date) {
                            Text("Selecione o dia")
                        }
                        DatePicker(selection: $startDate, displayedComponents: .hourAndMinute) {
                            Text("Início")
                        }.onChange(of: startDate) { _ in
                            calculateEndDate()
                        }
                        DatePicker(selection: $endDate, displayedComponents: .hourAndMinute) {
                            Text("Fim")
                        }
                    }
                }
                Button(action: save) {
                    Text("Agendar")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .padding(20)
            }
            .navigationTitle("Novo atendimento")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    private func calculateEndDate() {
        if let service = service,
           let serviceDuration = ServiceDuration(rawValue: Int(service.duration)) {
            self.endDate = calendar.date(byAdding: .minute, value: serviceDuration.rawValue, to: startDate)!
        }
    }
    
    private func save() {
        withAnimation { //TODO tratamento mesmo horario(horario ja ocupado)
            let appointment = Appointment(context: viewContext)
            appointment.id = UUID()
            appointment.startDate = startDate
            appointment.endDate = endDate
            appointment.price = price ?? 0
            appointment.serviceName = service?.name
            appointment.client = client
            try? self.viewContext.save()
            
            dismiss()
            
            if let onNewAppoitment = self.onNewAppoitment {
                onNewAppoitment()
            }
        }
    }
}

struct NewAppointmentView_Previews: PreviewProvider {
    static var previews: some View {
        NewAppointmentView()
    }
}
