import Foundation
import CoreFoundationLib
import SANLegacyLibrary

class SetupPullOffersUseCase: UseCase<Void, Void, StringErrorOutput> {
    
    private let pullOffersRepository: PullOffersRepositoryProtocol
    
    init(pullOffersRepository: PullOffersRepositoryProtocol) {
        self.pullOffersRepository = pullOffersRepository
    }
    
    override func executeUseCase(requestValues: Void) throws -> UseCaseResponse<Void, StringErrorOutput> {
        _ = pullOffersRepository.setup()
        return .ok()
    }
}
