//
//  NewCustomEventProtocols.swift
//  FinantialTimeline
//
//  Created by Jose Ignacio de Juan Díaz on 04/09/2019.
//

import Foundation

// MARK: - Wireframe
protocol NewCustomEventWireframeProtocol: AnyObject {
    func dismiss()
    func loadTimeLineEventDetail(_ event: TimeLineEvent)
    func loadTimeLine()
    func showAlert(error: Error)
}

// MARK: - Presenter
protocol NewCustomEventPresenterProtocol: AnyObject {
    var frequencyIsOK: Bool { get }
    func viewDidLoad()
    func onBackPressed()    
    func createCustomEventTapped(_ newEvent: NewCustomEventViewControllerOutput)
    func setFrequencyIsOK(_ newCustomEvent: NewCustomEventViewControllerOutput)
    func requerimentsAreOK(_ newCustomEvent: NewCustomEventViewControllerOutput) -> Bool
}

// MARK: - View
protocol NewCustomEventViewProtocol: AnyObject {
    func setTitle(isNew: Bool)
    func showDatePicker(sender: UITextField)
    func setFrequencyError(_ isFrequencyOK: Bool)
    func setUntilTextField()
    func loadEventToEdit(event: PeriodicEvent)
}


// MARK: - Interactor
protocol NewCustomEventInteractorProtocol: AnyObject {
    func createNewCustomEvent(_ customEvent: CreateCustomEvent, completion: @escaping (Result<PersonalEvent, Error>) -> Void)
    func updateCustomEvent(_ customEvent: CreateCustomEvent, completion: @escaping (Result<PersonalEvent, Error>) -> Void)
}

protocol NewCustomEventDelegate: AnyObject {
    func eventUpdated()
}
