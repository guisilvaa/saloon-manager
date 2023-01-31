//
//  AppointmentsDayTimelineViewController.swift
//  Beauttiee
//
//  Created by Guilherme Silva on 21/12/22.
//

import UIKit
import CoreData
import SwiftUI
import CurrencyFormatter
import Floaty

class AppointmentsDayTimelineViewController: DayViewController {
    
    var viewContext: NSManagedObjectContext!
    
    private let timeZone = TimeZone(identifier: "America/Sao_Paulo")!
    private var currentDate = Date.now
    
    private var currencyFormatter = CurrencyFormatter.init {
        $0.currency = .brazilianReal
        $0.locale = CurrencyLocale.portugueseBrazil
    }

    override func loadView() {
        calendar.timeZone = self.timeZone

        dayView = DayView(calendar: calendar)
        dayView.updateStyle(calendarStyle())
        view = dayView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Agenda"
        dayView.autoScrollToFirstEvent = true
        reloadData()
        
        setupFloatyButton()
    }
    
    private func setupFloatyButton() {
        let floaty = Floaty()
        floaty.buttonColor = UIColor(Color("pinkDark"))
        floaty.plusColor = UIColor(.white)
        floaty.overlayColor = UIColor(Color("greyLight")).withAlphaComponent(0.8)
        floaty.openAnimationType = .fade
        floaty.itemImageColor = UIColor(Color("pinkDark"))
        floaty.itemTitleColor = UIColor(Color("greyDark"))
        floaty.hasShadow = false
        floaty.itemShadowColor = UIColor.black.withAlphaComponent(0.2)
        floaty.addItem("Atendimento", icon: UIImage(systemName: "bag.badge.plus")) { [weak self] _ in
            guard let self = self else { return }
            self.navigateToAddAppointment()
        }
        floaty.addItem("Compromisso pessoal", icon: UIImage(systemName: "person.badge.plus")) { [weak self] _ in
            guard let self = self else { return }
            self.navigateToPersonalAppointment()
        }
        self.view.addSubview(floaty)
    }
    
    private func predicateForDayUsingDate(_ date: Date) -> NSPredicate {
        var calendar = Calendar.current
        calendar.timeZone = self.timeZone
        let startOfDay = calendar.startOfDay(for: date)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        let endOfDayLessOneSecond = endOfDay.addingTimeInterval(TimeInterval(-1))
        
        return NSPredicate(format: "startDate >= %@ AND endDate <= %@", argumentArray: [startOfDay, endOfDayLessOneSecond])
    }
    
    private func navigateToAppointmentDetail(_ appointment: Appointment) {
        if let type = AppointmentType(rawValue: Int(appointment.type)) {
            type == .client ? navigateToClientAppointment(appointment) : navigateToPersonalAppointment(appointment)
        }
    }
    
    private func appointmentInfo(_ appointment: Appointment) -> NSAttributedString {
        let hourFormatter = DateFormatter()
        hourFormatter.dateFormat = "HH:mm"
        let startTime = hourFormatter.string(from: appointment.startDate ?? Date.now)
        let endTime = hourFormatter.string(from: appointment.endDate ?? Date.now)
        let appointmentType = AppointmentType(rawValue: Int(appointment.type))
        let title = appointmentType == .client ? "\(appointment.client ?? "") - \(appointment.serviceName ?? "")\n" : "\(appointment.serviceName ?? "")\n"
        let hourInterval = "\(startTime) - \(endTime)"
        let textAttributesOne = [NSAttributedString.Key.foregroundColor: UIColor(Color("greyDark")),
                                 NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 14)]
        let textAttributesTwo = [NSAttributedString.Key.foregroundColor: UIColor(Color("greyDark")),
                                 NSAttributedString.Key.font: UIFont.systemFont(ofSize: 12)]
        let textPartOne = NSMutableAttributedString(string: title, attributes: textAttributesOne)
        let textPartTwo = NSMutableAttributedString(string: hourInterval, attributes: textAttributesTwo)
        let textCombination = NSMutableAttributedString()
        textCombination.append(textPartOne)
        textCombination.append(textPartTwo)
        
        return textCombination
    }
    
    private func calendarStyle() -> CalendarStyle {
        var style = CalendarStyle()
        style.header.daySelector.selectedBackgroundColor = UIColor(Color("pinkLight"))
        style.header.daySelector.activeTextColor = UIColor(Color("greyMedium"))
        style.header.daySelector.todayInactiveTextColor = UIColor(Color("pinkDark"))
        style.header.daySelector.todayActiveTextColor = UIColor(Color("greyLight"))
        style.header.daySelector.todayActiveBackgroundColor = UIColor(Color("pinkDark"))
        style.timeline.allDayStyle.backgroundColor = UIColor(Color("pinkDark"))
        style.timeline.allDayStyle.allDayFont = UIFont.boldSystemFont(ofSize: 14)
        style.timeline.allDayStyle.allDayColor = UIColor(Color("greyLight"))
        
        return style
    }
    
    private func navigateToAddAppointment(hour: Date? = nil) {
        var appointmentView = NewAppointmentView(date: self.currentDate, hour: hour)
        appointmentView.onNewAppoitment = {
            self.reloadData()
        }
        let hostingController = UIHostingController(rootView: appointmentView.environment(\.managedObjectContext, viewContext))
        navigationController?.present(hostingController, animated: true)
    }
    
    private func dayResumeEvent(appointments: [Appointment]) -> Event {
        let count = "Atendimentos: \(appointments.count)"
        let invoice = dayInvoice(appointments: appointments)
        let workedHours = dayWorkedHours(appointments: appointments)
        let event = Event()
        event.isAllDay = true
        event.text = "\(count)\n\(invoice)\n\(workedHours)"
        event.color = UIColor(Color("pinkDark"))
        event.lineBreakMode = .byTruncatingTail
        event.font = UIFont.boldSystemFont(ofSize: 14)
        event.textColor = UIColor(Color("greyLight"))
        
        return event
    }
    
    private func dayInvoice(appointments: [Appointment]) -> String {
        let invoiceValue: Double = appointments.reduce(0) { $0 + $1.price }
        let invoiceValueFormatted = currencyFormatter.string(from: invoiceValue) ?? ""
        return "Faturamento: \(invoiceValueFormatted)"
    }
    
    private func dayWorkedHours(appointments: [Appointment]) -> String {
        let minutes = appointments.reduce(0) { $0 + $1.duration }
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.minute, .hour]
        formatter.unitsStyle = .full
        formatter.zeroFormattingBehavior = .dropAll
        let durationFormatted = formatter.string(from: TimeInterval(minutes)) ?? ""

        return "Tempo: \(durationFormatted)"
    }
    
    private func navigateToClientAppointment(_ appointment: Appointment) {
        var appointmentView = AppointmentDetailView(appointment: appointment)
        appointmentView.onAppointmentChanged = {
            self.reloadData()
        }
        let hostingController = UIHostingController(rootView: appointmentView.environment(\.managedObjectContext, viewContext))
        navigationController?.present(hostingController, animated: true)
    }
    
    private func navigateToPersonalAppointment(_ appointment: Appointment? = nil) {
        var appointmentView = PersonalAppointmentView(date: self.currentDate, appointment: appointment)
        appointmentView.onNewPersonalAppoitment = {
            self.reloadData()
        }
        let hostingController = UIHostingController(rootView: appointmentView.environment(\.managedObjectContext, viewContext))
        navigationController?.present(hostingController, animated: true)
    }
    
    // MARK: EventDataSource
      
    override func eventsForDate(_ date: Date) -> [EventDescriptor] {
        var events: [Event] = []
        let fetchRequest: NSFetchRequest<Appointment> = Appointment.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \Appointment.startDate, ascending: true)]
        fetchRequest.predicate = predicateForDayUsingDate(date)
        let results = try? viewContext.fetch(fetchRequest)
        
        if let results = results {
            
            if !results.isEmpty {
                let clientAppointments = results.filter { $0.type == Int16(AppointmentType.client.rawValue) }
                if !clientAppointments.isEmpty {
                    events.append(dayResumeEvent(appointments: clientAppointments))
                }
                
                results.forEach { appointment in
                    let endDate = appointment.endDate ?? Date()
                    let eventEnd = calendar.date(byAdding: .minute, value: -1, to: endDate)!
                    let appointmentType = AppointmentType(rawValue: Int(appointment.type))
                    let event = Event()
                    event.userInfo = appointment
                    event.attributedText = appointmentType == .client ? appointmentInfo(appointment) : appointmentInfo(appointment)
                    event.dateInterval = DateInterval(start: appointment.startDate ?? Date(), end: eventEnd)
                    event.color = appointmentType == .client ? UIColor(Color("pinkDark")) : UIColor(Color("greyDark"))
                    event.lineBreakMode = .byTruncatingTail
                    events.append(event)
                }
            }
        }
        self.currentDate = date
        return events
    }
      
    // MARK: DayViewDelegate

    private var createdEvent: EventDescriptor?

    override func dayViewDidSelectEventView(_ eventView: EventView) {
        if let descriptor = eventView.descriptor as? Event,
           let appointment = descriptor.userInfo as? Appointment {
            navigateToAppointmentDetail(appointment)
        }
    }

    override func dayViewDidLongPressEventView(_ eventView: EventView) {
        guard let descriptor = eventView.descriptor as? Event else {
          return
        }
        endEventEditing()
        print("Event has been longPressed: \(descriptor) \(String(describing: descriptor.userInfo))")
        beginEditing(event: descriptor, animated: true)
        print(Date())
    }

    override func dayView(dayView: DayView, didTapTimelineAt date: Date) {
        endEventEditing()
        navigateToAddAppointment(hour: date)
    }

    override func dayViewDidBeginDragging(dayView: DayView) {
        endEventEditing()
        print("DayView did begin dragging")
    }

    override func dayView(dayView: DayView, willMoveTo date: Date) {
        print("DayView = \(dayView) will move to: \(date)")
    }

    override func dayView(dayView: DayView, didMoveTo date: Date) {
        print("DayView = \(dayView) did move to: \(date)")
    }

    override func dayView(dayView: DayView, didLongPressTimelineAt date: Date) {
        print("Did long press timeline at date \(date)")
    }

    override func dayView(dayView: DayView, didUpdate event: EventDescriptor) {
        print("did finish editing \(event)")
        print("new startDate: \(event.dateInterval.start) new endDate: \(event.dateInterval.end)")
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
