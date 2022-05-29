//
//  GetCardSettlementMovementsUseCase.swift
//  Cards
//
//  Created by Laura González on 13/10/2020.
//

import CoreFoundationLib
import SANLegacyLibrary

final class GetCardSettlementMovementsUseCase: UseCase<GetCardSettlementMovementsUseCaseInput, GetCardSettlementMovementsUseCaseOkOutput, StringErrorOutput> {
    private let dependenciesResolver: DependenciesResolver
    private let provider: BSANManagersProvider
    
    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
        self.provider = self.dependenciesResolver.resolve(for: BSANManagersProvider.self)
    }
    
    override func executeUseCase(requestValues: GetCardSettlementMovementsUseCaseInput) throws -> UseCaseResponse<GetCardSettlementMovementsUseCaseOkOutput, StringErrorOutput> {
        let globalPosition = dependenciesResolver.resolve(for: GlobalPositionWithUserPrefsRepresentable.self)
        let cardsManager = provider.getBsanCardsManager()
        let cardDetail = self.getDetailCard(requestValues.cardEntity.dto, cardsManager: cardsManager)
        let scaDate = getScaDate(provider) ?? Date()
        let faqsRepository = dependenciesResolver.resolve(for: FaqsRepositoryProtocol.self)
        let faqsEntity = faqsRepository.getFaqsList()?.nextSettlementCreditCard?.map { FaqsEntity($0) }
        let appConfigRepository = self.dependenciesResolver.resolve(for: AppConfigRepositoryProtocol.self)
        let enablePayLater = appConfigRepository.getBool("enablePayLater") ?? false
        let visibleCards = globalPosition.cards.visibles().filter { !$0.isDisabled && $0.isCreditCard && $0.isContractActive }
        let cardsBycontract = visibleCards.filter { requestValues.cardEntity.cardContract == $0.cardContract }
        guard let extractNumber = requestValues.cardSettlementDetailEntity.extractNumber else {
            return UseCaseResponse.ok(GetCardSettlementMovementsUseCaseOkOutput(settlementMovements: [], cardDetail: cardDetail, scaDate: scaDate, userCards: cardsBycontract, ownerPan: "", faqs: faqsEntity, enablePayLater: enablePayLater))
        }
        let response = try cardsManager.getCardSettlementListMovementsByContract(card: requestValues.cardEntity.dto, extractNumber: extractNumber)
        let allCardsOwnersPan = visibleCards.filter { $0.isOwnerSuperSpeed }.map { $0.pan }
        guard response.isSuccess(), let movementsDTO = try response.getResponseData() else {
            return UseCaseResponse.ok(GetCardSettlementMovementsUseCaseOkOutput(settlementMovements: [], cardDetail: cardDetail, scaDate: scaDate, userCards: cardsBycontract, ownerPan: "", faqs: faqsEntity, enablePayLater: enablePayLater))
        }
        var movementsForPan: [CardSettlementMovementWithPANEntity] = []
        var allMovementsPan: [String] = []
        for movement in movementsDTO {
            movementsForPan.append(CardSettlementMovementWithPANEntity(movement))
            allMovementsPan.append(movement.pan?.trim() ?? "")
        }
        let ownerPan = allMovementsPan.filter { allCardsOwnersPan.contains($0) }.first ?? ""
        return UseCaseResponse.ok(GetCardSettlementMovementsUseCaseOkOutput(settlementMovements: movementsForPan, cardDetail: cardDetail, scaDate: scaDate, userCards: cardsBycontract, ownerPan: ownerPan, faqs: faqsEntity, enablePayLater: enablePayLater))
    }
}

private extension GetCardSettlementMovementsUseCase {
    func getDetailCard(_ cardDTO: CardDTO, cardsManager: BSANCardsManager) -> CardDetailEntity? {
        let cardDetailResponse = try? cardsManager.getCardDetail(cardDTO: cardDTO)
        guard
            cardDetailResponse?.isSuccess() ?? false,
            let cardDetailDTO = try? cardDetailResponse?.getResponseData()
            else { return nil }
        let globalPosition: GlobalPositionRepresentable = self.dependenciesResolver.resolve(for: GlobalPositionRepresentable.self)
        let clientName = globalPosition.dto?.clientName ?? ""
        var cardDataDTO: CardDataDTO?
        if
            let pan = cardDTO.formattedPAN,
            let responseCardData = try? cardsManager.getCardData(pan),
            responseCardData.isSuccess(),
            let cardDataResponse = try? responseCardData.getResponseData() {
            cardDataDTO = cardDataResponse
        }
        return CardDetailEntity(cardDetailDTO, cardDataDTO: cardDataDTO, clientName: clientName)
    }
    
    func getScaDate(_ provider: BSANManagersProvider) -> Date? {
        let scaManager: BSANScaManager = provider.getBsanScaManager()
        let response: BSANResponse<CheckScaDTO>? = try? scaManager.checkSca()
        guard response?.isSuccess() ?? false,
            let checkScaDTO: CheckScaDTO = try? response?.getResponseData() else {
                return nil
        }
        return checkScaDTO.systemDate
    }
}

struct GetCardSettlementMovementsUseCaseInput {
    let cardEntity: CardEntity
    let cardSettlementDetailEntity: CardSettlementDetailEntity
}

struct GetCardSettlementMovementsUseCaseOkOutput {
    let settlementMovements: [CardSettlementMovementWithPANEntity]
    let cardDetail: CardDetailEntity?
    let scaDate: Date
    let userCards: [CardEntity]
    let ownerPan: String
    let faqs: [FaqsEntity]?
    let enablePayLater: Bool
}
