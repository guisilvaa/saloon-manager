//
//  PersonalAppointmentView.swift
//  Beauttiee
//
//  Created by Guilherme Silva on 31/01/23.
//

import SwiftUI

struct PersonalAppointmentView: View {
    
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) var dismiss
    
    @State var name: String = ""
    @State var startDate = Date.now
    @State var endDate = Date.now
    @State var allDay = false
    @State var showDelete = false
    
    private let timeZone = TimeZone(identifier: "America/Sao_Paulo")!
    private var calendar = Calendar.current
    private var appointment: Appointment?
    
    var onNewPersonalAppoitment: (() -> Void)?
    
    init(date: Date, appointment: Appointment? = nil) {
        calendar.timeZone = self.timeZone
        self.appointment = appointment
    }
    
    var body: some View {
        NavigationView{
            VStack {
                Form {
                    Section("Compromisso") {
                        TextField("Informe o nome", text: $name)
                    }
                    Section("Data do compromisso") {
                        Toggle("Dia inteiro", isOn: $allDay)
                            .tint(Color("pinkDark"))
                            .onChange(of: allDay) { _ in
                                calculateEndDate()
                            }
                        
                        DatePicker(selection: $startDate, displayedComponents: .date) {
                            Text("Selecione o dia")
                        }
                        .onChange(of: startDate) { _ in
                            calculateEndDate()
                        }
                        
                        if !allDay {
                            DatePicker(selection: $startDate, displayedComponents: .hourAndMinute) {
                                Text("Início")
                            }
                            .onChange(of: startDate) { _ in
                                calculateEndDate()
                            }
                            
                            DatePicker(selection: $endDate, displayedComponents: .hourAndMinute) {
                                Text("Fim")
                            }
                        }
                    }
                }
                .scrollContentBackground(.hidden)
                .foregroundColor(Color("greyDark"))
                
                if showDelete {
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
                    .padding(.horizontal, 20)
                    .padding(.bottom, 10)
                }
                
                Button(action: save) {
                    Text("Salvar")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            }
            .navigationTitle("Compromisso")
            .navigationBarTitleDisplayMode(.inline)
            .background(Color("greyLight"))
        }
        .onAppear {
            if let appointment = appointment {
                name = appointment.serviceName ?? ""
                startDate = appointment.startDate ?? Date.now
                endDate = appointment.endDate ?? Date.now
                allDay = appointment.isAllDay
                showDelete = true
            } else {
                calculateEndDate()
                showDelete = false
            }
        }
    }
    
    private func calculateEndDate() {
        if allDay {
            self.startDate = calendar.date(bySettingHour: 1, minute: 0, second: 0, of: self.startDate)!
            self.endDate = calendar.date(byAdding: .hour, value: 22, to: self.startDate)!
        } else {
            self.endDate = calendar.date(byAdding: .hour, value: 1, to: startDate)!
        }
    }
    
    private func save() {
        withAnimation { //TODO tratamento mesmo horario(horario ja ocupado)
            var appointmentData: Appointment?
            
            if let appointment = self.appointment {
                appointmentData = appointment
            } else {
                appointmentData = Appointment(context: viewContext)
                appointmentData?.id = UUID()
                appointmentData?.type = Int16(AppointmentType.personal.rawValue)
            }
            
            appointmentData?.startDate = startDate
            appointmentData?.endDate = endDate
            appointmentData?.serviceName = name
            appointmentData?.isAllDay = allDay

            appointmentChanged()
        }
    }
    
    private func delete() {
        if let appointment {
            viewContext.delete(appointment)
            appointmentChanged()
        }
    }
    
    private func appointmentChanged() {
        try? self.viewContext.save()
        
        dismiss()
        
        if let onNewPersonalAppoitment = self.onNewPersonalAppoitment {
            onNewPersonalAppoitment()
        }
    }
}

struct PersonalAppointmentView_Previews: PreviewProvider {
    static var previews: some View {
        PersonalAppointmentView(date: Date.now)
    }
}
