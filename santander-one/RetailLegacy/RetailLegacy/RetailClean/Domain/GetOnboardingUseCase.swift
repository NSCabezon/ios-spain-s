//
//  GetOnboardingUseCase.swift
//  RetailClean
//
//  Created by David Gálvez Alonso on 16/12/2019.
//  Copyright © 2019 Ciber. All rights reserved.
//

import Foundation
import CoreFoundationLib
import SANLegacyLibrary

final class GetOnboardingUseCase: UseCase<Void, GetOnboardingUseCaseOkOutput, StringErrorOutput> {

    private let appRepository: AppRepository
    private let bsanManagersProvider: BSANManagersProvider
    private var accountDescriptorRepository: AccountDescriptorRepository
    private let appConfigRepository: AppConfigRepository
    private let compilation: CompilationProtocol
    
    private let dependencies: PresentationComponent

    private var isTouchIdEnabled: Bool {
        let touchIdData = KeychainWrapper().touchIdData(compilation: compilation)
        return touchIdData?.touchIDLoginEnabled ?? false
    }
    
    private var isLocationAccessEnabled: Bool {
        return dependencies.locationManager.locationServicesStatus() == .authorized
    }
    
    init(bsanManagersProvider: BSANManagersProvider, appRepository: AppRepository, accountDescriptorRepository: AccountDescriptorRepository, appConfigRepository: AppConfigRepository, dependencies: PresentationComponent) {
        self.appRepository = appRepository
        self.bsanManagersProvider = bsanManagersProvider
        self.accountDescriptorRepository = accountDescriptorRepository
        self.appConfigRepository = appConfigRepository
        self.dependencies = dependencies
        self.compilation = dependencies.useCaseProvider.dependenciesResolver.resolve(for: CompilationProtocol.self)
    }

    override func executeUseCase(requestValues: Void) throws -> UseCaseResponse<GetOnboardingUseCaseOkOutput, StringErrorOutput> {
        
        //GlobalPositionWrapper & UserPrefs
        let merger = try GlobalPositionPrefsMerger(bsanManagersProvider: bsanManagersProvider, appRepository: appRepository, accountDescriptorRepository: accountDescriptorRepository, appConfigRepository: appConfigRepository).merge()
        guard let globalPositionWrapper = merger.globalPositionWrapper else {
            return UseCaseResponse.error(StringErrorOutput(nil))
        }
        let loginType = try? self.appRepository.getPersistedUser().getResponseData()?.loginType
        let userPrefEntity = appRepository.getUserPreferences(userId: globalPositionWrapper.userId)
        let list = self.dependencies.localAppConfig.languageList
        let current: Language
        let response = appRepository.getLanguage()
        let responseUser = appRepository.getPersistedUser()
        let user = try responseUser.getResponseData()
        if let data = try response.getResponseData(), let languageType = data {
            current = Language.createFromType(languageType: languageType, isPb: user?.isPb)
        } else {
            let defaultLanguage = self.dependencies.localAppConfig.language
            let languageList = self.dependencies.localAppConfig.languageList
            current = Language.createDefault(isPb: user?.isPb, defaultLanguage: defaultLanguage, availableLanguageList: languageList)
        }
        let permissionsStatusWrapper: PermissionsStatusWrapperProtocol = self.dependencies.useCaseProvider.dependenciesResolver.resolve(for: PermissionsStatusWrapperProtocol.self)
        let result: [FirstBoardingPermissionTypeItem] = permissionsStatusWrapper.getPermissions()
        return UseCaseResponse.ok(GetOnboardingUseCaseOkOutput(globalPosition: globalPositionWrapper,
                                                               userPrefEntity: UserPrefEntity.from(dto: userPrefEntity),
                                                               current: current,
                                                               loginType: loginType,
                                                               list: list,
                                                               items: result))
    }
}

struct GetOnboardingUseCaseOkOutput {

    let globalPosition: GlobalPositionWrapper
    let userPrefEntity: UserPrefEntity?
    let current: Language
    let loginType: UserLoginType?
    let list: [LanguageType]
    let items: [FirstBoardingPermissionTypeItem]
    
    init(globalPosition: GlobalPositionWrapper, userPrefEntity: UserPrefEntity?, current: Language, loginType: UserLoginType?, list: [LanguageType], items: [FirstBoardingPermissionTypeItem]) {
        self.globalPosition = globalPosition
        self.userPrefEntity = userPrefEntity
        self.current = current
        self.loginType = loginType
        self.list = list
        self.items = items
    }
}
