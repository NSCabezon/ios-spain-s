import UI
import CoreFoundationLib

struct ReuseSimpleContactViewModel {
    let title: TextWithAccessibility
    let info: TextWithAccessibility?
}

protocol ReuseSimpleContactItemViewProtocol {
    func update(with viewModel: ReuseSimpleContactViewModel)
}

final class ReuseSimpleContactItemView: XibView {
    @IBOutlet weak var titleLabel: UILabel! {
        didSet {
            self.titleLabel.textColor = .lisboaGray
        }
    }
    @IBOutlet weak var infoLabel: UILabel! {
        didSet {
            self.infoLabel.textColor = .lisboaGray
        }
    }
}

extension ReuseSimpleContactItemView: ReuseSimpleContactItemViewProtocol {
    func update(with viewModel: ReuseSimpleContactViewModel) {
        self.titleLabel.configureText(withKey: viewModel.title.text, andConfiguration: viewModel.title.style)
        if let info = viewModel.info {
            self.infoLabel.configureText(withKey: info.text, andConfiguration: info.style)
        } else {
            self.infoLabel.isHidden = true
        }
    }
}
