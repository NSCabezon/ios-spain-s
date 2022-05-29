import Foundation
import CoreFoundationLib
import SANLegacyLibrary

class GetBSANCurrentEnvironmentUseCase: UseCase<Void, GetCurrentBSANEnvironmentUseCaseOkOutput, GetCurrentBSANEnvironmentUseCaseErrorOutput> {

    private let bsanManagersProvider: BSANManagersProvider
    private let appRepository: AppRepository

    init(bsanManagersProvider: BSANManagersProvider, appRepository: AppRepository) {
        self.bsanManagersProvider = bsanManagersProvider
        self.appRepository = appRepository
    }

    override func executeUseCase(requestValues: Void) throws -> UseCaseResponse<GetCurrentBSANEnvironmentUseCaseOkOutput, GetCurrentBSANEnvironmentUseCaseErrorOutput> {
        guard let publicFilesEnvironment = try appRepository.getCurrentPublicFilesEnvironment().getResponseData(),
              let bsanEnvironment = try bsanManagersProvider.getBsanEnvironmentsManager().getCurrentEnvironment().getResponseData() else {
            return UseCaseResponse.error(GetCurrentBSANEnvironmentUseCaseErrorOutput("Found a nil value at GetCurrentEnvironmentUseCase."))
        }
        return UseCaseResponse.ok(GetCurrentBSANEnvironmentUseCaseOkOutput(bsanEnvironment: BSANEnvironment(bsanEnvironment), publicFilesEnvironment: PublicFilesEnvironment.createFrom(publicFilesEnvironment: publicFilesEnvironment)))
    }

}

class GetCurrentBSANEnvironmentUseCaseOkOutput {

    let bsanEnvironment: BSANEnvironment
    let publicFilesEnvironment: PublicFilesEnvironment

    init(bsanEnvironment: BSANEnvironment, publicFilesEnvironment: PublicFilesEnvironment) {
        self.bsanEnvironment = bsanEnvironment
        self.publicFilesEnvironment = publicFilesEnvironment
    }
}

class GetCurrentBSANEnvironmentUseCaseErrorOutput: StringErrorOutput {

}
