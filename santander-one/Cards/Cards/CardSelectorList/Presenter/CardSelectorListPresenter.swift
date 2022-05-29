//
//  CardSelectorListPresenter.swift
//  Cards
//
//  Created by Ignacio González Miró on 10/6/21.
//

import CoreFoundationLib
import SANLegacyLibrary

protocol CardSelectorListPresenterProtocol {
    var view: CardSelectorListGenericViewProtocol? { get set }
    func viewDidLoad()
    func viewWillAppear()
    func didTapBack()
    func didTapClose()
    func didTapInCard(_ viewModel: CardboardingCardCellViewModel)
}

final class CardSelectorListPresenter {
    weak var view: CardSelectorListGenericViewProtocol?
    let dependenciesResolver: DependenciesResolver
    var configuration: CardBoardingCardsSelectorConfiguration

    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
        self.configuration = dependenciesResolver.resolve(for: CardBoardingCardsSelectorConfiguration.self)
    }
}

private extension CardSelectorListPresenter {
    // MARK: Private properties
    var coordinator: CardSelectorListCoordinatorDelegate {
        return self.dependenciesResolver.resolve(for: CardSelectorListCoordinatorDelegate.self)
    }
    
    var baseUrlProvider: BaseURLProvider {
        return self.dependenciesResolver.resolve(for: BaseURLProvider.self)
    }
    
    var useCaseHandler: UseCaseScheduler {
        return self.dependenciesResolver.resolve()
    }
    
    var getCardSelectorListUseCase: CardSelectorListUseCase {
        return self.dependenciesResolver.resolve(for: CardSelectorListUseCase.self)
    }
    
    var selectorListConfiguration: CardSelectorListConfiguration {
        return self.dependenciesResolver.resolve(for: CardSelectorListConfiguration.self)
    }
    
    // MARK: Methods used in presenter methods
    func loadData() {
        self.view?.showLoadingView()
        let input = CardSelectorListUseCaseInput(baseUrl: self.baseUrlProvider.baseURL ?? "",
                                                 allowedTypes: selectorListConfiguration.allowedTypes)
        Scenario(useCase: getCardSelectorListUseCase, input: input)
            .execute(on: self.useCaseHandler)
            .onSuccess { [weak self] output in
                guard let self = self else { return }
                self.view?.hideLoadingView {
                    let cardSelectorList = output.cardSelectorList.map { cardEntity in
                        CardboardingCardCellViewModel(cardEntity: cardEntity,
                                                      baseUrl: self.baseUrlProvider.baseURL ?? "")
                    }
                    self.view?.loadCardSelectorList(cardSelectorList)
                }
            }
            .onError({ [weak self] _ in
                guard let self = self else { return }
                self.view?.hideLoadingView {
                    self.view?.loadCardSelectorList([])
                }
            })
    }
}

extension CardSelectorListPresenter: CardSelectorListPresenterProtocol {
    func viewDidLoad() {
        self.loadData()
    }
    
    func viewWillAppear() {
        self.view?.setNavigationBar(with: selectorListConfiguration.titleToolbar)
    }
    
    func didTapBack() {
        coordinator.dismiss()
    }
    
    func didTapClose() {
        coordinator.dismiss()
    }
    
    func didTapInCard(_ viewModel: CardboardingCardCellViewModel) {
        coordinator.didTapInCardSelector(viewModel)
    }
}
