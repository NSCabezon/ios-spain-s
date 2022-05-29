//
//  GetAppVersionUseCase.swift
//  GlobalPosition
//
//  Created by Laura González on 06/07/2020.
//

import CoreFoundationLib

class GetAppVersionUseCase: UseCase<Void, GetAppVersionOkOutput, StringErrorOutput> {
    private let dependenciesResolver: DependenciesResolver
    private let appInfoRepository: AppInfoRepositoryProtocol
    private let appRepository: AppRepositoryProtocol
    
    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
        self.appInfoRepository = dependenciesResolver.resolve()
        self.appRepository = dependenciesResolver.resolve()
    }
    
    override public func executeUseCase(requestValues: Void) throws -> UseCaseResponse<GetAppVersionOkOutput, StringErrorOutput> {
        if let urlBase = try appRepository.getCurrentPublicFilesEnvironment().getResponseData()?.urlBase {
            let languageType: LanguageType
            if let response = try appRepository.getLanguage().getResponseData(), let type = response {
                languageType = type
            } else {
                let defaultLanguage = self.dependenciesResolver.resolve(for: LocalAppConfig.self).language
                let languageList = self.dependenciesResolver.resolve(for: LocalAppConfig.self).languageList
                languageType = Language.createDefault(isPb: nil, defaultLanguage: defaultLanguage, availableLanguageList: languageList).languageType
            }
            self.appInfoRepository.load(baseUrl: urlBase, publicLanguage: languageType.getPublicLanguage)
        }
        let appInfo = appInfoRepository.getAppInfo() ?? AppVersionsInfoDTO(versions: [:])
        return UseCaseResponse.ok(GetAppVersionOkOutput(appInfo: appInfo))
    }
}

struct GetAppVersionOkOutput {
    let appInfo: AppVersionsInfoDTO
}
