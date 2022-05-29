//
//  Contacts.swift
//  Account
//
//  Created by Cristobal Ramos Laina on 31/01/2020.
//

import Foundation
import CoreFoundationLib
import UI

final class ContactSelectionNoEditCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak private var entityImageHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak private var entityImageConstraint: NSLayoutConstraint!
    @IBOutlet weak private var shareImageView: UIImageView!
    @IBOutlet weak private var downView: UIView!
    @IBOutlet weak private var countryView: UIView!
    @IBOutlet weak private var currencyView: UIView!
    @IBOutlet weak private var cellView: UIView!
    @IBOutlet weak private var contactNameLabel: UILabel!
    @IBOutlet weak private var contactSubtitleLabel: UILabel!
    @IBOutlet weak private var contactView: UIView!
    @IBOutlet weak private var accountLabel: UILabel!
    @IBOutlet weak private var countryLabel: UILabel!
    @IBOutlet weak private var worldImageView: UIImageView!
    @IBOutlet weak private var ticketImageView: UIImageView!
    @IBOutlet weak private var currencyLabel: UILabel!
    @IBOutlet weak private var entityImageView: UIImageView!
    @IBOutlet weak private var initialsLabel: UILabel!
    @IBOutlet weak private var nameView: UIView!
    private var view: UIView?
    private var viewModel: ContactListItemViewModel?
    weak var delegate: ContactSelectionCollectionViewCellDelegate?
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.resetCell()
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        self.cellView.drawRoundedAndShadowedNew(radius: 5, borderColor: .lightSkyBlue, widthOffSet: 1, heightOffSet: 2)
        self.nameView.layer.cornerRadius = self.nameView.bounds.height / 2
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.setAppearance()
        self.setAccessibilityIdentifiers()
    }
    
    func setup(withViewModel viewModel: ContactListItemViewModel) {
        self.viewModel = viewModel
        self.contactNameLabel.text = viewModel.name
        self.contactSubtitleLabel.text = viewModel.beneficiaryName
        self.accountLabel.text = viewModel.formattedAccount
        self.downView.isHidden = viewModel.areCountryAndCurrencyNil
        self.countryView.isHidden = viewModel.isCountryViewHidden
        self.currencyView.isHidden = viewModel.isCurrencyViewHidden
        self.setBankImage(bankIconUrl: viewModel.bankIconUrl)
        self.countryLabel.text = viewModel.countryCode
        self.currencyLabel.text = viewModel.currency
        self.initialsLabel.text = viewModel.avatarName
        self.nameView.backgroundColor = viewModel.avatarColor
    }
    
    @IBAction func didTapOnShared(_ sender: Any) {
        guard let viewModel = self.viewModel else { return }
        self.delegate?.didTapOnShareViewModel(viewModel)
    }
}

private extension ContactSelectionNoEditCollectionViewCell {
    func setAppearance() {
        self.initialsLabel?.textColor = .white
        self.initialsLabel?.font = .santander(family: .text, type: .bold, size: 15.0)
        self.accountLabel?.textColor = .lisboaGray
        self.accountLabel?.font = .santander(family: .text, type: .regular, size: 14.0)
        self.accountLabel?.adjustsFontSizeToFitWidth = true
        self.countryLabel?.textColor = .lisboaGray
        self.countryLabel?.font = .santander(family: .text, type: .regular, size: 14.0)
        self.currencyLabel?.textColor = .lisboaGray
        self.currencyLabel?.font = .santander(family: .text, type: .regular, size: 14.0)
        self.contactNameLabel?.textColor = .lisboaGray
        self.contactNameLabel?.font = .santander(family: .text, type: .bold, size: 16.0)
        self.contactSubtitleLabel?.textColor = .lisboaGray
        self.contactSubtitleLabel?.font = .santander(family: .text, type: .regular, size: 14.0)
        self.worldImageView.image = Assets.image(named: "icnWorld")
        self.ticketImageView.image = Assets.image(named: "icnCurrency")
        self.shareImageView.image = Assets.image(named: "icnShareAccount")
    }
    
    func setBankImage(bankIconUrl: String?) {
        if let iconUrl = bankIconUrl {
            self.entityImageView.loadImage(urlString: iconUrl) { [weak self] in
                if let iconUrlSize = self?.entityImageView?.image?.size {
                    let height = self?.entityImageHeightConstraint.constant
                    let newWidth = (iconUrlSize.width * (height ?? 15)) / iconUrlSize.height
                    self?.entityImageConstraint.constant = newWidth
                } else {
                    self?.entityImageView.image = nil
                    self?.entityImageConstraint.constant = 0
                }
            }
        } else {
            self.entityImageView.image = nil
            self.entityImageConstraint.constant = 0
        }
    }
    
    func resetCell() {
        self.viewModel = nil
        self.accountLabel.text = nil
        self.contactNameLabel.text = nil
        self.contactSubtitleLabel.text = nil
        self.countryLabel.text = nil
        self.downView.isHidden = false
        self.contentView.isHidden = false
        self.currencyView.isHidden = false
        self.entityImageView.image = nil
        self.entityImageConstraint.constant = 0
    }
    
    func setAccessibilityIdentifiers() {
        self.shareImageView.accessibilityIdentifier = "favoriteRecipientsBtnShare"
    }
}
