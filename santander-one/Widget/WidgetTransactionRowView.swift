import UIKit
import RetailLegacy

class WidgetTransactionRowView: UIView {
    
    @IBOutlet weak var separatorView: UIView!
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var dayLabel: UILabel!
    @IBOutlet weak var monthLabel: UILabel!
    @IBOutlet weak var leadingSeparatorSpace: NSLayoutConstraint!
    @IBOutlet weak var dateStackView: UIStackView!
    
    private var fontColor: UIColor?
    
    private struct Constants {
        static let smallSpace = CGFloat(17.0)
        static let bigSpace = CGFloat(64.0)
    }
    
    private func setupViews() {
        separatorView.backgroundColor = UIColor.sanGreyMedium.withAlphaComponent(0.5)
        amountLabel.textColor = fontColor
        amountLabel.font = UIFont.latoRegular(size: 16.0)
        titleLabel.textColor = fontColor
        titleLabel.font = UIFont.latoRegular(size: 13.0)
        dayLabel.textColor = UIColor.sanRed
        dayLabel.font = UIFont.latoRegular(size: 12.0)
        monthLabel.textColor = UIColor.sanRed
        monthLabel.font = UIFont.latoRegular(size: 8.0)
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        fontColor = fontColorMode
    }
    
    func setDate(day: String?, month: String?) {
        guard let day = day, let month = month else {
            setIsDateHidden(true)
            return
        }
        setIsDateHidden(false)
        dayLabel.text = day
        monthLabel.text = month
    }
    
    func setTitle(_ title: String) {
        setupViews()
        titleLabel.text = title
    }
    
    func setAmount(_ amount: String) {
        amountLabel.text = amount
        amountLabel.scaleDecimals()
    }
    
    private func setIsDateHidden(_ isDateHidden: Bool) {
        leadingSeparatorSpace.constant = isDateHidden ? Constants.bigSpace : Constants.smallSpace
        layoutIfNeeded()
        dateStackView.isHidden = isDateHidden
    }
}

extension WidgetTransactionRowView: ViewCreatable {}
