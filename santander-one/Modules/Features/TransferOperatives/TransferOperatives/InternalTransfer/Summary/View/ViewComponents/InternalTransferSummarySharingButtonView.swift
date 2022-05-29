//
//  InternalTransferSummarySharingButtonView.swift
//  TransferOperatives
//
//  Created by crodrigueza on 11/3/22.
//

import UI
import CoreFoundationLib

final class InternalTransferSummarySharingButtonView: XibView {

    @IBOutlet private weak var contentView: UIView!
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var titleLabel: UILabel!
    private var action: (() -> Void)?

    public override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }

    public init(with item: InternalTransferSummarySharingButtonItem) {
        super.init(frame: .zero)
        setupView()
        setItem(item)
    }

    public func setItem(_ item: InternalTransferSummarySharingButtonItem) {
        imageView.image = Assets.image(named: item.imageKey)
        imageView.image?.accessibilityIdentifier = item.imageKey
        titleLabel.text = localized(item.titleKey)
        action = item.action
        setAccessibilityIdentifiers(item.accessibilitySuffix)
    }
}

private extension InternalTransferSummarySharingButtonView {
    func setupView() {
        view?.backgroundColor = .white
        contentView.backgroundColor = .oneWhite
        contentView.setOneCornerRadius(type: .oneShRadius8)
        contentView.setOneShadows(type: .oneShadowSmall)
        titleLabel.font = .typography(fontName: .oneB300Regular)
        titleLabel.textColor = .oneLisboaGray
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTapOnSharingButtonView))
        contentView.addGestureRecognizer(tapGestureRecognizer)
        setAccessibilityIdentifiers()
    }

    func setAccessibilityIdentifiers(_ suffix: String? = nil) {
        view?.accessibilityIdentifier = AccessibilitySendMoneySummary.ShareButton.shareButtonView + (suffix ?? "")
        imageView.accessibilityIdentifier = AccessibilitySendMoneySummary.ShareButton.shareButtonImg + (suffix ?? "")
        titleLabel.accessibilityIdentifier = AccessibilitySendMoneySummary.ShareButton.shareButtonTitle + (suffix ?? "")
    }

    @objc func didTapOnSharingButtonView() {
        action?()
    }
}
