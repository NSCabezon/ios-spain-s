import Foundation
import CoreFoundationLib
import SANLibraryV3

final class SignPosSendMoneyUseCase: UseCase<Void, SignPosSendMoneyUseCaseOkOutput, StringErrorOutput> {
    private let dependenciesResolver: DependenciesResolver
    private lazy var provider: BSANManagersProvider = {
        return self.dependenciesResolver.resolve(for: BSANManagersProvider.self)
    }()
    
    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
    }
    
    override func executeUseCase(requestValues: Void) throws -> UseCaseResponse<SignPosSendMoneyUseCaseOkOutput, StringErrorOutput> {
        let response = try self.provider.getBSANBizumManager().getSignPositions()
        guard response.isSuccess(), let dto = try response.getResponseData() else {
            let errorDescription = try response.getErrorMessage() ?? ""
            return .error(StringErrorOutput(errorDescription))
        }
        guard let entity = SignatureWithTokenEntity(dto.signature) else {
            let errorDescription = try response.getErrorMessage() ?? ""
            return UseCaseResponse.error(StringErrorOutput(errorDescription))
        }
        return .ok(SignPosSendMoneyUseCaseOkOutput(signatureWithTokenEntity: entity))
    }
}

struct SignPosSendMoneyUseCaseOkOutput {
    let signatureWithTokenEntity: SignatureWithTokenEntity
}
