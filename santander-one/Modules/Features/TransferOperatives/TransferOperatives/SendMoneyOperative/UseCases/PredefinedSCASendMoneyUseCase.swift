//
//  PredefinedSCASendMoneyUseCase.swift
//  Transfer
//
//  Created by David Gálvez Alonso on 21/07/2021.
//

import CoreFoundationLib
import SANLegacyLibrary

protocol PredefinedSCASendMoneyUseCaseProtocol: UseCase<Void, PredefinedSCAOnePayTransferUseCaseOkOutput, StringErrorOutput> {}

final class PredefinedSCASendMoneyUseCase: UseCase<Void, PredefinedSCAOnePayTransferUseCaseOkOutput, StringErrorOutput> {
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

extension PredefinedSCASendMoneyUseCase: PredefinedSCASendMoneyUseCaseProtocol {}

struct PredefinedSCAOnePayTransferUseCaseOkOutput {
    let predefinedSCAEntity: PredefinedSCAEntity?
}
