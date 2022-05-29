import Foundation
import CoreFoundationLib
import SANLegacyLibrary

class OldGetMinEasyPayAmountUseCase: UseCase<Void, GetMinEasyPayAmountUseCaseOkOutput, StringErrorOutput> {
    private let defaultMinimimAmount = Double(60)
        
    override func executeUseCase(requestValues: Void) throws -> UseCaseResponse<GetMinEasyPayAmountUseCaseOkOutput, StringErrorOutput> {
        return .ok(GetMinEasyPayAmountUseCaseOkOutput(minimumAmount: defaultMinimimAmount))
    }
}

struct GetMinEasyPayAmountUseCaseOkOutput {
    let minimumAmount: Double
}
