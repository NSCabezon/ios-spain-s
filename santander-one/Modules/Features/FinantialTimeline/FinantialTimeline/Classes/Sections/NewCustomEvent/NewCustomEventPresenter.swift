//
//  NewCustomEventPresenter.swift
//  FinantialTimeline-FinantialTimeline
//
//  Created by Jose Ignacio de Juan Díaz on 04/09/2019.
//

import Foundation

struct NewCustomEventViewControllerOutput {
    var code: String?
    var title: String?
    var description: String?
    var startDate: String?
    var endDate: String?
    var frequency: GlobileDropdownData<Frequency>?
}

class NewCustomEventPresenter {
    
    // MARK: - Dependencies
    weak private var view: NewCustomEventViewProtocol?
    private let router: NewCustomEventWireframeProtocol
    private let interactor: NewCustomEventInteractorProtocol
    
    // MARK: - Properties
    weak var delegate: NewCustomEventDelegate?
    var periodicEventToEdit: PeriodicEvent?
    var frequencyIsOK = false
    
    init(view: NewCustomEventViewProtocol, router: NewCustomEventWireframeProtocol, interactor: NewCustomEventInteractorProtocol, periodicEventToEdit: PeriodicEvent?) {
        self.view = view
        self.router = router
        self.interactor = interactor
        self.periodicEventToEdit = periodicEventToEdit
    }
    
    // MARK: - Helper methods
    func buildNewEvent(_ newEvent: NewCustomEventViewControllerOutput) -> CreateCustomEvent? {
        
        guard let titleChecked = newEvent.title,
            let startDateChecked = newEvent.startDate,
            let frequencyChecked = newEvent.frequency?.value else { return nil }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = DateFormat.ddMMyyyyWithHyphenSeparator.rawValue

        guard let startDateFromString = dateFormatter.date(from: startDateChecked) else { return nil}
        let startDateFormatted = startDateFromString.string(format: .yyyyMMdd) + Utils.getTimeZone()
        
        var endDateFormatted: String?
        if let endDateString = newEvent.endDate, let endDate = dateFormatter.date(from: endDateString) {
            endDateFormatted = endDate.string(format: .yyyyMMdd) + Utils.getTimeZone()
        }
        
        return CreateCustomEvent(id: newEvent.code,
                                 title: titleChecked,
                                 description: newEvent.description,
                                 startDate: startDateFormatted,
                                 endDate: endDateFormatted,
                                 frequency: frequencyChecked)
    }
    
    func callNewCustomEvent(event: CreateCustomEvent) {
        interactor.createNewCustomEvent(event) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let personalEvent):
                self.router.loadTimeLineEventDetail(personalEvent.firstEvent)
            case .failure(let error):
                self.router.showAlert(error: error)
            }
        }
    }
    
    func callUpdateCustomEvent(event: CreateCustomEvent) {
        interactor.updateCustomEvent(event) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success:
                self.router.loadTimeLine()
                self.delegate?.eventUpdated()
            case .failure(let error):
                self.router.showAlert(error: error)
            }
        }
    }
    
}

// MARK: -
extension NewCustomEventPresenter: NewCustomEventPresenterProtocol {
    
    func viewDidLoad() {
        if let event = periodicEventToEdit {
            view?.loadEventToEdit(event: event)
            view?.setTitle(isNew: false)
        } else {
            view?.setTitle(isNew: true)
        }
    }
    
    func onBackPressed() {
        router.dismiss()
    }
    
    func createCustomEventTapped(_ newEvent: NewCustomEventViewControllerOutput) {
        
        guard let event = buildNewEvent(newEvent) else { return }
        
        if periodicEventToEdit != nil {
            callUpdateCustomEvent(event: event)
        } else {
            callNewCustomEvent(event: event)
        }

    }
    
    func checkFrequencyIsSelected(newCustomEvent: NewCustomEventViewControllerOutput) -> Frequency? {
        if let frequency = newCustomEvent.frequency?.value, frequency != .withoutFrequency {
            return frequency
        } else {
            frequencyIsOK = true
            view?.setFrequencyError(frequencyIsOK)
            return nil
        }
    }
    
    func checkBothDatesAreAvailable(_ newCustomEvent: NewCustomEventViewControllerOutput) -> (Date, Date)? {
        if let sinceDate = newCustomEvent.startDate?.getDate(withFormat: .ddMMyyyyWithHyphenSeparator),
            let untilDate = newCustomEvent.endDate?.getDate(withFormat: .ddMMyyyyWithHyphenSeparator) {
            return (sinceDate, untilDate)
        } else {
            frequencyIsOK = true
            view?.setFrequencyError(frequencyIsOK)
            return nil
        }
    }
    
    func checkRangeByFrequency(dates: (Date, Date), frequency: Frequency) {
        switch frequency {
        case .annually:
            frequencyIsOK = isInRange(dates: dates, component: .year, range: 1)
        case .monthly:
            frequencyIsOK = isInRange(dates: dates, component: .month, range: 1)
        case .everyTwoWeeks:
            frequencyIsOK = isInRange(dates: dates, component: .weekday, range: 14)
        case .weekly:
            frequencyIsOK = isInRange(dates: dates, component: .weekday, range: 7)
        default:
            frequencyIsOK = true
        }
        view?.setFrequencyError(frequencyIsOK)
    }
    
    func isInRange(dates: (Date, Date), component: Calendar.Component, range: Int) -> Bool {
        if let endRangeDate = Calendar.current.date(byAdding: component, value: range, to: dates.0) {
            let range = dates.0...endRangeDate
            return !range.contains(dates.1)
        } else {
            return true
        }
    }
    
    func setFrequencyIsOK(_ newCustomEvent: NewCustomEventViewControllerOutput) {
        if let frequencySelected = checkFrequencyIsSelected(newCustomEvent: newCustomEvent),
            let dates = checkBothDatesAreAvailable(newCustomEvent) {
            checkRangeByFrequency(dates: dates, frequency: frequencySelected)
        }
    }
        
    func requerimentsAreOK(_ newCustomEvent: NewCustomEventViewControllerOutput) -> Bool {

        let titleIsNotEmpty = newCustomEvent.title != nil && newCustomEvent.title != ""
        let sinceIsNotEmpty = newCustomEvent.startDate != nil && newCustomEvent.startDate != ""
        let frequencyIsSelected = newCustomEvent.frequency?.value != nil

        var datesAreOK = true
        
        if let selectedFrequency = newCustomEvent.frequency?.value, selectedFrequency != .withoutFrequency {
            datesAreOK = newCustomEvent.endDate != nil && newCustomEvent.endDate != ""
        }
        
        return titleIsNotEmpty && sinceIsNotEmpty && frequencyIsSelected && datesAreOK && frequencyIsOK
    }
    
}

