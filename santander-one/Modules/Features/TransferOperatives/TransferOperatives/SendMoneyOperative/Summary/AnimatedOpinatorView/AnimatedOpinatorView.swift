//
//  AnimatedOpinatorView.swift
//  TransferOperatives
//

import UI
import CoreFoundationLib

public final class AnimatedOpinatorView: XibView {

    @IBOutlet private weak var smileysImageView: UIImageView!
    @IBOutlet private weak var titleLabel: UILabel!

    private var onTapAction: (() -> Void)?

    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.configureView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.configureView()
    }

    func setup(titleKey: String, onTapAction: (() -> Void)?) {
        self.titleLabel.text = localized(titleKey)
        self.onTapAction = onTapAction
    }

    private func configureView() {
        self.view?.backgroundColor = .paleYellow
        self.view?.setOneCornerRadius(type: .oneShRadius8)
        self.smileysImageView.setSmileysAnimation()
        self.titleLabel.font = .typography(fontName: .oneB300Bold)
        self.titleLabel.textColor = .oneLisboaGray
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTapOnButtonView))
        self.view?.addGestureRecognizer(tapGestureRecognizer)
        self.setAccessibilityIdentifiers()
    }

    private func setAccessibilityIdentifiers() {
        self.view?.accessibilityIdentifier = AccessibilitySendMoneySummary.OpinatorView.opinatorView
        self.smileysImageView.accessibilityIdentifier = AccessibilitySendMoneySummary.OpinatorView.smileysImageView
        self.titleLabel.accessibilityIdentifier = AccessibilitySendMoneySummary.OpinatorView.title
    }

    @objc private func didTapOnButtonView() {
        self.onTapAction?()
    }
}
