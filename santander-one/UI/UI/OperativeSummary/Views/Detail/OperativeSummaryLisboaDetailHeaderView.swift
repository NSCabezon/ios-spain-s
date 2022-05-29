import CoreFoundationLib
import UIKit

public final class OperativeSummaryLisboaDetailHeaderView: XibView {

    @IBOutlet private weak var containerView: UIView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var amountLabel: UILabel!
    @IBOutlet private weak var topBorder: UIView!
    @IBOutlet private weak var leftBorder: UIView!
    @IBOutlet private weak var rightBorder: UIView!

    public override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    public func setViewModel(_ viewModel: OperativeSummaryLisboaDetailHeaderViewModel) {
        titleLabel.text = viewModel.title
        amountLabel.text = viewModel.total
        amountLabel.scaleDecimals()
    }
}

private extension OperativeSummaryLisboaDetailHeaderView {
    func setupView() {
        backgroundColor = .skyGray
        titleLabel.textColor = .grafite
        titleLabel.font = .santander(family: .text, type: .regular, size: 13)
        titleLabel.accessibilityIdentifier = "generic_hint_title_amount"
        amountLabel.textColor = .lisboaGray
        amountLabel.font = .santander(family: .text, type: .bold, size: 32)
        amountLabel.accessibilityIdentifier = "generic_hint_amount"
        topBorder.backgroundColor = .mediumSkyGray
        leftBorder.backgroundColor = .mediumSkyGray
        rightBorder.backgroundColor = .mediumSkyGray
    }
}
