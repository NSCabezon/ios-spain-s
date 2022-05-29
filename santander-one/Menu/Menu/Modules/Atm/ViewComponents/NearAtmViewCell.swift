//
//  NearAtmViewCell.swift
//  Menu
//
//  Created by Cristobal Ramos Laina on 28/10/2020.
//
import Foundation
import UI
import CoreFoundationLib

final class NearAtmViewCell: UICollectionViewCell {
    
    @IBOutlet private weak var operativeView: UIView!
    @IBOutlet private weak var adressLabel: UILabel!
    @IBOutlet private weak var distanceLabel: UILabel!
    @IBOutlet private weak var operativeLabel: UILabel!
    @IBOutlet private weak var viewContainer: UIView!
    @IBOutlet private weak var arrowImageView: UIImageView!
    
    override public func awakeFromNib() {
        super.awakeFromNib()
        self.configureCell()
    }
    
    func setViewModel(viewModel: AtmViewModel) {
        self.adressLabel?.font = .santander(family: .text, type: .regular, size: 14)
        self.adressLabel?.textColor = .lisboaGray
        self.adressLabel.text = viewModel.street.camelCasedString
        self.distanceLabel?.font = .santander(family: .text, type: .bold, size: 14)
        self.distanceLabel?.textColor = .lisboaGray
        self.distanceLabel.configureText(withLocalizedString: viewModel.distance)
        self.operativeLabel?.font = .santander(family: .text, type: .bold, size: 10)
        self.operativeLabel?.adjustsFontSizeToFitWidth = true
        
        if viewModel.isOperative {
            self.operativeView?.drawBorder(cornerRadius: 2, color: .limeGreen, width: 1)
            self.operativeLabel?.textColor = .limeGreen
            self.operativeLabel.text = localized("atm_label_works").uppercased()

        } else {
            self.operativeView?.drawBorder(cornerRadius: 2, color: .coolGray, width: 1)
            self.operativeLabel?.textColor = .coolGray
            self.operativeLabel?.text = localized("atm_label_notWorks").uppercased()
        }
    }
    
    func setAccesibilityIdentifier(index: Int) {
        self.accessibilityIdentifier = "atmBtnLocationAtm" + "\(index)"
        self.adressLabel.accessibilityIdentifier = AccessibilityAtm.NearestAtms.adress
        self.distanceLabel.accessibilityIdentifier = AccessibilityAtm.NearestAtms.distance
        self.operativeLabel.accessibilityIdentifier = AccessibilityAtm.NearestAtms.operative
        self.accessibilityIdentifier = AccessibilityAtm.NearestAtms.atmBtnLocationAtm
    }
}

private extension NearAtmViewCell {
    private func configureCell() {
        self.layer.masksToBounds = false
        self.viewContainer.drawBorder(cornerRadius: 4.0, color: .lightSkyBlue, width: 1)
        self.drawShadow(offset: (x: 1, y: 2), opacity: 0.5, color: .atmsShadowGray, radius: 2.0)
        self.contentView.backgroundColor = UIColor.clear
        self.viewContainer.clipsToBounds = true
        self.arrowImageView.image = Assets.image(named: "icnArrowLightGrey")
    }
}
