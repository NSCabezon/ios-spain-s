import SANLegacyLibrary
import CoreFoundationLib

class ValidateTotalFundTransferUseCase: UseCase<ValidateTotalFundTransferUseCaseInput, ValidateTotalFundTransferUseCaseOkOutput, ValidateTotalFundTransferUseCaseErrorOutput> {
    private let provider: BSANManagersProvider
    
    init(managersProvider: BSANManagersProvider) {
        self.provider = managersProvider
    }
    
    override func executeUseCase(requestValues: ValidateTotalFundTransferUseCaseInput) throws -> UseCaseResponse<ValidateTotalFundTransferUseCaseOkOutput, ValidateTotalFundTransferUseCaseErrorOutput> {
        let fundsManager = provider.getBsanFundsManager()
        let originFund = requestValues.originFund.fundDTO
        let destinationFund = requestValues.destinationFund.fundDTO
        var account: Account?
        
        let response = try fundsManager.validateFundTransferTotal(originFundDTO: originFund, destinationFundDTO: destinationFund)
        
        guard response.isSuccess(), let fundTransfer = try response.getResponseData(), let fundAccountAssociated = fundTransfer.linkedAccount else {
            let errorDescription = try response.getErrorMessage() ?? ""
            return UseCaseResponse.error(ValidateTotalFundTransferUseCaseErrorOutput(errorDescription))
        }
        
        let accountResponse = try getLinkedAccount(provider: provider, ibanDTO: fundAccountAssociated)
        if accountResponse.isSuccess(), let accountDTO = try accountResponse.getResponseData() {
            account = Account.create(accountDTO)
        }
        
        return UseCaseResponse.ok(ValidateTotalFundTransferUseCaseOkOutput(fundTransfer: fundTransfer, account: account))       
    }
}

struct ValidateTotalFundTransferUseCaseInput {
    let originFund: Fund
    let destinationFund: Fund
    
    init(originFund: Fund, destinationFund: Fund) {
        self.originFund = originFund
        self.destinationFund = destinationFund
    }
}

struct ValidateTotalFundTransferUseCaseOkOutput {
    let fundTransfer: FundTransferDTO
    let account: Account?
    
    init(fundTransfer: FundTransferDTO, account: Account?) {
        self.fundTransfer = fundTransfer
        self.account = account
    }
}

extension ValidateTotalFundTransferUseCase: AssociatedAccountRetriever {}

class ValidateTotalFundTransferUseCaseErrorOutput: StringErrorOutput {
    
}
