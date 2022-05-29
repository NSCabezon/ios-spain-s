//

import Foundation
import CoreFoundationLib
import CoreDomain

class CalculatePfmUseCase: UseCase<CalculatePfmUseCaseInput, CalculatePfmUseCaseOkOutput, StringErrorOutput> {
    override func executeUseCase(requestValues: CalculatePfmUseCaseInput) throws -> UseCaseResponse<CalculatePfmUseCaseOkOutput, StringErrorOutput> {
        let items = requestValues.pfmHelper.calcualtePfm(accounts: requestValues.accounts, cards: [], filter: [], months: requestValues.months)
        return UseCaseResponse.ok(CalculatePfmUseCaseOkOutput(monthsPfm: items))
    }
}

struct CalculatePfmUseCaseInput {
    let accounts: [AccountEntity]
    let months: Int
    let pfmHelper: PfmHelper
}

struct CalculatePfmUseCaseOkOutput {
    let monthsPfm: [MonthlyBalanceRepresentable]
}
