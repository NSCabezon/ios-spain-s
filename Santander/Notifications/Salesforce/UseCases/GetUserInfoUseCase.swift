//
//  GetUserInfoUseCase.swift
//  Santander
//
//  Created by Boris Chirino Fernandez on 16/04/2021.
//
import CoreFoundationLib
import RetailLegacy

class GetUserInfoUseCase: UseCase<Void, GetInfoPushNotificationsUseCaseOKOutput, StringErrorOutput> {
    private let dependenciesResolver: DependenciesResolver

    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
    }
    
    override public func executeUseCase(requestValues: Void) throws -> UseCaseResponse<GetInfoPushNotificationsUseCaseOKOutput, StringErrorOutput> {
        let appRepositoryProtocol: AppRepositoryProtocol = dependenciesResolver.resolve(for: AppRepositoryProtocol.self)
        guard appRepositoryProtocol.getPersistedUser().isSuccess(), let user = try appRepositoryProtocol.getPersistedUser().getResponseData() else {
            return .error(StringErrorOutput(nil))
        }
        return UseCaseResponse.ok(GetInfoPushNotificationsUseCaseOKOutput(userId: user.userId ?? ""))
    }
}

struct GetInfoPushNotificationsUseCaseOKOutput {
    let userId: String?
}
