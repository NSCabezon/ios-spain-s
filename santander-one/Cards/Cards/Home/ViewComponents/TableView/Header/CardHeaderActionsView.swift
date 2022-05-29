//
//  CardsTableViewHeader.swift
//  Cards
//
//  Created by Juan Carlos López Robles on 10/24/19.
//

import UIKit
import CoreFoundationLib
import UI

protocol CardHeaderActionsViewDelegate: AnyObject {
    func didTapOnFilterMovements()
    func didTapOnDownloadMovements()
    func didTapOnMoreOptions()
    func didSelectPendingMovement()
}

final class CardHeaderActionsView: XibView {
    
    weak var delegate: CardHeaderActionsViewDelegate?
    @IBOutlet weak var movementsLabel: UILabel!
    @IBOutlet weak var plusButonView: UIView!
    @IBOutlet weak var plusImageView: UIImageView!
    @IBOutlet weak var downloadButton: PressableButton!
    @IBOutlet weak var filterButton: PressableButton!
    @IBOutlet weak var pendingMovementButton: PressableButton!
    @IBOutlet weak var pdfLabel: UILabel!
    @IBOutlet weak var filterLabel: UILabel!
    @IBOutlet weak var pendingMovementLabel: UILabel!
    @IBOutlet weak var pendingMovementView: UIView!
    @IBOutlet weak var downLoadPDFView: UIView!
    @IBOutlet weak var plusButton: UIButton!
    
    convenience init() {
        let frame = CGRect(x: 0, y: 0, width: 0, height: 60)
        self.init(frame: frame)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    func setupView() {
        self.plusImageView.image = Assets.image(named: "icnPlus")
        self.plusButonView.layer.borderWidth = 1
        self.plusButonView.layer.cornerRadius = plusButonView.frame.height / 2
        self.plusButonView.layer.borderColor = UIColor.mediumSkyGray.cgColor
        self.plusButonView.backgroundColor = UIColor.skyGray
        self.movementsLabel.text =  localized("productHome_label_transaction").uppercased()
        self.movementsLabel.font = UIFont.santander(family: .text, type: .bold, size: 16)
        self.downloadButton.setImage(Assets.image(named: "icnDownload"), for: .normal)
        self.pdfLabel.configureText(withKey: "generic_button_downloadPDF")
        self.pdfLabel.textColor = UIColor.darkTorquoise
        self.pdfLabel.font = UIFont.santander(family: .text, type: .regular, size: 10)
        self.filterLabel.configureText(withKey: "generic_button_filters")
        self.filterLabel.textColor = UIColor.darkTorquoise
        self.filterLabel.font = UIFont.santander(family: .text, type: .regular, size: 10)
        self.filterButton.setImage(Assets.image(named: "icnFilter"), for: .normal)
        self.pendingMovementButton.setImage(Assets.image(named: "icnPendingSettlement"), for: .normal)
        self.pendingMovementLabel.text = localized("generic_button_pendingSettlement")
        self.pendingMovementLabel.font = UIFont.santander(family: .text, type: .regular, size: 10)
        self.pendingMovementLabel.textColor = UIColor.darkTorquoise
        self.setButtonsGestureEvent()
        self.setAccesibilityIdentifiers()
        self.setAccesibilityLabels()
    }
    
    func fadePlushButton(_ percentage: CGFloat) {
        self.plusButonView.alpha = percentage
    }
    
    func hidePlushButton() {
        self.plusButonView.isUserInteractionEnabled = false
        UIView.animate(withDuration: 0.6) { [weak self] in
            self?.plusButonView.alpha = 0
        }
    }
    
    func showPlusButton() {
        self.plusButonView.isUserInteractionEnabled = true
        UIView.animate(withDuration: 0.6) { [weak self] in
            self?.plusButonView.alpha = 1
        }
    }
    
    func togglePdfDownload(toHidden hidden: Bool) {
        self.pdfLabel.isHidden = hidden
        self.downloadButton.isHidden = hidden
        self.downLoadPDFView.isHidden = hidden
    }
    
    func setPendingMovement(hidden: Bool) {
        self.pendingMovementLabel.isHidden = hidden
        self.pendingMovementButton.isHidden = hidden
        self.pendingMovementView.isHidden = hidden
    }
    
    @IBAction func didTapOnMoreOptions(_ sender: Any) {
        if self.plusButonView.isUserInteractionEnabled {
            self.delegate?.didTapOnMoreOptions()
        }
    }
    
    private func setButtonsGestureEvent() {
        let downloandGesture = UITapGestureRecognizer(target: self, action: #selector(didTapOnDownloadMovements))
        let filterGesture = UITapGestureRecognizer(target: self, action: #selector(didTapOnFilterMovements))
        let pendingMovementGesture = UITapGestureRecognizer(target: self, action: #selector(didTapOnPendingMovement))
        self.downloadButton.addGestureRecognizer(downloandGesture)
        self.filterButton.addGestureRecognizer(filterGesture)
        self.pendingMovementButton.addGestureRecognizer(pendingMovementGesture)
    }
    
    @objc private func didTapOnDownloadMovements(_ sender: Any) {
        self.delegate?.didTapOnDownloadMovements()
    }
        
    @objc private func didTapOnFilterMovements(_ sender: Any) {
        self.delegate?.didTapOnFilterMovements()
    }
    
    @objc private func didTapOnPendingMovement() {
        self.delegate?.didSelectPendingMovement()
    }
    
    private func setAccesibilityIdentifiers() {
        self.plusButton.accessibilityIdentifier = AccessibilityCardsHome.btnPDF
        self.downloadButton.accessibilityIdentifier = AccessibilityCardsHome.btnPDF
        self.filterButton.accessibilityIdentifier = AccessibilityCardsHome.btnFilter
        self.filterLabel.accessibilityIdentifier = AccessibilityCardsHome.btnFilterTitle
        self.pendingMovementButton.accessibilityIdentifier = AccessibilityCardsHome.buttonPendingMovement
        self.movementsLabel.accessibilityIdentifier = AccessibilityCardsHome.movementsLabel
        self.pendingMovementLabel.accessibilityIdentifier = AccessibilityCardsHome.buttonPendingMovementTitle
    }
    
    private func setAccesibilityLabels() {
        self.plusButton.accessibilityLabel = localized(AccessibilityCardsHome.buttonMoreOptions)
        self.filterButton?.accessibilityLabel = localized(AccessibilityCardsHome.buttonFilters)
        self.downloadButton?.accessibilityLabel = localized(AccessibilityCardsHome.buttonPDF)
        self.pendingMovementButton.accessibilityLabel = localized(AccessibilityCardsHome.buttonPendingSettlement)
    }
}
