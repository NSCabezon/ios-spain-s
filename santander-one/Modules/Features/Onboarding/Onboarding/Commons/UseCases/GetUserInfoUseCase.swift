//
//  GetUserInfoUseCase.swift
//  Pods
//
//  Created by Jose Ignacio de Juan Díaz on 2/12/21.
//

import Foundation
import OpenCombine
import CoreDomain
import RxCombine
import CoreFoundationLib

protocol GetUserInfoUseCase {
    func fetch() -> AnyPublisher<OnboardingUserInfoRepresentable, Error>
}

class DefaultGetUserInfoUseCase {
    private let onboardingRepository: OnboardingRepository
    private let userPreferencesRepository: UserPreferencesRepository
    private typealias CombinedInfo = (onboardingInfo: OnboardingInfoRepresentable, userPreferencesInfo: UserPreferencesRepresentable)
    
    init(dependencies: OnboardingCommonExternalDependenciesResolver) {
        self.onboardingRepository = dependencies.resolve()
        self.userPreferencesRepository = dependencies.resolve()
    }
}

extension DefaultGetUserInfoUseCase: GetUserInfoUseCase {
    func fetch() -> AnyPublisher<OnboardingUserInfoRepresentable, Error> {
        onboardingRepository.getOnboardingInfo()
            .flatMap(mapOnboardingInfo)
            .map(mapUserInfo)
            .eraseToAnyPublisher()
    }
}

private extension DefaultGetUserInfoUseCase {
    struct GetUserInfoError: Error {}
    
    struct OnboardingUserInfo: OnboardingUserInfoRepresentable {
        let id: String
        let name: String
        var alias: String?
        var globalPosition: GlobalPositionOptionEntity
        var pgColorMode: PGColorMode
        var photoTheme: Int?
    }
    
    private func mapOnboardingInfo(_ onboardingInfo: OnboardingInfoRepresentable) -> AnyPublisher<CombinedInfo, Error> {
        self.userPreferencesRepository.getUserPreferences(userId: onboardingInfo.identifier)
            .first()
            .map { output in
                return (onboardingInfo, output)
            }
            .eraseToAnyPublisher()
    }
    
    private func mapUserInfo(_ combinedInfo: CombinedInfo) -> OnboardingUserInfo {
        OnboardingUserInfo(id: combinedInfo.onboardingInfo.identifier,
                           name: combinedInfo.onboardingInfo.name,
                           alias: combinedInfo.userPreferencesInfo.getUserAlias() ?? "",
                           globalPosition: combinedInfo.userPreferencesInfo.globalPositionOnboardingSelected(),
                           pgColorMode: combinedInfo.userPreferencesInfo.getPGColorMode(),
                           photoTheme: combinedInfo.userPreferencesInfo.photoThemeOnboardingSelected()
        )
    }
}
