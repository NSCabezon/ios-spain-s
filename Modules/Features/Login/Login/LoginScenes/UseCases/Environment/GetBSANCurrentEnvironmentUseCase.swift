//
//  GetBSANCurrentEnvironmentUseCase.swift
//  Pods
//
//  Created by Juan Carlos López Robles on 11/26/20.
//
import Foundation
import CoreFoundationLib
import SANLibraryV3

class GetBSANCurrentEnvironmentUseCase: UseCase<Void, GetCurrentBSANEnvironmentUseCaseOkOutput, GetCurrentBSANEnvironmentUseCaseErrorOutput> {
    private let bsanManagersProvider: BSANManagersProvider
    private let appRepository: AppRepositoryProtocol

    init(dependenciesResolver: DependenciesResolver) {
        self.bsanManagersProvider = dependenciesResolver.resolve(for: BSANManagersProvider.self)
        self.appRepository = dependenciesResolver.resolve(for: AppRepositoryProtocol.self)
    }

    override func executeUseCase(requestValues: Void) throws -> UseCaseResponse<GetCurrentBSANEnvironmentUseCaseOkOutput, GetCurrentBSANEnvironmentUseCaseErrorOutput> {
        guard let publicFilesEnvironmentDto = try appRepository.getCurrentPublicFilesEnvironment().getResponseData(),
              let bsanEnvironmentDto = try bsanManagersProvider.getBsanEnvironmentsManager().getCurrentEnvironment().getResponseData() else {
            return UseCaseResponse.error(GetCurrentBSANEnvironmentUseCaseErrorOutput("Found a nil value at GetCurrentEnvironmentUseCase."))
        }
        let publicFilesEnvironmentEntity = PublicFilesEnvironmentEntity(publicFilesEnvironmentDto)
        let bsanEnvironmentEntity = EnvironmentEntity(bsanEnvironmentDto)
        return UseCaseResponse.ok(GetCurrentBSANEnvironmentUseCaseOkOutput(bsanEnvironment: bsanEnvironmentEntity, publicFilesEnvironment: publicFilesEnvironmentEntity))
    }
}

class GetCurrentBSANEnvironmentUseCaseOkOutput {
    let bsanEnvironment: EnvironmentEntity
    let publicFilesEnvironment: PublicFilesEnvironmentEntity

    init(bsanEnvironment: EnvironmentEntity, publicFilesEnvironment: PublicFilesEnvironmentEntity) {
        self.bsanEnvironment = bsanEnvironment
        self.publicFilesEnvironment = publicFilesEnvironment
    }
}

class GetCurrentBSANEnvironmentUseCaseErrorOutput: StringErrorOutput { }
