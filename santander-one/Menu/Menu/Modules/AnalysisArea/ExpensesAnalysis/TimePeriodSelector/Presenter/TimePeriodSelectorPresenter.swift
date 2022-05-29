//
//  TimePeriodSelectorPresenter.swift
//  Menu
//
//  Created by Mario Rosales Maillo on 30/6/21.
//

import CoreFoundationLib

protocol TimePeriodSelectorPresenterProtocol: AnyObject, MenuTextWrapperProtocol {
    var view: TimePeriodSelectorViewProtocol? { get set }
    func viewDidLoad()
    func didSelectDismiss()
    func didSaveTimePeriodWith(_ configuration: TimePeriodConfiguration)
    func getLanguage() -> String
}

final class TimePeriodSelectorPresenter {
    
    weak var view: TimePeriodSelectorViewProtocol?
    let dependenciesResolver: DependenciesResolver
    private var coordinator: OldAnalysisAreaCoordinatorProtocol {
        self.dependenciesResolver.resolve(for: OldAnalysisAreaCoordinatorProtocol.self)
    }
    
    private var configuration: TimePeriodConfiguration {
        return self.dependenciesResolver.resolve(for: TimePeriodConfiguration.self)
    }
    
    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
    }
}

extension TimePeriodSelectorPresenter: TimePeriodSelectorPresenterProtocol {
    
    func viewDidLoad() {
        self.view?.setTimeConfiguration(configuration)
    }
    
    func didSaveTimePeriodWith(_ configuration: TimePeriodConfiguration) {
        self.trackSaveEvent(configuration.type)
        self.coordinator.didSaveTimePeriodWith(configuration)
        self.dependenciesResolver.resolve(for: OldAnalysisAreaCoordinator.self).dismiss()
    }

    func didSelectDismiss() {
        self.dependenciesResolver.resolve(for: OldAnalysisAreaCoordinator.self).dismiss()
    }
    
    func getLanguage() -> String {
        return dependenciesResolver.resolve(forOptionalType: StringLoader.self)?.getCurrentLanguage().languageType.rawValue ?? "es"
    }
}

private extension TimePeriodSelectorPresenter {
    func trackSaveEvent(_ type: TimePeriodType) {
        switch type {
        case .monthly:
            self.trackEvent(.saveMonthly)
        case .annual:
            self.trackEvent(.saveYearly)
        case .quarterly:
            self.trackEvent(.saveQuarterly)
        case .custom:
            self.trackEvent(.saveCustomDate)
        }
    }
}

extension TimePeriodSelectorPresenter: AutomaticScreenActionTrackable {
    
    var trackerManager: TrackerManager {
        self.dependenciesResolver.resolve()
    }
    
    var trackerPage: TimePeriodPage {
        return TimePeriodPage()
    }
}
