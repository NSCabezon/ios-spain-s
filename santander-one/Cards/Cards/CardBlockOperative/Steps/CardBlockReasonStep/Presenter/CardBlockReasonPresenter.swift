//
//  CardBlockReasonPresenter.swift
//  Cards
//
//  Created by Iván Estévez Nieto on 26/5/21.
//

import Foundation
import CoreFoundationLib
import Operative
import CoreDomain

protocol CardBlockReasonPresenterProtocol: OperativeStepPresenterProtocol {
    var view: CardBlockReasonViewProtocol? { get set }
    var showCommentReason: Bool { get }
    func viewDidLoad()
    func didSelectClose()
    func didSelectBack()
    func confirmButtonPressed()
    func newOptionSelected(_ option: CardBlockReasonOption)
    func getCommentReason(_ comment: String)
}

final class CardBlockReasonPresenter {
    weak var view: CardBlockReasonViewProtocol?
    private var optionSelected: CardBlockReasonOption?
    private let dependenciesResolver: DependenciesResolver
    var number: Int = 0
    var isBackButtonEnabled: Bool = true
    var isCancelButtonEnabled: Bool = true
    var container: OperativeContainerProtocol?
    lazy var operativeData: CardBlockOperativeData = {
        guard let container = self.container else { fatalError() }
        return container.get()
    }()
    
    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
    }
}

private extension CardBlockReasonPresenter {
    var baseUrlProvider: BaseURLProvider {
        self.dependenciesResolver.resolve(for: BaseURLProvider.self)
    }
    
    var coordinator: CardBlockFinishingCoordinatorProtocol {
        self.dependenciesResolver.resolve(for: CardBlockFinishingCoordinatorProtocol.self)
    }
    
    func blockCard() {
        guard let optionSelected = self.optionSelected, let cardEntity = self.cardEntity else { return }
        operativeData.blockReason = optionSelected
        let blockType: CardBlockType = self.getCardBlockType(optionSelected)
        self.operativeData.blockType = blockType
        self.container?.handler?.showOperativeLoading { [weak self] in
            guard let self = self else { return }
            let useCase = self.dependenciesResolver.resolve(for: CardBlockUseCaseProtocol.self)
            let requestValues = CardBlockUseCaseInput(card: cardEntity, blockType: blockType, blockText: optionSelected.reason)
            Scenario(useCase: useCase, input: requestValues)
                .execute(on: self.dependenciesResolver.resolve())
                .onSuccess { [weak self] result in
                    guard let scaEntity = result.scaEntity else {
                        self?.saveCardBlock(result: result)
                        return
                    }
                    self?.container?.save(scaEntity)
                    self?.container?.rebuildSteps()
                    self?.saveCardBlock(result: result)
                }
                .onError { [weak self] _ in
                    self?.container?.handler?.hideOperativeLoading {
                        self?.container?.showGenericError()
                    }
                }
        }
    }

    func saveCardBlock(result: CardBlockUseCaseOkOutput) {
        self.container?.handler?.hideOperativeLoading {
            self.operativeData.deliveryAddress = result.residentialAddress
            self.container?.save(self.operativeData)
            self.container?.stepFinished(presenter: self)
        }
    }
    
    func getCardBlockType(_ optionSelected: CardBlockReasonOption) -> CardBlockType {
        switch optionSelected.option {
        case .cardDeterioration:
            return .deterioration
        case .lost:
            return .lost
        case .stolen:
            return .stolen
        }
    }
    
    func setupHeader() {
        guard let selectedCard = self.operativeData.selectedCard,
              let baseUrl = self.baseUrlProvider.baseURL else {
            self.view?.setupHeader(CardBlockReasonViewModel(imageUrl: "", title: "", subtitle: ""))
            return
        }
        let imageUrl = baseUrl + selectedCard.cardImageUrl()
        let title = selectedCard.alias ?? ""
        let panDescription = selectedCard.shortContract
        let subtitle = localized(selectedCard.cardType.keyGP, [StringPlaceholder(.value, panDescription)]).text
        self.view?.setupHeader(CardBlockReasonViewModel(imageUrl: imageUrl, title: title, subtitle: subtitle))
    }
}

extension CardBlockReasonPresenter: CardBlockReasonPresenterProtocol {
    var showCommentReason: Bool {
        self.dependenciesResolver.resolve(for: CardBlockModifierProtocol.self).showCommentReason
    }
    
    var cardEntity: CardEntity? {
        self.operativeData.selectedCard
    }
    
    func viewDidLoad() {
        self.setupHeader()
    }
    
    func didSelectClose() {
        self.container?.close()
    }
    
    func didSelectBack() {
        self.container?.dismissOperative()
    }
    
    func confirmButtonPressed() {
        self.blockCard()
    }
    
    func newOptionSelected(_ option: CardBlockReasonOption) {
        self.optionSelected = option
    }
    
    func getCommentReason(_ comment: String) {
        self.operativeData.comment = comment
        self.container?.save(operativeData)
    }
}

extension CardBlockReasonPresenter: AutomaticScreenTrackable {
    var trackerPage: CardBlockReasonPage {
        return CardBlockReasonPage()
    }
    var trackerManager: TrackerManager {
        return dependenciesResolver.resolve(for: TrackerManager.self)
    }
}
