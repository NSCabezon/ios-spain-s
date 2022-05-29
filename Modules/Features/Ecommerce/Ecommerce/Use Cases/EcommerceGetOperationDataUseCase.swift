import CoreFoundationLib
import SANLegacyLibrary

public final class EcommerceGetOperationDataUseCase: UseCase<EcommerceGetOperationDataUseCaseInput, EcommerceGetOperationDataUseCaseOutput, StringErrorOutput> {
    private let provider: BSANManagersProvider
    
    public init(dependenciesResolver: DependenciesResolver) {
        self.provider = dependenciesResolver.resolve(for: BSANManagersProvider.self)
    }
    
    override public func executeUseCase(requestValues: EcommerceGetOperationDataUseCaseInput) throws -> UseCaseResponse<EcommerceGetOperationDataUseCaseOutput, StringErrorOutput> {
        let shortUrl = requestValues.ecommerceLastOperationCode
        let response = try provider.getBsanEcommerceManager().getOperationData(shortUrl: shortUrl)
        if response.isSuccess(), let ecommerceDto = try response.getResponseData() {
            let ecommerceData = EcommerceOperationDataEntity(ecommerceDto)
            return UseCaseResponse.ok(EcommerceGetOperationDataUseCaseOutput(ecommerceData: ecommerceData))
        } else {
            let errorDesc = try response.getErrorMessage()
            return .error(StringErrorOutput(errorDesc))
        }
    }
}

public struct EcommerceGetOperationDataUseCaseInput {
    let ecommerceLastOperationCode: String
}

public struct EcommerceGetOperationDataUseCaseOutput {
    let ecommerceData: EcommerceOperationDataEntity
}
