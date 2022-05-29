//
//  FractionableMovementView.swift
//  Cards
//
//  Created by alvola on 16/02/2021.
//

import UIKit
import CoreFoundationLib

public protocol FractionableMovementViewDelegate: AnyObject {
    func didSelectMovement(_ movement: FractionableMovementView)
}

public final class FractionableMovementView: UIView {
    
    private lazy var dateLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .bostonRed
        label.accessibilityIdentifier = "cardDetail_label_liquidatedDate"
        addSubview(label)
        return label
    }()
    
    private lazy var movementNameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .lisboaGray
        label.numberOfLines = 2
        label.accessibilityIdentifier = "fractionatePurchasesMovementLabelName"
        addSubview(label)
        return label
    }()
    
    private lazy var amountLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.santander(type: .bold, size: 18.0)
        label.textColor = .lisboaGray
        label.accessibilityIdentifier = "fractionatePurchasesMovementLabelAmount"
        addSubview(label)
        return label
    }()
    
    private lazy var circleGraphView: CircleGraphView = {
        let view = CircleGraphView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        view.frontCircleColor = .seafoamBlue
        view.backCircleColor = .silverDark
        view.circlesLineWidth = 8.0
        addSubview(view)
        return view
    }()
    
    private lazy var pendingLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .lisboaGray
        label.accessibilityIdentifier = "fractionatePurchases_label_pendingInstalments"
        label.configureText(withKey: "", andConfiguration: LocalizedStylableTextConfiguration(font: .santander(size: 12.0), alignment: .center, lineHeightMultiple: 0.7))
        label.numberOfLines = 0
        circleGraphView.addSubview(label)
        return label
    }()
    
    private let configuration: (CGFloat, FontType) -> LocalizedStylableTextConfiguration = {
        return LocalizedStylableTextConfiguration(font: .santander(type: $1, size: $0),
                                                  lineHeightMultiple: 0.9)
    }
    private weak var delegate: FractionableMovementViewDelegate?
    public var model: FractionableMovementViewModel?
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    public func setInfo(_ info: FractionableMovementViewModel, delegate: FractionableMovementViewDelegate?) {
        self.delegate = delegate
        self.model = info
        dateLabel.configureText(
            withKey: info.operativeDate.uppercased(),
            andConfiguration: LocalizedStylableTextConfiguration(font: .santander(type: .bold, size: 14.0)))
        movementNameLabel.configureText(
            withKey: info.camelCaseName,
            andConfiguration: LocalizedStylableTextConfiguration(font: .santander(size: 16.0), lineHeightMultiple: 0.7))
        setPendingLabel(info)
        circleGraphView.percentage = Double(info.totalFees - info.pendingFees) / Double(info.totalFees) * 100
        amountLabel.attributedText = amountAttributedText(info)
        if info.addTapGesture {
            addTapGesture()
        }
    }
    
    public func drawBorderAndShadow() {
        let shadowConfig = ShadowConfiguration(
            color: .shadesWhite,
            opacity: 0.35,
            radius: 0.0,
            withOffset: 1.0,
            heightOffset: 2.0
        )
        self.drawRoundedBorderAndShadow(
            with: shadowConfig,
            cornerRadius: 5.0,
            borderColor: .lightSkyBlue,
            borderWith: 1.0
        )
    }
}

private extension FractionableMovementView {
    func commonInit() {
        configureView()
        configureDateLabelConstraints()
        configureMovementNameLabelConstraints()
        configureAmountLabelConstraints()
        configureCircleGraphConstraints()
        configurePendingLabelConstraints()
    }
    
    func configureView() {
        backgroundColor = .white
        accessibilityIdentifier = "fractionatePurchasesMovement"
        heightAnchor.constraint(greaterThanOrEqualToConstant: 102.0).isActive = true
    }
    
    func configureDateLabelConstraints() {
        NSLayoutConstraint.activate([
            dateLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 19.0),
            dateLabel.topAnchor.constraint(equalTo: topAnchor, constant: 18.0),
            dateLabel.heightAnchor.constraint(equalToConstant: 17.0)
        ])
    }
    
    func configureMovementNameLabelConstraints() {
        NSLayoutConstraint.activate([
            movementNameLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 19.0),
            circleGraphView.leadingAnchor.constraint(greaterThanOrEqualTo: movementNameLabel.trailingAnchor, constant: 10.0),
            movementNameLabel.topAnchor.constraint(equalTo: dateLabel.bottomAnchor, constant: 2.0)
        ])
    }
    
    func configureAmountLabelConstraints() {
        NSLayoutConstraint.activate([
            amountLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 19.0),
            trailingAnchor.constraint(greaterThanOrEqualTo: amountLabel.trailingAnchor, constant: 10.0),
            amountLabel.topAnchor.constraint(equalTo: movementNameLabel.bottomAnchor, constant: 2.0),
            bottomAnchor.constraint(equalTo: amountLabel.bottomAnchor, constant: 22.0),
            amountLabel.heightAnchor.constraint(equalToConstant: 19.0)
        ])
    }
    
    func configureCircleGraphConstraints() {
        NSLayoutConstraint.activate([
            trailingAnchor.constraint(equalTo: circleGraphView.trailingAnchor, constant: 22.0),
            circleGraphView.centerYAnchor.constraint(equalTo: movementNameLabel.centerYAnchor),
            circleGraphView.heightAnchor.constraint(equalToConstant: 78.0),
            circleGraphView.widthAnchor.constraint(equalToConstant: 79.0)
        ])
    }
    
    func configurePendingLabelConstraints() {
        NSLayoutConstraint.activate([
            pendingLabel.centerYAnchor.constraint(equalTo: circleGraphView.centerYAnchor),
            pendingLabel.centerXAnchor.constraint(equalTo: circleGraphView.centerXAnchor)
        ])
    }
    
    func addTapGesture() {
        if let gestureRecognizers = gestureRecognizers,
           !gestureRecognizers.isEmpty {
            self.gestureRecognizers?.removeAll()
        }
        let tap = UITapGestureRecognizer(target: self, action: #selector(didTapItemView))
        addGestureRecognizer(tap)
    }
    
    @objc func didTapItemView() {
        delegate?.didSelectMovement(self)
    }
    
    func amountAttributedText(_ info: FractionableMovementViewModel) -> NSAttributedString? {
        guard let amount = info.amountEntity else { return nil }
        let font = UIFont.santander(type: .bold, size: 20.0)
        let decorator = MoneyDecorator(amount, font: font, decimalFontSize: 20.0)
        return decorator.formatAsMillions()
    }
    
    func pendingString(_ pending: Int) -> LocalizedStylableText {
        switch pending {
        case 0:
            return localized("fractionatePurchases_label_instalmentsFinished")
        case 1:
            return localized("fractionatePurchases_label_instalmentsValueLoading_one",
                             [StringPlaceholder(.number, "\(pending)")])
        default:
            return localized("fractionatePurchases_label_instalmentsValueLoading_other",
                             [StringPlaceholder(.number, "\(pending)")])
        }
    }
    
    func setPendingLabel(_ info: FractionableMovementViewModel) {
        let fontType: FontType = info.pendingFees > 0
            ? .regular
            : .bold
        let pendingLabelConfig = LocalizedStylableTextConfiguration(
            font: .santander(family: .text, type: fontType, size: 12.0),
            alignment: .center,
            lineHeightMultiple: 0.75,
            lineBreakMode: .none
        )
        pendingLabel.configureText(
            withLocalizedString: pendingString(info.pendingFees),
            andConfiguration: pendingLabelConfig
        )
    }
}
