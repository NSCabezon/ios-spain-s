//
//  GetRememberedUserAliasUseCase.swift
//  Ecommerce
//
//  Created by César González Palomino on 21/04/2021.
//

import Foundation
import CoreFoundationLib

class GetRememberedUserNameUseCase: UseCase<Void, GetRememberedUserNameUseCaseOkOutput, StringErrorOutput> {
    private let dependenciesResolver: DependenciesResolver
    private let appRepository: AppRepositoryProtocol
    
    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
        self.appRepository = self.dependenciesResolver.resolve(for: AppRepositoryProtocol.self)
    }
    
    override func executeUseCase(requestValues: Void) throws -> UseCaseResponse<GetRememberedUserNameUseCaseOkOutput, StringErrorOutput> {
        let persistedUserResponse = appRepository.getPersistedUser()
        let user = try persistedUserResponse.getResponseData()
        let persistedUser = PersistedUserEntity(dto: user)
        return UseCaseResponse.ok(GetRememberedUserNameUseCaseOkOutput(userName: persistedUser?.name,
                                                                       loginType: persistedUser?.loginType?.metricsValue,
                                                                       login: persistedUser?.login))
    }
}

struct GetRememberedUserNameUseCaseOkOutput {
    let userName: String?
    let loginType: String?
    let login: String?
}
