//
// Created by SYS_CIBER_ADMIN on 13/4/18.
// Copyright (c) 2018 Ciber. All rights reserved.
//

import Foundation
import CoreFoundationLib
import SANLegacyLibrary

class GetPersonalManagersUseCase: UseCase<Void, GetPersonalManagersUseCaseOkOutput, GetPersonalManagersUseCaseErrorOutput> {

    let bsanManagersProvider: BSANManagersProvider
    let appConfigRepository: AppConfigRepository

    init(bsanManagersProvider: BSANManagersProvider, appConfigRepository: AppConfigRepository) {
        self.bsanManagersProvider = bsanManagersProvider
        self.appConfigRepository = appConfigRepository
        super.init()
    }

    override func executeUseCase(requestValues: Void) throws -> UseCaseResponse<GetPersonalManagersUseCaseOkOutput, GetPersonalManagersUseCaseErrorOutput> {
        switch try getManagers() {
        case .success(let managers):
            return UseCaseResponse.ok(GetPersonalManagersUseCaseOkOutput(managerList: managers))
        case .failure(let errorMessage):
            return UseCaseResponse.error(GetPersonalManagersUseCaseErrorOutput(errorMessage))
        }
    }
}

extension GetPersonalManagersUseCase: UserManagersGetter {}

struct GetPersonalManagersUseCaseOkOutput {
    let managerList: ManagerList
}

class GetPersonalManagersUseCaseErrorOutput: StringErrorOutput {
}
