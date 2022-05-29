import CoreFoundationLib
import CoreDomain

class UpdatePersonalAreaDataUseCase: UseCase<UpdatePersonalAreaDataUseCaseInput, Void, StringErrorOutput> {
    override func executeUseCase(requestValues: UpdatePersonalAreaDataUseCaseInput) throws -> UseCaseResponse<Void, StringErrorOutput> {
        let appRepositoryProtocol: AppRepositoryProtocol = requestValues.dependenciesResolver.resolve(for: AppRepositoryProtocol.self)
        let repository: UserPreferencesRepository = requestValues.userPreferencesDependencies.resolve()
        let userPrefUpdate = requestValues.userPref.userPrefDTOEntity
        let updateUserPrefDTO = Update(
            userId: userPrefUpdate.userId,
            alias: userPrefUpdate.pgUserPrefDTO.alias,
            selectedGP: userPrefUpdate.pgUserPrefDTO.globalPositionOptionSelected,
            photoThemeOptionSelected: userPrefUpdate.pgUserPrefDTO.photoThemeOptionSelected,
            pgColorMode: userPrefUpdate.pgUserPrefDTO.pgColorMode,
            isPrivateMenuCoachManagerShown: userPrefUpdate.pgUserPrefDTO.isPrivateMenuCoachManagerShown
        )
        repository.updateUserPreferences(update: updateUserPrefDTO)
        _ = appRepositoryProtocol.setUserPreferences(userPref: requestValues.userPref.userPrefDTOEntity)
        return UseCaseResponse.ok()
    }
}

struct UpdatePersonalAreaDataUseCaseInput {
    let dependenciesResolver: DependenciesResolver
    let userPref: UserPrefEntity
    let userPreferencesDependencies: UserPreferencesDependenciesResolver
}

struct Update: UpdateUserPreferencesRepresentable {
    var userId: String
    var alias: String?
    var selectedGP: Int?
    var globalPositionOptionSelected: GlobalPositionOptionEntity? {
        if let selectedGP = selectedGP {
            return GlobalPositionOptionEntity(rawValue: selectedGP)
        }
        return nil
    }
    var photoThemeOptionSelected: Int?
    var pgColorMode: PGColorMode?
    var isPrivateMenuCoachManagerShown: Bool?
}
