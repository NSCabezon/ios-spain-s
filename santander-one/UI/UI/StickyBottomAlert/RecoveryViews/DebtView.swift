//
//  DebtView.swift
//  UI
//
//  Created by alvola on 06/10/2020.
//

import UIKit
import CoreFoundationLib

final class DebtView: UIView {
    
    private lazy var alertImage: UIImageView = {
        let image = UIImageView(image: Assets.image(named: "icnImportantNotice"))
        image.translatesAutoresizingMaskIntoConstraints = false
        addSubview(image)
        return image
    }()

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = localized("recoveredMoney_label_paymentSlip")
        label.textAlignment = .left
        label.font = UIFont.santander(size: 12.0)
        label.textColor = UIColor.lisboaGray
        addSubview(label)
        return label
    }()
    
    private lazy var debtNameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .left
        label.lineBreakMode = .byTruncatingTail
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
        label.text = localized("recoveredMoney_label_unpaidDebt")
        label.font = UIFont.santander(size: 14.0)
        label.textColor = UIColor.lisboaGray
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
        let name = viewModel.debtCount == 1 ? viewModel.debtTitle : localized("recoveredMoney_label_variousProducts")
        let countKey = viewModel.debtCount == 1 ? "recoveredMoney_label_paymentSlip_one" : "recoveredMoney_label_paymentSlip_other"
        titleLabel.configureText(withLocalizedString: localized(countKey, [StringPlaceholder(.number, String(viewModel.debtCount))]))
        titleLabel.font = UIFont.santander(size: 12.0)
        debtNameLabel.text = name
        amountLabel.text = viewModel.amount
    }
}

private extension DebtView {
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
        self.drawRoundedBorderAndShadow(with: ShadowConfiguration(color: UIColor.lightSanGray,
                                                                  opacity: 0.7,
                                                                  radius: 3.0,
                                                                  withOffset: 0.0, heightOffset: 2.0),
                                        cornerRadius: 6.0,
                                        borderColor: UIColor.mediumSkyGray,
                                        borderWith: 1.0)
    }
    
    func configureAlertImage() {
        NSLayoutConstraint.activate([alertImage.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 6.0),
                                     alertImage.topAnchor.constraint(equalTo: self.topAnchor, constant: 13.0),
                                     alertImage.widthAnchor.constraint(equalToConstant: 38.0),
                                     alertImage.heightAnchor.constraint(equalToConstant: 38.0)])
    }
    
    func configureTitleLabel() {
        NSLayoutConstraint.activate([titleLabel.leadingAnchor.constraint(equalTo: alertImage.trailingAnchor, constant: 3.0),
                                     self.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor, constant: 10.0),
                                     titleLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 16.0),
                                     titleLabel.heightAnchor.constraint(equalToConstant: 16.0)])
    }
    
    func configureDebtNameLabel() {
        NSLayoutConstraint.activate([debtNameLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
                                     self.trailingAnchor.constraint(equalTo: debtNameLabel.trailingAnchor, constant: 10.0),
                                     debtNameLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 0.0),
                                     debtNameLabel.heightAnchor.constraint(equalToConstant: 26.0)])
    }
    
    func configureTotalAmountView() {
        NSLayoutConstraint.activate([totalAmountView.leadingAnchor.constraint(equalTo: debtNameLabel.leadingAnchor),
                                     self.trailingAnchor.constraint(equalTo: totalAmountView.trailingAnchor, constant: 16.0),
                                     totalAmountView.topAnchor.constraint(equalTo: debtNameLabel.bottomAnchor, constant: 6.0),
                                     totalAmountView.heightAnchor.constraint(equalToConstant: 28.0)])
    }
    
    func configureTotalDebtLabel() {
        totalDebtLabel.setContentCompressionResistancePriority(UILayoutPriority.defaultLow, for: NSLayoutConstraint.Axis.horizontal)
        NSLayoutConstraint.activate([totalDebtLabel.leadingAnchor.constraint(equalTo: totalAmountView.leadingAnchor, constant: 8.0),
                                     totalDebtLabel.trailingAnchor.constraint(equalTo: amountLabel.leadingAnchor, constant: -5.0),
                                     totalDebtLabel.centerYAnchor.constraint(equalTo: totalAmountView.centerYAnchor, constant: -1.5),
                                     totalDebtLabel.heightAnchor.constraint(equalToConstant: 20.0)])
    }
    
    func configureAmountLabel() {
        amountLabel.setContentCompressionResistancePriority(UILayoutPriority.required, for: NSLayoutConstraint.Axis.horizontal)
        NSLayoutConstraint.activate([totalAmountView.trailingAnchor.constraint(equalTo: amountLabel.trailingAnchor, constant: 8.0),
                                     amountLabel.centerYAnchor.constraint(equalTo: totalAmountView.centerYAnchor, constant: -1.5),
                                     amountLabel.heightAnchor.constraint(equalToConstant: 20.0)])
    }
    
    func configureAccessibilityIds() {
        alertImage.accessibilityIdentifier = "icnImportantNotice"
        titleLabel.accessibilityIdentifier = "recoveredMoney_label_paymentSlip"
        debtNameLabel.accessibilityIdentifier = "recoveredMoney_label_variousProducts "
        totalDebtLabel.accessibilityIdentifier = "recoveredMoney_label_unpaidDebt"
        amountLabel.accessibilityIdentifier = "recoveredMoney_label_debtAmount"
        accessibilityIdentifier = "recoveredMoneyViewPaymentSlip"
    }
}
