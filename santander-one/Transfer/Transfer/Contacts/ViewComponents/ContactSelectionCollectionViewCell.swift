//
//  Contacts.swift
//  Account
//
//  Created by Cristobal Ramos Laina on 31/01/2020.
//

import Foundation
import CoreFoundationLib
import UI

final class ContactSelectionCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var entityImageHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var entityImageConstraint: NSLayoutConstraint!
    @IBOutlet weak var shareImageView: UIImageView!
    @IBOutlet weak var downView: UIView!
    @IBOutlet weak private var countryView: UIView!
    @IBOutlet weak private var currencyView: UIView!
    @IBOutlet weak var cellView: UIView!
    @IBOutlet weak var contactNameLabel: UILabel!
    @IBOutlet weak private var contactSubtitleLabel: UILabel!
    @IBOutlet var contactView: UIView!
    @IBOutlet weak var accountLabel: UILabel!
    @IBOutlet weak var countryLabel: UILabel!
    @IBOutlet weak var worldImageView: UIImageView!
    @IBOutlet weak var ticketImageView: UIImageView!
    @IBOutlet weak var currencyLabel: UILabel!
    @IBOutlet weak var entityImageView: UIImageView!
    @IBOutlet weak var initialsLabel: UILabel!
    @IBOutlet weak var nameView: UIView!
    @IBOutlet weak var separatorView: UIView!
    @IBOutlet weak var dragAndDropView: UIView!
    @IBOutlet weak var dragAndDropImage: UIImageView!
    
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
    
    func setLongGesture(_ gesture: UILongPressGestureRecognizer) {
        dragAndDropView.addGestureRecognizer(gesture)
    }
    
    @IBAction func didTapOnShared(_ sender: Any) {
        guard let viewModel = self.viewModel else { return }
        self.delegate?.didTapOnShareViewModel(viewModel)
    }
}

private extension ContactSelectionCollectionViewCell {
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
        self.dragAndDropImage.image = Assets.image(named: "icnShift")
        self.separatorView.backgroundColor = .mediumSkyGray
        self.dragAndDropView.backgroundColor = UIColor.skyGray.withAlphaComponent(0.37)
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
        self.dragAndDropView.accessibilityIdentifier = "FavoriteRecipientsBtnShift"
    }
}
