import SANLegacyLibrary

public final class AccountEasyPayFundableTypeUseCase: UseCase<AccountEasyPayFundableTypeUseCaseInput, AccountEasyPayFundableTypeUseCaseOkOutput, StringErrorOutput> {
    public override func executeUseCase(requestValues: AccountEasyPayFundableTypeUseCaseInput) throws -> UseCaseResponse<AccountEasyPayFundableTypeUseCaseOkOutput, StringErrorOutput> {
        return .ok(AccountEasyPayFundableTypeUseCaseOkOutput(accountEasyPayFundableType: easyPayFundableType(for: requestValues.amount, accountEasyPay: requestValues.accountEasyPay)))
    }
}

extension AccountEasyPayFundableTypeUseCase: AccountEasyPayChecker {}

public struct AccountEasyPayFundableTypeUseCaseInput {
    let amount: AmountEntity
    let accountEasyPay: AccountEasyPay
    
    public init(amount: AmountEntity, accountEasyPay: AccountEasyPay) {
        self.amount = amount
        self.accountEasyPay = accountEasyPay
    }
}

public struct AccountEasyPayFundableTypeUseCaseOkOutput {
    public let accountEasyPayFundableType: AccountEasyPayFundableType
}
