//
// Created by Guillermo on 23/2/18.
// Copyright (c) 2018 Ciber. All rights reserved.
//

import Foundation
import CoreFoundationLib

class GetCurrentPublicFilesEnvironmentUseCase: UseCase<Void, GetCurrentPublicFilesEnvironmentUseCaseOkOutput, GetCurrentPublicFilesEnvironmentUseCaseErrorOutput> {

    private let appRepository: AppRepository

    init(appRepository: AppRepository) {
        self.appRepository = appRepository
    }

    override func executeUseCase(requestValues: Void) throws -> UseCaseResponse<GetCurrentPublicFilesEnvironmentUseCaseOkOutput, GetCurrentPublicFilesEnvironmentUseCaseErrorOutput> {
        let response = appRepository.getCurrentPublicFilesEnvironment()
        if response.isSuccess(), let publicFilesEnvironment = try response.getResponseData() {
            let okOutput = GetCurrentPublicFilesEnvironmentUseCaseOkOutput(publicFilesEnvironment: PublicFilesEnvironment.createFrom(publicFilesEnvironment: publicFilesEnvironment))
            return UseCaseResponse.ok(okOutput)
        }
        return UseCaseResponse.error(GetCurrentPublicFilesEnvironmentUseCaseErrorOutput(try response.getErrorMessage()))
    }
}

struct GetCurrentPublicFilesEnvironmentUseCaseOkOutput {

    let publicFilesEnvironment: PublicFilesEnvironment

    init(publicFilesEnvironment: PublicFilesEnvironment) {
        self.publicFilesEnvironment = publicFilesEnvironment
    }
}

class GetCurrentPublicFilesEnvironmentUseCaseErrorOutput: StringErrorOutput {

}
