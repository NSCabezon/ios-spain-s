import UIKit
import UI

final class DeleteScheduledTransferShareViewDefault: XibView {
    
    @IBOutlet private weak var title: UILabel!
    @IBOutlet private weak var subtitle: UILabel!
    @IBOutlet private weak var secondaryText: UILabel!
    @IBOutlet private weak var separator: UIView!
    
    init(title: String, subtitle: String, secondary: String?) {
        super.init(frame: .zero)
        self.title.font = .santander(size: 13)
        self.title.textColor = .grafite
        self.title.text = title
        self.subtitle.font = .santander(size: 14)
        self.subtitle.textColor = .lisboaGray
        self.subtitle.text = subtitle
        self.secondaryText.font = .santander(size: 13)
        self.secondaryText.textColor = .grafite
        self.secondaryText.text = secondary
        self.secondaryText.isHidden = (secondary?.isEmpty ?? true)
        self.separator.backgroundColor = .mediumSkyGray
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
