import CoreFoundationLib
import Foundation

class UpdatePendingSolicitudeUseCase: UseCase<UpdatePendingSolicitudeUseCaseInput, Void, StringErrorOutput> {
    
    private let dependenciesResolver: DependenciesResolver
    
    public init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
    }
    
    override func executeUseCase(requestValues: UpdatePendingSolicitudeUseCaseInput) throws -> UseCaseResponse<Void, StringErrorOutput> {
        let appRepository = self.dependenciesResolver.resolve(for: AppRepositoryProtocol.self)
        appRepository.setPendingSolicitudeClosed(requestValues.pendingSolicitude)
        return .ok()
    }
}

struct UpdatePendingSolicitudeUseCaseInput {
    let pendingSolicitude: PendingSolicitudeEntity
}
