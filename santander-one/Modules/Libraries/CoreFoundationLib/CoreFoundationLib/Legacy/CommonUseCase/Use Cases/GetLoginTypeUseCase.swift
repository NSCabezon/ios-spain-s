//
//  GetLoginTypeUseCase.swift
//  QuickBalance
//
//  Created by Rubén Márquez Fernández on 21/4/21.
//

import SANLegacyLibrary

public final class GetLoginTypeUseCase: UseCase<Void, GetLoginTypeOkOutput, StringErrorOutput> {
    private let appRepository: AppRepositoryProtocol
    
    public init(dependenciesResolver: DependenciesResolver) {
        self.appRepository = dependenciesResolver.resolve()
    }
    
    override public func executeUseCase(requestValues: Void) throws -> UseCaseResponse<GetLoginTypeOkOutput, StringErrorOutput> {
        let response = appRepository.getPersistedUser()
        guard response.isSuccess(), let responseData = try response.getResponseData() else {
            return .error(StringErrorOutput(nil))
        }
        return .ok(GetLoginTypeOkOutput(responseData.loginType))
    }
}

public struct GetLoginTypeOkOutput {
    public let loginType: UserLoginType
    
    init(_ loginType: UserLoginType) {
        self.loginType = loginType
    }
    
}
