//
//  EasyPayPaymentPlanView.swift
//  Cards
//
//  Created by alvola on 09/12/2020.
//

import CoreFoundationLib
import UI

final class EasyPayPaymentPlanView: UIView {
    
    private lazy var containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .white
        view.layer.cornerRadius = 6.0
        view.layer.borderWidth = 1.0
        view.layer.borderColor = UIColor.mediumSkyGray.cgColor
        addSubview(view)
        return view
    }()
    
    private lazy var paymentImageView: UIImageView = {
        let image = UIImageView(image: Assets.image(named: "icnPaymentRed"))
        image.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(image)
        return image
    }()
    
    private lazy var paymentLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = localized("easyPay_label_paymentPlan")
        label.textAlignment = .left
        label.lineBreakMode = .byWordWrapping
        label.textColor = .lisboaGray
        label.font = UIFont.santander(size: 16.0)
        label.accessibilityIdentifier = AccessibilityCardsEasyPay.PaymentPlanView.paymentLabel
        containerView.addSubview(label)
        return label
    }()
    
    private lazy var warningLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.lineBreakMode = .byWordWrapping
        label.numberOfLines = 0
        label.textColor = .lisboaGray
        label.font = UIFont.santander(family: .headline, type: .regular, size: 14.0)
        label.text = localized("easyPay_label_signatureSliding")
        label.accessibilityIdentifier = AccessibilityCardsEasyPay.PaymentPlanView.warningLabel
        addSubview(label)
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup(.easyPay)
    }
    
    init(frame: CGRect, type: EasyPayPaymentPlanViewConfigurationType) {
        super.init(frame: frame)
        setup(type)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup(.easyPay)
    }
    
    func setMonthlyFees(_ fees: [[MonthlyFeeViewModel]]) {
        removeSubviews()
        var lastView: UIView = paymentLabel
        var lastJoinableView: UIView?
        fees.enumerated().forEach { years in
            years.element.enumerated().forEach {
                lastView = createMonthlyFee($0.element,
                                            below: lastView,
                                            last: $0.offset == years.element.count - 1,
                                            verticalSpace: $0.offset == 0 ? 8.0 : 0.0)
                joinTopView(lastJoinableView, with: lastView)
                lastJoinableView = lastView
            }
            let thereAreMoreYears = years.offset != fees.count - 1
            let yearSeparator = thereAreMoreYears ? fees[years.offset + 1].first?.year ?? "" : years.element.first?.year ?? ""
            lastView = createYearSeparator(yearSeparator,
                                           below: lastView,
                                           last: !thereAreMoreYears,
                                           verticalSpace: years.offset == 0 ? 5.0 : 0.0)
        }
    }
    
    func hideViewsForFractionablePurchaseDetail() {
        paymentImageView.isHidden = true
        paymentLabel.isHidden = true
        warningLabel.isHidden = true
        containerView.layer.borderWidth = 0
    }
    
    func createMonthlyFee(_ fee: MonthlyFeeViewModel, below: UIView, last: Bool, verticalSpace: CGFloat) -> UIView {
        let view = EasyPayMonthlyFeeView(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.setMonthlyFee(fee)
        view.hideBottomSeparator(last)
        containerView.addSubview(view)
        NSLayoutConstraint.activate([
            view.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            view.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            view.topAnchor.constraint(equalTo: below.bottomAnchor, constant: verticalSpace)
        ])
        return view
    }
    
    func createYearSeparator(_ year: String, below: UIView, last: Bool, verticalSpace: CGFloat) -> UIView {
        guard !last else {
            containerView.bottomAnchor.constraint(equalTo: below.bottomAnchor, constant: verticalSpace).isActive = true
            return below
        }
        let yearView = EasyPayYearSeparatorView(frame: .zero)
        yearView.translatesAutoresizingMaskIntoConstraints = false
        yearView.setYear(year)
        containerView.addSubview(yearView)
        NSLayoutConstraint.activate([
            yearView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            yearView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            below.bottomAnchor.constraint(equalTo: yearView.topAnchor)
        ])
        return yearView
    }
    
    func removeSubviews() {
        containerView.subviews.forEach {
            guard $0 is EasyPayYearSeparatorView ||
                    $0 is EasyPayMonthlyFeeView ||
                    $0 is DottedLineView else { return }
            $0.removeFromSuperview()
        }
    }
    
    func joinTopView(_ top: UIView?, with bottom: UIView?) {
        guard let top = top as? EasyPayMonthlyFeeView,
              let bottom = bottom as? EasyPayMonthlyFeeView else { return }
        let dottedView = DottedLineView()
        dottedView.backgroundColor = .clear
        dottedView.strokeColor = .grafite
        dottedView.lineDashPattern = [2, 4]
        dottedView.orientation = .vertical
        dottedView.lineWidth = 2.0
        dottedView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(dottedView)
        NSLayoutConstraint.activate([
            dottedView.topAnchor.constraint(equalTo: top.paymentImageView.bottomAnchor, constant: 0.0),
            dottedView.centerXAnchor.constraint(equalTo: top.paymentImageView.centerXAnchor),
            dottedView.widthAnchor.constraint(equalToConstant: 2.0),
            dottedView.bottomAnchor.constraint(equalTo: bottom.paymentImageView.topAnchor, constant: 6.0)
        ])
    }
}

private extension EasyPayPaymentPlanView {
    func setup(_ type: EasyPayPaymentPlanViewConfigurationType) {
        containerViewConstraints()
        warningLabelConstraints(type)
        paymentImageViewConstraints(type)
        paymentLabelConstraints(type)
    }
    
    func containerViewConstraints() {
        NSLayoutConstraint.activate([
            containerView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            containerView.topAnchor.constraint(equalTo: self.topAnchor, constant: 12.0),
            self.trailingAnchor.constraint(equalTo: containerView.trailingAnchor)
        ])
    }
    
    func warningLabelConstraints(_ configurationType: EasyPayPaymentPlanViewConfigurationType) {
        NSLayoutConstraint.activate([
            warningLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            warningLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 0.0),
            warningLabel.topAnchor.constraint(equalTo: containerView.bottomAnchor, constant: 16.0)
        ])
        NSLayoutConstraint.activate(warningLabelVariableConstraints(configurationType))
    }
    
    func paymentImageViewConstraints(_ configurationType: EasyPayPaymentPlanViewConfigurationType) {
        NSLayoutConstraint.activate([
            paymentImageView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 13.0),
            paymentImageView.widthAnchor.constraint(equalToConstant: 24.0)
        ])
        NSLayoutConstraint.activate(paymentImageViewVariableContraints(configurationType))
    }
    
    func paymentLabelConstraints(_ configurationType: EasyPayPaymentPlanViewConfigurationType) {
        NSLayoutConstraint.activate([
            paymentLabel.leadingAnchor.constraint(equalTo: paymentImageView.trailingAnchor, constant: 8.0)
        ])
        NSLayoutConstraint.activate(paymentLabelVariableConstraints(configurationType))
    }
    
    func paymentImageViewVariableContraints(_ configurationType: EasyPayPaymentPlanViewConfigurationType) -> [NSLayoutConstraint] {
        switch configurationType {
        case .easyPay:
            return [paymentImageView.heightAnchor.constraint(equalToConstant: 24),
                    paymentImageView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 8)]
        case .fractionablePurchaseDetail:
            return [paymentImageView.heightAnchor.constraint(equalToConstant: 0),
                    paymentImageView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 0)]
        }
    }
    
    func paymentLabelVariableConstraints(_ configurationType: EasyPayPaymentPlanViewConfigurationType) -> [NSLayoutConstraint] {
        switch configurationType {
        case .easyPay:
            return [ paymentLabel.heightAnchor.constraint(equalToConstant: 22.0),
                     paymentLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 8.0)]
        case .fractionablePurchaseDetail:
            return [ paymentLabel.heightAnchor.constraint(equalToConstant: 0),
                     paymentLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 0)]
        }
    }
    
    func warningLabelVariableConstraints(_ configurationType: EasyPayPaymentPlanViewConfigurationType) -> [NSLayoutConstraint] {
        switch configurationType {
        case .easyPay:
            return [self.bottomAnchor.constraint(equalTo: warningLabel.bottomAnchor, constant: 27.0)]
        case .fractionablePurchaseDetail:
            return [self.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: 0.0)]
        }
    }
}

struct EasyPayPaymentPlanViewConfiguration {
    let type: EasyPayPaymentPlanViewConfigurationType
    
}

public enum EasyPayPaymentPlanViewConfigurationType {
    case easyPay
    case fractionablePurchaseDetail
}
