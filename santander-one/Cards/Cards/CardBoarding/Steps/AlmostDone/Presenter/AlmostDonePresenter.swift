//
//  AlmostDonePresenter.swift
//  Cards
//
//  Created by Boris Chirino Fernandez on 16/10/2020.
//

import CoreFoundationLib

protocol AlmostDonePresenterProtocol: AnyObject {
    var view: AlmostDoneViewProtocol? { get set }
    func didSelectBack()
    func didSelectNext()
    func viewDidLoad()
    func didSelectTip(_ tip: OfferTipViewModel)
}

final class AlmostDonePresenter {
    weak var view: AlmostDoneViewProtocol?
    private let dependenciesResolver: DependenciesResolver
    private lazy var cardTipsUseCase: GetAlmostDoneCardTipsUseCase = {
        dependenciesResolver.resolve(for: GetAlmostDoneCardTipsUseCase.self)
    }()
    
    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
    }
}

extension AlmostDonePresenter: AlmostDonePresenterProtocol {
    func didSelectTip(_ tip: OfferTipViewModel) {
        guard let offerEntity = tip.offer else { return }
        self.coordinatorDelegate.didSelectOffer(offer: offerEntity)
    }
    
    func viewDidLoad() {
        self.getTips()
    }
    
    func didSelectBack() {
        self.coordinator.didSelectGoBackwards()
    }
    
    func didSelectNext() {
        self.coordinator.didSelectGoFoward()
    }
}

private extension AlmostDonePresenter {
    var coordinator: CardBoardingCoordinatorProtocol {
        return dependenciesResolver.resolve(for: CardBoardingCoordinatorProtocol.self)
    }
    
    var baseUrlProvider: BaseURLProvider {
        return self.dependenciesResolver.resolve(for: BaseURLProvider.self)
    }
    
    var configuration: CardboardingConfiguration {
        return dependenciesResolver.resolve(for: CardboardingConfiguration.self)
    }
    
    var useCaseHandler: UseCaseHandler {
        return self.dependenciesResolver.resolve(for: UseCaseHandler.self)
    }
    
    var coordinatorDelegate: CardBoardingCoordinatorDelegate {
        return self.dependenciesResolver.resolve(for: CardBoardingCoordinatorDelegate.self)
    }
    
    func getTips() {
        let requestValues = GetAlmostDoneCardTipsUseCaseInput(card: configuration.selectedCard)
        _ = self.cardTipsUseCase.setRequestValues(requestValues: requestValues)
        UseCaseWrapper(with: self.cardTipsUseCase, useCaseHandler: self.useCaseHandler, queuePriority: .normal, onSuccess: { result in
            guard let viewModel = result.cardTips?.map({OfferTipViewModel($0, baseUrl: self.baseUrlProvider.baseURL)}) else { return }
            self.view?.setTips(viewModel)
        }, onError: { _ in })
    }
}
