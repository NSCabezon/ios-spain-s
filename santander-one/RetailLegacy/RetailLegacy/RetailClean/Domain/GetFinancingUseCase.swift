//
//  GetFinancingUseCase.swift
//  RetailClean
//
//  Created by Cristobal Ramos Laina on 09/07/2020.
//  Copyright © 2020 Ciber. All rights reserved.
//

import Foundation
import CoreFoundationLib


class GetFinancingUseCase: UseCase<Void, GetFinancingUseCaseOkOutput, StringErrorOutput> {

    private let appConfigRepository: AppConfigRepository

    init(appConfigRepository: AppConfigRepository) {
        self.appConfigRepository = appConfigRepository
    }

    override func executeUseCase(requestValues: Void) throws -> UseCaseResponse<GetFinancingUseCaseOkOutput, StringErrorOutput> {
        let financingEnabled = appConfigRepository.getBool("enableFinancingZone")
        return UseCaseResponse.ok(GetFinancingUseCaseOkOutput(financingEnabled: financingEnabled ?? false))
    }
}

struct GetFinancingUseCaseOkOutput {
    let financingEnabled: Bool
}
