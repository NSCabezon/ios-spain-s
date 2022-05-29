//
//  LoanSimulatorPresenter.swift
//  GlobalPosition
//
//  Created by César González Palomino on 29/01/2020.
//

import CoreFoundationLib

public protocol LoanSimulatorOfferDelegate: AnyObject {
    func didSelect(offer: OfferEntity, in location: PullOfferLocation)
}

protocol LoanSimulatorPresenterProtocol: AnyObject {
    var view: LoanSimulatorViewProtocol? { get }
    func didSelectMonths(months: String, amount: String, fromSlider: Bool)
    func didSelectAmount(months: String, amount: String, fromSlider: Bool)
    func didSelectMoreInfo()
    func sliderDidStart()
    func sliderDidFinish()
}

final class LoanSimulatorPresenter {
    weak var view: LoanSimulatorViewProtocol? {
        didSet {
            view?.updateDataWith(simulatorViewModel)
            makeSimulationWith(months: Int(simulatorViewModel.monthsCurrent),
                               amount: Int(simulatorViewModel.amountCurrent))
        }
    }
    private let dependenciesResolver: DependenciesResolver
    private var simulatorViewModel: LoanSimulatorViewModel
    
    init(dependenciesResolver: DependenciesResolver, simulatorViewModel: LoanSimulatorViewModel) {
        self.dependenciesResolver = dependenciesResolver
        self.simulatorViewModel = simulatorViewModel
    }
    
    private var loanSimulationUseCase: LoanSimulationUseCase {
        return dependenciesResolver.resolve(for: LoanSimulationUseCase.self)
    }
    
    private func makeSimulationWith(months: Int, amount: Int) {
        view?.state = .loading
        UseCaseWrapper(
            with: loanSimulationUseCase.setRequestValues(requestValues: LoanSimulationUseCaseInput(months: months, amount: amount)),
            useCaseHandler: dependenciesResolver.resolve(for: UseCaseHandler.self),
            onSuccess: { [weak self] response in
                let entity = response.entity
                guard let strongSelf = self else { return }
                strongSelf.simulatorViewModel.simulationDoneWith(entity: entity,
                                                                 months: months,
                                                                 amount: amount)
                strongSelf.view?.updateDataWith(strongSelf.simulatorViewModel)
                strongSelf.view?.state = .data
            },
            onError: { [weak self] error in
                self?.view?.state = .error
                let errorMessage = self?.errorMessageFromErrorDescription(error.getErrorDesc()) ?? "generic_error_txt"
                self?.view?.showErrorWith(text: localized(localized(errorMessage)),
                                               animated: true,
                                               showingTime: 3.0)
            }
        )
    }
    
    private func errorMessageFromErrorDescription(_ desc: String?) -> String {
        switch desc {
        case "NetworkException":
            return "generic_error_needInternetConnection"
        default:
            return "generic_error_txt"
        }
    }
}

extension LoanSimulatorPresenter: LoanSimulatorPresenterProtocol {
    
    func sliderDidStart() {
        HapticTrigger.alert()
    }
    
    func sliderDidFinish() {
        HapticTrigger.alert()
    }
    
    func didSelectAmount(months: String, amount: String, fromSlider: Bool) {
        guard let months = Int(months), let amount = Int(amount) else { return }
        
        trackEventForAmount(amount: amount, fromSlider: fromSlider)
        
        makeSimulationWith(months: months, amount: amount)
    }
    
    func didSelectMonths(months: String, amount: String, fromSlider: Bool) {
        guard let months = Int(months), let amount = Int(amount) else { return }
        
        trackEventForMonths(months: months, fromSlider: fromSlider)
        
        makeSimulationWith(months: months, amount: amount)
    }
    
    func didSelectMoreInfo() {
        let offerEntity = simulatorViewModel.offerEntity
        let offerLocation  = simulatorViewModel.offerLocation
        trackEvent(.moreInfo, parameters: [:])
        let delegate = dependenciesResolver.resolve(for: LoanSimulatorOfferDelegate.self)
        delegate.didSelect(offer: offerEntity, in: offerLocation)
    }
}

extension LoanSimulatorPresenter: AutomaticScreenActionTrackable {
    
    var trackerManager: TrackerManager {
        return dependenciesResolver.resolve(for: TrackerManager.self)
    }
    
    var trackerPage: GlobalPositionLoanSimulatorPage {
        return GlobalPositionLoanSimulatorPage()
    }
    
    private func trackEventForAmount(amount: Int, fromSlider: Bool) {
        trackEvent(fromSlider ? .changeAmountSlider : .enterMaxValue, parameters: [.amount: "\(amount)"])
    }
    
    private func trackEventForMonths(months: Int, fromSlider: Bool) {
        trackEvent(fromSlider ? .changeMonthSlider : .enterMonths, parameters: [.months: "\(months)"])
    }
}
