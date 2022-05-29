import CoreFoundationLib
import SANLibraryV3
import SANLegacyLibrary

final class BizumCancelUseCase: UseCase<BizumCancelUseCaseInput, BizumCancelUseCaseOutput, StringErrorOutput> {
    private let dependenciesResolver: DependenciesResolver
    
    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
    }
    
    override func executeUseCase(requestValues: BizumCancelUseCaseInput) throws -> UseCaseResponse<BizumCancelUseCaseOutput, StringErrorOutput> {
        let provider: SANLibraryV3.BSANManagersProvider = self.dependenciesResolver.resolve(for: SANLibraryV3.BSANManagersProvider.self)
        let input: BizumCancelNotRegisterInputParam = BizumCancelNotRegisterInputParam(checkPayment: requestValues.checkPayment.dto, document: requestValues.document.dto, operation: requestValues.bizumOperation.dto, dateTime: requestValues.dateTime)
        let response = try provider.getBSANBizumManager().cancelPendingTransfer(input)
        guard response.isSuccess(), let dto = try response.getResponseData() else {
            let errorDescription = try response.getErrorMessage() ?? ""
            return .error(StringErrorOutput(errorDescription))
        }
        return .ok(BizumCancelUseCaseOutput(responseInfo: BizumResponseInfoEntity(dto)))
    }
}

struct BizumCancelUseCaseInput {
    let checkPayment: BizumCheckPaymentEntity
    let document: BizumDocumentEntity
    let bizumOperation: BizumOperationEntity
    let dateTime: Date
}

struct BizumCancelUseCaseOutput {
    let responseInfo: BizumResponseInfoEntity
}
