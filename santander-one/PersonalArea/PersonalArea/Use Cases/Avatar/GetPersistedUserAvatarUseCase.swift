import Foundation
import CoreFoundationLib

class GetPersistedUserAvatarUseCase: UseCase<GetPersistedUserAvatarUseCaseInput, GetPersistedUserAvatarUseCaseOkOutput, StringErrorOutput> {
    override public func executeUseCase(requestValues: GetPersistedUserAvatarUseCaseInput) throws -> UseCaseResponse<GetPersistedUserAvatarUseCaseOkOutput, StringErrorOutput> {
        let globalPosition: GlobalPositionRepresentable = requestValues.dependenciesResolver.resolve(for: GlobalPositionRepresentable.self)
        let appRepositoryProtocol: AppRepositoryProtocol = requestValues.dependenciesResolver.resolve(for: AppRepositoryProtocol.self)
        
        guard let userId = globalPosition.userId else {
            return UseCaseResponse.error(StringErrorOutput(nil))
        }
        let image = appRepositoryProtocol.getPersistedUserAvatar(userId: userId)
        return UseCaseResponse.ok(GetPersistedUserAvatarUseCaseOkOutput(image: image))
    }
}

struct GetPersistedUserAvatarUseCaseInput {
    let dependenciesResolver: DependenciesResolver
}

struct GetPersistedUserAvatarUseCaseOkOutput {
    let image: Data?
}
