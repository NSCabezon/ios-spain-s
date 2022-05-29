import CoreFoundationLib
import UIKit
import UI

struct ReceivedTransferDetailSectionViewModel {
    let titleKey: String
    let value: String
    let valueAccessibilityIdentifier: String
}

final class ReceivedTransferDetailSectionView: XibView {
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var valueLabel: UILabel!
    @IBOutlet weak var separator: DottedLineView!
    
    init(model: ReceivedTransferDetailSectionViewModel) {
        super.init(frame: .zero)
        self.setupView()
        self.configure(with: model)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupView()
    }
}

private extension ReceivedTransferDetailSectionView {
    func setupView() {
        configureStyle()
    }
    
    func configureStyle() {
        view?.backgroundColor = .mediumSkyGray
        containerView.backgroundColor = .white
        titleLabel.textColor = .grafite
        titleLabel.font = .santander(family: .text, type: .regular, size: 13)
        valueLabel.textColor = .lisboaGray
        valueLabel.font = .santander(family: .text, type: .regular, size: 14)
        separator.strokeColor = .mediumSkyGray
    }
    
    func configure(with model: ReceivedTransferDetailSectionViewModel) {
        titleLabel.text = localized(model.titleKey)
        valueLabel.text = model.value
        titleLabel.accessibilityIdentifier = model.titleKey
        valueLabel.accessibilityIdentifier = model.valueAccessibilityIdentifier
    }
}
