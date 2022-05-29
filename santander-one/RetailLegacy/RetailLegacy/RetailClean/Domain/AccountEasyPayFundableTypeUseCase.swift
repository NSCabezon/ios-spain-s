import Foundation
import CoreFoundationLib
import SANLegacyLibrary

class AccountEasyPayFundableTypeUseCase: UseCase<AccountEasyPayFundableTypeUseCaseInput, AccountEasyPayFundableTypeUseCaseOkOutput, StringErrorOutput> {
    
    override func executeUseCase(requestValues: AccountEasyPayFundableTypeUseCaseInput) throws -> UseCaseResponse<AccountEasyPayFundableTypeUseCaseOkOutput, StringErrorOutput> {
        return .ok(AccountEasyPayFundableTypeUseCaseOkOutput(accountEasyPayFundableType: easyPayFundableType(for: requestValues.amount.entity, accountEasyPay: requestValues.accountEasyPay)))
    }
}

extension AccountEasyPayFundableTypeUseCase: AccountEasyPayChecker {}

struct AccountEasyPayFundableTypeUseCaseInput {
    let amount: Amount
    let accountEasyPay: AccountEasyPay
}

struct AccountEasyPayFundableTypeUseCaseOkOutput {
    let accountEasyPayFundableType: AccountEasyPayFundableType
}
