//
//  StartUsingCardPresenter.swift
//  Cards
//
//  Created by Cristobal Ramos Laina on 07/10/2020.
//

import Foundation
import CoreFoundationLib
import Operative
import SANLegacyLibrary
import UI

protocol StartUsingCardPresenterProtocol: OperativeStepPresenterProtocol {
    var view: StartUsingCardViewProtocol? { get set }
    func viewDidLoad()
    func didSelectClose()
    func didSelectContinue()
}

extension StartUsingCardPresenterProtocol {
    var shouldShowProgressBar: Bool {
        false
    }
}

final class StartUsingCardPresenter {
    weak var view: StartUsingCardViewProtocol?
    let dependenciesResolver: DependenciesResolver
    var number: Int = 0
    var container: OperativeContainerProtocol?
    var isBackButtonEnabled: Bool = false
    var isCancelButtonEnabled: Bool = false
    var operativeData: CardBoardingActivationOperativeData {
        guard let container = self.container else { fatalError() }
        return container.get()
    }    
    var useCaseHandler: UseCaseHandler {
        self.dependenciesResolver.resolve(for: UseCaseHandler.self)
    }
    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
    }
    
    private var cardTextColorEntity: [CardTextColorEntity] {
        return self.dependenciesResolver.resolve(for: [CardTextColorEntity].self)
    }
    
    private var baseURLProvider: BaseURLProvider {
        return self.dependenciesResolver.resolve(for: BaseURLProvider.self)
    }
}

extension StartUsingCardPresenter: StartUsingCardPresenterProtocol {
    func didSelectContinue() {
        self.trackEvent(.activate, parameters: [:])
        self.container?.save(self.operativeData)
        self.activateCardIfNeeded()
    }

    func viewDidLoad() {
        self.trackScreen()
        let viewModel = PlasticCardViewModel(entity: self.operativeData.selectedCard,
                                             textColorEntity: self.cardTextColorEntity,
                                             baseUrl: baseURLProvider.baseURL ?? "",
                                             dependenciesResolver: dependenciesResolver)
        self.view?.showCard(viewModel: viewModel)
    }

    func didSelectClose() {
        self.trackEvent(.close, parameters: [:])
        self.container?.close()
    }
}

extension StartUsingCardPresenter: AutomaticScreenActionTrackable {
    var trackerManager: TrackerManager {
        return self.dependenciesResolver.resolve(for: TrackerManager.self)
    }
    var trackerPage: StartUsingCardPage {
        return StartUsingCardPage()
    }
}

private extension StartUsingCardPresenter {
    func activateCardIfNeeded() {
        guard operativeData.selectedCard.isInactive else {
            self.container?.stepFinished(presenter: self)
            return
        }
        guard let activateCardUseCase = self.dependenciesResolver.resolve(forOptionalType: ActivateCardUseCaseProtocol.self) else {
            self.container?.stepFinished(presenter: self)
            return
        }
        let input = ActivateCardUseCaseInput(selectedCard: operativeData.selectedCard)
        self.container?.handler?.showOperativeLoading { [weak self] in
            guard let self = self else { return }
            Scenario(useCase: activateCardUseCase, input: input)
                .execute(on: self.dependenciesResolver.resolve())
                .onSuccess { _ in
                    self.container?.handler?.hideOperativeLoading {
                        self.container?.stepFinished(presenter: self)
                    }
                }.onError { _ in
                    self.container?.handler?.hideOperativeLoading {
                        self.container?.showGenericError()
                    }
                }
        }
    }
}
