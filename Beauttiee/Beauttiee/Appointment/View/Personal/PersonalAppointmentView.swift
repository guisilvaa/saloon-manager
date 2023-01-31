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
                        DatePicker(selection: $startDate, displayedComponents: .date) {
                            Text("Selecione o dia")
                        }
                        .onChange(of: startDate) { _ in
                            calculateEndDate()
                        }
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
            .navigationTitle("Compromisso")
            .navigationBarTitleDisplayMode(.inline)
            .background(Color("greyLight"))
        }
        .onAppear {
            if let appointment = appointment {
                name = appointment.serviceName ?? ""
                startDate = appointment.startDate ?? Date.now
                endDate = appointment.endDate ?? Date.now
            }
        }
    }
    
    private func calculateEndDate() {
        self.endDate = calendar.date(byAdding: .hour, value: 1, to: startDate)!
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

            try? self.viewContext.save()
            
            dismiss()
            
            if let onNewPersonalAppoitment = self.onNewPersonalAppoitment {
                onNewPersonalAppoitment()
            }
        }
    }
}

struct PersonalAppointmentView_Previews: PreviewProvider {
    static var previews: some View {
        PersonalAppointmentView(date: Date.now)
    }
}
