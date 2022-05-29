//
//  ShareButtonView.swift
//  UI
//
//  Created by Juan Diego Vázquez Moreno on 4/11/21.
//

import UI
import CoreFoundationLib

class ShareButtonViewModel {
    let imageKey: String
    let titleKey: String
    let onTapAction: (() -> Void)?
    let accessibilitySuffix: String?

    init(imageKey: String,
         titleKey: String,
         onTapAction: (() -> Void)?,
         accessibilitySuffix: String? = nil) {
        self.imageKey = imageKey
        self.titleKey = titleKey
        self.onTapAction = onTapAction
        self.accessibilitySuffix = accessibilitySuffix
    }
}

public final class ShareButtonView: XibView {

    @IBOutlet private weak var contentView: UIView!
    @IBOutlet private weak var logoImageView: UIImageView!
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

    func setup(viewModel: ShareButtonViewModel) {
        self.logoImageView.image = Assets.image(named: viewModel.imageKey)
        self.titleLabel.text = localized(viewModel.titleKey)
        self.onTapAction = viewModel.onTapAction
        self.setAccessibilityIdentifiers(viewModel.accessibilitySuffix)
    }

    private func configureView() {
        self.view?.backgroundColor = .white
        self.contentView.backgroundColor = .white
        self.contentView.setOneCornerRadius(type: .oneShRadius8)
        self.contentView.setOneShadows(type: .oneShadowSmall)
        self.titleLabel.font = .typography(fontName: .oneB300Regular)
        self.titleLabel.textColor = .oneLisboaGray
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTapOnButtonView))
        self.view?.addGestureRecognizer(tapGestureRecognizer)
        self.setAccessibilityIdentifiers()
    }

    private func setAccessibilityIdentifiers(_ suffix: String? = nil) {
        self.view?.accessibilityIdentifier = AccessibilitySendMoneySummary.ShareButton.shareButtonView + (suffix ?? "")
        self.logoImageView.accessibilityIdentifier = AccessibilitySendMoneySummary.ShareButton.shareButtonImg + (suffix ?? "")
        self.titleLabel.accessibilityIdentifier = AccessibilitySendMoneySummary.ShareButton.shareButtonTitle + (suffix ?? "")
    }

    @objc private func didTapOnButtonView() {
        self.onTapAction?()
    }
}

