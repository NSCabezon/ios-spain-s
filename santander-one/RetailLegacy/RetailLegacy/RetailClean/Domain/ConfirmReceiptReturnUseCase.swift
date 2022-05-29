import SANLegacyLibrary
import CoreFoundationLib

class ConfirmReceiptReturnUseCase: ConfirmUseCase<ConfirmReceiptReturnUseCaseInput, Void, GenericErrorSignatureErrorOutput> {
    private let dependenciesResolver: DependenciesResolver
    private let provider: BSANManagersProvider
    
    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
        self.provider = self.dependenciesResolver.resolve(for: BSANManagersProvider.self)
    }
    
    override func executeUseCase(requestValues: ConfirmReceiptReturnUseCaseInput) throws -> UseCaseResponse<Void, GenericErrorSignatureErrorOutput> {
        let manager = provider.getBsanBillTaxesManager()
        var enableBillAndTaxesRemedy: Bool {
            let appConfigRepository = self.dependenciesResolver.resolve(for: AppConfigRepositoryProtocol.self)
            return appConfigRepository.getBool(BillsConstants.enableBillAndTaxesRemedy) ?? false
        }
        let response = try manager
            .confirmReceiptReturn(account: requestValues.account.accountDTO,
                                  bill: requestValues.bill.billDTO,
                                  billDetail: requestValues.detailBill.billDetailDTO,
                                  signature: requestValues.signature.dto,
                                  enableBillAndTaxesRemedy: enableBillAndTaxesRemedy)
        if response.isSuccess() {
            return UseCaseResponse.ok()
        }
        let signatureType = try getSignatureResult(response)
        let errorDescription = try response.getErrorMessage() ?? ""
        let errorCode = try response.getErrorCode()
        return UseCaseResponse.error(GenericErrorSignatureErrorOutput(errorDescription, signatureType, errorCode))
    }
}

struct ConfirmReceiptReturnUseCaseInput {
    let bill: Bill
    let detailBill: BillDetail
    let account: Account
    let signature: Signature
}
