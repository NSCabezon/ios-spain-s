//
//  FinancingPresenter.swift
//  Menu
//
//  Created by Cristobal Ramos Laina on 23/06/2020.
//

import Foundation
import CoreFoundationLib
import UI

enum FinancingLocations: String, CaseIterable {
    case update = "ZF_DEFAULTER_WEB"
}

protocol FinancingPresenterProtocol: AnyObject, MenuTextWrapperProtocol {
    var view: FinancingViewProtocol? { get set }
    func didSelectMenu()
    func didSelectDismiss()
    func didSelectSearch()
    func viewDidLoad()
    func executeOffer()
    func getCurrentSelectedOption() -> Int
    func setCurrentSelectedOption(_ currentSelectedOption: Int)
}

final class FinancingPresenter {
    weak var view: FinancingViewProtocol?
    let dependenciesResolver: DependenciesResolver
    private var currentSelectedOption: Int = 0
    private var defaulterOfferViewModel: OfferEntityViewModel?
    private var list: [String] = ["financing_tab_forFinanciate", "financing_tab_yourFinancing"]
    private var pullOfferCandidates: [PullOfferLocation: OfferEntity]?
    private let locations: [PullOfferLocation] = PullOffersLocationsFactoryEntity().financing
    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
    }
    
    private var coordinatorDelegate: FinancingCoordinatorDelegate {
        self.dependenciesResolver.resolve(for: FinancingCoordinatorDelegate.self)
    }
    
    private var getPullOffersCandidatesUseCase: GetOffersCandidatesUseCase {
        self.dependenciesResolver.resolve()
    }
    
    func loadOffers(completion: @escaping () -> Void) {
        UseCaseWrapper(
            with: getPullOffersCandidatesUseCase.setRequestValues(requestValues: GetOffersCandidatesUseCaseInput(locations: self.locations)),
            useCaseHandler: self.dependenciesResolver.resolve(for: UseCaseHandler.self),
            onSuccess: { [weak self] result in
                self?.pullOfferCandidates = result.pullOfferCandidates
                self?.getLocation()
                completion()
            }
        )
    }
    
    func getLocation() {
        guard self.pullOfferCandidates != nil else {
            return
        }
        FinancingLocations.allCases.forEach {
            guard let offerEntity = self.pullOfferCandidates?.location(key: $0.rawValue)?.offer else { return }
            self.defaulterOfferViewModel = OfferEntityViewModel(entity: offerEntity)
            self.list = ["financing_tab_forFinanciate", "financing_tab_yourFinancing", "financing_tab_paymentsUpdate"]
        }
    }
}

extension FinancingPresenter: FinancingPresenterProtocol {
    func executeOffer() {
        coordinatorDelegate.didSelectOffer(self.defaulterOfferViewModel?.offer)
    }
    
    func viewDidLoad() {
        self.loadOffers {
            self.view?.setSegmentedControlView(list: self.list)
            self.view?.addFinancingView()
        }
    }
    
    func getCurrentSelectedOption() -> Int {
        return self.currentSelectedOption
    }
    
    func setCurrentSelectedOption(_ currentSelectedOption: Int) {
        self.currentSelectedOption = currentSelectedOption
    }
    
    func didSelectMenu() {
        self.coordinatorDelegate.didSelectMenu()
    }
    
    func didSelectDismiss() {
        self.coordinatorDelegate.didSelectDismiss()
    }
    
    func didSelectSearch() {
        self.coordinatorDelegate.didSelectSearch()
    }
}

extension FinancingPresenter: AutomaticScreenTrackable {
    
    var trackerPage: FinancingPage {
        FinancingPage()
    }
    
    var trackerManager: TrackerManager {
        return dependenciesResolver.resolve(for: TrackerManager.self)
    }
}
