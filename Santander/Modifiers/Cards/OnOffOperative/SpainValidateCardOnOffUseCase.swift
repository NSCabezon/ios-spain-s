//
//  SpainValidateCardOnOffUseCase.swift
//  Santander
//
//  Created by Iván Estévez Nieto on 6/9/21.
//

import Cards
import SANLegacyLibrary
import CoreFoundationLib

final class SpainValidateCardOnOffUseCase: UseCase<ValidateCardOnOffUseCaseInput, ValidateCardOnOffUseCaseOkOutput, StringErrorOutput> {
    private let provider: BSANManagersProvider

    init(resolver: DependenciesResolver) {
        self.provider = resolver.resolve()
    }

    override func executeUseCase(requestValues: ValidateCardOnOffUseCaseInput) throws -> UseCaseResponse<ValidateCardOnOffUseCaseOkOutput, StringErrorOutput> {
        let cardDTO = requestValues.card.dto
        let responseDetail = try provider.getBsanCardsManager().getCardDetailToken(cardDTO: cardDTO, cardTokenType: CardTokenType.panWithSpaces)
        if responseDetail.isSuccess() {
            if let codApli = try responseDetail.getResponseData()?.codAplic, codApli.uppercased().elementsEqual("MP") {
                let response = try provider.getBsanCardsManager().blockCard(cardDTO: cardDTO, blockText: "", cardBlockType: requestValues.blockType)
                guard response.isSuccess(), let blockCardDTO = try response.getResponseData(), let signature = blockCardDTO.signature else {
                    return UseCaseResponse.error(StringErrorOutput(try response.getErrorMessage()))
                }
                return UseCaseResponse.ok(ValidateCardOnOffUseCaseOkOutput(sca: SCAEntity(signature)))
            } else {
                return UseCaseResponse.error(StringErrorOutput("generic_alert_errorCard"))
            }
        }
        return UseCaseResponse.error(StringErrorOutput(try responseDetail.getErrorMessage()))
    }
}

extension SpainValidateCardOnOffUseCase: ValidateCardOnOffUseCaseProtocol {}
