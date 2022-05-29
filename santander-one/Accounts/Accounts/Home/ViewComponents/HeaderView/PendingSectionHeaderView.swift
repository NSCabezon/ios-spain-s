//
//  PendingSectionView.swift
//  Account
//
//  Created by Boris Chirino Fernandez on 24/11/21.
//
import CoreFoundationLib
import CoreGraphics

final class PendingSectionHeaderView: UITableViewHeaderFooterView {
    private var label: UILabel
    private enum Constants {
        static let backgroundAlphaValue: CGFloat = 0.9
        enum Constraints {
            static let labelLeadingSpace: CGFloat = 16.0
            static let labelVerticalSpace: CGFloat = 10.0
        }
    }
    override init(reuseIdentifier: String?) {
        self.label = UILabel(frame: .zero)
        super.init(reuseIdentifier: reuseIdentifier)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        self.label = UILabel(frame: .zero)
        super.init(coder: coder)
        commonInit()
    }
}

private extension PendingSectionHeaderView {
    func commonInit() {
        setupLabel()
        setupView()
    }
    
    func setupView() {
        if #available(iOS 14.0, *) {
            var backgroundConfig = UIBackgroundConfiguration.clear()
            backgroundConfig.backgroundColor = UIColor.white.withAlphaComponent(Constants.backgroundAlphaValue)
            backgroundConfiguration = backgroundConfig
        } else {
            self.layer.backgroundColor = UIColor.white.withAlphaComponent(Constants.backgroundAlphaValue).cgColor
        }
    }
    
    func setupLabel() {
        self.contentView.addSubview(label)
        label.text = localized("orderStatus_label_pending")
        label.setSantanderTextFont(type: .bold, size: 14.0, color: .grafite)
        label.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: Constants.Constraints.labelLeadingSpace),
            label.centerXAnchor.constraint(equalTo: self.contentView.centerXAnchor),
            label.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: Constants.Constraints.labelVerticalSpace),
            label.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: -Constants.Constraints.labelVerticalSpace)
        ])
    }
}
