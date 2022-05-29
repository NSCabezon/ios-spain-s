//
//  ValidateCardOnOffUseCase.swift
//  Cards
//
//  Created by Iván Estévez Nieto on 31/8/21.
//

import Foundation
import CoreFoundationLib
import SANLegacyLibrary
import CoreDomain

public protocol ValidateCardOnOffUseCaseProtocol: UseCase<ValidateCardOnOffUseCaseInput, ValidateCardOnOffUseCaseOkOutput, StringErrorOutput> {}

public struct ValidateCardOnOffUseCaseInput {
    public let card: CardEntity
    public let blockType: CardBlockType
}

public struct ValidateCardOnOffUseCaseOkOutput {
    let sca: SCAEntity
    
    public init(sca: SCAEntity) {
        self.sca = sca
    }
}
