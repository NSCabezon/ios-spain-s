
import CoreDomain
import CoreFoundationLib

extension LoanDetailRepresentable {
    var seedAmount: String? {
        guard let initialAmount = self.initialAmountRepresentable.map(AmountEntity.init) else { return nil }
        let initialAmountDecorator = MoneyDecorator(initialAmount,
                                  font: UIFont.santander(family: .text,
                                                         type: .regular,
                                                         size: 16.0))
        return initialAmountDecorator.formatAsMillionsWithoutDecimals()?.string
    }
}
