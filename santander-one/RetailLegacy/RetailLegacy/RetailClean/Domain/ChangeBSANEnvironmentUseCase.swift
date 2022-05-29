import Foundation
import CoreFoundationLib
import SANLegacyLibrary

class ChangeBSANEnvironmentUseCase: UseCase<ChangeBSANEnvironmentUseCaseInput, Void, ChangeBSANEnvironmentUseCaseErrorOutput> {
    private var netInsightRepository: NetInsightRepository
    private let bsanManagersProvider: BSANManagersProvider
    
    init(bsanManagersProvider: BSANManagersProvider, netInsightRepository: NetInsightRepository) {
        self.bsanManagersProvider = bsanManagersProvider
        self.netInsightRepository = netInsightRepository
    }

    override func executeUseCase(requestValues: ChangeBSANEnvironmentUseCaseInput) throws -> UseCaseResponse<Void, ChangeBSANEnvironmentUseCaseErrorOutput> {
        let response: BSANResponse<Void> = bsanManagersProvider.getBsanEnvironmentsManager().setEnvironment(bsanEnvironment: requestValues.bsanEnvironment.getBSANEnvironmentDTO())
        netInsightRepository.baseUrl = requestValues.bsanEnvironment.getBSANEnvironmentDTO().urlNetInsight
        if response.isSuccess() {
            return UseCaseResponse.ok()
        }
        return UseCaseResponse.error(ChangeBSANEnvironmentUseCaseErrorOutput(try response.getErrorMessage()))
    }
    
}

struct ChangeBSANEnvironmentUseCaseInput {

    let bsanEnvironment: BSANEnvironment

    init(bsanEnvironment: BSANEnvironment) {
        self.bsanEnvironment = bsanEnvironment
    }
}

class ChangeBSANEnvironmentUseCaseErrorOutput: StringErrorOutput {
    
}
