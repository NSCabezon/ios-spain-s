//
//  GetCardSettlementDetailUseCase.swift
//  Cards
//
//  Created by David Gálvez Alonso on 07/10/2020.
//

import SANLegacyLibrary

public final class GetCardSettlementDetailUseCase: UseCase<GetCardSettlementDetailUseCaseInput, GetCardSettlementDetailUseCaseOkOutput, StringErrorOutput> {
    private let dependenciesResolver: DependenciesResolver
    private let provider: BSANManagersProvider
    
    public init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
        self.provider = self.dependenciesResolver.resolve(for: BSANManagersProvider.self)
    }
    
    public override func executeUseCase(requestValues: GetCardSettlementDetailUseCaseInput) throws -> UseCaseResponse<GetCardSettlementDetailUseCaseOkOutput, StringErrorOutput> {
        let appConfigRepository = self.dependenciesResolver.resolve(for: AppConfigRepositoryProtocol.self)
        guard let isEnableNextSettlementCreditCard = appConfigRepository.getBool("enableNextSettlementCreditCard"), isEnableNextSettlementCreditCard else {
            return UseCaseResponse.error(StringErrorOutput(""))
        }
        let cardsManager = provider.getBsanCardsManager()
        let cardDto = requestValues.card.dto
        let scaDate = getScaDate(provider)
        let response = try cardsManager.getCardSettlementDetail(card: cardDto, date: scaDate ?? Date())
        guard response.isSuccess(),
            let dto = try response.getResponseData() else {
            let errorDescription = try response.getErrorMessage() ?? ""
            return UseCaseResponse.error(StringErrorOutput(errorDescription))
        }
        let settlementDetailEntity = CardSettlementDetailEntity(dto)
        return UseCaseResponse.ok(GetCardSettlementDetailUseCaseOkOutput(cardSettlementDetailEntity: settlementDetailEntity, scaDate: scaDate))
    }
}

public struct GetCardSettlementDetailUseCaseInput {
    public let card: CardEntity
    public init(card: CardEntity) {
        self.card = card
    }
}

public struct GetCardSettlementDetailUseCaseOkOutput {
    public let cardSettlementDetailEntity: CardSettlementDetailEntity
    public let scaDate: Date?
}

private extension GetCardSettlementDetailUseCase {
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
