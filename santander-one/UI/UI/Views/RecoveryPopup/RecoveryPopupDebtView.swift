//
//  RecoveryPopupDebtView.swift
//  UI
//
//  Created by alvola on 16/10/2020.
//

import UIKit
import CoreFoundationLib

final class RecoveryPopupDebtView: UIView {
    private lazy var alertImage: UIImageView = {
        let image = UIImageView(image: Assets.image(named: "icnImportantNotice"))
        image.translatesAutoresizingMaskIntoConstraints = false
        addSubview(image)
        return image
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .left
        label.font = UIFont.santander(size: 12.0)
        label.textColor = UIColor.lisboaGray
        label.configureText(withKey: "recoveredMoney_label_payment")
        addSubview(label)
        return label
    }()
    
    private lazy var debtNameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .left
        label.lineBreakMode = .byWordWrapping
        label.numberOfLines = 0
        label.font = UIFont.santander(type: .bold, size: 18.0)
        label.textColor = UIColor.lisboaGray
        addSubview(label)
        return label
    }()
    
    private lazy var totalAmountView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 4.0
        view.backgroundColor = UIColor.whitesmokes
        addSubview(view)
        return view
    }()
    
    private lazy var totalDebtLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .left
        label.lineBreakMode = .byTruncatingTail
        label.font = UIFont.santander(size: 14.0)
        label.textColor = UIColor.lisboaGray
        label.configureText(withKey: "recoveredMoney_label_unpaidDebt")
        totalAmountView.addSubview(label)
        return label
    }()
    
    private lazy var amountLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .right
        label.font = UIFont.santander(type: .bold, size: 14.0)
        label.textColor = UIColor.lisboaGray
        totalAmountView.addSubview(label)
        return label
    }()
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    func setRecoveryViewModel(_ viewModel: RecoveryViewModel) {
        amountLabel.text = viewModel.amount
        let debtLabelContent = viewModel.debtCount > 1 ?
            localized("recoveredMoney_label_productPendingPays", [StringPlaceholder(.value, String(viewModel.debtCount))]) :
            LocalizedStylableText(text: viewModel.debtTitle, styles: nil)
        debtNameLabel.configureText(withLocalizedString: debtLabelContent,
                                    andConfiguration: LocalizedStylableTextConfiguration(lineHeightMultiple: 0.85))
    }
    
    func setExpandedMode() {
        debtNameLabel.lineBreakMode = .byWordWrapping
        debtNameLabel.numberOfLines = 0
    }
}

private extension RecoveryPopupDebtView {
    func commonInit() {
        configureView()
        configureAlertImage()
        configureTitleLabel()
        configureDebtNameLabel()
        configureTotalAmountView()
        configureAccessibilityIds()
        configureTotalDebtLabel()
        configureAmountLabel()
    }
    
    func configureView() {
        backgroundColor = .white
        self.drawBorder(cornerRadius: 6.0, color: UIColor.mediumSkyGray, width: 1.0)
    }
    
    func configureAlertImage() {
        NSLayoutConstraint.activate([alertImage.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 11.0),
                                     alertImage.topAnchor.constraint(equalTo: self.topAnchor, constant: 4.0),
                                     alertImage.widthAnchor.constraint(equalToConstant: 50.0),
                                     alertImage.heightAnchor.constraint(equalToConstant: 55.0)])
    }
    
    func configureTitleLabel() {
        NSLayoutConstraint.activate([titleLabel.leadingAnchor.constraint(equalTo: alertImage.trailingAnchor, constant: 7.0),
                                     self.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor, constant: 10.0),
                                     titleLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 15.0),
                                     titleLabel.heightAnchor.constraint(equalToConstant: 16.0)])
    }
    
    func configureDebtNameLabel() {
        NSLayoutConstraint.activate([debtNameLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
                                     self.trailingAnchor.constraint(equalTo: debtNameLabel.trailingAnchor, constant: 10.0),
                                     debtNameLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor)])
    }
    
    func configureTotalAmountView() {
        NSLayoutConstraint.activate([totalAmountView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 14.0),
                                     self.trailingAnchor.constraint(equalTo: totalAmountView.trailingAnchor, constant: 14.0),
                                     totalAmountView.topAnchor.constraint(equalTo: debtNameLabel.bottomAnchor, constant: 7.0),
                                     self.bottomAnchor.constraint(equalTo: totalAmountView.bottomAnchor, constant: 14.0),
                                     totalAmountView.heightAnchor.constraint(equalToConstant: 28.0)])
    }
    
    func configureTotalDebtLabel() {
        totalDebtLabel.setContentCompressionResistancePriority(UILayoutPriority.defaultLow, for: NSLayoutConstraint.Axis.horizontal)
        NSLayoutConstraint.activate([totalDebtLabel.leadingAnchor.constraint(equalTo: totalAmountView.leadingAnchor, constant: 10.0),
                                     totalDebtLabel.trailingAnchor.constraint(equalTo: amountLabel.leadingAnchor, constant: -5.0),
                                     totalDebtLabel.centerYAnchor.constraint(equalTo: totalAmountView.centerYAnchor),
                                     totalDebtLabel.heightAnchor.constraint(equalToConstant: 20.0)])
    }
    
    func configureAmountLabel() {
        amountLabel.setContentCompressionResistancePriority(UILayoutPriority.required, for: NSLayoutConstraint.Axis.horizontal)
        NSLayoutConstraint.activate([totalAmountView.trailingAnchor.constraint(equalTo: amountLabel.trailingAnchor, constant: 8.0),
                                     amountLabel.centerYAnchor.constraint(equalTo: totalAmountView.centerYAnchor),
                                     amountLabel.heightAnchor.constraint(equalToConstant: 20.0)])
    }
    
    func configureAccessibilityIds() {
        alertImage.accessibilityIdentifier = "icnImportantNotice"
        titleLabel.accessibilityIdentifier = "recoveredMoney_label_payment"
        debtNameLabel.accessibilityIdentifier = "recoveredMoney_label_productPendingPays"
        totalDebtLabel.accessibilityIdentifier = "recoveredMoney_label_unpaidDebt"
        amountLabel.accessibilityIdentifier = "recoveredMoney_label_debtAmount"
        accessibilityIdentifier = "pgViewImportantNotice"
    }
}
