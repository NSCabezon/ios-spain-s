//

import UIKit
import CoreFoundationLib

final class EasyPayTitleTableViewCell: UITableViewCell {
    @IBOutlet private weak var titleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = .white
        contentView.backgroundColor = .white
        titleLabel.textColor = .santanderRed
        titleLabel.font = UIFont.santander(type: .bold, size: 15.0)
        selectionStyle = .none
    }
    
    func setTitle(title: String?) {
        titleLabel.text = title
    }
}

extension EasyPayTitleTableViewCell: EasyPayTableViewCellProtocol {
    func setCellInfo(_ info: Any) {
        guard let info = info as? EasyPayTitleTableModelView else { return }
        setTitle(title: info.date)
    }
}
