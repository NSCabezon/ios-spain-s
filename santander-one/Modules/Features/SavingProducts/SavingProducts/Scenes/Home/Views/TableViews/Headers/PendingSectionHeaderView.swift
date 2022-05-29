//
//  PendingSectionView.swift
//  Account
//
//  Created by Jose Camallonga on 24/2/22.
//
import CoreFoundationLib
import CoreGraphics

final class PendingSectionHeaderView: UITableViewHeaderFooterView {
    private var label: UILabel
    private enum Constants {
        static let backgroundAlphaValue: CGFloat = 0.9
        static let labelFontSize: CGFloat = 14.0
        enum Constraints {
            static let labelLeadingSpace: CGFloat = 16.0
            static let horizontalLineHeight: CGFloat = 1
        }
    }
    override init(reuseIdentifier: String?) {
        label = UILabel(frame: .zero)
        super.init(reuseIdentifier: reuseIdentifier)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        label = UILabel(frame: .zero)
        super.init(coder: coder)
        commonInit()
    }
    
    func setAccessibilityIdentifiers() {
        accessibilityIdentifier = "pendingSectionView"
        label.accessibilityIdentifier = "generic_label_pending"
        label.accessibilityLabel = localized("voiceover_pendingTransactions")
    }
}

private extension PendingSectionHeaderView {
    func commonInit() {
        setupLabel()
        setupView()
        setAccessibilityIdentifiers()
    }
    
    func setupView() {
        if #available(iOS 14.0, *) {
            var backgroundConfig = UIBackgroundConfiguration.clear()
            backgroundConfig.backgroundColor = UIColor.white.withAlphaComponent(Constants.backgroundAlphaValue)
            backgroundConfiguration = backgroundConfig
        } else {
            layer.backgroundColor = UIColor.white.withAlphaComponent(Constants.backgroundAlphaValue).cgColor
        }
    }
    
    func setupLabel() {
        contentView.addSubview(label)
        label.text = localized("orderStatus_label_pending")
        label.scaledFont = UIFont.santander(family: .text, type: .bold, size: Constants.labelFontSize)
        label.textColor = .grafite
        label.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Constants.Constraints.labelLeadingSpace),
            label.topAnchor.constraint(equalTo: contentView.topAnchor),
            label.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }
}
