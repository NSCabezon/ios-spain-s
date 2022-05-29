//
// Created by Guillermo on 23/2/18.
// Copyright (c) 2018 Ciber. All rights reserved.
//

import Foundation
import CoreFoundationLib

class GetPublicFilesEnvironmentsUseCase: UseCase<Void, GetPublicFilesEnvironmentsUseCaseOkOutput, GetPublicFilesEnvironmentsUseCaseErrorOutput> {

    private let appRepository: AppRepository

    init(appRepository: AppRepository) {
        self.appRepository = appRepository
    }

    override func executeUseCase(requestValues: Void) throws -> UseCaseResponse<GetPublicFilesEnvironmentsUseCaseOkOutput, GetPublicFilesEnvironmentsUseCaseErrorOutput> {
        let response = appRepository.getPublicFilesEnvironments()
        if response.isSuccess(), let publicFilesEnvironments = try response.getResponseData() {
            let okOutput = GetPublicFilesEnvironmentsUseCaseOkOutput(publicFilesEnvironments: publicFilesEnvironments.compactMap {
                PublicFilesEnvironment.createFrom(publicFilesEnvironment: $0)
            })
            return UseCaseResponse.ok(okOutput)
        }
        return UseCaseResponse.error(GetPublicFilesEnvironmentsUseCaseErrorOutput(try response.getErrorMessage()))
    }
}

class GetPublicFilesEnvironmentsUseCaseOkOutput {

    let publicFilesEnvironments: [PublicFilesEnvironment]

    init(publicFilesEnvironments: [PublicFilesEnvironment]) {
        self.publicFilesEnvironments = publicFilesEnvironments
    }
}

class GetPublicFilesEnvironmentsUseCaseErrorOutput: StringErrorOutput {

}
