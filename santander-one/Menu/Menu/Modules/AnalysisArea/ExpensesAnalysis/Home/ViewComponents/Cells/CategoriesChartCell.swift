//
//  CategoriesChartCell.swift
//  Menu
//
//  Created by Mario Rosales Maillo on 9/6/21.
//

import UIKit
import CoreFoundationLib
import UI

final class CategoriesChartCell: UICollectionViewCell {
    
    public enum Config {
        static let disclaimerHeight: CGFloat = 55.0
        static let disclaimerFont: UIFont = UIFont.santander(family: .text, type: .regular, size: 12.0)
        static let disclaimerColor: UIColor = .brownishGray
    }
    
    @IBOutlet private weak var chart: InteractiveSectoredChartView!
    @IBOutlet private weak var disclaimerLabel: UILabel!
    @IBOutlet private weak var disclaimerImage: UIImageView!
    @IBOutlet private weak var toolTipButton: UIButton!
    @IBOutlet private weak var disclaimerConstraint: NSLayoutConstraint!
    private var constraintWasResized: Bool = false
    @IBOutlet private weak var disclaimerLabelWidthConstraint: NSLayoutConstraint!
    private var type: ExpensesIncomeCategoriesChartType = .expenses
    
    override func prepareForReuse() {
        super.prepareForReuse()
        chart.reset()
    }
    
    func load(with viewModel: ExpensesIncomeCategoriesViewModel,
              and type: ExpensesIncomeCategoriesChartType) {
        self.configureDisclaimerLabel(with: viewModel, and: type)
        self.setUpChartAndImage(with: viewModel, and: type)
        toolTipButton.setImage(Assets.image(named: "icnInfoRedLight"), for: .normal)
        self.toolTipButton.isAccessibilityElement = true
        self.type = type
        layoutSubviews()
    }
    
    @IBAction func didSelectToolTipButton(_ sender: UIButton) {
        let styledText: LocalizedStylableText = getTooltipText()
        let peakHeight: CGFloat = 8.0
        let bubbleConfiguration = BubbleLabelConfiguration(fixedWidth: 248.0,
                                                           frameSeparation: 5.0,
                                                           peakHeight: peakHeight,
                                                           leftMargin: 16.0)
        let senderViewFrame = sender.convert(sender.bounds, to: window)
        let bubble = BubbleLabelView(associated: sender,
                                     text: styledText.text,
                                     position: .top,
                                     fixedWidthIsOn: false,
                                     configuration: bubbleConfiguration,
                                     xPeak: senderViewFrame.midX,
                                     yPeak: senderViewFrame.maxY)
        bubble.frame.origin.y = senderViewFrame.minY - (bubble.frame.height) + 18
        bubble.frame.origin.x = senderViewFrame.midX - (bubble.frame.width) * 3/4
        window?.addSubview(bubble)
        addCloseCourtain()
    }
}

private extension CategoriesChartCell {
    func configureDisclaimerLabel(with viewModel: ExpensesIncomeCategoriesViewModel,
                                  and type: ExpensesIncomeCategoriesChartType) {
        disclaimerConstraint.constant = viewModel.showDisclamerView(for: type) ? Config.disclaimerHeight : 0
        disclaimerLabel.font = .santander(family: .text, type: .regular, size: 12)
        disclaimerLabel.textColor = .brownishGray
        disclaimerLabel.configureText(withLocalizedString: viewModel.getDisclaimerText(for: type))
        resizeLabelWidth()
    }
    
    func setUpChartAndImage(with viewModel: ExpensesIncomeCategoriesViewModel,
                            and type: ExpensesIncomeCategoriesChartType) {
        chart.sectors = viewModel.getFormattedChartData(for: type)
        let centerImage = Assets.image(named: viewModel.getCenterIconKey(for: type))
        disclaimerImage.image = centerImage
        chart.centerIcon = centerImage
        chart.centerAttributedTextTop = viewModel.getCenterAttributedTextTop(for: type)
        chart.centerAttributedTextBottom = viewModel.getCenterAttributedTextBottom(for: type)
        chart.setNeedsDisplay()
    }
    
    func resizeLabelWidth() {
        guard !self.constraintWasResized else { return }
        let size = disclaimerLabel.intrinsicContentSize.width
        disclaimerLabelWidthConstraint.constant = size * 0.55
        self.constraintWasResized = true
    }
    
    func addCloseCourtain() {
        let curtain = UIView(frame: UIScreen.main.bounds)
        curtain.backgroundColor = UIColor.clear
        curtain.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(closeBubble(_:))))
        curtain.isUserInteractionEnabled = true
        window?.addSubview(curtain)
    }
    
    @objc func closeBubble(_ sender: UITapGestureRecognizer) {
        window?.subviews.forEach { ($0 as? BubbleLabelView)?.dismiss() }
        sender.view?.removeFromSuperview()
    }
    
    func getTooltipText() -> LocalizedStylableText {
        switch type {
        case .incomes:
            return LocalizedStylableText(text: "", styles: nil)
        case .expenses:
            return localized("analysis_text_tooltipExpenses")
        case .payments:
            return localized("analysis_text_tooltipPayments")
        }
    }
}
