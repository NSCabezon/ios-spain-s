//
//  ClassicGradientColumn.swift
//  GlobalPosition
//
//  Created by alvola on 30/01/2020.
//

import UIKit
import UI
import CoreFoundationLib

final class ClassicGradientColumn: DesignableView {
    
    @IBOutlet weak var containerStack: UIStackView?
    @IBOutlet weak var bottomLabel: UILabel!
    @IBOutlet weak var topLabel: UILabel!
    @IBOutlet weak var barView: UIView!
    @IBOutlet private weak var predictiveExpenseBarView: UIView!
    @IBOutlet weak var baseLineView: UIView!
    @IBOutlet var barHeightConstraint: NSLayoutConstraint?
    @IBOutlet private weak var predictiveBarHeightConstraint: NSLayoutConstraint!
    private weak var gradient: CAGradientLayer?
    private weak var roundedShape: CAShapeLayer?
    private weak var predictiveRoundedShape: CAShapeLayer?
    @IBOutlet public weak var predictiveTooltipAreaView: UIView!
    @IBOutlet private weak var predictiveTooltipHeight: NSLayoutConstraint!
    
    public var predictiveExpense: Decimal?
    private var imBlurred: Bool?
    private var monthInfo: String?
    
    private var dottedBorderLayer: CAShapeLayer?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupView()
    }
    
    private func setupView() {
        setupStackView()
        setupTopLabel()
        setupBarView()
        setupPredictiveExpenseBarView()
        baseLineView.backgroundColor = UIColor.darkRedGraphic
        setupBottomLabel()
        setAccessibilityIdentifiers()
    
        topLabel.isHidden = true
        barView.isHidden = true
        predictiveExpenseBarView.isHidden = true
    }
    
    func setBarHeight(_ total: CGFloat, contentHeight: CGFloat) {
        let leftSpace = min(max(total, 0), 1)
        let barHeight = contentHeight - bottomLabel.frame.height - baseLineView.frame.height * 2
        self.barHeightConstraint?.constant = barHeight * leftSpace
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        containerStack?.layoutIfNeeded()
        self.gradient?.frame = barView.bounds
        let rounded = UIBezierPath(roundedRect: barView.bounds, byRoundingCorners: [.topLeft, .topRight], cornerRadii: CGSize(width: 5, height: 5))
        self.roundedShape?.path = rounded.cgPath
        self.roundedShape?.frame = barView.bounds
        
        if let imBlurred = imBlurred {
            checkBlur(imBlurred)
        }
    }
    
    func checkBlur(_ imBlurred: Bool) {
        topLabel.removeBlur()
        if imBlurred {
            DispatchQueue.main.async {
                self.topLabel.blur(5.0, 5.0)
            }
        }
    }
    
    func setBaseLineColor(_ color: UIColor) {
        baseLineView.backgroundColor = color
    }
    
    func setBottomText(_ text: String?) {
        bottomLabel.text = text
    }
    
    func setTopText(_ text: String?) {
        self.topLabel.text = text
    }
    
    func setBlurred(_ blurred: Bool) {
        self.imBlurred = blurred
        self.setAccessibility()
    }
    
    func setMonthInfo(_ text: String) {
        self.monthInfo = text
    }
    
    func setBottomLabelFont(_ font: UIFont, color: UIColor) {
        bottomLabel.font = font
        bottomLabel.textColor = color
    }
    
    func setPredictiveBarHeight(_ total: CGFloat, contentHeight: CGFloat) {
        var barHeight = contentHeight - bottomLabel.frame.height - baseLineView.frame.height * 2
        if barHeight < 0 {
            barHeight = contentHeight - baseLineView.frame.height * 2
        }
        self.predictiveBarHeightConstraint.constant = barHeight * total
        dottedBorderLayer?.isHidden = false
        setAreaTooltipView()
        reconfigureBorder()
    }
    
    func setMaxPredictiveBarHeight(_ height: CGFloat) {
        self.predictiveBarHeightConstraint.constant = height - baseLineView.frame.height * 2 - bottomLabel.frame.height - topLabel.frame.height
        setAreaTooltipView()
        reconfigureBorder()
    }
    
    func setupWith(_ info: ExpensesBarInfo, contentHeight: CGFloat) {
        clipsToBounds = false
        self.setBlurred(info.blurred)
        self.setTopText(info.topTitle)
        self.setBottomText(info.bottomTitle)
        self.setBarHeight(CGFloat(info.barSize), contentHeight: contentHeight)
        self.setMonthInfo(info.monthInfo)
        self.setAccessibility()
    }
    
    func show(_ animated: Bool) {
        guard animated else {
            self.topLabel.isHidden = false
            self.barView.isHidden = false
            self.predictiveExpenseBarView.isHidden = false
            self.layoutIfNeeded()
            return
        }
        UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.2, options: .curveEaseInOut, animations: {
            self.topLabel.isHidden = false
            self.barView.isHidden = false
            self.layoutIfNeeded()
        }, completion: { _ in
            if self.predictiveTooltipHeight.constant != 0 {
                self.showPredictiveExpenseBar(animated)
            }
        })
    }
    
    public func reconfigureBorder() {
        layoutIfNeeded()
        let frameSize = predictiveExpenseBarView.frame.size
        dottedBorderLayer?.bounds = predictiveExpenseBarView?.bounds ?? CGRect.zero
        dottedBorderLayer?.position = CGPoint(x: frameSize.width/2, y: frameSize.height/2)
        dottedBorderLayer?.path = UIBezierPath(roundedRect: predictiveExpenseBarView?.bounds ?? CGRect.zero, cornerRadius: 5).cgPath
    }
    
    // MARK: - Helpers
    
    fileprivate func setupStackView() {
        containerStack?.spacing = 0
        containerStack?.distribution = .fill
        containerStack?.alignment = .center
    }
    
    fileprivate func setupTopLabel() {
        topLabel.clipsToBounds = false
        topLabel.font = .santander(family: .text, type: .bold, size: 12.0)
        topLabel.textAlignment = .center
        topLabel.textColor = .lisboaGray
    }
    
    fileprivate func setupBarView() {
        let rounded = UIBezierPath(roundedRect: barView.bounds, byRoundingCorners: [.topLeft, .topRight], cornerRadii: CGSize(width: 5, height: 5))
        let shape = CAShapeLayer()
        shape.frame = barView.frame
        shape.path = rounded.cgPath
        self.roundedShape = shape
        barView.layer.mask = shape
        
        barView.layer.cornerRadius = 5
        let gradient = CAGradientLayer()
        self.gradient = gradient
        gradient.frame = barView.bounds
        gradient.colors = [UIColor.lightRedGraphic.withAlphaComponent(0.96).cgColor, UIColor.darkRedGraphic.withAlphaComponent(0.96).cgColor]
        barView.layer.addSublayer(gradient)
    }
    
    fileprivate func setupBottomLabel() {
        bottomLabel.font = .santander(family: .text, type: .regular, size: 12.0)
        bottomLabel.textColor = .mediumSanGray
        bottomLabel.textAlignment = .center
    }
    
    // MARK: Accessibility
    
    private func setAccessibility() {
        self.barView.isAccessibilityElement = true
        if bottomLabel.text != localized("pg_label_yourExpenses") {
            self.bottomLabel.isAccessibilityElement = false
        }
        self.barView.accessibilityIdentifier = AccessibilityGlobalPosition.gradientColumn
        guard let monthInf = self.monthInfo,
              let topLabelText = self.topLabel.text else { return }
        if #available(iOS 11.0, *) {
            let textLabel: NSAttributedString = NSAttributedString(string: "\(monthInf); \(topLabelText)", attributes: [.accessibilitySpeechQueueAnnouncement: true])
            self.barView.accessibilityAttributedLabel = textLabel
        } else {
            self.barView.accessibilityLabel = "\(monthInf); /n \(topLabelText)"
        }
    }
}

private extension ClassicGradientColumn {
    func setupPredictiveExpenseBarView() {
        predictiveExpenseBarView.layer.cornerRadius = 5
        predictiveExpenseBarView.backgroundColor = UIColor.lightRedGraphic.withAlphaComponent(0.12)
        
        dottedBorderLayer = CAShapeLayer()
        dottedBorderLayer?.bounds = predictiveExpenseBarView?.bounds ?? CGRect.zero
        dottedBorderLayer?.position = CGPoint(x: predictiveExpenseBarView.frame.size.width/2, y: predictiveExpenseBarView.frame.size.height/2)
        dottedBorderLayer?.fillColor = UIColor.clear.cgColor
        dottedBorderLayer?.strokeColor = UIColor.redGraphic.cgColor
        dottedBorderLayer?.lineWidth = 1.0
        dottedBorderLayer?.lineJoin = .round
        dottedBorderLayer?.lineDashPattern = [2, 2]
        dottedBorderLayer?.path = UIBezierPath(roundedRect: predictiveExpenseBarView?.bounds ?? CGRect.zero, cornerRadius: 5).cgPath
        dottedBorderLayer?.isHidden = true
        predictiveExpenseBarView.layer.addSublayer(dottedBorderLayer ?? CAShapeLayer())
    }
    
    func setAreaTooltipView() {
        predictiveTooltipHeight.constant = predictiveBarHeightConstraint.constant - (barHeightConstraint?.constant ?? 0.0)
    }
    
    func showPredictiveExpenseBar(_ animated: Bool) {
        UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.2, options: .curveEaseInOut, animations: {
            self.predictiveExpenseBarView.isHidden = false
            self.layoutIfNeeded()
        }, completion: nil)
    }
    
    func setAccessibilityIdentifiers() {
        self.accessibilityIdentifier = "pgClassic_header_yourExpenses_view"
        topLabel.accessibilityIdentifier = "pgClassic_header_yourExpenses_valueMonth"
        bottomLabel.accessibilityIdentifier = "pgClassic_header_yourExpenses_month"
    }
}
