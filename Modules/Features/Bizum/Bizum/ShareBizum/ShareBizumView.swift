//
//  ShareBizumView.swift
//  Bizum
//
//  Created by Laura González on 01/12/2020.
//

import Foundation
import UIKit
import UI
import CoreFoundationLib
import ESUI

final class ShareBizumView: UIShareView {
    @IBOutlet weak var containerView: UIView!
    @IBOutlet private weak var santanderImage: UIImageView!
    @IBOutlet private weak var bizumImage: UIImageView!
    @IBOutlet private weak var nameTitle: UILabel!
    @IBOutlet private weak var brokenTicketImage: UIImageView!
    @IBOutlet private weak var amountTitle: UILabel!
    @IBOutlet private weak var amountText: UILabel!
    @IBOutlet private weak var conceptTitle: UILabel!
    @IBOutlet private weak var conceptText: UILabel!
    @IBOutlet private weak var sentDateTitle: UILabel!
    @IBOutlet private weak var sentDateText: UILabel!
    @IBOutlet private weak var stackView: UIStackView!
    @IBOutlet private weak var sentDateView: UIView!
    @IBOutlet private weak var separatorView: UIView!
    
    init() {
        super.init(nibName: "ShareBizumView", bundleName: .module)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setAccessibilityIdentifiers()
    }
    
    func setInfoFromDetail(_ viewModel: ShareBizumDetailViewModel) {
        nameTitle.set(localizedStylableText: viewModel.transferTitle)
        amountText.attributedText = viewModel.amountText
        conceptText.text = viewModel.concept
        sentDateText.text = viewModel.transferDate
        self.containerView.layoutIfNeeded()
    }
    
    func setInfoFromSummary(_ viewModel: ShareBizumSummaryViewModel) {
        nameTitle.set(localizedStylableText: viewModel.transferTitle ?? .empty)
        amountText.attributedText = viewModel.amountText
        conceptText.text = viewModel.concept
        self.setSentDateView(with: viewModel)
        self.containerView.layoutIfNeeded()
    }
}

private extension ShareBizumView {
    func setupView() {
        santanderImage.image = Assets.image(named: "icnSantander")
        brokenTicketImage.image = Assets.image(named: "imgTornBig")
        bizumImage.image = ESAssets.image(named: "icnBizumBrand")
        amountTitle.set(localizedStylableText: localized("bizumDetail_label_amount"))
        conceptTitle.set(localizedStylableText: localized("bizumDetail_label_concept"))
        sentDateTitle.set(localizedStylableText: localized("bizumDetail_label_sentDate"))
        nameTitle.setSantanderTextFont(type: .regular, size: 14.4, color: .lisboaGray)
        amountTitle.setSantanderTextFont(type: .regular, size: 13.0, color: .brownishGray)
        conceptTitle.setSantanderTextFont(type: .regular, size: 13.0, color: .brownishGray)
        sentDateTitle.setSantanderTextFont(type: .regular, size: 13.0, color: .brownishGray)
        amountText.setSantanderTextFont(type: .bold, size: 28.8, color: .lisboaGray)
        conceptText.setSantanderTextFont(type: .italic, size: 14.0, color: .lisboaGray)
        sentDateText.setSantanderTextFont(type: .regular, size: 14.0, color: .lisboaGray)
    }
    
    func setAccessibilityIdentifiers() {
        santanderImage.accessibilityIdentifier = "icnSantander"
        bizumImage.accessibilityIdentifier = "icnBizumBrand"
        brokenTicketImage.accessibilityIdentifier = "imgTornBig"
        amountTitle.accessibilityIdentifier = "bizumDetail_label_amount"
        conceptTitle.accessibilityIdentifier = "bizumDetail_label_concept"
        sentDateTitle.accessibilityIdentifier = "bizumDetail_label_sentDate"
        nameTitle.accessibilityIdentifier = "bizum_label_shareWith"
        amountText.accessibilityIdentifier = "bizumDetail_label_amountText"
        conceptText.accessibilityIdentifier = "bizumDetail_label_conceptText"
        sentDateText.accessibilityIdentifier = "bizumDetail_label_sentDateText"
    }
    
    func setSentDateView(with viewModel: ShareBizumSummaryViewModel) {
        if let dateText = viewModel.sentDateFormatted {
            self.sentDateText.text = dateText
            self.sentDateTitle.configureText(withKey: viewModel.sentDateTitle)
        } else {
            self.sentDateView.isHidden = true
            self.stackView.removeArrangedSubview(self.sentDateView)
            self.stackView.removeArrangedSubview(self.separatorView)
        }
    }
}
