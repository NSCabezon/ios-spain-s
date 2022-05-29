//
//  TimeSelectorViewModel.swift
//  Menu
//
//  Created by Jose Javier Montes Romero on 27/1/22.
//

import UI
import Foundation
import OpenCombine
import CoreDomain
import CoreFoundationLib

enum TimeSelectorState: State {
    case idle
    case updateTimeViewSelected(TimeViewOptions)
    case isEnableConfirmDates(Bool)
    case updateSelectedDates((startDate: Date, endDate: Date))
}

final class TimeSelectorViewModel: DataBindable {
    private var anySubscriptions: Set<AnyCancellable> = []
    private let dependencies: TimeSelectorDependenciesResolver
    private let stateSubject = CurrentValueSubject<TimeSelectorState, Never>(.idle)
    var state: AnyPublisher<TimeSelectorState, Never>
    @BindingOptional fileprivate var timeSelectorSelected: TimeSelectorRepresentable?
    @BindingOptional fileprivate var timeSelectorOutsider: TimeSelectorOutsider?
    private var currenTimeSelector: TimeSelectorRepresentable = DefatultTimeSelectorModel()
    
    init(dependencies: TimeSelectorDependenciesResolver) {
        self.dependencies = dependencies
        state = stateSubject.eraseToAnyPublisher()
    }
    
    func viewDidLoad() {
        if let timeSelected = timeSelectorSelected {
            self.currenTimeSelector = DefatultTimeSelectorModel(timeViewSelected: timeSelected.timeViewSelected,
                                                                startDateSelected: timeSelected.startDateSelected,
                                                                endDateSelected: timeSelected.endDateSelected)
        }
        self.stateSubject.send(.updateTimeViewSelected(self.currenTimeSelector.timeViewSelected))
        self.updateDateViews()
    }
    
    var dataBinding: DataBinding {
        return dependencies.resolve()
    }
}

extension TimeSelectorViewModel {
    
    func close() {
        coordinator.close()
    }
    
    func didTapConfirm() {
        timeSelectorOutsider?.send(currenTimeSelector)
        coordinator.dismiss()
    }
    
    func didTapOnTimeView(index: Int) {
        self.currenTimeSelector.timeViewSelected = TimeViewOptions.allCases[index]
        switch currenTimeSelector.timeViewSelected {
        case .mounthly, .quarterly, .yearly:
            currenTimeSelector.clearDates()
            timeSelectorOutsider?.send(currenTimeSelector)
            coordinator.dismiss()
        case .customized:
            self.stateSubject.send(.updateTimeViewSelected(.customized))
            if currenTimeSelector.startDateSelected == nil {
                self.stateSubject.send(.isEnableConfirmDates(false))
            } else {
                self.stateSubject.send(.isEnableConfirmDates(true))
            }
        }
    }
    
    func didStartDateChanged(_ date: Date) {
        self.currenTimeSelector.startDateSelected = date
        self.stateSubject.send(.isEnableConfirmDates(true))
    }
    
    func didEndDateChanged(_ date: Date) {
        self.currenTimeSelector.endDateSelected = date
    }
}

private extension TimeSelectorViewModel {
    var coordinator: TimeSelectorCoordinator {
        return dependencies.resolve()
    }
    
    func updateDateViews() {
        guard let startDate = self.currenTimeSelector.startDateSelected else { return }
        self.stateSubject.send(.updateSelectedDates((startDate: startDate,
                                                     endDate: self.currenTimeSelector.endDateSelected)))
    }
}

// MARK: - Subscriptions

private extension TimeSelectorViewModel {}

// MARK: - Publishers

private extension TimeSelectorViewModel {}
