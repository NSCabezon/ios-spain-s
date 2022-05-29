//
//  SPSendMoneyNoSepaValidateProtocol.swift
//  Santander
//
//  Created by Angel Abad Perez on 7/2/22.
//

import TransferOperatives
import CoreFoundationLib
import SANSpainLibrary
import CoreDomain
import SANLegacyLibrary

public protocol SPSendMoneyNoSepaValidateProtocol: AnyObject, SendMoneyNoSEPAInputCreatorCapable {
    var dependenciesResolver: DependenciesResolver { get }
    func validateNoSepa(requestValues: SendMoneyOperativeData) throws -> UseCaseResponse<SendMoneyOperativeData, StringErrorOutput>
}

public extension SPSendMoneyNoSepaValidateProtocol {
    func validateNoSepa(requestValues: SendMoneyOperativeData) throws -> UseCaseResponse<SendMoneyOperativeData, StringErrorOutput> {
        guard let noSepaInput = self.getNoSepaTransferInput(requestValues: requestValues)
        else {
            return .error(StringErrorOutput("Input not valid"))
        }
        let manager: SpainTransfersRepository = dependenciesResolver.resolve()
        var validationSwift: ValidationSwiftRepresentable?
        let result = try manager.validateSwift(noSepaTransferInput: noSepaInput)
        switch result {
        case .success(let validationSwiftRepresentable):
            validationSwift = validationSwiftRepresentable
            requestValues.swiftValidationRepresentable = validationSwiftRepresentable
        case .failure(let error):
            return .error(StringErrorOutput(error.localizedDescription))
        }
        let response = try manager.validateNoSEPATransfer(noSepaTransferInput: noSepaInput, validationSwift: validationSwift)
        switch response {
        case .success(let validationNoSepaIntRepresentable):
            requestValues.noSepaTransferValidation = validationNoSepaIntRepresentable
            guard let sca = validationNoSepaIntRepresentable.scaRepresentable else { return .ok(requestValues)}
            requestValues.scaRepresentable = SignatureAndOTP(signature: sca)
            return .ok(requestValues)
        case .failure(let error):
            return .error(StringErrorOutput(error.localizedDescription))
        }
    }
}

public protocol SendMoneyNoSEPAInputCreatorCapable {
    func getNoSepaTransferInput(requestValues: SendMoneyOperativeData) -> SendMoneyNoSEPAInput?
}

extension SendMoneyNoSEPAInputCreatorCapable {
    func getNoSepaTransferInput(requestValues: SendMoneyOperativeData) -> SendMoneyNoSEPAInput? {
        guard let originAccount = requestValues.selectedAccount,
              let amount = requestValues.amount else { return nil }
        let transferType = (requestValues.selectedTransferType?.type as? SpainTransferType)?.serviceString
        return SendMoneyNoSEPAInput(originAccountRepresentable: originAccount,
                                    beneficiary: requestValues.destinationName ?? "",
                                    beneficiaryAccountSwift: requestValues.bicSwift,
                                    beneficiaryAccount: requestValues.destinationAccount ?? "",
                                    beneficiaryAccountAddress: nil,
                                    beneficiaryAccountLocality: nil,
                                    beneficiaryAccountCountry: "",
                                    beneficiaryAccountBankName: requestValues.bankName ?? "",
                                    beneficiaryAccountBankAddress: requestValues.bankAddress,
                                    beneficiaryAccountBankLocation: nil,
                                    beneficiaryAccountBankCountry: nil,
                                    indicatorResidence: false,
                                    dateOperation: DateModel(date: requestValues.issueDate),
                                    transferAmount: amount,
                                    expensiveIndicator: requestValues.expenses?.serviceValue ?? "",
                                    type: transferType,
                                    countryCode: requestValues.country?.code ?? requestValues.countryCode ?? "",
                                    concept: requestValues.description ?? "",
                                    beneficiaryEmail: requestValues.beneficiaryMail ?? "")
    }
}
