//
//  SpainGetCardOnOffPredefinedSCAUseCase.swift
//  Santander
//
//  Created by Iván Estévez Nieto on 8/9/21.
//

import Foundation
import Cards
import SANLegacyLibrary
import CoreFoundationLib

final class SpainGetCardOnOffPredefinedSCAUseCase: UseCase<Void, GetCardOnOffPredefinedSCAUseCaseOkOutput, StringErrorOutput> {

    override func executeUseCase(requestValues: Void) throws -> UseCaseResponse<GetCardOnOffPredefinedSCAUseCaseOkOutput, StringErrorOutput> {
        return .ok(GetCardOnOffPredefinedSCAUseCaseOkOutput(predefinedSCAEntity: .signature))
    }
}

extension SpainGetCardOnOffPredefinedSCAUseCase: GetCardOnOffPredefinedSCAUseCaseProtocol {}
