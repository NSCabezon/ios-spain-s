//
//  AnalysisCarouselCollectionViewCell.swift
//  Menu
//
//  Created by Laura González on 19/03/2020.
//

import Foundation
import CoreFoundationLib
import UI

protocol AnalysisCarouselCollectionViewCellDelegate: AnyObject {
    func didPressBudgetCell(originView: UIView, newBudget: Bool)
}

class AnalysisCarouselCollectionViewCell: UICollectionViewCell {
    
    // MARK: - Outlets
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var ovalChartView: UIView!
    @IBOutlet weak var resumeLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var editBudgetImage: UIImageView!
    @IBOutlet weak var editBudgetView: UIView!
    @IBOutlet weak var totalSavedLabel: UILabel!
    
    static let cellIdentifier = "AnalysisCarouselCollectionViewCell"
    
    private weak var delegate: AnalysisCarouselCollectionViewCellDelegate?
    
    private var circleLayer: CAShapeLayer?
    private var circleShadowLayer: CAShapeLayer?
    
    // MARK: - Public
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupView()
        setAccessibilityIdentifiers()
    }
    
    public func setDelegate(_ delegate: AnalysisCarouselCollectionViewCellDelegate?) {
        self.delegate = delegate
    }
    
    func configure(_ viewModel: AnalysisCarouselViewCellModel) {
        setCircleValue(viewModel)
        setResumeLabel(viewModel)
        setTitlesWithType(viewModel.modelType, userBudget: viewModel.userBudget)
        setEditBudget(viewModel.modelType)
        setAmountLabel(viewModel)
    }
    
    func setCircleValue(_ viewModel: AnalysisCarouselViewCellModel) {
        if let percentageValue = viewModel.percentageValue, let circleValue = viewModel.circleValue {
            switch viewModel.modelType {
            case .savings:
                if circleValue > 0 {
                    self.drawCircleShadow(percentageValue, strokeColor: viewModel.amountStyle)
                } else {
                    self.drawCircleShadow(0, strokeColor: viewModel.amountStyle)
                }
            case .budget:
                if circleValue < 0 {
                    self.drawCircleShadow(percentageValue, strokeColor: viewModel.amountStyle)
                } else if circleValue > 0 {
                    self.drawCircleShadow(100, strokeColor: viewModel.amountStyle)
                } else {
                    self.drawCircleShadow(0, strokeColor: viewModel.amountStyle)
                }
            case .editBudget:
                break
            }
        } else {
            self.drawCircleShadow(0, strokeColor: viewModel.amountStyle)
        }
    }
    
    func setAmountLabel(_ viewModel: AnalysisCarouselViewCellModel) {
        if let amountValue = viewModel.amountText {
            switch viewModel.modelType {
            case .savings:
                if amountValue > 0 {
                    amountLabel.attributedText = formattedMoneyFrom(amountValue)
                } else {
                    amountLabel.attributedText = formattedMoneyWithoutDecimals(amountValue)
                }
            case .budget:
                if amountValue == 0 {
                    amountLabel.attributedText = formattedMoneyWithoutDecimals(amountValue)
                } else {
                    amountLabel.attributedText = formattedMoneyFrom(amountValue)
                }
            case .editBudget:
                break
            }
        } else {
            amountLabel.attributedText = formattedMoneyFrom(0.0)
        }
    }
    
    func setResumeLabel(_ viewModel: AnalysisCarouselViewCellModel) {
        if let resume = viewModel.resumeText {
            resumeLabel.configureText(withLocalizedString: resume,
                                      andConfiguration: LocalizedStylableTextConfiguration(font: .santander(family: .text, type: .regular, size: 13)))
        }
    }

    func setTitlesWithType(_ modelType: AnalysisCarouselViewModelType, userBudget: Decimal?) {
        switch modelType {
        case .savings:
            titleLabel.configureText(withKey: "analysis_label_saving",
                                     andConfiguration: LocalizedStylableTextConfiguration(font: .santander(family: .text, type: .regular, size: 14)))
            totalSavedLabel.configureText(withKey: "analysis_label_totalSaved",
                                          andConfiguration: LocalizedStylableTextConfiguration(font: .santander(family: .text, type: .regular, size: 11.7)))
        case .budget:
            if let userBudget = userBudget {
                let budgetText = formattedMoneyWithoutDecimals(userBudget)
                titleLabel.configureText(withLocalizedString: localized("analysis_label_budget", [StringPlaceholder(.value, budgetText.string)]),
                                         andConfiguration: LocalizedStylableTextConfiguration(font: .santander(family: .text, type: .regular, size: 14)))
            }
            totalSavedLabel.isHidden = true
        case .editBudget:
            break
        }
    }
    
    func setEditBudget(_ modelType: AnalysisCarouselViewModelType) {
        switch modelType {
        case .budget:
            editBudgetView.isHidden = false
            editBudgetImage.isHidden = false
            editBudgetImage.image = Assets.image(named: "icnEdit")
        case .savings:
            editBudgetView.isHidden = true
            editBudgetImage.isHidden = true
        case .editBudget:
            return
        }
    }
        
    func decimalToString(_ decimal: Decimal) -> String {
        guard let decimalToString = formatterForRepresentation(.decimal(decimals: 2)).string(for: decimal) else {
            return ""
        }
        return decimalToString
    }
}

// MARK: - Private

private extension AnalysisCarouselCollectionViewCell {
    func setupView() {
        self.setupContainerView()
        self.setupLabels()
    }
    
    func setupContainerView() {
        containerView.backgroundColor = UIColor.white
        self.layer.shadowOffset = CGSize(width: 0, height: 2)
        self.layer.shadowOpacity = 0.7
        self.layer.shadowRadius = 6
        self.layer.masksToBounds = false
        self.clipsToBounds = false
        self.layer.shadowColor = UIColor.lightSanGray.cgColor
        self.containerView.drawBorder(cornerRadius: 6, color: UIColor.mediumSkyGray, width: 1)
        self.editBudgetView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didPressedEditView)))
    }
    
    func setupLabels() {
        titleLabel.textColor = .lisboaGray
        amountLabel.setSantanderTextFont(type: .bold, size: 20.0, color: .lisboaGray)
        amountLabel.adjustsFontSizeToFitWidth = true
        amountLabel.textAlignment = .center
        resumeLabel.textColor = .grafite
        totalSavedLabel.textColor = .mediumSanGray
    }
    
    func formattedMoneyFrom(_ amount: Decimal) -> NSAttributedString {
        let amountEntity = self.amountDecimalToAmountEntity(amount)
        let moneyFont = UIFont.santander(family: .text, type: .bold, size: 26)
        let decorator = MoneyDecorator(amountEntity, font: moneyFont, decimalFontSize: 20.0)
        let formmatedDecorator = decorator.formatAsMillions()
        return formmatedDecorator ?? NSAttributedString()
    }
    
    func formattedMoneyWithoutDecimals(_ amount: Decimal) -> NSAttributedString {
        let amountEntity = self.amountDecimalToAmountEntity(amount)
        let decorator = MoneyDecorator(amountEntity, font: UIFont.santander(family: .text, type: .bold, size: 26))
        let formmatedDecorator = decorator.formatAsMillionsWithoutDecimals()
        return formmatedDecorator ?? NSAttributedString()
    }

    func amountDecimalToAmountEntity(_ value: Decimal) -> AmountEntity {
        return AmountEntity(value: value)
    }
    
    func drawCircleShadow(_ percentage: CGFloat, strokeColor: UIColor) {
        self.circleLayer?.removeFromSuperlayer()
        let finalPercentage = CGFloat(Int(percentage))
        let start: CGFloat = -CGFloat.pi / 2.0
        let end = start + (finalPercentage * 2.0 * .pi / 100.0)
        let circlePath = UIBezierPath(
            arcCenter: CGPoint(x: ovalChartView.frame.size.width / 2.0, y: ovalChartView.frame.size.height / 2.0),
            radius: (ovalChartView.frame.size.width + 6) / 2.0,
            startAngle: start,
            endAngle: end,
            clockwise: true)
        
        let circleLayer = CAShapeLayer()
        self.circleLayer = circleLayer
        circleLayer.path = circlePath.cgPath
        circleLayer.fillColor = UIColor.clear.cgColor
        circleLayer.strokeColor = strokeColor.cgColor
        circleLayer.lineWidth = 12.0
        addCircleShadow()
        ovalChartView.layer.addSublayer(circleLayer)
        animateCircle()
    }
    
    func addCircleShadow() {
        self.circleShadowLayer?.removeFromSuperlayer()
        let circleShadowLayer = CAShapeLayer()
        self.circleShadowLayer = circleShadowLayer
        circleShadowLayer.path = UIBezierPath(
            arcCenter: CGPoint(x: ovalChartView.frame.size.width / 2.0, y: ovalChartView.frame.size.height / 2.0),
            radius: (ovalChartView.frame.size.width + 6) / 2.0,
            startAngle: 0.0,
            endAngle: 2 * .pi,
            clockwise: true).cgPath
        circleShadowLayer.fillColor = UIColor.clear.cgColor
        circleShadowLayer.strokeColor = UIColor.lightSanGray.cgColor
        circleShadowLayer.lineWidth = 12.0
        circleShadowLayer.strokeEnd = 1.0
        ovalChartView.layer.addSublayer(circleShadowLayer)
    }
    
    func animateCircle() {
        let animation = CABasicAnimation(keyPath: "strokeEnd")
        animation.duration = 1.0
        animation.fromValue = 0
        animation.toValue = 1
        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        self.circleLayer?.strokeEnd = 1.0
        self.circleLayer?.add(animation, forKey: "animateCircle")
    }
    
    func setAccessibilityIdentifiers() {
        containerView.accessibilityIdentifier = AccessibilityAnalysisArea.areaCard.rawValue
        titleLabel.accessibilityIdentifier = AccessibilityAnalysisArea.labelSaving.rawValue
        ovalChartView.accessibilityIdentifier = AccessibilityAnalysisArea.oval.rawValue
        resumeLabel.accessibilityIdentifier = AccessibilityAnalysisArea.lastMonth.rawValue
    }
    
    @objc func didPressedEditView() {
        delegate?.didPressBudgetCell(originView: titleLabel, newBudget: false)
    }
}
