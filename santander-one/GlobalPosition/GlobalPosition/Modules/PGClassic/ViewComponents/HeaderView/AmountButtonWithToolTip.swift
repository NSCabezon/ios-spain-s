//
//  AmountButtonWithToolTip.swift
//  Account
//
//  Created by Carlos Monfort Gómez on 26/11/2019.
//

import UIKit
import UI
import CoreFoundationLib

enum TooltipType {
    case gray
    case red
}

class AmountButtonWithToolTip: DesignableView, DiscreteModeConformable {
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var fakeButton: UIButton!
    @IBOutlet weak var subtitle: BluringLabel!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var tooltipButton: UIButton!
    @IBOutlet weak var toolTipstackView: UIStackView!
    
    private var tooltipText = ""
    var discreteMode: Bool = false {
        didSet {
            subtitle.isBlured = discreteMode
        }
    }
    private var alternateToNotSelectedForFirstTime: Bool = false
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setSubtitle()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setSubtitle()
        self.setAccessibilty()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.setSubtitle()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.subtitle.isBlured = self.discreteMode
    }
    
    var titleSelectedFont: UIFont = UIFont.santander(family: .text, type: .bold, size: 12.0)
    var titleUnselectedFont: UIFont = UIFont.santander(family: .text, type: .regular, size: 12.0)
    var titleSelectedColor: UIColor = UIColor.darkTorquoise
    var titleUnselectedColor: UIColor = UIColor.grafite
    var subtitleSelectedFont: UIFont = UIFont.santander(family: .text, type: .bold, size: 26.0)
    var subtitleUnselectedFont: UIFont = UIFont.santander(family: .text, type: .regular, size: 22.0)
    var subtitleSelectedColor: UIColor = UIColor.lisboaGray
    var subtitleUnselectedColor: UIColor = UIColor.grafite
    
    var onTapAction: (() -> Void)?
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        self.onTapAction?()
    }
    
    func setTitle(_ title: NSAttributedString?) {
        self.title.attributedText = title
        self.setAmountLabelAccessibility()
    }
    
    func setSubtitle(_ subtitle: NSAttributedString?) {
        self.subtitle.attributedText = subtitle
        self.setAmountLabelAccessibility()
    }
    
    func setTooltipStyle(_ tooltipType: TooltipType) {
        if tooltipType == .gray {
            tooltipButton.setImage(Assets.image(named: "icnInfoWhitePg"), for: .normal)
        } else {
            tooltipButton.setImage(Assets.image(named: "icnInfoPg"), for: .normal)
        }
        tooltipButton.widthAnchor.constraint(equalToConstant: 20).isActive = true
        tooltipButton.heightAnchor.constraint(equalToConstant: 20).isActive = true
    }
    
    func setDiscreteMode(_ enabled: Bool) {
        self.discreteMode = enabled
    }
    
    func setSelected(isSelected: Bool) {
        if alternateToNotSelectedForFirstTime {
            self.subtitle.renderMargin = isSelected ? 25 : 0.0
        }
        self.subtitle.isBlured = self.discreteMode
        alternateToNotSelectedForFirstTime = true
    }
    
    func setTooltipText(_ text: String) {
        tooltipText = text
    }
    
    @IBAction func showToolTip(_ sender: UIButton) {
        guard let window = window,
              !(window.subviews.contains { $0 is BubbleMultipleLabelView }) else { return }
        let subview = BubbleMultipleLabelView(associated: tooltipButton,
                                              localizedStyleText: localized(tooltipText),
                                              subText: localized("tooltip_text_pgMoneyFinancingRemember"),
                                              bubbleId: .yourMoneyBubble,
                                              window: window)
        window.addSubview(subview)
    }
}

private extension AmountButtonWithToolTip {
    private func setSubtitle() {
        subtitle.blurRadius = 14
        subtitle.applyTextAlignmentToAttributedText = true
        subtitle.translatesAutoresizingMaskIntoConstraints = false
        subtitle.clipsToBounds = false
        subtitle.adjustsFontSizeToFitWidth = true
        subtitle.minimumScaleFactor = 0.2
    }
    
    @objc private func closeBubble(_ sender: UITapGestureRecognizer) {
        window?.subviews.forEach { ($0 as? BubbleMultipleLabelView)?.dismiss() }
        sender.view?.removeFromSuperview()
    }
    
    private func setAccessibilityIdentifiers() {
        self.fakeButton.accessibilityIdentifier = AccessibilityGlobalPosition.btnYourBalanceToolTip
        self.title.accessibilityIdentifier = AccessibilityGlobalPosition.pgLabelTotMoney
        self.subtitle.accessibilityIdentifier = AccessibilityGlobalPosition.pgLabeTotMoneyValue
        self.tooltipButton.accessibilityIdentifier = AccessibilityGlobalPosition.icnInfoWhitePG
    }
    
    private func setAccessibilty() {
        self.setAccessibilityIdentifiers()
        self.title.isAccessibilityElement = false
        self.tooltipButton.isAccessibilityElement = false
        self.fakeButton.isAccessibilityElement = true
        self.fakeButton.accessibilityLabel = localized("pg_label_totMoney")
    }
    
    func setAmountLabelAccessibility() {
        guard let label = self.subtitle.attributedText?.string else { return }
        let billons = localized("voiceover_billions").text
        let millons = localized("voiceover_millons").text
        self.subtitle.accessibilityLabel = label.replacingOccurrences(of: "B", with: billons)
        self.subtitle.accessibilityLabel = label.replacingOccurrences(of: "M", with: millons)
    }
}
