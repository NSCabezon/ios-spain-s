//
//  CVVQueryPredefinedSCAUsecase.swift
//  Pods
//
//  Created by Juan Carlos López Robles on 6/26/21.
//
import CoreFoundationLib
import SANLegacyLibrary

protocol CVVQueryPredefinedSCAUsecaseProtocol: UseCase<Void, CVVQueryPredefinedSCAUsecaseOutput, StringErrorOutput> {}

final class CVVQueryPredefinedSCAUsecase: UseCase<Void, CVVQueryPredefinedSCAUsecaseOutput, StringErrorOutput> {
    let bsanProvider: BSANManagersProvider
    
    init(dependenciesResolver: DependenciesResolver) {
        self.bsanProvider = dependenciesResolver.resolve()
    }
    
    override func executeUseCase(requestValues: Void) throws -> UseCaseResponse<CVVQueryPredefinedSCAUsecaseOutput, StringErrorOutput> {
        let response = self.bsanProvider.getBsanPredefineSCAManager().getCVVQueryPredefinedSCA()
        guard response.isSuccess(), let representable = try response.getResponseData() else {
            return .ok(CVVQueryPredefinedSCAUsecaseOutput(predefinedSCAEntity: nil))
        }
        let predefineSCAEntity = PredefinedSCAEntity(rawValue: representable.rawValue)
        return .ok(CVVQueryPredefinedSCAUsecaseOutput(predefinedSCAEntity: predefineSCAEntity))
    }
}

extension CVVQueryPredefinedSCAUsecase: CVVQueryPredefinedSCAUsecaseProtocol {}
struct CVVQueryPredefinedSCAUsecaseOutput {
    let predefinedSCAEntity: PredefinedSCAEntity?
}
