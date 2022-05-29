//
// Created by SYS_CIBER_ADMIN on 13/4/18.
// Copyright (c) 2018 Ciber. All rights reserved.
//

import Foundation
import SANLegacyLibrary

class LoadManagersUseCase: UseCase<Void, Void, StringErrorOutput> {

    private let bsanManagersProvider: BSANManagersProvider

    init(dependenciesResolver: DependenciesResolver) {
        self.bsanManagersProvider = dependenciesResolver.resolve()
    }

    override func executeUseCase(requestValues: Void) throws -> UseCaseResponse<Void, StringErrorOutput> {
        let bsanManagersManager = bsanManagersProvider.getBsanManagersManager()
        let bsanResponse = try bsanManagersManager.loadManagers()
        if bsanResponse.isSuccess() {
            return UseCaseResponse.ok()
        }
        return UseCaseResponse.error(StringErrorOutput(try bsanResponse.getErrorMessage()))
    }

}
