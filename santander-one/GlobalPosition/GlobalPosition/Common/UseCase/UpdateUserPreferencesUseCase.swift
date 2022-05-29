import CoreFoundationLib

final class UpdateUserPreferencesUseCase: UseCase<UpdateUserPreferencesUseCaseInput, Void, StringErrorOutput> {
    override func executeUseCase(requestValues: UpdateUserPreferencesUseCaseInput) throws -> UseCaseResponse<Void, StringErrorOutput> {
        let appRepositoryProtocol: AppRepositoryProtocol = requestValues.dependenciesResolver.resolve(for: AppRepositoryProtocol.self)
        _ = appRepositoryProtocol.setUserPreferences(userPref: requestValues.userPref.userPrefDTOEntity)
        return UseCaseResponse.ok()
    }
}

struct UpdateUserPreferencesUseCaseInput {
    let dependenciesResolver: DependenciesResolver
    let userPref: UserPrefEntity
}
