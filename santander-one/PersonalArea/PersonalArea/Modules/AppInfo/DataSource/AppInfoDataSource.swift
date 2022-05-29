//
//  AppInfoDataSource.swift
//  PersonalArea
//
//  Created by alvola on 22/04/2020.
//

import CoreFoundationLib

protocol AppInfoDataSourceProtocol: AnyObject {
    func getAppInfo(_ completion: @escaping (AppVersionsInfoDTO) -> Void)
}

final class AppInfoDataSource: AppInfoDataSourceProtocol {
    
    private var dependenciesEngine: DependenciesDefault
    
    init(dependenciesEngine: DependenciesResolver) {
        self.dependenciesEngine = DependenciesDefault(father: dependenciesEngine)
        self.setupDependencies()
    }
    
    private var useCaseHandler: UseCaseHandler {
        return self.dependenciesEngine.resolve(for: UseCaseHandler.self)
    }
    
    private func setupDependencies() {
        self.dependenciesEngine.register(for: GetAppInfoUseCaseProtocol.self) { dependenciesResolver in
            return GetAppInfoUseCase(dependenciesResolver: dependenciesResolver)
        }
    }
    
    func getAppInfo(_ completion: @escaping (AppVersionsInfoDTO) -> Void) {
        let useCase: GetAppInfoUseCaseProtocol = self.dependenciesEngine.resolve(for: GetAppInfoUseCaseProtocol.self)
        let useCaseHandler: UseCaseHandler = dependenciesEngine.resolve(for: UseCaseHandler.self)
        UseCaseWrapper(with: useCase, useCaseHandler: useCaseHandler, onSuccess: { resp in
            completion(resp.appInfo)
        })
    }
}
