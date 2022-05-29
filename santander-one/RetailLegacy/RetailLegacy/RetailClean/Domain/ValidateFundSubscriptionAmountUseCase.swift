import SANLegacyLibrary
import CoreFoundationLib

class ValidateFundSubscriptionAmountUseCase: UseCase<ValidateFundSubscriptionAmountUseCaseInput, ValidateFundSubscriptionAmountUseCaseOkOutput, ValidateFundSubscriptionAmountUseCaseErrorOutput> {
    private let provider: BSANManagersProvider
    
    init(managersProvider: BSANManagersProvider) {
        self.provider = managersProvider
    }
    
    override func executeUseCase(requestValues: ValidateFundSubscriptionAmountUseCaseInput) throws -> UseCaseResponse<ValidateFundSubscriptionAmountUseCaseOkOutput, ValidateFundSubscriptionAmountUseCaseErrorOutput> {
        let fundsManager = provider.getBsanFundsManager()
        let fundDTO = requestValues.fund.fundDTO
        let amountDTO = requestValues.amount.amountDTO
        var account: Account?
        
        let response = try fundsManager.validateFundSubscriptionAmount(fundDTO: fundDTO, amountDTO: amountDTO)
        
        guard response.isSuccess(), let fundSubscriptionDTO = try response.getResponseData(), let fundAccountAssociated = fundSubscriptionDTO.directDebtAccount else {
            let errorDescription = try response.getErrorMessage() ?? ""
            return UseCaseResponse.error(ValidateFundSubscriptionAmountUseCaseErrorOutput(errorDescription))
        }
        
        let accountResponse = try getLinkedAccount(provider: provider, ibanDTO: fundAccountAssociated)
        if accountResponse.isSuccess(), let accountDTO = try accountResponse.getResponseData() {
            account = Account.create(accountDTO)
        }
        let fundSubscription = FundSubscription.create(fundSubscriptionDTO)
        return UseCaseResponse.ok(ValidateFundSubscriptionAmountUseCaseOkOutput(fundSubscription: fundSubscription, account: account))
    }
}

struct ValidateFundSubscriptionAmountUseCaseInput {
    let fund: Fund
    let amount: Amount
}

struct ValidateFundSubscriptionAmountUseCaseOkOutput {
    let fundSubscription: FundSubscription
    let account: Account?
}

extension ValidateFundSubscriptionAmountUseCase: AssociatedAccountRetriever {}
class ValidateFundSubscriptionAmountUseCaseErrorOutput: StringErrorOutput {
    
}
