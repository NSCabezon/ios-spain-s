import UIKit
import UI

final class DeleteScheduledTransferShareViewAccount: XibView {
    
    @IBOutlet private weak var title: UILabel!
    @IBOutlet private weak var bankImage: UIImageView!
    @IBOutlet private weak var accountNumber: UILabel!
    @IBOutlet private weak var separator: UIView!
    
    init(title: String, bankImage: String?, accountNumber: String) {
        super.init(frame: .zero)
        self.title.font = .santander(size: 13)
        self.title.textColor = .grafite
        self.title.text = title
        self.accountNumber.font = .santander(size: 13)
        self.accountNumber.textColor = .lisboaGray
        self.accountNumber.text = accountNumber
        self.bankImage.loadImage(urlString: bankImage ?? "", placeholder: nil) {
            self.bankImage.isHidden = self.bankImage.image == nil
        }
        self.separator.backgroundColor = .mediumSkyGray
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
