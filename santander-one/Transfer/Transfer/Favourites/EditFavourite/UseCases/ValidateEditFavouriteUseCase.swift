//
//  ValidateEditFavouriteUseCase.swift
//  Transfer
//
//  Created by Jose Enrique Montero Prieto on 11/08/2021.
//

import Foundation
import CoreFoundationLib
import SANLegacyLibrary

public protocol ValidateEditFavouriteUseCaseProtocol: UseCase<ValidateEditFavouriteUseCaseInput, ValidateEditFavouriteUseCaseOkOutput, StringErrorOutput> { }

final class ValidateEditFavouriteUseCase: UseCase<ValidateEditFavouriteUseCaseInput, ValidateEditFavouriteUseCaseOkOutput, StringErrorOutput> {
    private let dependenciesResolver: DependenciesResolver
    
    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
    }
    
    override func executeUseCase(requestValues: ValidateEditFavouriteUseCaseInput) throws -> UseCaseResponse<ValidateEditFavouriteUseCaseOkOutput, StringErrorOutput> {
        let provider = self.dependenciesResolver.resolve(firstTypeOf: BSANManagersProvider.self).getBsanTransfersManager()
        let response = try provider.validateUpdateSepaPayee(payeeId: requestValues.payeeId, payee: nil, newCurrencyDTO: nil, newBeneficiaryBAOName: requestValues.beneficiaryName, newIban: requestValues.iban?.dto)
        guard response.isSuccess() else {
            if let resp = try response.getErrorMessage(), resp != "" {
                return .error(StringErrorOutput(resp))
            }
            return .error(StringErrorOutput("generic_error_txt"))
        }
        return .ok(ValidateEditFavouriteUseCaseOkOutput())
    }
}

public struct ValidateEditFavouriteUseCaseInput {
    public let beneficiaryName: String?
    public let iban: IBANEntity?
    public let payeeId: String
    
    public init(
        beneficiaryName: String?,
        iban: IBANEntity?,
        payeeId: String) {
        self.beneficiaryName = beneficiaryName
        self.iban = iban
        self.payeeId = payeeId
    }
}

public struct ValidateEditFavouriteUseCaseOkOutput {
    let signatureWithToken: SignatureWithTokenEntity?
    
    public init(signatureWithToken: SignatureWithTokenEntity? = nil) {
        self.signatureWithToken = signatureWithToken
    }
}

extension ValidateEditFavouriteUseCase: ValidateEditFavouriteUseCaseProtocol { }
