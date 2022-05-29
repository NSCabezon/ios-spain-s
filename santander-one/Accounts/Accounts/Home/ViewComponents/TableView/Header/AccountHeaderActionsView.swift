//
//  AccountsTableViewHeader.swift
//  Accounts
//
//  Created by Juan Carlos López Robles on 11/7/19.
//

import CoreFoundationLib
import UI

protocol AccountHeaderActionsViewDelegate: AnyObject {
    func didTapOnFilterMovements()
    func didTapOnDownloadMovements()
    func didTapOnMoreOptions()
}

final class AccountHeaderActionsView: XibView {
    
    weak var delegate: AccountHeaderActionsViewDelegate?
    @IBOutlet weak var movementsLabel: UILabel!
    @IBOutlet weak var plusButonView: UIView!
    @IBOutlet weak var plusImageView: UIImageView!
    @IBOutlet weak var downloadButton: PressableButton!
    @IBOutlet weak var filterButton: PressableButton!
    @IBOutlet weak var pdfLabel: UILabel!
    @IBOutlet weak var filterLabel: UILabel!
    @IBOutlet weak var plusButton: UIButton!
    @IBOutlet private weak var pdfStackView: UIStackView!
    @IBOutlet private weak var filterStackView: UIStackView!
    private var pdfActionButtonHidden: Bool = false

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
        setAccessibilityIds()
        setAccessibilityLabels()
    }
    
    func setupView() {
        self.clipsToBounds = true
        self.plusButton.accessibilityIdentifier = "generic_button_more_options"
        self.plusImageView.image = Assets.image(named: "icnPlus")
        self.plusButonView.backgroundColor = .skyGray
        self.plusButonView.layer.cornerRadius = plusButonView.frame.height / 2
        self.plusButonView.layer.borderColor = UIColor.mediumSkyGray.cgColor
        self.plusButonView.layer.borderWidth = 1
        self.movementsLabel.text =  localized("productHome_label_transaction").uppercased()
        self.movementsLabel.font = UIFont.santander(family: .text, type: .bold, size: 16)
        self.downloadButton.setImage(Assets.image(named: "icnDownload"), for: .normal)
        self.downloadButton.accessibilityIdentifier = "icn_download"
        self.pdfLabel.configureText(withKey: "generic_button_downloadPDF")
        self.pdfLabel.textColor = UIColor.darkTorquoise
        self.pdfLabel.font = UIFont.santander(family: .text, type: .regular, size: 10)
        self.filterLabel.configureText(withKey: "generic_button_filters")
        self.filterLabel.textColor = UIColor.darkTorquoise
        self.filterLabel.font = UIFont.santander(family: .text, type: .regular, size: 10)
        self.filterButton.setImage(Assets.image(named: "icnFilter"), for: .normal)
        self.filterButton.accessibilityIdentifier = "icn_filter"
        self.setButtonsGestureEvent()
    }
    
    func fadePlushButton(_ percentage: CGFloat) {
        plusButonView.alpha = percentage
        plusButonView.isUserInteractionEnabled = percentage > 0.0
    }
    
    func hidePlushButton() {
        UIView.animate(withDuration: 0.6) { [weak self] in
            self?.plusButonView.alpha = 0
        }
    }
    
    func showPlusButton() {
        UIView.animate(withDuration: 0.6) { [weak self] in
            self?.plusButonView.alpha = 1
        }
    }
    
    func setIsHiddenPlusButonView(_ isHidden: Bool) {
        self.plusButonView.isHidden = isHidden
        self.plusButton.isHidden = isHidden
    }
    
    func togglePdfDownload(toHidden hidden: Bool) {
        guard self.pdfActionButtonHidden == false else {
            return
        }
        self.pdfLabel.isHidden = hidden
        self.downloadButton.isHidden = hidden
    }
    
    @IBAction func didTapOnMoreOptions(_ sender: Any) {
        if self.plusButonView.isUserInteractionEnabled {
            self.delegate?.didTapOnMoreOptions()
        }
    }
    
    @objc private func didTapOnDownloadMovements(_ sender: Any) {
        self.delegate?.didTapOnDownloadMovements()
    }
    
    @objc private func didTapOnFilterMovements(_ sender: Any) {
        self.delegate?.didTapOnFilterMovements()
    }
}

private extension AccountHeaderActionsView {
    func setButtonsGestureEvent() {
        let downloandGesture = UITapGestureRecognizer(target: self, action: #selector(didTapOnDownloadMovements))
        let filterGesture = UITapGestureRecognizer(target: self, action: #selector(didTapOnFilterMovements))
        self.downloadButton.addGestureRecognizer(downloandGesture)
        self.filterButton.addGestureRecognizer(filterGesture)
    }
    
    func setAccessibilityIds() {
        self.accessibilityIdentifier = "accountHome_view_moves"
        self.downloadButton?.accessibilityIdentifier = AccessibilityAccountsHome.btnPDF
        self.filterButton?.accessibilityIdentifier = AccessibilityAccountsHome.btnFilter
        self.movementsLabel.accessibilityIdentifier = "accountHome_label_moves"
        self.filterLabel.accessibilityIdentifier = "generic_button_filters"
        self.pdfLabel.accessibilityIdentifier = "generic_button_downloadPDF"
        self.downloadButton.imageView?.accessibilityIdentifier = "icn_download"
        self.filterButton.imageView?.accessibilityIdentifier = "icn_filter"
    }
    
    func setAccessibilityLabels() {
        self.pdfLabel.isAccessibilityElement = false
        self.downloadButton.isAccessibilityElement = false
        self.pdfStackView.isAccessibilityElement = true
        self.pdfStackView.accessibilityTraits = .button
        self.pdfStackView?.accessibilityLabel = localized(AccessibilityAccountsHome.buttonPDF)
        self.filterLabel.isAccessibilityElement = false
        self.filterButton.isAccessibilityElement = false
        self.filterStackView.isAccessibilityElement = true
        self.filterStackView.accessibilityTraits = .button
        self.filterStackView?.accessibilityLabel = localized(AccessibilityAccountsHome.buttonFilters)
        self.plusButton.accessibilityLabel = localized(AccessibilityAccountsHome.buttonMoreOptions)
    }
}

extension AccountHeaderActionsView {
    func hidePDFButton() {
        self.pdfActionButtonHidden = true
        self.downloadButton.isHidden = true
        self.pdfLabel.isHidden = true
    }
}
