//
//  GetPendingSolicitudesUseCase.swift
//  GlobalPosition
//
//  Created by José Carlos Estela Anguita on 01/04/2020.
//

import CoreFoundationLib
import SANLegacyLibrary
import Foundation

final class GetPendingSolicitudesUseCase: UseCase<Void, GetPendingSolicitudesUseCaseOutput, StringErrorOutput> {
    private let dependenciesResolver: DependenciesResolver
    private let provider: BSANManagersProvider
    
    public init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
        self.provider = self.dependenciesResolver.resolve(for: BSANManagersProvider.self)
    }
    
    override func executeUseCase(requestValues: Void) throws -> UseCaseResponse<GetPendingSolicitudesUseCaseOutput, StringErrorOutput> {
        let appConfig = self.dependenciesResolver.resolve(for: AppConfigRepositoryProtocol.self)
        let enableGlobalPositionPendingDocuments = appConfig.getBool("enableGlobalPositionPendingDocuments") ?? false
        guard enableGlobalPositionPendingDocuments == true else { return .error(StringErrorOutput(nil)) }
        let response = try provider.getBsanPendingSolicitudesManager().getPendingSolicitudes()
        guard response.isSuccess(), let data = try response.getResponseData() else {
            let errorDescription = try response.getErrorMessage()
            return .error(StringErrorOutput(errorDescription))
        }
        let appRepository = self.dependenciesResolver.resolve(for: AppRepositoryProtocol.self)
        let closed = try appRepository.getPendingSolicitudesClosed().getResponseData() ?? []
        let pendingSolicitudeListEntity = PendingSolicitudeListEntity(data)
        let pendingSolicitudes = pendingSolicitudeListEntity.pendingSolicitudes.filter({ !closed.contains($0) })
        return .ok(GetPendingSolicitudesUseCaseOutput(pendingSolicitudes: pendingSolicitudes))
    }
}

struct GetPendingSolicitudesUseCaseOutput {
    let pendingSolicitudes: [PendingSolicitudeEntity]
}
