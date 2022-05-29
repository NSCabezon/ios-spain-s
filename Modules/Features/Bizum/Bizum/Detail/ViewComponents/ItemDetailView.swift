import UI

final class ItemDetailView: XibView {
    @IBOutlet private weak var titleLabel: UILabel! {
        didSet {
            self.titleLabel.setSantanderTextFont(size: 13, color: .grafite)
        }
    }
    @IBOutlet private weak var valueLabel: UILabel! {
        didSet {
            self.valueLabel.textColor = .lisboaGray
        }
    }
    @IBOutlet private weak var infoLabel: UILabel! {
        didSet {
            self.infoLabel.textColor = .mediumSanGray
        }
    }
    @IBOutlet private weak var dottedLineView: PointLine!
}

extension ItemDetailView: ItemDetailViewProtocol {
    func update(with viewModel: ItemDetailViewModel) {
        self.titleLabel.configureText(withKey: viewModel.title.text)
        self.titleLabel.accessibilityIdentifier = viewModel.title.accessibility
        if let value = viewModel.value {
            self.valueLabel.configureText(withKey: value.text, andConfiguration: value.style)
            self.valueLabel.accessibilityIdentifier = value.accessibility
        }
        if let info = viewModel.info {
            self.infoLabel.configureText(withKey: info.text, andConfiguration: info.style)
            self.infoLabel.accessibilityIdentifier = info.accessibility
        } else {
            self.infoLabel.isHidden = true
        }
    }
}
