//
//  ConfirmCardBlockUseCase.swift
//  Cards
//
//  Created by Laura González on 08/06/2021.
//

import Foundation
import CoreFoundationLib
import SANLegacyLibrary
import CoreDomain

protocol ConfirmCardBlockUseCaseProtocol: UseCase<ConfirmCardBlockUseCaseInput, ConfirmCardBlockUseCaseOkOutput, GenericErrorSignatureErrorOutput> { }

final class ConfirmCardBlockUseCase: UseCase<ConfirmCardBlockUseCaseInput, ConfirmCardBlockUseCaseOkOutput, GenericErrorSignatureErrorOutput> {
    
    private let dependenciesResolver: DependenciesResolver
    private let provider: BSANManagersProvider
    
    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
        self.provider = dependenciesResolver.resolve()
    }
    
    override func executeUseCase(requestValues: ConfirmCardBlockUseCaseInput) throws -> UseCaseResponse<ConfirmCardBlockUseCaseOkOutput, GenericErrorSignatureErrorOutput> {
        guard let signature = requestValues.signature as? SignatureDTO else {
            return .error(GenericErrorSignatureErrorOutput(nil, .otherError, nil))
        }
        let response = try provider.getBsanCardsManager().confirmBlockCard(cardDTO: requestValues.card.dto,
                                                                           signatureDTO: signature,
                                                                           blockText: requestValues.blockText,
                                                                           cardBlockType: requestValues.blockCardStatus)
        if response.isSuccess(), let blockCardConfirmDTO = try response.getResponseData() {
            let output = ConfirmCardBlockUseCaseOkOutput(deliveryAddress: blockCardConfirmDTO.deliveryAddress,
                                                         blockTime: blockCardConfirmDTO.blockTime)
            return .ok(output)
        }
        let signatureType = try processSignatureResult(response)
        let errorDescription = try response.getErrorMessage() ?? ""
        let errorCode = try response.getErrorCode()
        return .error(GenericErrorSignatureErrorOutput(errorDescription, signatureType, errorCode))
    }
}

extension ConfirmCardBlockUseCase: ConfirmCardBlockUseCaseProtocol {}

struct ConfirmCardBlockUseCaseInput {
    let card: CardEntity
    let blockCardStatus: CardBlockType
    let blockText: String
    let signature: SignatureRepresentable
}

struct ConfirmCardBlockUseCaseOkOutput {
    let deliveryAddress: String?
    let blockTime: Date?
}
