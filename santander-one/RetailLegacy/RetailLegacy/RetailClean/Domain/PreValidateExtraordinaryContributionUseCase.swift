import Foundation
import SANLegacyLibrary
import CoreFoundationLib

class PreValidateExtraordinaryContributionUseCase: UseCase<PreValidateExtraordinaryContributionUseCaseInput, PreValidateExtraordinaryContributionUseCaseOkOutput, PreValidateExtraordinaryContributionUseCaseErrorOutput> {
    private let provider: BSANManagersProvider
    
    init(managersProvider: BSANManagersProvider) {
        self.provider = managersProvider
    }
    
    override func executeUseCase(requestValues: PreValidateExtraordinaryContributionUseCaseInput) throws -> UseCaseResponse<PreValidateExtraordinaryContributionUseCaseOkOutput, PreValidateExtraordinaryContributionUseCaseErrorOutput> {
        let originPension = requestValues.originPension
        switch Decimal.getAmountParserResult(value: requestValues.amount) {
        case .success(let value):
            guard let amountReference = originPension.getAmount(), let amount = Amount.createWith(value: value, amount: amountReference) else {
                let key = Decimal.defaultErrorDescriptionKey(forAmountError: .notValid)
                return UseCaseResponse.error(PreValidateExtraordinaryContributionUseCaseErrorOutput(key))
            }
            let pensionsManager = provider.getBsanPensionsManager()
            let pensionDTO = originPension.pensionDTO
            var account: Account?
            let response = try pensionsManager.getPensionContributions(pensionDTO: pensionDTO, pagination: nil)
            guard response.isSuccess(),
                let responseData = try response.getResponseData(),
                let pensionAccountAssociated = responseData.pensionInfoOperationDTO.pensionAccountAssociated else {
                    let errorDescription = try response.getErrorMessage() ?? ""
                    return UseCaseResponse.error(PreValidateExtraordinaryContributionUseCaseErrorOutput(errorDescription))
            }
            let accountResponse = try getLinkedAccount(provider: provider, ibanDTO: pensionAccountAssociated)
            if accountResponse.isSuccess(), let accountDTO = try accountResponse.getResponseData() {
                account = Account.create(accountDTO)
            }
            let pensionInfoOperation = responseData.pensionInfoOperationDTO
            let extraContributionPension = ExtraContributionPension(
                originPension: originPension,
                pensionInfoOperation: PensionInfoOperation(pensionInfoOperation),
                account: account,
                amount: amount)
            return UseCaseResponse.ok(PreValidateExtraordinaryContributionUseCaseOkOutput(extraContributionPension: extraContributionPension))            
        case .error(let error):
            let key = Decimal.defaultErrorDescriptionKey(forAmountError: error)
            return UseCaseResponse.error(PreValidateExtraordinaryContributionUseCaseErrorOutput(key))
        }
    }
}

extension PreValidateExtraordinaryContributionUseCase: AssociatedAccountRetriever {}

struct PreValidateExtraordinaryContributionUseCaseInput {
    let amount: String?
    let originPension: Pension
}

struct PreValidateExtraordinaryContributionUseCaseOkOutput {
    let extraContributionPension: ExtraContributionPension
}

class PreValidateExtraordinaryContributionUseCaseErrorOutput: StringErrorOutput {
}
