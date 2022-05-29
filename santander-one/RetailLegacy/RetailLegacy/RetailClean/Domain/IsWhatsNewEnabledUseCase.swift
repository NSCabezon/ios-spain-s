//
//  IsWhatsNewEnabledUseCase.swift
//  RetailClean
//
//  Created by David Gálvez Alonso on 18/09/2020.
//  Copyright © 2020 Ciber. All rights reserved.
//

import CoreFoundationLib

class IsWhatsNewEnabledUseCase: UseCase<Void, IsWhatsNewEnabledUseCaseOkOutput, StringErrorOutput> {
    private let appConfigRepository: AppConfigRepository
    
    init(appConfigRepository: AppConfigRepository) {
        self.appConfigRepository = appConfigRepository
    }
    
    override func executeUseCase(requestValues: Void) throws -> UseCaseResponse<IsWhatsNewEnabledUseCaseOkOutput, StringErrorOutput> {
        let isEnabled: Bool? = appConfigRepository.getAppConfigBooleanNode(nodeName: DomainConstant.enabledWhatsNew)
        return UseCaseResponse.ok(IsWhatsNewEnabledUseCaseOkOutput(isEnabled: isEnabled ?? false))
    }
}

struct IsWhatsNewEnabledUseCaseOkOutput {
    let isEnabled: Bool
}
