//
//  LoadRememberedLoginDataUseCase.swift
//  Pods
//
//  Created by Juan Carlos López Robles on 12/3/20.
//

import Foundation
import SANLibraryV3
import CoreFoundationLib

class LoadRememberedLoginDataUseCase: UseCase<Void, LoadRememberedLoginDataUseCaseOkOutput, LoadRememberedLoginDataUseCaseErrorOutput> {
    private let appRepository: AppRepositoryProtocol
    private let segmentedUserRepository: SegmentedUserRepository
    private let dependenciesResolver: DependenciesResolver
    private let defaultTheme: BackgroundImagesTheme = BackgroundImagesTheme.nature
    private let backgroundMinId: Int = 1
    private let backgroundMaxId: Int = 10
    
    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
        self.appRepository = self.dependenciesResolver.resolve(for: AppRepositoryProtocol.self)
        self.segmentedUserRepository = self.dependenciesResolver.resolve(for: SegmentedUserRepository.self)
    }
    
    override func executeUseCase(requestValues: Void) throws -> UseCaseResponse<LoadRememberedLoginDataUseCaseOkOutput, LoadRememberedLoginDataUseCaseErrorOutput> {
        let persistedUserResponse = appRepository.getPersistedUser()
        guard persistedUserResponse.isSuccess() else {
            return .error(LoadRememberedLoginDataUseCaseErrorOutput(try persistedUserResponse.getErrorMessage()))
        }
        let user = try persistedUserResponse.getResponseData()
        let type: SemanticSegmentTypeEntity
        if user?.isPb == true {
            type = .spb
        } else if user?.isSmart == true {
            type = .universitarios
        } else {
            let matcher = SegmentedUserMatcher(isPB: false, repository: segmentedUserRepository)
            if let commercialSegment = matcher.retrieveUserSegment(bdpType: user?.bdpCode, comCode: user?.comCode) {
                let commercialEntity = CommercialSegmentEntity(dto: commercialSegment)
                type = commercialEntity.semanticSegment
            } else {
                type = .retail
            }
        }
        let userId: String? = user?.userId
        let theme: BackgroundImagesTheme = self.getBackgroundThemeForUserId(userId)
        let backgroundType: RememberedLoginBackgroundType = self.getBackgroundType(theme)
        let alias: String? = self.getAliasForUserId(userId)
        return UseCaseResponse.ok(LoadRememberedLoginDataUseCaseOkOutput(persistedUser: PersistedUserEntity(dto: user), type: type, backgroundType: backgroundType, alias: alias))
        
    }
}

private extension LoadRememberedLoginDataUseCase {
    func getUserPreferencesForUserId(_ userId: String?) -> UserPrefDTOEntity? {
        guard let userIdUnwrapped: String = userId else { return nil }
        let appRepository: AppRepositoryProtocol = self.dependenciesResolver.resolve()
        let userPreferences: UserPrefDTOEntity = appRepository.getUserPreferences(userId: userIdUnwrapped)
        appRepository.setSharedUserPref(userId: userPreferences.userId)
        return userPreferences
    }
    
    func getAliasForUserId(_ userId: String?) -> String? {
        guard let userPreferences = self.getUserPreferencesForUserId(userId) else { return nil }
        return userPreferences.pgUserPrefDTO.alias
    }
    
    func randomBackgroundId() -> Int {
        return Int.random(in: self.backgroundMinId...self.backgroundMaxId)
    }
    
    func getBackgroundThemeForUserId(_ userId: String?) -> BackgroundImagesTheme {
        guard let userPreferences = self.getUserPreferencesForUserId(userId) else { return self.defaultTheme }
        guard
            let themeId = userPreferences.pgUserPrefDTO.photoThemeOptionSelected,
            let theme = self.getBackgroundTheme(for: themeId)
            else { return self.defaultTheme }
        return theme
    }
    
    func getBackgroundType(_ theme: BackgroundImagesTheme) -> RememberedLoginBackgroundType {
        let randomId: Int = self.randomBackgroundId()
        if theme.isLocalTheme {
            return .assets(name: "\(theme.name)_\(randomId)")
        } else {
            let _: BackgroundImageManagerProtocol = self.dependenciesResolver.resolve()
            let getBackgroundImageRepositoryProtocol: GetBackgroundImageRepositoryProtocol = self.dependenciesResolver.resolve()
            let images: [Data] = getBackgroundImageRepositoryProtocol.get(theme.name)
            guard images.count > self.backgroundMaxId - self.backgroundMinId else {
                return self.getBackgroundType(self.defaultTheme)
            }
            let index: Int = randomId - backgroundMinId
            return .documents(data: images[index])
        }
    }
}

struct LoadRememberedLoginDataUseCaseOkOutput {
    let persistedUser: PersistedUserEntity?
    let type: SemanticSegmentTypeEntity
    let backgroundType: RememberedLoginBackgroundType
    let alias: String?
}

class LoadRememberedLoginDataUseCaseErrorOutput: StringErrorOutput {
    
}

enum RememberedLoginBackgroundType {
    case assets(name: String)
    case documents(data: Data)
}

private extension LoadRememberedLoginDataUseCase {
    
    var photoThemeModifier: PhotoThemeModifierProtocol? {
        return dependenciesResolver.resolve(forOptionalType: PhotoThemeModifierProtocol.self)
    }
    
    func getBackgroundTheme(for identifier: Int) -> BackgroundImagesTheme? {
        guard let theme = BackgroundImagesTheme(id: identifier) else {
            return photoThemeModifier?.getBackGroundImage(for: identifier)
        }
        return theme
    }
}
