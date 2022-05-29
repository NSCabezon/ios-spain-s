//
//  EasyPayMonthlyFeeView.swift
//  Cards
//
//  Created by alvola on 09/12/2020.
//

import CoreFoundationLib

public enum MonthlyViewModelType {
    case easyPay
    case fractionablePurchase
}

public protocol EasyPayMonthlyFeeViewProtocol {
    var day: String { get set }
    var month: String { get set }
    var year: String { get set }
    var feeNum: LocalizedStylableText { get set }
    var feeAmount: NSAttributedString? { get set }
    var pendingAmount: String? { get set }
    var amortizationAmount: String? { get set }
    var feeStatus: String? { get set }
    var viewType: MonthlyViewModelType { get set }
    var feeStatusColor: UIColor? { get set }
    var calendarColor: UIColor { get set }
    var secondTitleLabel: String { get set }
    var thirdTitleLabel: String { get set }
}

public final class EasyPayMonthlyFeeView: UIView {
    
    public lazy var paymentImageView: EasyPayCalendarView = {
        let view = EasyPayCalendarView(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }()
    
    private lazy var feeNumLabel: UILabel = {
        let label = defaultLabel(16.0, .lisboaGray, .left)
        label.font = UIFont.santander(type: .bold, size: 16.0)
        addSubview(label)
        return label
    }()
    
    private lazy var feeStatusView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        addSubview(view)
        return view
    }()
    
    private lazy var feeStatus: UILabel = {
        let label = defaultLabel(10.0, .clear, .center)
        label.font = UIFont.santander(family: .text, type: .bold, size: 10)
        addSubview(label)
        return label
    }()
    
    private lazy var pendingTitleLabel: UILabel = {
        let label = defaultLabel(14.0, .grafite, .left)
        label.accessibilityIdentifier = AccessibilityCardsEasyPay.MonthlyFeeView.pendingTitleLabel
        addSubview(label)
        return label
    }()
    
    private lazy var amortizationTitleLabel: UILabel = {
        let label = defaultLabel(12.0, .grafite, .left)
        label.accessibilityIdentifier = AccessibilityCardsEasyPay.MonthlyFeeView.amortizationTitleLabel
        addSubview(label)
        return label
    }()
    
    private lazy var feeAmountLabel: UILabel = {
        let label = defaultLabel(16.0, .lisboaGray, .right)
        label.font = UIFont.santander(type: .bold, size: 16.0)
        label.setContentCompressionResistancePriority(.required, for: .horizontal)
        addSubview(label)
        return label
    }()
    
    private lazy var pendingAmountLabel: UILabel = {
        let label = defaultLabel(14.0, .grafite, .right)
        label.setContentCompressionResistancePriority(.required, for: .horizontal)
        addSubview(label)
        return label
    }()
    
    private lazy var amortizationAmountLabel: UILabel = {
        let label = defaultLabel(12.0, .grafite, .right)
        label.setContentCompressionResistancePriority(.required, for: .horizontal)
        addSubview(label)
        return label
    }()
    
    private lazy var bottomSeparator: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .mediumSkyGray
        addSubview(view)
        return view
    }()
    
    private let defaultLabel: (CGFloat, UIColor, NSTextAlignment) -> UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = $2
        label.lineBreakMode = .byWordWrapping
        label.textColor = $1
        label.font = UIFont.santander(size: $0)
        return label
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    public func setMonthlyFee(_ fee: EasyPayMonthlyFeeViewProtocol) {
        pendingTitleLabel.text = fee.secondTitleLabel
        amortizationTitleLabel.text = fee.thirdTitleLabel
        paymentImageView.setDay(fee.day, month: fee.month)
        feeNumLabel.configureText(withLocalizedString: fee.feeNum)
        feeAmountLabel.attributedText = fee.feeAmount
        pendingAmountLabel.text = fee.pendingAmount
        amortizationAmountLabel.text = fee.amortizationAmount
        paymentImageView.setImageColor(fee.calendarColor)
        if fee.viewType == .fractionablePurchase {
            feeStatus.text = fee.feeStatus?.uppercased()
            feeStatus.textColor = fee.feeStatusColor
            feeStatusView.drawBorder(cornerRadius: 2, color: fee.feeStatusColor ?? .clear, width: 1)
        } else {
            feeStatus.isHidden = true
            feeStatusView.isHidden = true
        }
    }
    
    public func hideBottomSeparator(_ hide: Bool) {
        bottomSeparator.backgroundColor = hide ? .clear : .mediumSkyGray
    }
}

private extension EasyPayMonthlyFeeView {
    func setup() {
        paymentImageViewConstraints()
        feeNumLabelConstraints()
        pendingTitleLabelConstraints()
        amortizationTitleLabelConstraints()
        bottomSeparatorConstraints()
        feeAmountLabelConstraints()
        pendingAmountLabelConstraints()
        amortizationAmountLabelConstraints()
        feeStatusViewConstraints()
        feeStatusLabelConstraints()
    }
    
    func paymentImageViewConstraints() {
        NSLayoutConstraint.activate([
            paymentImageView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 15.0),
            paymentImageView.topAnchor.constraint(equalTo: self.topAnchor, constant: 11.0),
            paymentImageView.heightAnchor.constraint(equalToConstant: 50.0),
            paymentImageView.widthAnchor.constraint(equalToConstant: 50.0)
        ])
    }
    
    func feeNumLabelConstraints() {
        NSLayoutConstraint.activate([
            feeNumLabel.leadingAnchor.constraint(equalTo: paymentImageView.trailingAnchor, constant: 15.0),
            feeNumLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 18.0),
            feeNumLabel.heightAnchor.constraint(equalToConstant: 16.0)
        ])
    }
    
    func feeStatusViewConstraints() {
        NSLayoutConstraint.activate([
            feeStatusView.leadingAnchor.constraint(equalTo: feeNumLabel.trailingAnchor, constant: 4.0),
            feeStatusView.centerYAnchor.constraint(equalTo: feeNumLabel.centerYAnchor)
        ])
    }
    
    func feeStatusLabelConstraints() {
        NSLayoutConstraint.activate([
            feeStatus.leadingAnchor.constraint(equalTo: feeStatusView.leadingAnchor, constant: 4.0),
            feeStatus.trailingAnchor.constraint(equalTo: feeStatusView.trailingAnchor, constant: -4.0),
            feeStatus.topAnchor.constraint(equalTo: feeStatusView.topAnchor, constant: 0.0),
            feeStatus.bottomAnchor.constraint(equalTo: feeStatusView.bottomAnchor, constant: 0.0)
        ])
    }
    
    func pendingTitleLabelConstraints() {
        NSLayoutConstraint.activate([
            pendingTitleLabel.leadingAnchor.constraint(equalTo: paymentImageView.trailingAnchor, constant: 15.0),
            pendingTitleLabel.topAnchor.constraint(equalTo: feeNumLabel.bottomAnchor, constant: 4.0),
            pendingTitleLabel.heightAnchor.constraint(equalToConstant: 20.0)
        ])
    }
    
    func amortizationTitleLabelConstraints() {
        NSLayoutConstraint.activate([
            amortizationTitleLabel.leadingAnchor.constraint(equalTo: paymentImageView.trailingAnchor, constant: 15.0),
            amortizationTitleLabel.topAnchor.constraint(equalTo: pendingTitleLabel.bottomAnchor),
            amortizationTitleLabel.heightAnchor.constraint(equalToConstant: 18.0)
        ])
    }
    
    func bottomSeparatorConstraints() {
        NSLayoutConstraint.activate([
            bottomSeparator.leadingAnchor.constraint(equalTo: paymentImageView.trailingAnchor, constant: 15.0),
            bottomSeparator.topAnchor.constraint(equalTo: amortizationTitleLabel.bottomAnchor, constant: 11.0),
            self.trailingAnchor.constraint(equalTo: bottomSeparator.trailingAnchor, constant: 17.0),
            bottomSeparator.heightAnchor.constraint(equalToConstant: 1.0),
            bottomSeparator.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 0.0)
        ])
    }
    
    func feeAmountLabelConstraints() {
        NSLayoutConstraint.activate([
            self.trailingAnchor.constraint(equalTo: feeAmountLabel.trailingAnchor, constant: 16.0),
            feeAmountLabel.centerYAnchor.constraint(equalTo: feeNumLabel.centerYAnchor),
            feeAmountLabel.leadingAnchor.constraint(greaterThanOrEqualTo: feeNumLabel.trailingAnchor, constant: 5.0),
            feeAmountLabel.heightAnchor.constraint(equalToConstant: 16.0)
        ])
    }
    
    func pendingAmountLabelConstraints() {
        NSLayoutConstraint.activate([
            self.trailingAnchor.constraint(equalTo: pendingAmountLabel.trailingAnchor, constant: 16.0),
            pendingAmountLabel.centerYAnchor.constraint(equalTo: pendingTitleLabel.centerYAnchor),
            pendingAmountLabel.leadingAnchor.constraint(greaterThanOrEqualTo: pendingTitleLabel.trailingAnchor, constant: 5.0),
            pendingAmountLabel.heightAnchor.constraint(equalToConstant: 20.0)
        ])
    }
    
    func amortizationAmountLabelConstraints() {
        NSLayoutConstraint.activate([
            self.trailingAnchor.constraint(equalTo: amortizationAmountLabel.trailingAnchor, constant: 16.0),
            amortizationAmountLabel.centerYAnchor.constraint(equalTo: amortizationTitleLabel.centerYAnchor),
            amortizationAmountLabel.leadingAnchor.constraint(greaterThanOrEqualTo: amortizationTitleLabel.trailingAnchor, constant: 5.0),
            amortizationAmountLabel.heightAnchor.constraint(equalToConstant: 18.0)
        ])
    }
}
