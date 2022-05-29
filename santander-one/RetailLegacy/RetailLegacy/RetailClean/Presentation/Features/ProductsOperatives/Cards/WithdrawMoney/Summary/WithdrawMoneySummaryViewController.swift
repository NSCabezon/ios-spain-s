//
//  WithdrawMoneySummaryViewController.swift
//  RetailClean
//
//  Created by David Gálvez Alonso on 24/02/2020.
//  Copyright © 2020 Ciber. All rights reserved.
//

import UIKit
import CoreFoundationLib
import UI

class WithdrawMoneySummaryViewController: BaseViewController<WithdrawMoneySummaryPresenterProtocol> {
    
    @IBOutlet weak var okImageView: UIImageView!
    @IBOutlet weak var headerTitleLabel: UILabel!
    @IBOutlet weak var headerSubTitleLabel: UILabel!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var footerView: UIView!
    @IBOutlet weak var footerTitleLabel: UILabel!
    @IBOutlet weak var actionStackView: UIStackView!
    @IBOutlet weak var footerStackView: UIStackView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var codeDetailView: SummaryCodeDetailView!
    @IBOutlet weak var qrView: SummaryQRView!
    
    override var progressBarBackgroundColor: UIColor? {
        return .sky30
    }
    
    override static var storyboardName: String {
        return "WithdrawMoneySummary"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setAppearance()
        self.setAccessibility()
        self.setAccessibilityIdentifiers()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.setupNavigationBar()
    }
    
    private func setAppearance() {
        self.view.backgroundColor = UIColor.sky30
        self.scrollView.backgroundColor = UIColor.sky30
        self.navigationController?.navigationBar.setNavigationBarColor(.white)
        self.okImageView.image = Assets.image(named: "icnOkSummary")
        self.headerTitleLabel.text = localized(key: "summe_title_perfect").text
        self.headerTitleLabel.font = UIFont.santander(family: .headline, type: .bold, size: 28)
        self.headerTitleLabel.textColor = UIColor.lisboaGrayNew
        self.headerSubTitleLabel.text = localized(key: "summary_title_successCode").text
        self.footerTitleLabel.text = localized(key: "summary_label_nowThat").text
        self.footerTitleLabel.font = UIFont.santander(family: .text, type: .bold, size: 20)
        self.footerTitleLabel.textColor = UIColor.white
        self.contentView.layer.borderWidth = 1
        self.contentView.layer.borderColor = UIColor.mediumSkyGray.cgColor
        self.footerView.backgroundColor = UIColor.blueAnthracita
        self.infoLabel.font = UIFont.santander(family: .headline, type: .regular, size: 14)
        self.infoLabel.set(localizedStylableText: localized(key: "summary_link_atmClosest"))
        
    }
    
    func setupNavigationBar() {
        let style: NavigationBarBuilder.Style
        if #available(iOS 11.0, *) {
            style = .clear(tintColor: .santanderRed)
        } else {
            style = .custom(background: NavigationBarBuilder.Background.color(UIColor.white), tintColor: UIColor.santanderRed)
        }
        let builder = NavigationBarBuilder(
            style: style,
            title: .title(key: "genericToolbar_title_summary", identifier: "withdrawMoneySummary_title")
        )
        builder.setRightActions(
            .close(action: #selector(finishOperative))
        )
        builder.build(on: self, with: nil)
    }

    @objc private func finishOperative() {
        self.presenter.finishOperativeSelected()
    }
    
    func addActions(_ viewModels: [SummaryActionViewModel]) {
        viewModels.forEach {
            let action = ActionButton()
            action.addSelectorAction(target: self, #selector(didTapOnAction))
            action.setViewModel($0)
            self.actionStackView.addArrangedSubview(action)
        }
    }
    
    public func addAction(_ action: ActionButton) {
        self.actionStackView.addArrangedSubview(action)
    }

    private func addSeparator(stackView: UIStackView) {
        let viewSeparator = UIView()
        viewSeparator.backgroundColor = UIColor.mediumSkyGray
        stackView.addArrangedSubview(viewSeparator)
        let heightConstraint = NSLayoutConstraint(item: viewSeparator, attribute: NSLayoutConstraint.Attribute.height, relatedBy: NSLayoutConstraint.Relation.equal, toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute, multiplier: 1, constant: 1)
        view.addConstraint(heightConstraint)
    }
    
    public final func configureView(footer: [FooterWithdrawSummaryModel]) {
        addSeparator(stackView: footerStackView)
        for item in footer {
            addFooterItem(stackView: footerStackView, title: localized(key: item.title).text, image: Assets.image(named: item.image), identifier: item.identifier, action: item.action)
            addSeparator(stackView: footerStackView)
        }
        //Add safe area extra bottom view
        if #available(iOS 11.0, *) {
            let extraView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 16))
            footerStackView.addArrangedSubview(extraView)
        }
    }
    
    public func setSummaryData(code: String, amount: String, date: String, fee: String, phone: String, codQR: String) {
        codeDetailView.codeLabel.text = code
        codeDetailView.amountLabel.text = amount
        codeDetailView.expiryDateLabel.text = date
        codeDetailView.commissionLabel.text = fee
        codeDetailView.phoneLabel.text = phone
        qrView.setQRImage(codQR: codQR)
    }
    
    private func addFooterItem(stackView: UIStackView, title: String, image: UIImage?, identifier: String? = nil, action: (() -> Void)?) {
        let view = SummaryFooterSubView()
        view.action = action
        view.titleLabel.text = title
        if let identifier = identifier {
            view.titleLabel.accessibilityIdentifier = identifier + "title"
        }
        view.titleImageview.image = image
        stackView.addArrangedSubview(view)
    }
    
    @objc private func didTapOnAction(_ gesture: UIGestureRecognizer) {
        guard
            let actionButton = gesture.view as? ActionButton,
            let summaryAction = actionButton.getViewModel() as? SummaryActionViewModel
            else { return }
        summaryAction.action()
    }
    
    private func setAccessibility() {
        let footerItems = self.footerStackView.arrangedSubviews.compactMap({ $0 as? SummaryFooterSubView })
        footerItems[0].accessibilityIdentifier = AccessibilityWithdrawMoneySummary.areaBtnSendMoney
        footerItems[1].accessibilityIdentifier = AccessibilityWithdrawMoneySummary.areaBtnGlobalPosition
        footerItems[2].accessibilityIdentifier = AccessibilityWithdrawMoneySummary.areaBtnImprove
        actionStackView.arrangedSubviews[0].accessibilityIdentifier = AccessibilityWithdrawMoneySummary.btnATM
        actionStackView.arrangedSubviews[1].accessibilityIdentifier = AccessibilityWithdrawMoneySummary.btnShare
    }
    
    private func setAccessibilityIdentifiers() {
        headerTitleLabel.accessibilityIdentifier = "withdrawMoneySummary_header_title"
        headerSubTitleLabel.accessibilityIdentifier = "withdrawMoneySummary_header_subtitle"
        footerTitleLabel.accessibilityIdentifier = "withdrawMoneySummary_footer_title"
        infoLabel.accessibilityIdentifier = "withdrawMoneySummary_infoLabel"
        codeDetailView.setAccessibilityIdentifiers(identifier: "withdrawMoneySummary")
        qrView.setAccessibilityIdentifiers(identifier: "withdrawMoneySummary_qrImage")
    }
}
