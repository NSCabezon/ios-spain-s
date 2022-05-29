//
//  LoadCMPSUseCase.swift
//  Session
//
//  Created by José Carlos Estela Anguita on 15/9/21.
//

import Foundation
import SANLegacyLibrary

final class LoadCMPSUseCase: UseCase<Void, Void, StringErrorOutput> {
    
    private let dependenciesResolver: DependenciesResolver

    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
    }
    
    override func executeUseCase(requestValues: Void) throws -> UseCaseResponse<Void, StringErrorOutput> {
        let manager = dependenciesResolver.resolve(for: BSANManagersProvider.self).getBsanSendMoneyManager()
        let response = try manager.loadCMPSStatus()
        guard response.isSuccess() else { return .error(StringErrorOutput(try response.getErrorMessage())) }
        return .ok()
    }
}
