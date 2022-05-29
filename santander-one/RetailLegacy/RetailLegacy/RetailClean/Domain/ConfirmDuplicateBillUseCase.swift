import SANLegacyLibrary
import CoreFoundationLib

class ConfirmDuplicateBillUseCase: ConfirmUseCase<ConfirmDuplicateBillUseCaseInput, Void, GenericErrorSignatureErrorOutput> {
    private let provider: BSANManagersProvider
    private let dependenciesResolver: DependenciesResolver
    
    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
        self.provider = self.dependenciesResolver.resolve(for: BSANManagersProvider.self)
    }
    
    override func executeUseCase(requestValues: ConfirmDuplicateBillUseCaseInput) throws -> UseCaseResponse<Void, GenericErrorSignatureErrorOutput> {
        var enableBillAndTaxesRemedy: Bool {
            let appConfigRepository = self.dependenciesResolver.resolve(for: AppConfigRepositoryProtocol.self)
            return appConfigRepository.getBool(BillsConstants.enableBillAndTaxesRemedy) ?? false
        }
        let manager = provider.getBsanBillTaxesManager()
        let response = try manager.confirmDuplicateBill(account: requestValues.account.accountDTO,
                                                        bill: requestValues.bill.billDTO,
                                                        signature: requestValues.signature.dto,
                                                        enableBillAndTaxesRemedy: enableBillAndTaxesRemedy)
        if response.isSuccess() {
            return UseCaseResponse.ok()
        }
        let signatureType = try getSignatureResult(response)
        let errorDescription = try response.getErrorMessage() ?? ""
        let errorCode = try response.getErrorCode()
        return UseCaseResponse.error(GenericErrorSignatureErrorOutput(errorDescription,
                                                                      signatureType, errorCode))
    }
}

struct ConfirmDuplicateBillUseCaseInput {
    let bill: Bill
    let account: Account
    let signature: Signature
}
