import CoreFoundationLib
import Foundation

class SetPersistedUserAvatarUseCase: UseCase<SetPersistedUserAvatarUseCaseInput, Void, StringErrorOutput> {    
    override public func executeUseCase(requestValues: SetPersistedUserAvatarUseCaseInput) throws -> UseCaseResponse<Void, StringErrorOutput> {
        let globalPosition: GlobalPositionRepresentable = requestValues.dependenciesResolver.resolve(for: GlobalPositionRepresentable.self)
        let appRepositoryProtocol: AppRepositoryProtocol = requestValues.dependenciesResolver.resolve(for: AppRepositoryProtocol.self)
        guard let userId = globalPosition.userId else {
            return UseCaseResponse.error(StringErrorOutput(nil))
        }
        _ = appRepositoryProtocol.setPersistedUserAvatar(userId: userId, image: requestValues.image)
        return UseCaseResponse.ok()
    }
}

struct SetPersistedUserAvatarUseCaseInput {
    let dependenciesResolver: DependenciesResolver
    let image: Data
}
