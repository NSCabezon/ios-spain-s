import Foundation
import CoreFoundationLib
import SANLegacyLibrary

class ValidateCancelDirectBillingUseCase: UseCase<ValidateCancelDirectBillingUseCaseInput, ValidateCancelDirectBillingUseCaseOkOutput, StringErrorOutput> {
    private let provider: BSANManagersProvider
    private let dependenciesResolver: DependenciesResolver
    
    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
        self.provider = self.dependenciesResolver.resolve(for: BSANManagersProvider.self)
    }
    
    override func executeUseCase(requestValues: ValidateCancelDirectBillingUseCaseInput) throws -> UseCaseResponse<ValidateCancelDirectBillingUseCaseOkOutput, StringErrorOutput> {
        let accountDTO = requestValues.account.accountDTO
        let billDTO = requestValues.bill.billDTO
        var enableBillAndTaxesRemedy: Bool {
            let appConfigRepository = self.dependenciesResolver.resolve(for: AppConfigRepositoryProtocol.self)
            return appConfigRepository.getBool(BillsConstants.enableBillAndTaxesRemedy) ?? false
        }
        let response = try provider
            .getBsanBillTaxesManager()
            .cancelDirectBilling(account: accountDTO,
                                 bill: billDTO,
                                 enableBillAndTaxesRemedy: enableBillAndTaxesRemedy)
        
        guard
            response.isSuccess(),
            let cancelDirectBillingDTO = try response.getResponseData(),
            let signatureDTO = cancelDirectBillingDTO.signature
            else {
                let errorDescription = try response.getErrorMessage() ?? ""
                return UseCaseResponse.error(StringErrorOutput(errorDescription))
        }
        return UseCaseResponse.ok(ValidateCancelDirectBillingUseCaseOkOutput(cancelDirectBilling: CancelDirectBilling(dto: cancelDirectBillingDTO),
                                                                             signature: Signature(dto: signatureDTO)))
    }
}

struct ValidateCancelDirectBillingUseCaseInput {
    let account: Account
    let bill: Bill
}

struct ValidateCancelDirectBillingUseCaseOkOutput {
    let cancelDirectBilling: CancelDirectBilling
    let signature: Signature
}
