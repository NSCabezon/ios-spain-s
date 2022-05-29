//
//  SpainConfirmCardOnOffUseCase.swift
//  Santander
//
//  Created by Iván Estévez Nieto on 8/9/21.
//

import Cards
import SANLegacyLibrary
import CoreFoundationLib

final class SpainConfirmOnOffCardUseCase: UseCase<ConfirmCardOnOffUseCaseInput, Void, GenericErrorSignatureErrorOutput> {
    private let provider: BSANManagersProvider

    init(resolver: DependenciesResolver) {
        self.provider = resolver.resolve()
    }

    override func executeUseCase(requestValues: ConfirmCardOnOffUseCaseInput) throws -> UseCaseResponse<Void, GenericErrorSignatureErrorOutput> {
        let cardDTO = requestValues.card.dto
        guard let signature = requestValues.signature as? SignatureDTO else {
            return UseCaseResponse.error(GenericErrorSignatureErrorOutput(nil, .otherError, nil))
        }
        let cardBlockType = requestValues.localState
        let response = try provider.getBsanCardsManager().confirmBlockCard(cardDTO: cardDTO, signatureDTO: signature, blockText: "", cardBlockType: cardBlockType)
        guard response.isSuccess(), try response.getResponseData() != nil else {
            let signatureType = try processSignatureResult(response)
            let errorDescription = try response.getErrorMessage() ?? ""
            let errorCode = try response.getErrorCode()
            return UseCaseResponse.error(GenericErrorSignatureErrorOutput(errorDescription, signatureType, errorCode))
        }
        return .ok()
    }
}

extension SpainConfirmOnOffCardUseCase: ConfirmCardOnOffUseCaseProtocol {}
