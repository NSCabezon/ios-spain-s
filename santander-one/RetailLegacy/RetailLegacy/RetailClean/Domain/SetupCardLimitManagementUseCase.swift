import Foundation
import SANLegacyLibrary
import CoreFoundationLib

class SetupCardLimitManagementUseCase: SetupUseCase<SetupCardLimitManagementUseCaseInput, SetupCardLimitManagementUseCaseOkOutput, StringErrorOutput> {
    
    override func executeUseCase(requestValues: SetupCardLimitManagementUseCaseInput) throws -> UseCaseResponse<SetupCardLimitManagementUseCaseOkOutput, StringErrorOutput> {
        let operativeConfig = try getOperativeConfig().getOkResult().operativeConfig
        
        guard requestValues.card != nil else {
            return UseCaseResponse.error(StringErrorOutput(nil))
        }
        
        return UseCaseResponse.ok(SetupCardLimitManagementUseCaseOkOutput(operativeConfig: operativeConfig))
    }
}

struct SetupCardLimitManagementUseCaseInput {
    let card: Card?
}

struct SetupCardLimitManagementUseCaseOkOutput: SetupUseCaseOkOutputProtocol {
    var operativeConfig: OperativeConfig
}
