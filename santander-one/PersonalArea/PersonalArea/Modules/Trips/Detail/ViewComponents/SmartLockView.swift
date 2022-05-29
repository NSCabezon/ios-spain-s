import UIKit
import CoreFoundationLib
import UI

protocol SmartLockViewDelegate: AnyObject {
    func didPressSmartLockButton()
}

final class SmartLockView: XibView {
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var cardImageView: UIImageView!
    @IBOutlet private weak var descriptionLabel: UILabel!
    @IBOutlet private weak var button: WhiteLisboaButton!
    @IBOutlet weak var separatorView: UIView!
    
    var countryName: String? {
        didSet {
            guard let name = countryName else { return }
            self.titleLabel.configureText(withLocalizedString: localized("yourTrips_label_yourCards", [StringPlaceholder(.value, name)]),
                                          andConfiguration: LocalizedStylableTextConfiguration(font: .santander(family: .text, type: .bold, size: 20)))
        }
    }
    
    weak var delegate: SmartLockViewDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupViews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupViews()
    }
    
    private func setupViews() {
        self.titleLabel.textColor = .lisboaGray
        
        self.cardImageView.image = Assets.image(named: "imgTripSmartLockCard")
        
        self.descriptionLabel.textColor = .lisboaGray
        self.descriptionLabel.configureText(withKey: "yourTrips_text_yourCards",
                                            andConfiguration: LocalizedStylableTextConfiguration(font: .santander(family: .text, type: .light, size: 16)))
        
        self.button.titleLabel?.font = UIFont.santander(family: .text, type: .regular, size: 14)
        self.button.contentInsets = UIEdgeInsets(top: 0, left: 17, bottom: 0, right: 17)
        self.button.addSelectorAction(target: self, #selector(didPressSmartLockButton))
        self.button.setTitle(localized("yourTrips_button_smartLock"), for: .normal)
        self.button.accessibilityIdentifier = "btnSmartLock"
        
        self.separatorView.backgroundColor = .mediumSkyGray
    }
    
    @objc private func didPressSmartLockButton() {
        self.delegate?.didPressSmartLockButton()
    }
}
