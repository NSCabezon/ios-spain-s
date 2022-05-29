//
//  HistoricExtractUseCase.swift
//  Cards
//
//  Created by Ignacio González Miró on 16/11/2020.
//

import CoreFoundationLib
import SANLegacyLibrary

class HistoricExtractUseCase: UseCase<GetHistoricExtractUseCaseInput, GetHistoricExtractUseCaseOkOutput, StringErrorOutput> {
    private let dependenciesResolver: DependenciesResolver
    private let provider: BSANManagersProvider
    
    public init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
        self.provider = self.dependenciesResolver.resolve(for: BSANManagersProvider.self)
    }
    override func executeUseCase(requestValues: GetHistoricExtractUseCaseInput) throws -> UseCaseResponse<GetHistoricExtractUseCaseOkOutput, StringErrorOutput> {
        let differenceBetweenMonths = requestValues.differenceBetweenMonths <= 11 ? requestValues.differenceBetweenMonths : 11
        var scaDate = getScaDate(provider) ?? Date()
        if -differenceBetweenMonths < 0 {
            scaDate = scaDate.addMonth(months: -differenceBetweenMonths)
        }
        let appConfigRepository = self.dependenciesResolver.resolve(for: AppConfigRepositoryProtocol.self)
        let isEnableCardsHomeLocationMap = appConfigRepository.getBool(CardConstants.isEnableCardsHomeLocationMap) ?? false
        let cardDTO = requestValues.card.dto
        // MARK: - Call to Settlement Detail
        let settlementDetailResponse = try self.getSettlementDetail(cardDTO, scaDate: scaDate)
        guard settlementDetailResponse.isSuccess(),
              let cardSettlementDetailDto = try settlementDetailResponse.getResponseData()
        else { return UseCaseResponse.error(StringErrorOutput(nil)) }
        let cardSettlementDetailEntity = CardSettlementDetailEntity(cardSettlementDetailDto)
        // MARK: - Call to Payment Type
        let changePaymentDTO = self.getPaymentType(cardDTO)
        let currentPaymentMethodMode = changePaymentDTO?.currentPaymentMethodDescription
        let currentPaymentMethod = CardPaymentMethodTypeEntity(changePaymentDTO?.currentPaymentMethod)
        // MARK: - Call to Detail Card
        let cardDetail = self.getDetailCard(cardDTO)
        // MARK: - Call to Settlement Movements Card
        guard let extractNumber = cardSettlementDetailEntity.extractNumber else {
            return UseCaseResponse.ok(GetHistoricExtractUseCaseOkOutput(cardSettlementDetailEntity: cardSettlementDetailEntity,
                                                                        scaDate: scaDate,
                                                                        currentPaymentMethod: currentPaymentMethod,
                                                                        currentPaymentMethodMode: currentPaymentMethodMode,
                                                                        settlementMovementsList: [],
                                                                        cardDetailEntity: cardDetail,
                                                                        isEnableCardsHomeLocationMap: isEnableCardsHomeLocationMap))
        }
        let settlementMovementsResponse = try self.getSettlementMovements(cardDTO, extractNumber: extractNumber)
        guard
            settlementMovementsResponse.isSuccess(),
            let movementsDTO = try? settlementMovementsResponse.getResponseData() else {
                return UseCaseResponse.ok(GetHistoricExtractUseCaseOkOutput(cardSettlementDetailEntity: cardSettlementDetailEntity,
                                                                            scaDate: scaDate,
                                                                            currentPaymentMethod: currentPaymentMethod,
                                                                            currentPaymentMethodMode: currentPaymentMethodMode,
                                                                            settlementMovementsList: [],
                                                                            cardDetailEntity: cardDetail,
                                                                            isEnableCardsHomeLocationMap: isEnableCardsHomeLocationMap))
        }
        let settlementMovementsList: [CardSettlementMovementEntity] = movementsDTO.map { CardSettlementMovementEntity($0) }
        return UseCaseResponse.ok(GetHistoricExtractUseCaseOkOutput(cardSettlementDetailEntity: cardSettlementDetailEntity,
                                                                    scaDate: scaDate,
                                                                    currentPaymentMethod: currentPaymentMethod,
                                                                    currentPaymentMethodMode: currentPaymentMethodMode,
                                                                    settlementMovementsList: settlementMovementsList,
                                                                    cardDetailEntity: cardDetail,
                                                                    isEnableCardsHomeLocationMap: isEnableCardsHomeLocationMap))
    }
}

private extension HistoricExtractUseCase {
    func getSettlementDetail(_ cardDTO: CardDTO, scaDate: Date) throws -> BSANResponse<CardSettlementDetailDTO> {
        let cardsManager = self.provider.getBsanCardsManager()
        let response = try cardsManager.getCardSettlementDetail(card: cardDTO, date: scaDate)
        return response
    }
    
    func getPaymentType(_ cardDTO: CardDTO) -> ChangePaymentDTO? {
        let cardsManager = self.provider.getBsanCardsManager()
        let paymentMethodResponse = try? cardsManager.getPaymentChange(cardDTO: cardDTO)
        guard
            paymentMethodResponse?.isSuccess() ?? false,
            let changePaymentDTO = try? paymentMethodResponse?.getResponseData() else {
               return nil
        }
        return changePaymentDTO
    }
    
    func getSettlementMovements(_ cardDTO: CardDTO, extractNumber: Int) throws -> BSANResponse<[CardSettlementMovementDTO]> {
        let cardsManager = self.provider.getBsanCardsManager()
        let response = try cardsManager.getCardSettlementListMovements(card: cardDTO, extractNumber: extractNumber)
        return response
    }
    
    func getDetailCard(_ cardDTO: CardDTO) -> CardDetailEntity? {
        let cardsManager = self.provider.getBsanCardsManager()
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
        let scaManager: BSANScaManager = self.provider.getBsanScaManager()
        let response: BSANResponse<CheckScaDTO>? = try? scaManager.checkSca()
        guard response?.isSuccess() ?? false,
            let checkScaDTO: CheckScaDTO = try? response?.getResponseData() else {
            return nil
        }
        return checkScaDTO.systemDate
    }
}

// MARK: - Input and Output
struct GetHistoricExtractUseCaseInput {
    let card: CardEntity
    let differenceBetweenMonths: Int
}

struct GetHistoricExtractUseCaseOkOutput {
    var cardSettlementDetailEntity: CardSettlementDetailEntity?
    var scaDate: Date?
    var currentPaymentMethod: CardPaymentMethodTypeEntity?
    var currentPaymentMethodMode: String?
    var settlementMovementsList: [CardSettlementMovementEntity]?
    var cardDetailEntity: CardDetailEntity?
    var isEnableCardsHomeLocationMap: Bool
}
