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
    private let paymentTypes = PaymentType.allCases
    @State private var paymentType: PaymentType?
    
    private let timeZone = TimeZone(identifier: "America/Sao_Paulo")!
    private var calendar = Calendar.current
    
    var onAppointmentChanged: (() -> Void)?
    
    private var client: String { self.appointment.client ?? "" }
    private var service: String { self.appointment.serviceName ?? "" }
    
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
                        Text(service) //TODO colocar duracao
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
            if let paymentType = paymentType {
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
}

struct AppointmentDetailView_Previews: PreviewProvider {
    static var previews: some View {
        AppointmentDetailView(appointment: Appointment())
    }
}
