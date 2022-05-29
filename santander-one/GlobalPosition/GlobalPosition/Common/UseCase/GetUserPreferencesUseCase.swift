import CoreFoundationLib

final class GetUserPreferencesUseCase: UseCase<GetUserPreferencesUseCaseInput, GetUserPreferencesUseCaseOkOutput, StringErrorOutput> {
    override func executeUseCase(requestValues: GetUserPreferencesUseCaseInput) throws -> UseCaseResponse<GetUserPreferencesUseCaseOkOutput, StringErrorOutput> {
        let appRepositoryProtocol: AppRepositoryProtocol = requestValues.dependenciesResolver.resolve()
        let userPrefDTO = appRepositoryProtocol.getUserPreferences(userId: requestValues.userId ?? "")
        return UseCaseResponse.ok(GetUserPreferencesUseCaseOkOutput(userPref: UserPrefEntity.from(dto: userPrefDTO)))
    }
}

struct GetUserPreferencesUseCaseInput {
    let dependenciesResolver: DependenciesResolver
    let userId: String?
}

struct GetUserPreferencesUseCaseOkOutput {
    let userPref: UserPrefEntity
}
