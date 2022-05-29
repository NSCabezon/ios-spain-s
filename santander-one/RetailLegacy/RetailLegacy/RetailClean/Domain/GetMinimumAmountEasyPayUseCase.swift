import Foundation
import CoreFoundationLib

import SANLegacyLibrary

class GetMinimumAmountEasyPayAmountUseCase: UseCase<Void, MinimumAmountEasyPayOkOutput, StringErrorOutput> {
    private let bsanManagersProvider: BSANManagersProvider
    private let defaultMinimimAmount = Double(60)
    
    init(bsanManagersProvider: BSANManagersProvider) {
        self.bsanManagersProvider = bsanManagersProvider
    }
    
    override public func executeUseCase(requestValues: Void) throws -> UseCaseResponse<MinimumAmountEasyPayOkOutput, StringErrorOutput> {
        return UseCaseResponse.ok(MinimumAmountEasyPayOkOutput(minimumAmount: defaultMinimimAmount))
    }
}

struct MinimumAmountEasyPayOkOutput {
    let minimumAmount: Double
}
