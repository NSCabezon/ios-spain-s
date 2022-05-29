//
//  GetManagerNotificationUseCase.swift
//  CommonUseCase
//
//  Created by alvola on 16/09/2020.
//

import SANLegacyLibrary

public final class GetManagerNotificationUseCase: UseCase<Void, GetManagerNotificationUseCaseOkOutput, StringErrorOutput> {
    private let dependenciesResolver: DependenciesResolver
    
    public init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
    }
    
    override public func executeUseCase(requestValues: Void) throws -> UseCaseResponse<GetManagerNotificationUseCaseOkOutput, StringErrorOutput> {
        let managersProvider = dependenciesResolver.resolve(for: BSANManagersProvider.self)
        let manager = managersProvider.getManagerNotificationsManager()
        let response = try manager.getManagerNotificationsInfo()
        guard response.isSuccess(), let managerNotificationsDTO = try response.getResponseData() else {
            let errorMessage = try response.getErrorMessage()
            return  UseCaseResponse.error(StringErrorOutput(errorMessage))
        }
        return .ok(GetManagerNotificationUseCaseOkOutput(hasNewNotifications: Int(managerNotificationsDTO.unreadMessages) ?? 0 > 0))
    }
}

public struct GetManagerNotificationUseCaseOkOutput {
    public let hasNewNotifications: Bool
}
