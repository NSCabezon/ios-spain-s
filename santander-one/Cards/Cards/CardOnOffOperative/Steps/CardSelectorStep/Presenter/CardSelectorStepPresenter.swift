//
//  CardSelectorPresenter.swift
//  Cards
//
//  Created by Iván Estévez Nieto on 7/9/21.
//

import Foundation
import CoreFoundationLib
import Operative
import CoreDomain

protocol CardSelectorStepPresenterProtocol: OperativeStepPresenterProtocol, MenuTextWrapperProtocol {
    var view: CardSelectorStepViewProtocol? { get set }
    func viewDidLoad()
    func viewWillAppear()
    func didSelectCard(_ viewModel: CardboardingCardCellViewModel)
    func didTapClose()
    func didTapGoBack()
}

final class CardSelectorStepPresenter {
    weak var view: CardSelectorStepViewProtocol?
    let dependenciesResolver: DependenciesResolver
    var number: Int = 0
    var container: OperativeContainerProtocol?
    var isBackButtonEnabled: Bool = false
    var isCancelButtonEnabled: Bool = false
    lazy var operativeData: CardOnOffOperativeData = {
        guard let container = self.container else { fatalError() }
        return container.get()
    }()
    private var sca: SCA? {
        let entity: SCAEntity? = self.container?.getOptional()
        return entity?.sca
    }
    
    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
    }
}

private extension CardSelectorStepPresenter {
    var baseUrlProvider: BaseURLProvider {
        return self.dependenciesResolver.resolve(for: BaseURLProvider.self)
    }
    
    func showErrorDialog(_ error: String) {
        self.view?.showErrorDialog(error)
    }
}

extension CardSelectorStepPresenter: CardSelectorStepPresenterProtocol {
    func viewDidLoad() {
        let cardSelectorList = operativeData.list.map { cardEntity in
            CardboardingCardCellViewModel(cardEntity: cardEntity,
                                          baseUrl: self.baseUrlProvider.baseURL ?? "")
        }
        self.view?.loadCardSelectorList(cardSelectorList)
    }
    
    func viewWillAppear() {
        self.view?.setNavigationBar(with: localized("deeplink_label_selectOriginCard"))
    }
    
    func didSelectCard(_ viewModel: CardboardingCardCellViewModel) {
        self.operativeData.selectedCard = viewModel.entity
        let useCase = self.dependenciesResolver.resolve(for: ValidateCardOnOffUseCaseProtocol.self)
        let input = ValidateCardOnOffUseCaseInput(card: viewModel.entity, blockType: self.operativeData.option)
        self.view?.showLoading {
            Scenario(useCase: useCase, input: input)
                .execute(on: self.dependenciesResolver.resolve())
                .onSuccess { [weak self] result in
                    guard let self = self else { return }
                    self.view?.dismissLoading(completion: {
                        self.container?.save(result.sca)
                        self.container?.save(self.operativeData)
                        self.sca?.prepareForVisitor(self)
                        self.container?.stepFinished(presenter: self)
                    })
                }
                .onError { [weak self] error in
                    self?.view?.dismissLoading(completion: {
                        self?.showErrorDialog(error.getErrorDesc() ?? "")
                    })
                }
        }
    }
    
    func didTapClose() {
        container?.close()
    }
    
    func didTapGoBack() {
        container?.dismissOperative()
    }
}

extension CardSelectorStepPresenter: SCASignatureCapable {
    func prepareForSignature(_ signature: SignatureRepresentable) {
        self.container?.save(signature)
    }
}

extension CardSelectorStepPresenter: SCACapable {}

extension CardSelectorStepPresenter: OperativeStepPresenterProtocol {}
