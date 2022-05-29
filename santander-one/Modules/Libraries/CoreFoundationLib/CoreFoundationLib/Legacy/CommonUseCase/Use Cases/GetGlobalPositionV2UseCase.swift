//
//  GetGlobalPositionV2UseCase.swift
//  CommonUseCase
//
//  Created by Juan Carlos López Robles on 2/28/20.
//
import Foundation
import SANLegacyLibrary

public class GetGlobalPositionV2UseCase: UseCase<Void, Void, StringErrorOutput> {
    private let dependenciesResolver: DependenciesResolver
    private let provider: BSANManagersProvider
    
    public init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
        self.provider = self.dependenciesResolver.resolve(for: BSANManagersProvider.self)
    }
    
    public override func executeUseCase(requestValues: Void) throws -> UseCaseResponse<Void, StringErrorOutput> {
        let globalPosition = dependenciesResolver.resolve(for: GlobalPositionRepresentable.self)
        let response = try provider.getBsanPGManager().loadGlobalPositionV2(onlyVisibleProducts: true, isPB: globalPosition.isPb ?? false)
        guard response.isSuccess() else {
            let errorDescription = try response.getErrorMessage()
            return .error(StringErrorOutput(errorDescription))
        }
        return .ok()
    }
}
