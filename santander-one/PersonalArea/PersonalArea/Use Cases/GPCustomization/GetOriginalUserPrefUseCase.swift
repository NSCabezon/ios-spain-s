import CoreFoundationLib

class GetGPCustomizationConfigurationUseCase: UseCase<GetGPCustomizationConfigurationUseCaseInput, GetGPCustomizationConfigurationUseCaseOkOutput, StringErrorOutput> {
    override func executeUseCase(requestValues: GetGPCustomizationConfigurationUseCaseInput) throws -> UseCaseResponse<GetGPCustomizationConfigurationUseCaseOkOutput, StringErrorOutput> {
        let globalPosition: GlobalPositionWithUserPrefsRepresentable = requestValues.dependenciesResolver.resolve(for: GlobalPositionWithUserPrefsRepresentable.self)
        let defaultGlobalPosition: GlobalPositionRepresentable = requestValues.dependenciesResolver.resolve(for: GlobalPositionRepresentable.self)
        let newUserPref = UserPrefEntity.from(dto: UserPrefDTOEntity(userId: globalPosition.userId ?? ""))
        let defaultMerge = GlobalPositionPrefsMergerEntity(resolver: requestValues.dependenciesResolver, globalPosition: defaultGlobalPosition, userPref: newUserPref, saveUserPreferences: false)
        return UseCaseResponse.ok(GetGPCustomizationConfigurationUseCaseOkOutput(globalPosition: globalPosition, defaultGlobalPosition: defaultMerge))
    }
}

struct GetGPCustomizationConfigurationUseCaseInput {
    let dependenciesResolver: DependenciesResolver
}

struct GetGPCustomizationConfigurationUseCaseOkOutput {
    let globalPosition: GlobalPositionWithUserPrefsRepresentable
    let defaultGlobalPosition: GlobalPositionWithUserPrefsRepresentable
}
