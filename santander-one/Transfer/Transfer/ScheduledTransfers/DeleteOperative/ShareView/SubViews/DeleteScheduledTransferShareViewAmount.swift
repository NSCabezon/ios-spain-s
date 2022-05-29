import UIKit
import UI
import CoreFoundationLib

final class DeleteScheduledTransferShareViewAmount: XibView {
    
    @IBOutlet private weak var title: UILabel!
    @IBOutlet private weak var amount: UILabel!
    @IBOutlet private weak var separator: UIView!
    
    init(_ amount: AmountEntity?) {
        super.init(frame: .zero)
        guard let amount = amount else { return }
        self.title.font = .santander(size: 13)
        self.title.textColor = .grafite
        self.title.text = localized("summary_item_amount")
        let decorator = MoneyDecorator(amount,
                                       font: .santander(type: .bold, size: 32),
                                       decimalFontSize: 18)
        self.amount.textColor = .lisboaGray
        self.amount.attributedText = decorator.formatAsMillions()
        self.separator.backgroundColor = .mediumSkyGray
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
