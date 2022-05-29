import UI
import CoreFoundationLib

struct ReceiverDetailViewModel {
    let value: TextWithAccessibility
    var info: TextWithAccessibility?
    var moneyDecorator: TextWithAccessibility?
}

protocol ReceiverDetailViewProtocol {
    func setupViewModel(_ viewModel: ReceiverDetailViewModel)
}

final class ReceiverDetailView: XibView {
    @IBOutlet private weak var valueLabel: UILabel! {
        didSet {
            self.valueLabel.setSantanderTextFont(type: .bold, size: 14.0, color: .lisboaGray)
        }
    }
    @IBOutlet private weak var infoLabel: UILabel! {
        didSet {
            self.infoLabel.textColor = .mediumSanGray
        }
    }
    @IBOutlet private weak var amountLabel: UILabel! {
        didSet {
            self.amountLabel.setSantanderTextFont(type: .bold, size: 14.0, color: .lisboaGray)
        }
    }
    
    @IBOutlet weak private var bulletView: UIView! {
        didSet {
            let cornerRadius = bulletView.layer.frame.width / 2
            bulletView.layer.cornerRadius = cornerRadius
            bulletView.backgroundColor = .bostonRedLight
        }
    }
}

extension ReceiverDetailView: ReceiverDetailViewProtocol {
    func setupViewModel(_ viewModel: ReceiverDetailViewModel) {
        let receiver = viewModel.value
        self.valueLabel.configureText(withKey: receiver.text, andConfiguration: receiver.style)
        self.valueLabel.accessibilityIdentifier = receiver.accessibility
        if let info = viewModel.info {
            self.infoLabel.configureText(withKey: info.text, andConfiguration: info.style)
            self.infoLabel.accessibilityIdentifier = info.accessibility
        } else {
            self.infoLabel.isHidden = true
        }
        if let amount = viewModel.moneyDecorator {
            self.amountLabel.attributedText = amount.attribute
            self.amountLabel.accessibilityIdentifier =  amount.accessibility
        } else {
            self.amountLabel.isHidden = true
        }
    }
}
