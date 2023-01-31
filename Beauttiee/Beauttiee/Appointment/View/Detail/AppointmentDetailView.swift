//
//  AppointmentDetailView.swift
//  Beauttiee
//
//  Created by Guilherme Silva on 26/12/22.
//

import SwiftUI
import CurrencyTextField
import CurrencyFormatter
import CoreData

struct AppointmentDetailView: View {
    
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) var dismiss
    
    @ObservedObject var appointment: Appointment
    
    @State var price: Double? = 0.0
    @State var priceText: String = "R$ 0,00"
    @State var startDate = Date.now
    @State var endDate = Date.now
    @State var obs: String = ""
    @State private var currencyFormatter = CurrencyFormatter.init {
        $0.currency = .brazilianReal
        $0.locale = CurrencyLocale.portugueseBrazil
    }
    private let paymentTypes = PaymentType.allCases.filter { $0 != .none }
    @State private var paymentType: PaymentType?
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Service.name, ascending: true)],
        animation: .default)
    private var services: FetchedResults<Service>
    @State private var service: Service?
    
    private let timeZone = TimeZone(identifier: "America/Sao_Paulo")!
    private var calendar = Calendar.current
    
    var onAppointmentChanged: (() -> Void)?
    
    private var client: String { self.appointment.client ?? "" }
    
    init(appointment: Appointment) {
        self.appointment = appointment
        calendar.timeZone = self.timeZone
        _priceText = State(initialValue: currencyFormatter.string(from: self.appointment.price) ?? "")
    }
    
    var body: some View {
        NavigationView{
            VStack {
                Form {
                    Section("Cliente") {
                        Text(client)
                        
                        if service != nil {
                            Picker("Serviço", selection: $service) {
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
                        } else {
                            Text(self.appointment.serviceName ?? "")
                        }
                        
                    }
                    Section("Valor") {
                        CurrencyTextField(
                            configuration: CurrencyTextFieldConfiguration(placeholder: "Informe o valor",
                                                                          text: $priceText,
                                                                          inputAmount: $price,
                                                                          formatter: $currencyFormatter,
                                                                          textFieldConfiguration: nil))
                        Picker("Forma de pagamento", selection: $paymentType) {
                            Text(" ").tag(nil as PaymentType?)
                            ForEach(paymentTypes, id: \.self) { s in
                                Text(s.description)
                                    .tag(s as PaymentType?)
                            }
                        }
                    }
                    Section("Data do atendimento") {
                        DatePicker(selection: $startDate, displayedComponents: .date) {
                            Text("Dia")
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
                    Section("Observação") {
                        TextField("Informe a observação", text: $obs)
                    }
                    Section {
                    } footer: {
                        VStack(spacing: 15) {
                            Button(action: delete) {
                                Text("Apagar")
                                    .foregroundColor(Color("pinkDark"))
                                    .padding()
                                    .frame(maxWidth: .infinity)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 10)
                                            .stroke(Color("pinkDark"), lineWidth: 1)
                                    )
                            }
                            .tint(Color("pinkDark"))
                            .controlSize(.large)
                            
                            Button(action: save) {
                                Text("Salvar")
                                    .frame(maxWidth: .infinity)
                            }
                            .buttonStyle(.borderedProminent)
                            .foregroundColor(.white)
                            .tint(Color("pinkDark"))
                            .controlSize(.large)
                            .padding(.bottom, 20)
                        }
                        .listRowInsets(EdgeInsets())
                    }

                }
                .scrollContentBackground(.hidden)
                .foregroundColor(Color("greyDark"))
            }
            .navigationTitle("Detalhes")
            .navigationBarTitleDisplayMode(.inline)
            .background(Color("greyLight"))
        }
        .onAppear {
            self.service = fetchService()
            self.obs = self.appointment.observation ?? ""
            self.startDate = self.appointment.startDate ?? Date.now
            self.endDate = self.appointment.endDate ?? Date.now
            if self.appointment.paymentType > 0 {
                self.paymentType = PaymentType(rawValue: Int(self.appointment.paymentType))
            }
        }
    }
    
    private func save() {
        withAnimation { //TODO tratamento mesmo horario(horario ja ocupado)
            self.appointment.startDate = startDate
            self.appointment.endDate = endDate
            self.appointment.price = price ?? 0
            self.appointment.observation = obs
            
            if let service {
                self.appointment.serviceName = service.name
            }
            
            if let paymentType {
                self.appointment.paymentType = Int16(paymentType.rawValue)
            }
            
            appointmentChanged()
        }
    }
    
    private func delete() {
        viewContext.delete(appointment)
        appointmentChanged()
    }
    
    private func appointmentChanged() {
        try? self.viewContext.save()
        
        dismiss()
        
        if let onAppointmentChanged = self.onAppointmentChanged {
            onAppointmentChanged()
        }
    }
    
    private func calculateEndDate() {
        if let service = service,
           let serviceDuration = ServiceDuration(rawValue: Int(service.duration)) {
            self.endDate = calendar.date(byAdding: .minute, value: serviceDuration.rawValue, to: startDate)!
        }
    }
    
    private func fetchService() -> Service? {
        let fetchRequest: NSFetchRequest<Service> = Service.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "name = %@", argumentArray: [self.appointment.serviceName ?? ""])
        let results = try? viewContext.fetch(fetchRequest)
        return results?.first
    }
}

struct AppointmentDetailView_Previews: PreviewProvider {
    static var previews: some View {
        AppointmentDetailView(appointment: Appointment())
    }
}
