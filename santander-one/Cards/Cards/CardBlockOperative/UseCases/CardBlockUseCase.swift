//
//  CardBlockUseCase.swift
//  Cards
//
//  Created by Iván Estévez Nieto on 1/6/21.
//

import Foundation
import CoreFoundationLib
import CoreDomain

public protocol CardBlockUseCaseProtocol: UseCase<CardBlockUseCaseInput, CardBlockUseCaseOkOutput, StringErrorOutput> { }

public struct CardBlockUseCaseInput {
    public let card: CardEntity
    public let blockType: CardBlockType
    public let blockText: String
    
    public init(card: CardEntity, blockType: CardBlockType, blockText: String) {
        self.card = card
        self.blockType = blockType
        self.blockText = blockText
    }
}

public struct CardBlockUseCaseOkOutput {
    let scaEntity: SCAEntity?
    let residentialAddress: String?
    
    public init(scaEntity: SCAEntity?, residentialAddress: String?) {
        self.scaEntity = scaEntity
        self.residentialAddress = residentialAddress
    }
}
