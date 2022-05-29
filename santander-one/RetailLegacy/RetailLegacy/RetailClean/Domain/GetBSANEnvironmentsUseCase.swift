import Foundation
import CoreFoundationLib
import SANLegacyLibrary

class GetBSANEnvironmentsUseCase: UseCase<Void, GetBSANEnvironmentsUseCaseOkOutput, GetBSANEnvironmentsUseCaseErrorOutput> {
    
    private let bsanManagersProvider: BSANManagersProvider
    
    init(bsanManagersProvider: BSANManagersProvider) {
        self.bsanManagersProvider = bsanManagersProvider
    }

    override func executeUseCase(requestValues: Void) throws -> UseCaseResponse<GetBSANEnvironmentsUseCaseOkOutput, GetBSANEnvironmentsUseCaseErrorOutput> {
        let response: BSANResponse<[BSANEnvironmentDTO]> = bsanManagersProvider.getBsanEnvironmentsManager().getEnvironments()
        if response.isSuccess(), let bsanEnvironments = try response.getResponseData() {
            let okOutput = GetBSANEnvironmentsUseCaseOkOutput(bsanEnvironments: bsanEnvironments.compactMap {
                BSANEnvironment($0)
            })
            return UseCaseResponse.ok(okOutput)
        }
        return UseCaseResponse.error(GetBSANEnvironmentsUseCaseErrorOutput(try response.getErrorMessage()))
    }
}

struct GetBSANEnvironmentsUseCaseOkOutput {

    let bsanEnvironments: [BSANEnvironment]

    init(bsanEnvironments: [BSANEnvironment]) {
        self.bsanEnvironments = bsanEnvironments
    }
}

class GetBSANEnvironmentsUseCaseErrorOutput: StringErrorOutput {
    
}
