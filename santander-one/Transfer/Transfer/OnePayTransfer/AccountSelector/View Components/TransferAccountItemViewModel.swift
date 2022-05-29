import CoreFoundationLib
import ModelIO
import TransferOperatives

public final class TransferAccountItemViewModel: AccountSelectionViewModelProtocol {
    public let account: AccountEntity
    private let dependenciesResolver: DependenciesResolver
    
    public init(account: AccountEntity, dependenciesResolver: DependenciesResolver) {
        self.account = account
        self.dependenciesResolver = dependenciesResolver
    }
    
    // It´s the currentBalanceAmount, it´s not the availableAmount although in design shows "Undrawn balance" label (same like Madrid)
    public var currentBalanceAmount: NSAttributedString {
        guard let amount = getAmount(account: self.account) else { return NSAttributedString(string: "") }
        let moneyDecorator = MoneyDecorator(amount, font: .santander(family: .text, type: .regular, size: 22), decimalFontSize: 16)
        return moneyDecorator.getFormatedCurrency() ?? NSAttributedString(string: "")
    }
    
    public var iban: String {
        guard let numberFormat = self.dependenciesResolver.resolve(forOptionalType: AccountNumberFormatterProtocol.self) else {
            return self.account.getIBANShort
        }
        return numberFormat.accountNumberFormat(self.account)
    }
}

private extension TransferAccountItemViewModel {
    private func getAmount(account: AccountEntity) -> AmountEntity? {
        if self.dependenciesResolver.resolve(forOptionalType: OnePayTransferModifierProtocol.self) != nil {
            return account.availableAmount
        } else {
            return account.currentBalanceAmount
        }
    }
}
