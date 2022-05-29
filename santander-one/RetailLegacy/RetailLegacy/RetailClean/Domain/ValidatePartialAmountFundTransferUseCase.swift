import SANLegacyLibrary
import CoreFoundationLib

class ValidatePartialAmountFundTransferUseCase: UseCase<ValidatePartialAmountFundTransferUseCaseInput, ValidatePartialAmountFundTransferUseCaseOkOutput, ValidatePartialAmountFundTransferUseCaseErrorOutput> {
    private let provider: BSANManagersProvider
    
    init(managersProvider: BSANManagersProvider) {
        self.provider = managersProvider
    }
    
    override func executeUseCase(requestValues: ValidatePartialAmountFundTransferUseCaseInput) throws -> UseCaseResponse<ValidatePartialAmountFundTransferUseCaseOkOutput, ValidatePartialAmountFundTransferUseCaseErrorOutput> {
        let fundsManager = provider.getBsanFundsManager()
        let originFund = requestValues.originFund.fundDTO
        let destinationFund = requestValues.destinationFund.fundDTO
        let amount = requestValues.amount
        var account: Account?

        let response = try fundsManager.validateFundTransferPartialByAmount(originFundDTO: originFund, destinationFundDTO: destinationFund, amountDTO: amount.amountDTO)
        
        guard response.isSuccess(), let fundTransfer = try response.getResponseData(), let fundAccountAssociated = fundTransfer.linkedAccount else {
            let errorDescription = try response.getErrorMessage() ?? ""
            return UseCaseResponse.error(ValidatePartialAmountFundTransferUseCaseErrorOutput(errorDescription))
        }
        
        let accountResponse = try getLinkedAccount(provider: provider, ibanDTO: fundAccountAssociated)
        if accountResponse.isSuccess(), let accountDTO = try accountResponse.getResponseData() {
            account = Account.create(accountDTO)
        }
        
        return UseCaseResponse.ok(ValidatePartialAmountFundTransferUseCaseOkOutput(fundTransfer: fundTransfer, account: account))
    }
}

struct ValidatePartialAmountFundTransferUseCaseInput {
    let originFund: Fund
    let destinationFund: Fund
    let amount: Amount

    init(originFund: Fund, destinationFund: Fund, amount: Amount) {
        self.originFund = originFund
        self.destinationFund = destinationFund
        self.amount = amount
    }
}

struct ValidatePartialAmountFundTransferUseCaseOkOutput {
    let fundTransfer: FundTransferDTO
    let account: Account?
    
    init(fundTransfer: FundTransferDTO, account: Account?) {
        self.fundTransfer = fundTransfer
        self.account = account
    }
}

extension ValidatePartialAmountFundTransferUseCase: AssociatedAccountRetriever {}
class ValidatePartialAmountFundTransferUseCaseErrorOutput: StringErrorOutput {
    
}
