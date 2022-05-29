//
//  GetCardOnOffPredefinedSCAUseCase.swift
//  Cards
//
//  Created by Iván Estévez Nieto on 8/9/21.
//

import Foundation
import CoreFoundationLib
import SANLegacyLibrary

public protocol GetCardOnOffPredefinedSCAUseCaseProtocol: UseCase<Void, GetCardOnOffPredefinedSCAUseCaseOkOutput, StringErrorOutput> {}

public struct GetCardOnOffPredefinedSCAUseCaseOkOutput {
    let predefinedSCAEntity: PredefinedSCAEntity?
    
    public init(predefinedSCAEntity: PredefinedSCAEntity?) {
        self.predefinedSCAEntity = predefinedSCAEntity
    }
}
