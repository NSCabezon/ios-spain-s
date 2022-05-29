//
//  PredefinedSCAOnePayTransferUseCase.swift
//  RetailLegacy
//
//  Created by Jose Javier Montes Romero on 12/5/21.
//

import CoreFoundationLib
import Foundation
import SANLegacyLibrary

protocol PredefinedSCAOnePayTransferUseCaseProtocol: UseCase<Void, PredefinedSCAOnePayTransferUseCaseOkOutput, StringErrorOutput> {}

final class PredefinedSCAOnePayTransferUseCase: UseCase<Void, PredefinedSCAOnePayTransferUseCaseOkOutput, StringErrorOutput> {
    private let provider: BSANManagersProvider
    
    init(dependenciesResolver: DependenciesResolver) {
        self.provider = dependenciesResolver.resolve()
    }
    
    override func executeUseCase(requestValues: Void) throws -> UseCaseResponse<PredefinedSCAOnePayTransferUseCaseOkOutput, StringErrorOutput> {
        let response = self.provider.getBsanPredefineSCAManager()
            .getOnePayTransferPredefinedSCA()
        guard response.isSuccess(), let representable = try response.getResponseData() else {
            return .ok(PredefinedSCAOnePayTransferUseCaseOkOutput(predefinedSCAEntity: nil))
        }
        let predefinedSCAEntity = PredefinedSCAEntity(rawValue: representable.rawValue)
        return .ok(PredefinedSCAOnePayTransferUseCaseOkOutput(predefinedSCAEntity: predefinedSCAEntity))
    }
}

extension PredefinedSCAOnePayTransferUseCase: PredefinedSCAOnePayTransferUseCaseProtocol {}

struct PredefinedSCAOnePayTransferUseCaseOkOutput {
    let predefinedSCAEntity: PredefinedSCAEntity?
}
