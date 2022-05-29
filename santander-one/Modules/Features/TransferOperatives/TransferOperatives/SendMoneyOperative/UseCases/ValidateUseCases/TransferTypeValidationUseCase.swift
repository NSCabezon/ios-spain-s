//
//  SubtypeTransferUseCase.swift
//  Transfer
//
//  Created by David Gálvez Alonso on 26/07/2021.
//

import CoreFoundationLib
import CoreDomain

public final class TransferTypeValidationUseCase: UseCase<TransferTypeValidationUseCaseInput,
                                                          TransferTypeValidationUseCaseOkOutput,
                                                          StringErrorOutput>,
                                                  TransferTypeValidationUseCaseProtocol {
    private enum Constants {
        static let errorPL_5304: String = "PL_5304"
        static let errorSI_1016: String = "SI_1016"
        static let errorSI_1018: String = "SI_1018"
        static let appConfigUrgentNationalTransfersError5304Text: String = "urgentNationalTransfers5304Text"
    }
    
    let dependenciesResolver: DependenciesResolver
    var transfersRepository: TransfersRepository {
        self.dependenciesResolver.resolve()
    }
    var appConfigRepository: AppConfigRepositoryProtocol {
        self.dependenciesResolver.resolve(for: AppConfigRepositoryProtocol.self)
    }
    
    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
    }
    
    public override func executeUseCase(requestValues: TransferTypeValidationUseCaseInput) throws -> UseCaseResponse<TransferTypeValidationUseCaseOkOutput, StringErrorOutput> {
        switch requestValues.type {
        case .national:
            return try self.sepaTransfer(national: true, requestValues: requestValues)
        case .sepa:
            return try self.sepaTransfer(national: false, requestValues: requestValues)
        case .noSepa:
            return try self.noSepaTransfer(requestValues: requestValues)
        }
    }
}

private extension TransferTypeValidationUseCase {
    func sepaTransfer(national: Bool, requestValues: TransferTypeValidationUseCaseInput) throws -> UseCaseResponse<TransferTypeValidationUseCaseOkOutput, StringErrorOutput> {
        if let beneficiaryMail = requestValues.beneficiaryMail,
           !beneficiaryMail.isEmpty,
           !beneficiaryMail.isValidEmail() {
            return .error(ValidateTransferUseCaseErrorOutput(.invalidEmail))
        }
        let transferType = self.dependenciesResolver.resolve(forOptionalType: SendMoneyModifierProtocol.self)?
            .transferTypeFor(onePayType: requestValues.type,
                             subtype: requestValues.subType?.serviceString ?? "")
        let genericTransferInput = self.getSendMoneyGenericTransferInput(from: requestValues, transferType: transferType)
        if requestValues.checkEntityAdhered {
            let checkEntityAdheredResponse = try self.checkEntityAdhered(requestValues: requestValues, genericTransferInput: genericTransferInput)
            guard checkEntityAdheredResponse.isOkResult else { return checkEntityAdheredResponse }
        }
        let response = try self.transfersRepository.validateGenericTransfer(originAccount: requestValues.originAccount,
                                                                            nationalTransferInput: genericTransferInput)
        guard !requestValues.isUrgent || !self.checkError5304(response: response) else {
            let textError5304 = self.appConfigRepository.getString(Constants.appConfigUrgentNationalTransfersError5304Text)
            return .error(TransferTypeValidationUseCaseErrorOutput(.urgentNationalTransfers5304(text: textError5304)))
        }
        switch response {
        case .success(let data):
            if let errorCode = data.errorCode {
                return .error(TransferTypeValidationUseCaseErrorOutput(.serviceError(errorDesc: errorCode)))
            }
            return .ok(TransferTypeValidationUseCaseOkOutput(transferNational: data.transferNationalRepresentable))
        case .failure(let error):
            return .error(TransferTypeValidationUseCaseErrorOutput(.serviceError(errorDesc: error.localizedDescription)))
        }
    }
    
    func noSepaTransfer(requestValues: TransferTypeValidationUseCaseInput) throws -> UseCaseResponse<TransferTypeValidationUseCaseOkOutput, StringErrorOutput> {
        return .error(ValidateTransferUseCaseErrorOutput(.serviceError(errorDesc: nil)))
    }
    
    func getSendMoneyGenericTransferInput(from requestValues: TransferTypeValidationUseCaseInput,
                                          transferType: String?) -> SendMoneyGenericTransferInput {
        return SendMoneyGenericTransferInput(
            ibanRepresentable: requestValues.destinationIBAN,
            amountRepresentable: requestValues.amount,
            concept: requestValues.concept,
            beneficiary: requestValues.name,
            saveAsUsual: requestValues.saveFavorites,
            saveAsUsualAlias: requestValues.alias,
            transferType: transferType,
            beneficiaryMail: requestValues.beneficiaryMail
        )
    }
    
    func checkEntityAdhered(requestValues: TransferTypeValidationUseCaseInput,
                            genericTransferInput: SendMoneyGenericTransferInput) throws -> UseCaseResponse<TransferTypeValidationUseCaseOkOutput, StringErrorOutput>  {
        guard requestValues.maxAmount == nil || requestValues.amount.value ?? -1 < requestValues.maxAmount?.value ?? 0
        else {
            return .error(TransferTypeValidationUseCaseErrorOutput(.maxAmount))
        }
        let responseAdhered = try self.transfersRepository.checkEntityAdhered(genericTransferInput: genericTransferInput)
        if case .failure(let error) = responseAdhered {
            let descriptionError = error.localizedDescription
            if descriptionError == Constants.errorSI_1016 || descriptionError == Constants.errorSI_1018 {
                return .error(TransferTypeValidationUseCaseErrorOutput(.nonAttachedEntity))
            } else {
                return .error(TransferTypeValidationUseCaseErrorOutput(.serviceError(errorDesc: descriptionError)))
            }
        }
        return .ok()
    }
    
    func checkError5304(response: Result<ValidateAccountTransferRepresentable, Error>) -> Bool {
        guard self.appConfigRepository.getBool(TransferOperativesConstant.appConfigUrgentNationalTransfersEnable5304) ?? false
        else {
            return false
        }
        if case .failure(let error) = response, error.localizedDescription == Constants.errorPL_5304 {
            return true
        }
        if case .success(let data) = response, data.errorCode == Constants.errorPL_5304 {
            return true
        }
        return false
    }
}
