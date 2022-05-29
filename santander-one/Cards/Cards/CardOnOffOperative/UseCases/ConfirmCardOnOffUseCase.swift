//
//  ConfirmCardOnOffUseCase.swift
//  Cards
//
//  Created by Iván Estévez Nieto on 31/8/21.
//

import Foundation
import CoreFoundationLib
import CoreDomain

public protocol ConfirmCardOnOffUseCaseProtocol: UseCase<ConfirmCardOnOffUseCaseInput, Void, GenericErrorSignatureErrorOutput> {}

public struct ConfirmCardOnOffUseCaseInput {
    public let card: CardEntity
    public let signature: SignatureRepresentable
    public let localState: CardBlockType
}
