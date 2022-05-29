//
//  GetInsuranceBillEmittersUseCase.swift
//  RetailLegacy
//
//  Created by César González Palomino on 6/9/21.
//

import Foundation
import CoreFoundationLib


class GetInsuranceBillEmittersUseCase: UseCase<Void, GetInsuranceBillEmittersOkOutput, StringErrorOutput> {

    private let appConfigRepository: AppConfigRepository

    init(appConfigRepository: AppConfigRepository) {
        self.appConfigRepository = appConfigRepository
    }
    
    override func executeUseCase(requestValues: Void) throws -> UseCaseResponse<GetInsuranceBillEmittersOkOutput, StringErrorOutput> {
        let insuranceBillEmitters = appConfigRepository.getAppConfigListNode("insuranceBillEmitters") ?? []
        return UseCaseResponse.ok(GetInsuranceBillEmittersOkOutput(insuranceBillEmitters: insuranceBillEmitters))
    }
}

struct GetInsuranceBillEmittersOkOutput {
    let insuranceBillEmitters: [String]
}
