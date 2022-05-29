//

import Foundation
import CoreFoundationLib
import SANLegacyLibrary
import CoreDomain

class ValidateLocalTransferUseCase: UseCase<ValidateLocalTransferUseCaseInput, ValidateLocalTransferUseCaseOkOutput, StringErrorOutput> {
    
    private let provider: BSANManagersProvider
    private let appConfigRepository: AppConfigRepository
    private let trusteerRepository: TrusteerRepositoryProtocol
    private let dependenciesResolver: DependenciesResolver
    
    init(managersProvider: BSANManagersProvider, appConfigRepository: AppConfigRepository, trusteerRepository: TrusteerRepositoryProtocol, dependenciesResolver: DependenciesResolver) {
        self.provider = managersProvider
        self.appConfigRepository = appConfigRepository
        self.trusteerRepository = trusteerRepository
        self.dependenciesResolver = dependenciesResolver
    }
    
    override func executeUseCase(requestValues: ValidateLocalTransferUseCaseInput) throws -> UseCaseResponse<ValidateLocalTransferUseCaseOkOutput, StringErrorOutput> {
        
        let originAccountDTO = requestValues.originAccount.accountDTO
        let destinationAccountDTO = requestValues.destinationAccount.accountDTO
        let amountDTO = requestValues.amount.amountDTO
        let concept = requestValues.concept
        
        let pgResponse = try provider.getBsanPGManager().getGlobalPosition()
        guard pgResponse.isSuccess(), let pgData = try pgResponse.getResponseData() else {
            return UseCaseResponse.error(StringErrorOutput(try pgResponse.getErrorMessage()))
        }
        
        switch requestValues.transferTime {
        case .now:
             let response = try provider.getBsanTransfersManager().validateAccountTransfer(originAccountDTO: originAccountDTO, destinationAccountDTO: destinationAccountDTO, accountTransferInput: AccountTransferInput(amountDTO: amountDTO, concept: concept))
            if response.isSuccess(),
               let validateAccountTransferDTO = try response.getResponseData(),
               let signature = self.getSignature(validateAccountTransferDTO.scaRepresentable),
               let transferAccount = TransferAccount(from: validateAccountTransferDTO, signature: signature) {
                return UseCaseResponse.ok(ValidateLocalTransferUseCaseOkOutput(transferAccount: transferAccount, scheduledTransfer: nil))
             }
             let errorDescription = try response.getErrorMessage() ?? ""
             return UseCaseResponse.error(StringErrorOutput(errorDescription))
        case .day(let date):
            let strategy = NationalDeferredTransferStrategy(provider: provider, appConfigRepository: appConfigRepository, trusteerRepository: self.trusteerRepository, dependenciesResolver: self.dependenciesResolver)
            let input = ValidateOnePayTransferUseCaseInput(
                originAccount: requestValues.originAccount,
                destinationIBAN: requestValues.destinationAccount.getIban()!,
                name: pgData.clientName,
                alias: "",
                isSpanishResident: true,
                saveFavorites: false,
                beneficiaryMail: "",
                amount: requestValues.amount,
                concept: requestValues.concept,
                type: .national,
                subType: .standard,
                time: requestValues.transferTime,
                scheduledTransfer: nil,
                tokenPush: nil
            )
            
            let response = try  strategy.validateTransfer(requestValues: input)
            
            guard response.isOkResult else {
                let errorDescription = try response.getErrorResult()
                return UseCaseResponse.error(StringErrorOutput(errorDescription.getErrorDesc()))
            }
            
            let responseData = try response.getOkResult()
            
            guard let scheduledTransfer = responseData.scheduledTransfer,
                  let signature = self.getSignature(scheduledTransfer.scaRepresentable),
                  let transferAccount = TransferAccount(from: scheduledTransfer, issueDate: date, transferAmount: input.amount, signature: signature) else {
                return  UseCaseResponse.error(StringErrorOutput(nil))
            }
            
            return UseCaseResponse.ok(ValidateLocalTransferUseCaseOkOutput(transferAccount: transferAccount, scheduledTransfer: scheduledTransfer))
        case .periodic(startDate: let startDate, endDate: _, periodicity: _, workingDayIssue: _):
            let strategy = NationalPeriodicTransferStrategy(provider: provider, appConfigRepository: appConfigRepository, trusteerRepository: trusteerRepository, dependenciesResolver: self.dependenciesResolver)
            let input = ValidateOnePayTransferUseCaseInput(
                originAccount: requestValues.originAccount,
                destinationIBAN: requestValues.destinationAccount.getIban()!,
                name: pgData.clientName,
                alias: "",
                isSpanishResident: true,
                saveFavorites: false,
                beneficiaryMail: "",
                amount: requestValues.amount,
                concept: requestValues.concept,
                type: .national,
                subType: .standard,
                time: requestValues.transferTime,
                scheduledTransfer: requestValues.scheduledTransfer,
                tokenPush: nil
            )
            
            let response = try  strategy.validateTransfer(requestValues: input)
            
            guard response.isOkResult else {
                let errorDescription = try response.getErrorResult()
                return UseCaseResponse.error(StringErrorOutput(errorDescription.getErrorDesc()))
            }
            
            let responseData = try response.getOkResult()
            
            guard let scheduledTransfer = responseData.scheduledTransfer,
                  let signature = self.getSignature(scheduledTransfer.scaRepresentable),
                  let transferAccount = TransferAccount(from: scheduledTransfer, issueDate: startDate, transferAmount: input.amount, signature: signature)  else {
                return  UseCaseResponse.error(StringErrorOutput(nil))
            }
            return UseCaseResponse.ok(ValidateLocalTransferUseCaseOkOutput(transferAccount: transferAccount, scheduledTransfer: scheduledTransfer))
        }
    }
}

private extension ValidateLocalTransferUseCase {
    func getSignature(_ scaRepresentable: SCARepresentable?) -> Signature? {
        guard let scaRepresentable = scaRepresentable else { return nil }
        return LegacySCAEntity(scaRepresentable).sca as? Signature
    }
}

struct ValidateLocalTransferUseCaseInput {
    let originAccount: Account
    let destinationAccount: Account
    let amount: Amount
    let concept: String
    let transferTime: OnePayTransferTime
    let scheduledTransfer: ScheduledTransfer?
}

struct TransferAccount: OperativeParameter {
    
    let issueDate: Date
    let transferAmount: Amount
    let bankChargeAmount: Amount
    let expensesAmount: Amount
    let netAmount: Amount
    let signature: Signature
    
    init?(from transferAccountDTO: TransferAccountDTO, signature: Signature) {
        guard
            let issueDate = transferAccountDTO.issueDate,
            let transferAmountDTO = transferAccountDTO.transferAmount,
            let bankChargeAmountDTO = transferAccountDTO.bankChargeAmount,
            let expensesAmountDTO = transferAccountDTO.expensesAmount,
            let netAmountDTO = transferAccountDTO.netAmount
        else {
            return nil
        }
        self.issueDate = issueDate
        self.transferAmount = Amount.createFromDTO(transferAmountDTO)
        self.bankChargeAmount = Amount.createFromDTO(bankChargeAmountDTO)
        self.expensesAmount = Amount.createFromDTO(expensesAmountDTO)
        self.netAmount = Amount.createFromDTO(netAmountDTO)
        self.signature = signature
    }
    
    init?(from scheduledTransfer: ScheduledTransfer, issueDate: Date, transferAmount: Amount, signature: Signature ) {
        let netAmount = Amount.createWith(value: 0)
        let expensesAmount = Amount.createWith(value: 0)
        
        guard let bankChargeAmount = scheduledTransfer.bankChargeAmount else {
            return nil
        }
        self.issueDate = issueDate
        self.transferAmount = transferAmount
        self.bankChargeAmount = bankChargeAmount
        self.expensesAmount = expensesAmount
        self.netAmount = netAmount
        self.signature = signature
    }
}

struct ValidateLocalTransferUseCaseOkOutput {
    let transferAccount: TransferAccount
    let scheduledTransfer: ScheduledTransfer?
}
