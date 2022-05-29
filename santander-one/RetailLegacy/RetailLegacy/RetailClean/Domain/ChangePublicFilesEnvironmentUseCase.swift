//
// Created by Guillermo on 23/2/18.
// Copyright (c) 2018 Ciber. All rights reserved.
//

import Foundation
import CoreFoundationLib

class ChangePublicFilesEnvironmentUseCase: UseCase<ChangePublicFilesEnvironmentUseCaseInput, Void, ChangePublicFilesEnvironmentUseCaseErrorOutput> {
    private let appRepository: AppRepository
    private let appConfigRepository: AppConfigRepository
    private let segmentedUserRepository: SegmentedUserRepository
    private let accountDescriptorRepository: AccountDescriptorRepository

    init(appRepository: AppRepository,
         appConfigRepository: AppConfigRepository,
         segmentedUserRepository: SegmentedUserRepository,
         accountDescriptorRepository: AccountDescriptorRepository) {
        self.appRepository = appRepository
        self.appConfigRepository = appConfigRepository
        self.segmentedUserRepository = segmentedUserRepository
        self.accountDescriptorRepository = accountDescriptorRepository
    }

    override func executeUseCase(requestValues: ChangePublicFilesEnvironmentUseCaseInput) throws -> UseCaseResponse<Void, ChangePublicFilesEnvironmentUseCaseErrorOutput> {
        let publicFilesEnvironmentDTO = requestValues.publicFilesEnvironment.getPublicFilesEnvironment()
        let response: RepositoryResponse<Void> = appRepository.setPublicEnvironment(publicFilesEnvironmentDTO: publicFilesEnvironmentDTO)
        if response.isSuccess() {
            appConfigRepository.remove()
            segmentedUserRepository.remove()
            accountDescriptorRepository.remove()
            return UseCaseResponse.ok()
        }
        return UseCaseResponse.error(ChangePublicFilesEnvironmentUseCaseErrorOutput(try response.getErrorMessage()))
    }

}

struct ChangePublicFilesEnvironmentUseCaseInput {

    let publicFilesEnvironment: PublicFilesEnvironment

    init(publicFilesEnvironment: PublicFilesEnvironment) {
        self.publicFilesEnvironment = publicFilesEnvironment
    }
}

class ChangePublicFilesEnvironmentUseCaseErrorOutput: StringErrorOutput {

}
