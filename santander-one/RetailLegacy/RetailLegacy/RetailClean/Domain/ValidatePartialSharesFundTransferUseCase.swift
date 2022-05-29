import SANLegacyLibrary
import CoreFoundationLib
import Foundation

class ValidatePartialSharesFundTransferUseCase: UseCase<ValidatePartialSharesFundTransferUseCaseInput, ValidatePartialSharesFundTransferUseCaseOkOutput, ValidatePartialSharesFundTransferUseCaseErrorOutput> {
    private let provider: BSANManagersProvider
    
    init(managersProvider: BSANManagersProvider) {
        self.provider = managersProvider
    }
    
    override func executeUseCase(requestValues: ValidatePartialSharesFundTransferUseCaseInput) throws -> UseCaseResponse<ValidatePartialSharesFundTransferUseCaseOkOutput, ValidatePartialSharesFundTransferUseCaseErrorOutput> {
        let fundsManager = provider.getBsanFundsManager()
        let originFund = requestValues.originFund.fundDTO
        let destinationFund = requestValues.destinationFund.fundDTO
        let shares = requestValues.shares
        var account: Account?
        
        let response = try fundsManager.validateFundTransferPartialByShares(originFundDTO: originFund, destinationFundDTO: destinationFund, sharesNumber: shares)
        
        guard response.isSuccess(), let fundTransfer = try response.getResponseData(), let fundAccountAssociated = fundTransfer.linkedAccount else {
            let errorDescription = try response.getErrorMessage() ?? ""
            return UseCaseResponse.error(ValidatePartialSharesFundTransferUseCaseErrorOutput(errorDescription))
        }
        
        let accountResponse = try getLinkedAccount(provider: provider, ibanDTO: fundAccountAssociated)
        if accountResponse.isSuccess(), let accountDTO = try accountResponse.getResponseData() {
            account = Account.create(accountDTO)
        }
        
        return UseCaseResponse.ok(ValidatePartialSharesFundTransferUseCaseOkOutput(fundTransfer: fundTransfer, account: account))
    }
}

struct ValidatePartialSharesFundTransferUseCaseInput {
    let originFund: Fund
    let destinationFund: Fund
    let shares: Decimal
    
    init(originFund: Fund, destinationFund: Fund, shares: Decimal) {
        self.originFund = originFund
        self.destinationFund = destinationFund
        self.shares = shares
    }
}

struct ValidatePartialSharesFundTransferUseCaseOkOutput {
    let fundTransfer: FundTransferDTO
    let account: Account?
    
    init(fundTransfer: FundTransferDTO, account: Account?) {
        self.fundTransfer = fundTransfer
        self.account = account
    }
}

extension ValidatePartialSharesFundTransferUseCase: AssociatedAccountRetriever {}
class ValidatePartialSharesFundTransferUseCaseErrorOutput: StringErrorOutput {
    
}
