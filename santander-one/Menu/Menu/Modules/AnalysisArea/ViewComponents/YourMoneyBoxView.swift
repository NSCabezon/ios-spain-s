//
//  YourMoneyBoxView.swift
//  Menu
//
//  Created by Ignacio González Miró on 04/06/2020.
//

import UIKit
import UI
import CoreFoundationLib

protocol YourMoneyBoxDelegate: AnyObject {
    func didTapInBanner(_ viewModel: OfferBannerViewModel?)
}

class YourMoneyBoxView: UIDesignableView {
    @IBOutlet weak private var stackView: UIStackView!
    @IBOutlet weak private var availableMoneyBox: AvailableMoneyBox!
    @IBOutlet weak private var defaultMoneyBox: OfferBannerView!
    
    weak var delegate: YourMoneyBoxDelegate?
    
    override func getBundleName() -> String {
        return "Menu"
    }
    
    override public func commonInit() {
        super.commonInit()
        self.setupView()
    }
    
    func bannerView() -> OfferBannerView {
        return self.defaultMoneyBox
    }
    
    func configBannerView() {
        self.stackView.removeArrangedSubview(self.availableMoneyBox)
        self.availableMoneyBox.isHidden = true
        self.defaultMoneyBox.delegate = self
    }
    
    func configAvailableView(_ title: String, _ detail: NSAttributedString) {
        self.stackView.removeArrangedSubview(self.defaultMoneyBox)
        self.defaultMoneyBox.isHidden = true
        self.availableMoneyBox.configView(title, detail)
    }
}

private extension YourMoneyBoxView {
    func setupView() {
        self.backgroundColor = .skyGray
        self.defaultMoneyBox.accessibilityIdentifier = AccessibilityAnalysisArea.piggyBanner.rawValue
    }
}

extension YourMoneyBoxView: OfferBannerViewProtocol {
    func didSelectBanner(_ viewModel: OfferBannerViewModel?) {
        delegate?.didTapInBanner(viewModel)
    }
}
