//
//  SmartFinantialStatusView.swift
//  GlobalPosition
//
//  Created by Boris Chirino Fernandez on 10/01/2020.
//

import UI
import CoreFoundationLib

final class SimpleFinancialStatusView: DesignableView {
    @IBOutlet weak var leftLabel: UILabel!
    @IBOutlet weak var infoButton: UIButton!
    @IBOutlet weak var budgetLabel: UILabel!
    @IBOutlet weak var xpenseLabel: UILabel!
    @IBOutlet weak var budgetImageView: UIImageView!
    @IBOutlet weak var xpenseImageView: UIImageView!
    
    /// This attribute must be set in order to display text inside the popup, once it appear
    struct PopUpConfiguration {
        let text: LocalizedStylableText
        let subtitle: LocalizedStylableText?
        let position: BubbleLabelView.BubblePosition
    }
    
    private var popUpConfiguration: PopUpConfiguration?
    
    override func commonInit() {
        super.commonInit()
        setupUI()
    }
    
    func refreshLabels() {
        budgetLabel.text = localized("pg_label_budget")
        xpenseLabel.text = localized("search_tab_expenses")
        leftLabel.text = localized("pg_label_yourExpenses")
    }
    
    @IBAction func didTapOnInfoButton(sender: UIButton) {
        guard let configuration = popUpConfiguration else {
            return
        }
        if configuration.subtitle == nil {
            BubbleLabelView.startWith(associated: sender,
                                      text: configuration.text.text,
                                      position: configuration.position)
        } else {
            guard let window = window,
                  !(window.subviews.contains { $0 is BubbleMultipleLabelView }) else { return }
            guard let subtitle = configuration.subtitle  else { return }
            window.addSubview(BubbleMultipleLabelView(associated: sender,
                                                      localizedStyleText: configuration.text,
                                                      subText: subtitle.text,
                                                      bubbleId: .yourMoneyBubble,
                                                      window: window))
            addCloseCourtain()
        }
    }
    
    /// Configure the popup
    /// - Parameter configuration: configure text and popUp type
    func configurePopUpWith(configuration: PopUpConfiguration) {
        popUpConfiguration = configuration
    }
}

// MARK: - Private methods

private extension SimpleFinancialStatusView {
    func setupUI() {
        let iconImage = Assets.image(named: "icnInfoWhite")

        budgetImageView.image = Assets.image(named: "icnBudgetChart")
        xpenseImageView.image = Assets.image(named: "icnExpensesChart")
        infoButton.setImage(iconImage, for: .normal)
                
        leftLabel.textColor = .white
        
        budgetLabel.font = UIFont.santander(family: .text, type: .bold, size: 12.0)
        budgetLabel.alpha = 0.75
        budgetLabel.text = localized("pg_label_budget")

        xpenseLabel.font = UIFont.santander(family: .text, type: .bold, size: 12.0)
        xpenseLabel.alpha = 0.75
        xpenseLabel.text = localized("search_tab_expenses")
        
        let txt: LocalizedStylableText = localized("pg_label_yourExpenses")
        self.leftLabel.configureText(withLocalizedString: txt,
                                     andConfiguration: LocalizedStylableTextConfiguration(font: .santander(family: .headline, type: .regular, size: 14.0)))
        self.leftLabel.set(localizedStylableText: txt)
        self.setAccesibilityIdentifiers()
    }
    
    func setAccesibilityIdentifiers() {
        self.leftLabel.accessibilityIdentifier = AccessibilityGlobalPosition.pgLabelYourExpenses
        self.budgetLabel.accessibilityIdentifier = AccessibilityGlobalPosition.pgLabelBudget
        self.xpenseLabel.accessibilityIdentifier = AccessibilityGlobalPosition.pgLabelExpenses
        self.budgetImageView.accessibilityIdentifier = AccessibilityGlobalPosition.pgImageBudget
        self.xpenseImageView.accessibilityIdentifier = AccessibilityGlobalPosition.pgImageExpenses
    }
    
    // MARK: - Needed when using BubbleMultipleLabelView
    
    func addCloseCourtain() {
        let curtain = UIView(frame: UIScreen.main.bounds)
        curtain.backgroundColor = UIColor.clear
        curtain.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(closeBubble(_:))))
        curtain.isUserInteractionEnabled = true
        window?.addSubview(curtain)
    }
    
    @objc  func closeBubble(_ sender: UITapGestureRecognizer) {
        window?.subviews.forEach { ($0 as? BubbleMultipleLabelView)?.dismiss() }
        sender.view?.removeFromSuperview()
    }
}
