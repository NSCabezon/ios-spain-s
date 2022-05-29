//
//  GetAppInfoUseCase.swift
//  PersonalArea
//
//  Created by alvola on 22/04/2020.
//

public protocol GetAppInfoUseCaseProtocol: UseCase<Void, GetAppInfoOkOutput, StringErrorOutput> {}

public final class GetAppInfoUseCase: UseCase<Void, GetAppInfoOkOutput, StringErrorOutput>, GetAppInfoUseCaseProtocol {
    
    private let appInfoRepository: AppInfoRepositoryProtocol
    private let dependenciesResolver: DependenciesResolver
    
    public init(dependenciesResolver: DependenciesResolver) {
        self.appInfoRepository = dependenciesResolver.resolve()
        self.dependenciesResolver = dependenciesResolver
    }
    
    override public func executeUseCase(requestValues: Void) throws -> UseCaseResponse<GetAppInfoOkOutput, StringErrorOutput> {

        let appRepository: AppRepositoryProtocol = self.dependenciesResolver.resolve(for: AppRepositoryProtocol.self)
        
        guard let urlBase = try appRepository.getCurrentPublicFilesEnvironment().getResponseData()?.urlBase else {
            return UseCaseResponse.error(StringErrorOutput(nil))
        }
        
        let languageType = appRepository.getCurrentLanguage()
        appInfoRepository.load(baseUrl: urlBase, publicLanguage: languageType.getPublicLanguage)
        
        let appInfo = appInfoRepository.getAppInfo() ?? AppVersionsInfoDTO(versions: [:])

        return UseCaseResponse.ok(GetAppInfoOkOutput(appInfo: appInfo))
    }
}

public struct GetAppInfoOkOutput {
    public let appInfo: AppVersionsInfoDTO
}
