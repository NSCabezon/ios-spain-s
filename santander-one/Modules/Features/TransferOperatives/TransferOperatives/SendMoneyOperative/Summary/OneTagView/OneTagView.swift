//
//  OneTagView.swift
//  TransferOperatives
//

import UI
import CoreFoundationLib

public final class OneTagView: XibView {

    @IBOutlet private weak var contentView: UIView!
    @IBOutlet private weak var titleLabel: UILabel!

    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.configureView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.configureView()
    }

    func setup(titleKey: String) {
        self.titleLabel.text = localized(titleKey).uppercased()
    }

    private func configureView() {
        self.view?.backgroundColor = .white
        self.contentView.backgroundColor = .white
        self.contentView.setOneCornerRadius(type: .oneShRadius4)
        self.contentView.setOneShadows(type: .oneShadowLarge)
        self.titleLabel.font = .typography(fontName: .oneB100Bold)
        self.titleLabel.textColor = .oneBostonRed
        self.setAccessibilityIdentifiers()
    }

    private func setAccessibilityIdentifiers() {
        self.titleLabel.accessibilityIdentifier = AccessibilitySendMoneySummary.financingTag
    }
}
