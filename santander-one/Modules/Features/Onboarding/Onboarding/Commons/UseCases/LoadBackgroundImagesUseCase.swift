//
//  LoadBackgroundImagesUseCase.swift
//  Onboarding
//
//  Created by Jose Camallonga on 15/12/21.
//

import Foundation
import CoreDomain
import OpenCombine
import CoreFoundationLib

protocol LoadBackgroundImagesUseCase {
    func execute(userId: String, current: BackgroundImagesTheme) -> AnyPublisher<Void, Error>
}

struct DefaultLoadBackgroundImagesUseCase: LoadBackgroundImagesUseCase {
    private let appRepository: AppRepositoryProtocol
    private let backgroundImageRepository: BackgroundImageRepositoryProtocol
    private let deleteBackgroundImageRepository: DeleteBackgroundImageRepositoryProtocol
    private let userPreferencesRepository: UserPreferencesRepository
    private let photoThemeModifier: PhotoThemeModifierProtocol?
    
    init(dependencies: OnboardingPhotoThemeExternalDependenciesResolver) {
        self.appRepository = dependencies.resolve()
        self.backgroundImageRepository = dependencies.resolve()
        self.userPreferencesRepository = dependencies.resolve()
        self.deleteBackgroundImageRepository = dependencies.resolve()
        self.photoThemeModifier = dependencies.resolve()
    }
    
    func execute(userId: String, current: BackgroundImagesTheme) -> AnyPublisher<Void, Error> {
        return userPreferencesRepository
            .getUserPreferences(userId: userId)
            .first()
            .flatMap { userPreferences -> AnyPublisher<Void, Error> in
                let oldTheme = self.getBackgroudTheme(for: userPreferences.photoThemeOnboardingSelected() ?? 0)
                guard oldTheme != current else {
                    return Just(())
                        .setFailureType(to: Error.self)
                        .eraseToAnyPublisher()
                }
                let oldFolder: String? = oldTheme?.isLocalTheme == false ? oldTheme?.name : nil
                if current.isLocalTheme {
                    if let oldFolderToDelete = oldFolder {
                        deleteBackgroundImageRepository.delete(oldFolderToDelete)
                    }
                } else {
                    guard let urlBase = try? self.appRepository.getCurrentPublicFilesEnvironment().getResponseData()?.urlBase,
                          backgroundImageRepository.loadWithName(current.name, baseUrl: urlBase, oldName: oldFolder) else {
                              return Fail<Void, Error>(error: LoadBackgroundImageRepositoryError.fileNotFound)
                                  .eraseToAnyPublisher()
                          }
                }
                let update = Update(userId: userId, photoThemeOptionSelected: current.id)
                userPreferencesRepository.updateUserPreferences(update: update)
                return Just(())
                    .setFailureType(to: Error.self)
                    .eraseToAnyPublisher()
            }.eraseToAnyPublisher()
    }
}

private extension DefaultLoadBackgroundImagesUseCase {
    struct Update: UpdateUserPreferencesRepresentable {
        let userId: String
        let alias: String? = nil
        let globalPositionOptionSelected: GlobalPositionOptionEntity? = nil
        let photoThemeOptionSelected: Int?
        let pgColorMode: PGColorMode? = nil
        let isPrivateMenuCoachManagerShown: Bool? = nil
    }
    
    func getBackgroudTheme(for id: Int) -> BackgroundImagesTheme? {
        guard let theme = BackgroundImagesTheme(id: id) else {
            return photoThemeModifier?.getBackGroundImage(for: id)
        }
        return theme
    }
}
