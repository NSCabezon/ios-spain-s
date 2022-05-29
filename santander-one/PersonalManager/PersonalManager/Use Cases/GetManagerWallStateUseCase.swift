//
//  GetManagerWallStateUseCase.swift
//  PersonalManager
//
//  Created by alvola on 18/09/2020.
//

import CoreFoundationLib
import SANLegacyLibrary

final class GetManagerWallStateUseCase: UseCase<Void, LoadPersonalWithManagerUseCaseOkOutput, StringErrorOutput> {
    
    private let appConfigRepository: AppConfigRepositoryProtocol
    
    init(dependenciesResolver: DependenciesResolver) {
        self.appConfigRepository = dependenciesResolver.resolve(for: AppConfigRepositoryProtocol.self)
    }
    
    override func executeUseCase(requestValues: Void) throws -> UseCaseResponse<LoadPersonalWithManagerUseCaseOkOutput, StringErrorOutput> {
        let managerWallEnabled = appConfigRepository.getBool("enableManagerWall") ?? false
        let managerWallVersion = appConfigRepository.getInt("managerWallVersion") ?? 0
        let enableSidebarManagerNotifications = appConfigRepository.getBool("enableSidebarManagerNotifications") ?? false
        
        return UseCaseResponse.ok(LoadPersonalWithManagerUseCaseOkOutput(managerWallEnabled: managerWallEnabled,
                                                                         managerWallVersion: managerWallVersion,
                                                                         enableManagerNotifications: enableSidebarManagerNotifications))
    }
}

struct LoadPersonalWithManagerUseCaseOkOutput {
    let managerWallEnabled: Bool
    let managerWallVersion: Int
    let enableManagerNotifications: Bool
}
