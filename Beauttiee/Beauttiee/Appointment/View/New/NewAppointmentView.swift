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
    
    init(date: Date, hour: Date?) {
        calendar.timeZone = self.timeZone
        var startDate = date
        var endDate = date
        let hourDate = hour ?? Date.now
        let components = calendar.dateComponents([.hour, .minute, .second], from: hourDate)
        startDate = calendar.date(bySettingHour: components.hour ?? 0,
                                  minute: components.minute ?? 0,
                                  second: 0,
                                  of: startDate) ?? Date.now
        endDate = calendar.date(bySettingHour: components.hour ?? 0,
                                  minute: components.minute ?? 0,
                                  second: 0,
                                  of: endDate) ?? Date.now
        _startDate = State(initialValue: startDate)
        _endDate = State(initialValue: endDate)
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
                    }
                    Section("Data do atendimento") {
                        DatePicker(selection: $startDate, displayedComponents: .date) {
                            Text("Selecione o dia")
                        }
                        .onChange(of: startDate) { _ in
                            calculateEndDate()
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
                .scrollContentBackground(.hidden)
                .foregroundColor(Color("greyDark"))
                
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
            .background(Color("greyLight"))
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
            appointment.type = Int16(AppointmentType.client.rawValue) 
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
        NewAppointmentView(date: Date.now, hour: nil)
    }
}
