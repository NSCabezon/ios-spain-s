//
//  ChangeCardAliasPresenter.swift
//  Cards
//
//  Created by Juan Carlos López Robles on 10/5/20.
//

import Foundation
import CoreFoundationLib

protocol ChangeCardAliasPresenterProtocol {
    var view: ChangeCardAliasViewProtocol? { get set }
    var currentAlias: String { get }
    func didSelectBack()
    func didSelectNext()
    func viewDidLoad()
    func changeCardAlias(_ alias: String?)
}

final class ChangeCardAliasPresenter {
    weak var view: ChangeCardAliasViewProtocol?
    private let dependenciesResolver: DependenciesResolver
    private var coordinator: CardBoardingCoordinatorProtocol {
        return dependenciesResolver.resolve(for: CardBoardingCoordinatorProtocol.self)
    }
    
    private var cardTextColorEntity: [CardTextColorEntity] {
        self.dependenciesResolver.resolve(for: [CardTextColorEntity].self)
    }
    
    private var baseURLProvider: BaseURLProvider {
          return dependenciesResolver.resolve(for: BaseURLProvider.self)
    }
    
    private var configuration: CardboardingConfiguration {
        dependenciesResolver.resolve(for: CardboardingConfiguration.self)
    }
    
    private var cardBoardingStepTracker: CardBoardingStepTracker {
        return self.dependenciesResolver.resolve(for: CardBoardingStepTracker.self)
    }
    
    private lazy var changeCardAliasNameUseCase: ChangeCardAliasNameUseCaseProtocol = {
        dependenciesResolver.resolve(for: ChangeCardAliasNameUseCaseProtocol.self)
    }()
    
    private var useCaseHandler: UseCaseHandler {
        dependenciesResolver.resolve(for: UseCaseHandler.self)
    }
    
    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
    }
}

extension ChangeCardAliasPresenter: ChangeCardAliasPresenterProtocol {
    var currentAlias: String {
        var cardAlias = self.cardBoardingStepTracker.stepTracker.currentAlias
        if cardAlias.count > CardBoardingConstants.maxAliasChars {
            cardAlias = cardAlias.substring(0, CardBoardingConstants.maxAliasChars) ?? cardAlias
        }
        return cardAlias
    }
    
    func changeCardAlias(_ alias: String?) {
        guard let optionalAlias = alias else {
            return
        }
        let cleanAlias = optionalAlias.trim()
        guard !cleanAlias.isEmpty, currentAlias != cleanAlias else {
            self.didSelectNext()
            return
        }
        self.view?.showLoading()
        let requestValues = ChangeCardAliasNameInputUseCase(card: configuration.selectedCard, alias: cleanAlias)
        _ = self.changeCardAliasNameUseCase.setRequestValues(requestValues: requestValues)
        UseCaseWrapper(with: self.changeCardAliasNameUseCase, useCaseHandler: self.useCaseHandler, queuePriority: .normal, onSuccess: { [weak self] _ in
            self?.cardBoardingStepTracker.stepTracker.updateAlias(cleanAlias)
            self?.dismissAndNavigateNext()
        }, onError: {  [weak self] error in
            self?.dissmissAndShowError(error)
        })
    }
    
    func viewDidLoad() {
        let selectedCard = configuration.selectedCard
        let viewModel = PlasticCardViewModel(entity: selectedCard,
                                             textColorEntity: self.cardTextColorEntity,
                                             baseUrl: baseURLProvider.baseURL ?? "",
                                             dependenciesResolver: dependenciesResolver)
        self.view?.updateCardInformationWithViewModel(viewModel)
    }
    
    func didSelectBack() {
        coordinator.didSelectGoBackwards()
    }
    
    func didSelectNext() {
        self.coordinator.didSelectGoFoward()
    }
}

private extension ChangeCardAliasPresenter {
    func dismissAndNavigateNext() {
        self.view?.dismissLoading(completion: { [weak self] in
            self?.didSelectNext()
        })
    }
    
    func dissmissAndShowError(_ error: UseCaseError<StringErrorOutput>) {
        self.view?.dismissLoading(completion: {
            let acceptComponents = DialogButtonComponents(titled: localized("generic_button_accept"), does: nil)
            self.view?.showOldDialog(withDependenciesResolver: self.dependenciesResolver, for: error, acceptAction: acceptComponents, cancelAction: nil, isCloseOptionAvailable: false)
        })
    }
}
