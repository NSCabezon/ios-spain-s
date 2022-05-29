import UIKit
import UI
import CoreFoundationLib

final class DestinationEmittedTransferView: XibView {
    @IBOutlet private weak var title: UILabel!
    @IBOutlet private weak var beneficiary: UILabel!
    @IBOutlet private weak var account: UILabel!
    @IBOutlet private weak var copyBtn: UIButton!
    @IBOutlet private weak var bankImage: UIImageView!
    
    var shareAction: ((String) -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupView()
    }
    
    private func setupView() {
        self.configureStyle()
        self.setText()
        self.setAccessibilityIdentifiers()
    }
    
    func setText() {
        self.title.configureText(withKey: "deliveryDetails_label_destination")
    }
    
    func configureStyle() {
        self.backgroundColor = .mediumSkyGray
        self.title.textColor = .grafite
        self.title.font = .santander(family: .text, type: .regular, size: 13)
        self.beneficiary.textColor = .lisboaGray
        self.beneficiary.font = .santander(family: .text, type: .bold, size: 14)
        self.account.textColor = .lisboaGray
        self.account.font = .santander(family: .text, type: .regular, size: 14)
        let shareImage = Assets.image(named: "icnShareAccount")?.withRenderingMode(.alwaysOriginal)
        self.copyBtn.setImage(shareImage, for: .normal)
    }
    
    func setAccessibilityIdentifiers() {
        self.title.accessibilityIdentifier = TransferEmittedDetailAccessibilityIdentifier.destinationTitle
        self.beneficiary.accessibilityIdentifier = TransferEmittedDetailAccessibilityIdentifier.beneficiary
        self.account.accessibilityIdentifier = TransferEmittedDetailAccessibilityIdentifier.account
        self.copyBtn.accessibilityIdentifier = TransferEmittedDetailAccessibilityIdentifier.shareButton
        self.bankImage.accessibilityIdentifier = TransferEmittedDetailAccessibilityIdentifier.bankImage
    }
    
    func set(beneficiary: String?) {
        self.beneficiary.text = beneficiary?.lowercased().capitalized
    }
    
    func set(account: String?) {
        self.account.text = account
    }
    
    func set(bankIconUrl: String?) {
        guard let bankIconUrl = bankIconUrl else { return }
        self.bankImage.loadImage(urlString: bankIconUrl)
    }
    
    @IBAction func copyAction(_ sender: Any) {
        self.shareAction?(self.account.text ?? "")
    }
}
