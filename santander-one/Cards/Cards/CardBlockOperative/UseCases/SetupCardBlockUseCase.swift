//
//  SetupCardBlockUseCase.swift
//  Cards
//
//  Created by Laura González on 08/06/2021.
//

import Foundation
import SANLegacyLibrary
import CoreFoundationLib

protocol SetupCardBlockUseCaseProtocol: UseCase<Void, SetupCardBlockUseCaseOkOutput, StringErrorOutput> { }

final class SetupCardBlockUseCase: UseCase<Void, SetupCardBlockUseCaseOkOutput, StringErrorOutput> {
    
    private let provider: BSANManagersProvider
    
    init(dependenciesResolver: DependenciesResolver) {
        self.provider = dependenciesResolver.resolve()
    }
    
    override func executeUseCase(requestValues: Void) throws -> UseCaseResponse<SetupCardBlockUseCaseOkOutput, StringErrorOutput> {
        let response = self.provider.getBsanPredefineSCAManager()
            .getCardBlockPredefinedSCA()
        guard response.isSuccess(), let representable = try response.getResponseData() else {
            return .ok(SetupCardBlockUseCaseOkOutput(predefinedSCAEntity: nil))
        }
        let predefineSCAEntity = PredefinedSCAEntity(rawValue: representable.rawValue)
        return .ok(SetupCardBlockUseCaseOkOutput(predefinedSCAEntity: predefineSCAEntity))
    }
}

extension SetupCardBlockUseCase: SetupCardBlockUseCaseProtocol {}

struct SetupCardBlockUseCaseOkOutput {
    let predefinedSCAEntity: PredefinedSCAEntity?
}
