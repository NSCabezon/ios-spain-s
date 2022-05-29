import SANLegacyLibrary
import CoreFoundationLib
import Foundation

class ValidateFundSubscriptionSharesUseCase: UseCase<ValidateFundSubscriptionSharesUseCaseInput, ValidateFundSubscriptionSharesUseCaseOkOutput, ValidateFundSubscriptionSharesUseCaseErrorOutput> {
    private let provider: BSANManagersProvider
    
    init(managersProvider: BSANManagersProvider) {
        self.provider = managersProvider
    }
    
    override func executeUseCase(requestValues: ValidateFundSubscriptionSharesUseCaseInput) throws -> UseCaseResponse<ValidateFundSubscriptionSharesUseCaseOkOutput, ValidateFundSubscriptionSharesUseCaseErrorOutput> {
        let fundsManager = provider.getBsanFundsManager()
        let fundDTO = requestValues.fund.fundDTO
        let sharesNumber = requestValues.sharesNumber
        var account: Account?
        
        let response = try fundsManager.validateFundSubscriptionShares(fundDTO: fundDTO, sharesNumber: sharesNumber)
        
        guard response.isSuccess(), let fundSubscriptionDTO = try response.getResponseData(), let fundAccountAssociated = fundSubscriptionDTO.directDebtAccount else {
            let errorDescription = try response.getErrorMessage() ?? ""
            return UseCaseResponse.error(ValidateFundSubscriptionSharesUseCaseErrorOutput(errorDescription))
        }
        
        let accountResponse = try getLinkedAccount(provider: provider, ibanDTO: fundAccountAssociated)
        if accountResponse.isSuccess(), let accountDTO = try accountResponse.getResponseData() {
            account = Account.create(accountDTO)
        }
         let fundSubscription = FundSubscription.create(fundSubscriptionDTO)
        return UseCaseResponse.ok(ValidateFundSubscriptionSharesUseCaseOkOutput(fundSubscription: fundSubscription, account: account))
    }
}

struct ValidateFundSubscriptionSharesUseCaseInput {
    let fund: Fund
    let sharesNumber: Decimal
}

struct ValidateFundSubscriptionSharesUseCaseOkOutput {
    let fundSubscription: FundSubscription
    let account: Account?
}

extension ValidateFundSubscriptionSharesUseCase: AssociatedAccountRetriever {}
class ValidateFundSubscriptionSharesUseCaseErrorOutput: StringErrorOutput {
    
}
