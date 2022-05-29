//
//  GetLoginErrorLinksUseCase.swift
//  Login
//
//  Created by Juan Carlos López Robles on 11/19/20.
//
import Foundation
import CoreFoundationLib
import SANLibraryV3

public final class GetLoginErrorLinksUseCase: UseCase<Void, GetLoginErrorLinksUseCaseOkOutput, StringErrorOutput> {
    private let appConfig: AppConfigRepositoryProtocol
    
    public init(dependenciesResolver: DependenciesResolver) {
        self.appConfig = dependenciesResolver.resolve(for: AppConfigRepositoryProtocol.self)
    }
    
    public override func executeUseCase(requestValues: Void) throws -> UseCaseResponse<GetLoginErrorLinksUseCaseOkOutput, StringErrorOutput> {
        let obtainKeysUrl: String? = appConfig.getString(LoginConstants.appConfigObtainKeysUrl)
        let recoverKeysUrl: String? = appConfig.getString(LoginConstants.appConfigRecoverKeysUrl)
        return UseCaseResponse.ok(GetLoginErrorLinksUseCaseOkOutput(obtainKeysUrl: obtainKeysUrl, recoverKeysUrl: recoverKeysUrl))
    }
}

public struct GetLoginErrorLinksUseCaseOkOutput {
    let obtainKeysUrl: String?
    let recoverKeysUrl: String?
    
    public init(obtainKeysUrl: String?, recoverKeysUrl: String?) {
        self.obtainKeysUrl = obtainKeysUrl
        self.recoverKeysUrl = recoverKeysUrl
    }
}
