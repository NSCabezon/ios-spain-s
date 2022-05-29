//
//  PreValidateEditFavouriteUseCase.swift
//  Transfer
//
//  Created by Jose Enrique Montero Prieto on 11/08/2021.
//

import Foundation
import CoreFoundationLib

public protocol PreValidateEditFavouriteUseCaseProtocol: UseCase<PreValidateEditFavouriteUseCaseInput, PreValidateEditFavouriteUseCaseOkOutput, PreValidateEditFavouriteUseCaseErrorOutput> { }

final class PreValidateEditFavouriteUseCase: UseCase<PreValidateEditFavouriteUseCaseInput, PreValidateEditFavouriteUseCaseOkOutput, PreValidateEditFavouriteUseCaseErrorOutput> {
    private let dependenciesResolver: DependenciesResolver
    
    private var bankingUtils: BankingUtilsProtocol {
        return dependenciesResolver.resolve()
    }
    
    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
    }
    
    override func executeUseCase(requestValues: PreValidateEditFavouriteUseCaseInput) throws -> UseCaseResponse<PreValidateEditFavouriteUseCaseOkOutput, PreValidateEditFavouriteUseCaseErrorOutput> {
        guard let alias = requestValues.alias else {
            let error = ErrorDescriptionType.key("onePay_alert_alias")
            return .error(PreValidateEditFavouriteUseCaseErrorOutput(error))
        }
        guard let ibanString = requestValues.iban,
              bankingUtils.isValidIban(ibanString: ibanString)
              else {
            let error = ErrorDescriptionType.key("onePay_alert_valueIban")
            return .error(PreValidateEditFavouriteUseCaseErrorOutput(error))
        }
        let ibanEntity = IBANEntity.create(fromText: ibanString)
        return .ok(PreValidateEditFavouriteUseCaseOkOutput(iban: ibanEntity, alias: alias))
    }
}

public struct PreValidateEditFavouriteUseCaseInput {
    public let iban: String?
    public let alias: String?
}

public struct PreValidateEditFavouriteUseCaseOkOutput {
    let iban: IBANEntity
    let alias: String
    
    public init(iban: IBANEntity, alias: String) {
        self.iban = iban
        self.alias = alias
    }
}

public final class PreValidateEditFavouriteUseCaseErrorOutput: StringErrorOutput {
    let errorInfo: ErrorDescriptionType
    
    public init(_ error: ErrorDescriptionType) {
        self.errorInfo = error
        super.init(nil)
    }
}

extension PreValidateEditFavouriteUseCase: PreValidateEditFavouriteUseCaseProtocol { }
