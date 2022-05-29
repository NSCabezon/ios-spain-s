import Foundation

public class LoadBackgroundImagesUseCase: UseCase<LoadBackgroundImagesUseCaseInput, Void, StringErrorOutput> {
    private let dependenciesResolver: DependenciesResolver

    public init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
    }
    
    public override func executeUseCase(requestValues: LoadBackgroundImagesUseCaseInput) throws -> UseCaseResponse<Void, StringErrorOutput> {
        let _: BackgroundImageManagerProtocol = self.dependenciesResolver.resolve()

        let globalPosition: GlobalPositionRepresentable = self.dependenciesResolver.resolve()
        let appRepository: AppRepositoryProtocol = self.dependenciesResolver.resolve()
        guard let userId: String = globalPosition.userId else {
            return .error(StringErrorOutput(nil))
        }
        let userPreferences: UserPrefDTOEntity = appRepository.getUserPreferences(userId: userId)
        let oldTheme: BackgroundImagesTheme?
        if let oldThemeId = userPreferences.pgUserPrefDTO.photoThemeOptionSelected {
            oldTheme = self.getBackgroudTheme(for: oldThemeId)
        } else {
            oldTheme = nil
        }
        let theme = requestValues.theme
        guard oldTheme != theme else {
            return .ok()
        }
        let oldFolder: String? = oldTheme?.isLocalTheme == false ? oldTheme?.name : nil
        if theme.isLocalTheme {
            if let oldFolderToDelete = oldFolder {
                let deleteBackgroundImageRepositoryProtocol: DeleteBackgroundImageRepositoryProtocol = self.dependenciesResolver.resolve()
                deleteBackgroundImageRepositoryProtocol.delete(oldFolderToDelete)
            }
        } else {
            guard let urlBase = try appRepository.getCurrentPublicFilesEnvironment().getResponseData()?.urlBase else {
                return .error(StringErrorOutput(nil))
            }
            let backgroundImageRepository: BackgroundImageRepositoryProtocol = dependenciesResolver.resolve()
            guard backgroundImageRepository.loadWithName(theme.name, baseUrl: urlBase, oldName: oldFolder) else {
                return .error(StringErrorOutput(nil))
            }
        }
        userPreferences.pgUserPrefDTO.photoThemeOptionSelected = theme.id
        appRepository.setUserPreferences(userPref: userPreferences)
        return .ok()
    }
}

private extension LoadBackgroundImagesUseCase {
    var photoThemeModifier: PhotoThemeModifierProtocol? {
        return dependenciesResolver.resolve(forOptionalType: PhotoThemeModifierProtocol.self)
    }
    
    func getBackgroudTheme(for id: Int) -> BackgroundImagesTheme? {
        guard let theme = BackgroundImagesTheme(id: id) else {
            return photoThemeModifier?.getBackGroundImage(for: id)
        }
        return theme
    }
}

public struct LoadBackgroundImagesUseCaseInput {
    let theme: BackgroundImagesTheme
    
    public init(theme: BackgroundImagesTheme) {
        self.theme = theme
    }
}
