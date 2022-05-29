import UI
import CoreFoundationLib

struct ReuseMultipleContactViewModel {
    let initialsViewModel: [BizumInitialsViewModel]
}

protocol ReuseMultipleContactItemViewProtocol {
    func update(_ viewModel: ReuseMultipleContactViewModel)
}

final class ReuseMultipleContactItemView: XibView {
    @IBOutlet weak var sendLabel: UILabel! {
        didSet {
            self.sendLabel.font = .santander(family: .text, type: .regular, size: 10)
            self.sendLabel.textColor = .lisboaGray
            self.sendLabel.text = localized("bizum_label_multipleTo")
            self.sendLabel.accessibilityIdentifier = AccessibilityBizumReuseContact.bizumLabelMultipleTo
        }
    }
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var quantityLabel: UILabel! {
        didSet {
            self.quantityLabel.accessibilityIdentifier = AccessibilityBizumReuseContact.reuseContactLabelNumberContacts
        }
    }
}

extension ReuseMultipleContactItemView: ReuseMultipleContactItemViewProtocol {
    func update(_ viewModel: ReuseMultipleContactViewModel) {
        let initials = viewModel.initialsViewModel.prefix(3)
        let rest = viewModel.initialsViewModel.count - initials.count
        initials.forEach { (initial) in
            let view = BizumInitialsView(frame: CGRect(x: 0, y: 0, width: 31, height: 31))
            view.translatesAutoresizingMaskIntoConstraints = false
            view.widthAnchor.constraint(equalToConstant: 31).isActive = true
            view.heightAnchor.constraint(equalToConstant: 31).isActive = true
            view.configureView(with: initial)
            stackView.addArrangedSubview(view)
        }
        if rest > 0 {
            let holder = StringPlaceholder(.number, String(rest))
            let textConfiguration = LocalizedStylableTextConfiguration(font: UIFont.santander(size: 16))
            self.quantityLabel.configureText(withLocalizedString: localized("bizum_label_andMore", [holder]),
                                             andConfiguration: textConfiguration)
        } else {
            self.quantityLabel.isHidden = true
        }
    }
}
