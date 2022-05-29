import Foundation
import CoreFoundationLib
import SANLegacyLibrary

protocol GetAllCardsSettlementsSuperUseCaseDelegate: AnyObject {
    func didFinishGetCardsSettlementsSuccessfully(with cardSettlementsData: [GetCardsSettlementsOutput])
    func didFinishWithError(error: String?)
}

struct GetCardsSettlementsOutput {
    var cardEntity: CardEntity
    let cardSettlementDetailEntity: CardSettlementDetailEntity
}

final class GetCardsSettlementsSuperUseCaseDelegateHandler: SuperUseCaseDelegate {
    var allCardsSettlements: [GetCardsSettlementsOutput] = []
    var allRequestedCards: [CardEntity] = []
    weak var delegate: GetAllCardsSettlementsSuperUseCaseDelegate?

    func onSuccess() {
        let output = sortCardSettlementsOutput()
        self.delegate?.didFinishGetCardsSettlementsSuccessfully(with: output)
    }

    func onError(error: String?) {
        self.delegate?.didFinishWithError(error: error)
    }
}

private extension GetCardsSettlementsSuperUseCaseDelegateHandler {
    func sortCardSettlementsOutput() -> [GetCardsSettlementsOutput] {
        var sortedResult: [GetCardsSettlementsOutput] = []
        allRequestedCards.forEach { item in
            allCardsSettlements.forEach { output in
                if item.pan == output.cardEntity.pan {
                    sortedResult.append(output)
                }
            }
        }
        return sortedResult
    }
}

class GetAllCardSettlementsSuperUseCase: SuperUseCase<GetCardsSettlementsSuperUseCaseDelegateHandler> {
    private let dependenciesResolver: DependenciesResolver
    private var handlerDelegate: GetCardsSettlementsSuperUseCaseDelegateHandler?
    private var timeManager: TimeManager {
        return dependenciesResolver.resolve(for: TimeManager.self)
    }
    private var cards: [CardEntity] = []

    weak var delegate: GetAllCardsSettlementsSuperUseCaseDelegate? {
        get { return self.handlerDelegate?.delegate }
        set { self.handlerDelegate?.delegate = newValue }
    }

    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
        self.handlerDelegate = GetCardsSettlementsSuperUseCaseDelegateHandler()
        let useCaseHandler = self.dependenciesResolver.resolve(for: UseCaseHandler.self)
        
        super.init(useCaseHandler: useCaseHandler,
                   delegate: self.handlerDelegate)
    }
    
    private var isFirstTime = true

    override func setupUseCases() {
        cards.forEach(self.loadSettlementForCard)
    }
    
    func executeWith(cards: [CardEntity]) {
        handlerDelegate?.allCardsSettlements = []
        self.cards = cards
        super.execute()
    }
}

private extension GetAllCardSettlementsSuperUseCase {
    func loadSettlementForCard(_ card: CardEntity) {
        handlerDelegate?.allRequestedCards.append(card)
        let useCase = self.dependenciesResolver.resolve(for: GetCardSettlementDetailUseCase.self)
        let input = GetCardSettlementDetailUseCaseInput(card: card)
        add(
            useCase.setRequestValues(requestValues: input), isMandatory: false) { result in
                self.handlerDelegate?.allCardsSettlements.append(
                    GetCardsSettlementsOutput(
                        cardEntity: card,
                        cardSettlementDetailEntity: result.cardSettlementDetailEntity)
                )
            }
    }
}
