//
//  PendingSolicitudeUseCase.swift
//  Models
//
//  Created by Juan Carlos López Robles on 1/16/20.
//

import Foundation
import CoreFoundationLib
import SANLegacyLibrary

final class GetPendingSolicitudesUseCase: UseCase<Void, GetPendingSolicitudesUseCaseOutput, StringErrorOutput> {
    private let dependenciesResolver: DependenciesResolver
    private let provider: BSANManagersProvider
    
    public init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
        self.provider = self.dependenciesResolver.resolve(for: BSANManagersProvider.self)
    }
    
    override func executeUseCase(requestValues: Void) throws -> UseCaseResponse<GetPendingSolicitudesUseCaseOutput, StringErrorOutput> {
        let response = try provider.getBsanPendingSolicitudesManager().getPendingSolicitudes()
        guard response.isSuccess(), let data = try response.getResponseData() else {
            let errorDescription = try response.getErrorMessage()
            return .error(StringErrorOutput(errorDescription))
        }
        
        let pendingSolicitudeListEntity = PendingSolicitudeListEntity(data)
        return .ok(GetPendingSolicitudesUseCaseOutput(response: pendingSolicitudeListEntity))
    }
}

struct GetPendingSolicitudesUseCaseOutput {
    let response: PendingSolicitudeListEntity
}
