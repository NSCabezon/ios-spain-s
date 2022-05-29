import Foundation
import CoreFoundationLib
import SANLegacyLibrary
import CoreDomain

class ConfirmBillEmittersPaymentUseCase: UseCase<ConfirmBillEmittersPaymentUseCaseInput, Void, GenericErrorSignatureErrorOutput> {
    
    private let dependenciesResolver: DependenciesResolver
    private lazy var provider: BSANManagersProvider = {
        return self.dependenciesResolver.resolve(for: BSANManagersProvider.self)
    }()
    
    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
    }
    
    override func executeUseCase(requestValues: ConfirmBillEmittersPaymentUseCaseInput) throws -> UseCaseResponse<Void, GenericErrorSignatureErrorOutput> {
        guard let signature = requestValues.signature as? SignatureDTO else {
            return .error(GenericErrorSignatureErrorOutput(nil, .otherError, nil))
        }
        let response = try self.provider.getBsanBillTaxesManager()
            .emittersPaymentConfirmation(
                account: requestValues.account.dto,
                signature: signature,
                amount: requestValues.amount.dto,
                emitterCode: requestValues.emitterCode,
                productIdentifier: requestValues.productIdentifier,
                collectionTypeCode: requestValues.collectionTypeCode,
                collectionCode: requestValues.collectionCode,
                billData: requestValues.billData
            )
        if response.isSuccess() {
            return UseCaseResponse.ok()
        }
        let signatureType = try processSignatureResult(response)
        let errorDescription = try response.getErrorMessage() ?? ""
        let errorCode = try response.getErrorCode()
        return .error(GenericErrorSignatureErrorOutput(errorDescription, signatureType, errorCode))
    }
}

struct ConfirmBillEmittersPaymentUseCaseInput {
    let account: AccountEntity
    let signature: SignatureRepresentable
    let amount: AmountEntity
    let emitterCode: String
    let productIdentifier: String
    let collectionTypeCode: String
    let collectionCode: String
    let billData: [String]
}
