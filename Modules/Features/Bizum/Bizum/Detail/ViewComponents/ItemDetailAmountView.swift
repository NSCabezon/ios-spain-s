import UI
import CoreFoundationLib

final class ItemDetailAmountView: XibView {
    @IBOutlet private weak var titleLabel: UILabel! {
        didSet {
            self.titleLabel.setSantanderTextFont(size: 13, color: .grafite)
        }
    }
    @IBOutlet private weak var amount: UILabel! {
        didSet {
            self.amount.textColor = .lisboaGray
        }
    }
    @IBOutlet private weak var infoLabel: UILabel! {
        didSet {
            self.infoLabel.textColor = .lisboaGray
        }
    }
    @IBOutlet private weak var stateImage: UIImageView!
    @IBOutlet private weak var stateLabel: UILabel! {
        didSet {
            self.stateLabel.font = .santander(family: .text, type: .bold, size: 12)
        }
    }
    @IBOutlet private weak var dottedLineView: PointLine!
    @IBOutlet private weak var stateStackView: UIStackView!
    @IBOutlet weak var amountTopConstraint: NSLayoutConstraint!
    
    func hideStateView() {
        self.stateStackView.isHidden = true
    }
    
    func setTopConstraint(_ value: CGFloat) {
        amountTopConstraint.constant = value
    }
}

extension ItemDetailAmountView: ItemDetailAmountViewProtocol {
    func update(with viewModel: ItemDetailAmountViewModel) {
        self.titleLabel.configureText(withKey: viewModel.title.text)
        self.titleLabel.accessibilityIdentifier = viewModel.title.accessibility
        self.amount.accessibilityIdentifier = viewModel.amountAccessibility
        if let amount = viewModel.amountWithAttributed {
            self.amount.attributedText = amount
        }
        if let color = viewModel.stateViewModel?.color,
           let image = viewModel.stateViewModel?.image,
           let state = viewModel.stateLabel {
            self.stateLabel.textColor = color
            self.stateImage.image = image
            self.stateLabel.text = state.text
            self.stateLabel.accessibilityIdentifier = state.accessibility
        } else {
            self.stateImage.isHidden = true
            self.stateLabel.isHidden = true
        }
        if let info = viewModel.info {
            self.infoLabel.configureText(withKey: info.text, andConfiguration: info.style)
            self.infoLabel.accessibilityIdentifier = info.accessibility
        } else {
            self.infoLabel.isHidden = true
        }
    }
}
