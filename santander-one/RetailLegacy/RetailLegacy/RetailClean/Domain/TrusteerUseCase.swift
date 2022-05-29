import CoreFoundationLib
import Foundation

class TrusteerUseCase: UseCase<Void, Void, StringErrorOutput> {
    private let appConfigRepository: AppConfigRepository
    private let trusteerRepository: TrusteerRepositoryProtocol
    
    init(appConfigRepository: AppConfigRepository, trusteerRepository: TrusteerRepositoryProtocol) {
        self.appConfigRepository = appConfigRepository
        self.trusteerRepository = trusteerRepository
    }
    
    override func executeUseCase(requestValues: Void) throws -> UseCaseResponse<Void, StringErrorOutput> {
        let enableTrusteer = appConfigRepository.getAppConfigBooleanNode(nodeName: TrusteerConstants.appConfigEnableTrusteer)
        if enableTrusteer == true {
            trusteerRepository.initialize()
        }
        return UseCaseResponse.ok()
    }
}
