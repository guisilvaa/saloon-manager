//
//  MonthFinancialView.swift
//  Beauttiee
//
//  Created by Guilherme Silva on 24/01/23.
//

import SwiftUI
import CoreData
import CurrencyFormatter

struct MonthFinancialView: View {
    
    @Environment(\.managedObjectContext) private var viewContext
    @State private var monthDate = Date.now
    @State private var appointments: [Appointment] = []
    
    private let timeZone = TimeZone(identifier: "America/Sao_Paulo")!
    private var calendar = Calendar.current
    
    private var currencyFormatter = CurrencyFormatter.init {
        $0.currency = .brazilianReal
        $0.locale = CurrencyLocale.portugueseBrazil
    }
    
    @State private var monthTotal: Double = 0
    
    init() {
        calendar.timeZone = self.timeZone
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                if !appointments.isEmpty {
                    let (workDays , invoice, count) = monthResume()
                    MonthResumeView(workDays: workDays, invoice: invoice, appointmentCount: count)
                    Spacer(minLength: 10)
                    
                    let daysRanking = daysRanking()
                    if !daysRanking.isEmpty {
                        DaysRankingView(items: daysRanking)
                        Spacer(minLength: 10)
                    }
                    
                    PaymentTypesView(items: paymentTypesResume())
                }
                
                /*
                VStack {
                    Text("Top 5 Receita por serviço")
                    Text("GRAFICO")
                    Button(action: save) {
                        Text("Ver todos")
                            .frame(maxWidth: .infinity)
                    }
                        .buttonStyle(.borderedProminent)
                        .controlSize(.large)
                        .padding(10)
                }*/
            }
            .navigationTitle("Financeiro")
            .navigationBarTitleDisplayMode(.inline)
            .background(Color("greyLight"))
        }
        .onAppear {
            fetchMonthAppointments()
        }
    }
    
    private func fetchMonthAppointments() {
        let (startOfMonth, endOfMonth) = monthInterval()
        let fetchRequest: NSFetchRequest<Appointment> = Appointment.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \Appointment.startDate, ascending: true)]
        fetchRequest.predicate = NSPredicate(format: "startDate >= %@ AND startDate <= %@", argumentArray: [startOfMonth, endOfMonth])
        let results = try? viewContext.fetch(fetchRequest)
        appointments.removeAll()
        appointments = results ?? []
        monthTotal = appointments.reduce(0) { $0 + $1.price }
    }
    
    private func monthInterval() -> (startMonth: Date, endMonth: Date) {
        let startMonthComponents = calendar.dateComponents([.year, .month],
                                                           from: monthDate)
        let startOfMonth = calendar.date(from: startMonthComponents)!
        var endMonthComponents = DateComponents()
        endMonthComponents.month = 1
        endMonthComponents.second = -1
        let endOfMonth = calendar.date(byAdding: endMonthComponents, to: startOfMonth)!
        
        return (startOfMonth, endOfMonth)
    }
    
    private func monthResume() -> (workDays: String, invoice: String, appointmentCount: String) {
        return ( "\(appointmentsGroupedByDay().count)", monthInvoiceFormatted(), "\(appointments.count)")
    }
    
    private func monthInvoiceFormatted() -> String {
        return currencyFormatter.string(from: monthTotal) ?? ""
    }
    
    private func appointmentsGroupedByDay() -> [Date: [Appointment]] {
        return Dictionary(grouping: appointments) { (appointment) -> Date in

            let dateComponents = calendar.dateComponents([.day, .year, .month], from: (appointment.startDate)!)
            let date = calendar.date(from: dateComponents) ?? Date.now
            return date
        }
    }
    
    private func appointmentsGroupedByPaymentType() -> [PaymentType: [Appointment]] {
        var grouped = Dictionary(grouping: appointments) { (appointment) -> PaymentType in
            let paymentType = PaymentType(rawValue: Int(appointment.paymentType)) ?? .none
            return paymentType
        }.filter { $0.key != .none }
        let paymentTypes = PaymentType.allCases.filter { $0 != .none }
        if grouped.isEmpty || grouped.count < paymentTypes.count {
            paymentTypes.forEach { paymentType in
                if !grouped.contains(where: { $0.key == paymentType }) {
                    grouped.updateValue([], forKey: paymentType)
                }
            }
        }
        
        return grouped
    }
    
    private func paymentTypesResume() -> [PaymentTypeInfo] {
        let paymentTypesGrouped = appointmentsGroupedByPaymentType()
        let resultArray = paymentTypesGrouped.keys.map { (paymentType) -> PaymentTypeInfo in
            let appointments = paymentTypesGrouped[paymentType]!
            let sum = appointments.reduce(0) { $0 + $1.price }
            let sumFormatted = currencyFormatter.string(from: sum) ?? ""
            let percentage = percentageValue(sum)
            
            return PaymentTypeInfo(imageName: paymentType.iconName,
                                   name: paymentType.description,
                                   value: sum, valueFormatted: sumFormatted,
                                   percentage: percentage)
        }.sorted{ $0.value > $1.value }
        
        return resultArray
    }
    
    private func percentageValue(_ value: Double) -> String {
        let percentage = (value * 100) / monthTotal
        return String(format: "%.1f%%", percentage)
    }
    
    private func daysRanking() -> [DayInfo]{
        let daysGrouped = appointmentsGroupedByDay()
        if daysGrouped.count > 3 {
            let resultArray = daysGrouped.keys.map { (date) -> DayInfo in
                let appointments = daysGrouped[date]!
                let count = appointments.count
                let sum = appointments.reduce(0) { $0 + $1.price }
                let sumFormatted = currencyFormatter.string(from: sum) ?? ""
                let workedHours = dayWorkedHours(appointments: appointments)
                let dayFormatter = DateFormatter()
                dayFormatter.dateFormat = "EEE dd"
                let dayFormatted = dayFormatter.string(from: date)
                
                return DayInfo(date: dayFormatted, appointmentsCount: "\(count)", value: sum, valueFormatted: sumFormatted, hoursWorked: workedHours)
            }.sorted{ $0.value > $1.value }
            
            return Array(resultArray.prefix(upTo: 3))
        }
        
        return []
    }
    
    private func dayWorkedHours(appointments: [Appointment]) -> String {
        let minutes = appointments.reduce(0) { $0 + $1.duration }
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.minute, .hour]
        formatter.unitsStyle = .short
        formatter.zeroFormattingBehavior = .dropAll
        
        return formatter.string(from: TimeInterval(minutes)) ?? ""
    }
}

struct MonthResumeView: View {
    var workDays: String
    var invoice: String
    var appointmentCount: String
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10)
                .strokeBorder(Color("pinkDark"), lineWidth: 1)
                .background(.white)
                .padding(.horizontal, 5)
                .shadow(radius: 2)
            HStack {
                Spacer()
                MonthResumeItemView(title: "Faturamento", description: invoice)
                Spacer()
                MonthResumeItemView(title: "Dias trabalhados", description: workDays)
                Spacer()
                MonthResumeItemView(title: "Atendimentos", description: appointmentCount)
                Spacer()
            }
        }
    }
}

struct MonthResumeItemView: View {
    let title: String
    let description: String
    
    var body: some View {
        VStack(spacing: 2) {
            Text(title)
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(Color("pinkDark"))
            Text(description)
                .font(.system(size: 12))
                .foregroundColor(Color("greyDark"))
        }
        .padding(.vertical, 10)
    }
}

struct DayInfo: Hashable {
    var date: String
    var appointmentsCount: String
    var value: Double
    var valueFormatted: String
    var hoursWorked: String
}

struct DaysRankingView: View {
    var items: [DayInfo]
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10)
                .strokeBorder(Color("pinkDark"), lineWidth: 1)
                .background(.white)
                .padding(.horizontal, 5)
                .shadow(radius: 2)
            
            VStack {
                Text("Top 3 dias")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(Color("pinkDark"))
                    .padding(.top, 10)
                    .padding(.bottom, 3)
                
                HStack(alignment: .center, spacing: 5) {
                    Spacer()
                    
                    ForEach(items, id: \.self) { dayInfo in
                        DayInfoView(dayInfo: dayInfo)
                        Spacer()
                    }
                }
                .padding(.bottom, 10)
            }
        }
    }
}

struct DayInfoView: View {
    var dayInfo: DayInfo
    
    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            DayInfoItemView(imageName: "calendar.circle", description: dayInfo.date)
            DayInfoItemView(imageName: "person.circle", description: dayInfo.appointmentsCount)
            DayInfoItemView(imageName: "dollarsign.circle", description: dayInfo.valueFormatted)
            DayInfoItemView(imageName: "clock", description: dayInfo.hoursWorked)
        }
        .foregroundColor(Color("pinkDark"))
        .font(.system(size: 12))
    }
}

struct DayInfoItemView: View {
    var imageName: String
    var description: String
    
    var body: some View {
        HStack {
            Image(systemName: imageName)
                .font(.system(size: 20))
            Text(description)
                .foregroundColor(Color("greyDark"))
                .font(.system(size: 12))
        }
    }
}

struct PaymentTypesView: View {
    var items: [PaymentTypeInfo]
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10)
                .strokeBorder(Color("pinkDark"), lineWidth: 1)
                .background(.white)
                .padding(.horizontal, 5)
                .shadow(radius: 2)
            
            VStack {
                Text("Formas de pagamento")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(Color("pinkDark"))
                    .padding(.top, 10)
                    .padding(.bottom, 10)
                
                HStack (alignment: .center, spacing: 5) {
                    Spacer()
                    
                    ForEach(items, id: \.self) { paymentTypeInfo in
                        PaymentTypeInfoView(info: paymentTypeInfo)
                        Spacer()
                    }
                }
                .padding(.bottom, 10)
            }
        }
    }
}

struct PaymentTypeInfo: Hashable {
    var imageName: String
    var name: String
    var value: Double
    var valueFormatted: String
    var percentage: String
}

struct PaymentTypeInfoView: View {
    var info: PaymentTypeInfo
    
    var body: some View {
        VStack(spacing: 2) {
            Image(systemName: info.imageName)
                .font(.system(size: 20))
                .foregroundColor(Color("pinkDark"))
            Text(info.name)
            Text(info.valueFormatted)
            Text(info.percentage)
                .font(.system(size: 14, weight: .bold))
        }
        .foregroundColor(Color("greyDark"))
        .font(.system(size: 12))
    }
}

struct MonthFinancialView_Previews: PreviewProvider {
    static var previews: some View {
        MonthFinancialView()
    }
}
