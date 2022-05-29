import UIKit
import UI
import CoreFoundationLib

final class DeleteScheduledTransferShareViewHeader: XibView {
    
    @IBOutlet private weak var image: UIImageView!
    @IBOutlet private weak var label: UILabel!
    @IBOutlet private weak var separator: UIView!
    
    init(_ name: String) {
        super.init(frame: .zero)
        image.image = Assets.image(named: "icnSantander")
        label.font = .santander(size: 16)
        label.textColor = .lisboaGray
        label.configureText(withLocalizedString: localized("share_label_transferDelete",
                                                           [StringPlaceholder(.name, name)]))
        label.numberOfLines = 0
        separator.backgroundColor = .mediumSkyGray
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
