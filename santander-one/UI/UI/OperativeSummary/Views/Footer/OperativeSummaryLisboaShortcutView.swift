import UIKit
import CoreFoundationLib

public final class OperativeSummaryLisboaShortcutView: XibView {
    
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var separatorView: UIView!
    private var action: (() -> Void)?
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    public func setViewModel(_ viewModel: OperativeSummaryLisboaShortcutViewModel) {
        titleLabel.text = viewModel.title
        titleLabel.accessibilityIdentifier = viewModel.accessibilityIdentifier
        imageView.image = Assets.image(named: viewModel.imageName)
        imageView.image?.accessibilityIdentifier = viewModel.imageName
        action = viewModel.action
    }
}

private extension OperativeSummaryLisboaShortcutView {
    func setupView() {
        separatorView.backgroundColor = .mediumSkyGray
        titleLabel.textColor = .white
        titleLabel.font = .santander(family: .text, type: .regular, size: 14)
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(performAction)))
    }
    
    @objc func performAction() {
        action?()
    }
}
