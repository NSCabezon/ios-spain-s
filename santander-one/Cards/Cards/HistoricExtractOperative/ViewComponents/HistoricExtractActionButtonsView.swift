//
//  HistoricExtractActionButtonsView.swift
//  Cards
//
//  Created by Ignacio González Miró on 19/11/2020.
//

import Foundation
import UI
import CoreFoundationLib

protocol DidSelectInActionButtonsDelegate: AnyObject {
    func didTapInShopMap()
    func didTapInPdfExtract()
}

final class HistoricExtractActionButtonsView: UIDesignableView {
    @IBOutlet private weak var shopMapView: UIView!
    @IBOutlet private weak var shopMapBgImage: UIImageView!
    @IBOutlet private weak var shopMapTitleLabel: UILabel!
    @IBOutlet private weak var pdfExtractView: UIView!
    @IBOutlet private weak var pdfExtractImage: UIImageView!
    @IBOutlet private weak var pdfExtractTitleLabel: UILabel!
    @IBOutlet private weak var topSeparatorView: UIView!
    @IBOutlet private weak var separatorView: UIView!
    
    weak var delegate: DidSelectInActionButtonsDelegate?
    
    override func getBundleName() -> String {
        return "Cards"
    }
    
    override func commonInit() {
        super.commonInit()
        self.setupView()
    }
    
    func enableShoppingMapPill() {
        self.shopMapView.isUserInteractionEnabled = true
        self.shopMapView.alpha = 1.0
    }
    
    func enableExtractPdfPill() {
        self.pdfExtractView.isUserInteractionEnabled = true
        self.pdfExtractView.alpha = 1.0
    }
    
    func disableShoppingMapPill() {
        self.shopMapView.isUserInteractionEnabled = false
        self.shopMapView.alpha = 0.5
    }
    
    func disableExtractPdfPill() {
        self.pdfExtractView.isUserInteractionEnabled = false
        self.pdfExtractView.alpha = 0.5
    }
}

private extension HistoricExtractActionButtonsView {
    func setupView() {
        self.backgroundColor = .skyGray
        self.separatorView.backgroundColor = .mediumSkyGray
        self.topSeparatorView.backgroundColor = .mediumSkyGray
        self.setLabels()
        self.setupShopMapPill()
        self.setupPdfExtractPill()
        self.setAccessibilityIds()
    }
    
    func setLabels() {
        self.shopMapTitleLabel.font = UIFont.santander(family: .text, type: .regular, size: 16)
        self.shopMapTitleLabel.textAlignment = .left
        self.shopMapTitleLabel.numberOfLines = 2
        self.pdfExtractTitleLabel.font = UIFont.santander(family: .text, type: .regular, size: 16)
    }
    
    func setShoppingMapView() {
        self.shopMapView.backgroundColor = .clear
        self.addShadow(forView: shopMapView)
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapInShopMapPill))
        self.shopMapView.addGestureRecognizer(tapGesture)
    }
    
    func setExtractPdfView() {
        self.pdfExtractView.backgroundColor = .white
        self.addBorder(forView: pdfExtractView)
        self.addShadow(forView: pdfExtractView)
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapInPdfExtractPill))
        self.pdfExtractView.addGestureRecognizer(tapGesture)
    }
    
    func setupShopMapPill() {
        self.shopMapBgImage.image = Assets.image(named: "imgPurchaseModule")
        self.shopMapBgImage.contentMode = .scaleToFill
        self.shopMapTitleLabel.configureText(withKey: "generic_button_map")
        self.setShoppingMapView()
    }
    
    func setupPdfExtractPill() {
        self.pdfExtractImage.image = Assets.image(named: "icnPdf")
        self.pdfExtractTitleLabel.configureText(withKey: "generic_button_pdfStatement")
        self.setExtractPdfView()
    }
    
    func addBorder(forView view: UIView?) {
        view?.layer.borderWidth = 1
        view?.layer.cornerRadius = 5
        view?.layer.borderColor = UIColor.mediumSkyGray.cgColor
    }
    
    func addShadow(forView view: UIView?) {
        view?.layer.shadowOffset = CGSize(width: 1, height: 2)
        view?.layer.shadowRadius = 5
        view?.layer.shadowOpacity = 0.7
        view?.layer.shadowColor = UIColor.mediumSkyGray.cgColor
        view?.layer.masksToBounds = false
        view?.clipsToBounds = false
    }
    
    func setAccessibilityIds() {
        self.shopMapBgImage.accessibilityIdentifier = AccessibilityHistoricExtract.shoppingMapImage.rawValue
        self.shopMapTitleLabel.accessibilityIdentifier = AccessibilityHistoricExtract.shoppingMapTitle.rawValue
        self.shopMapView.accessibilityIdentifier = AccessibilityHistoricExtract.shoppingMapPill.rawValue
        self.pdfExtractImage.accessibilityIdentifier = AccessibilityHistoricExtract.extractPdfImage.rawValue
        self.pdfExtractTitleLabel.accessibilityIdentifier = AccessibilityHistoricExtract.extractPdfTitle.rawValue
        self.pdfExtractView.accessibilityIdentifier = AccessibilityHistoricExtract.extractPdfPill.rawValue
    }
    
    // MARK: Actions
    @objc func didTapInShopMapPill() {
        delegate?.didTapInShopMap()
    }
    
    @objc func didTapInPdfExtractPill() {
        delegate?.didTapInPdfExtract()
    }
}
