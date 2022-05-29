//

import UIKit
import CoreFoundationLib
import UI

final class EasyPayCardTableViewCell: UITableViewCell {
    @IBOutlet weak var cardImage: UIImageView!
    @IBOutlet private weak var separatorView: UIView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var amountLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        backgroundColor = .white
        contentView.backgroundColor = .white
        separatorView.backgroundColor = .lightSanGray
        titleLabel.textColor = .sanGreyDark
        titleLabel.font = UIFont.santander(size: 15.0)
        amountLabel.textColor = .sanGreyDark
        amountLabel.font = UIFont.santander(type: .bold, size: 22.0)
    }
    
    func set(title: String?, amount: String?) {
        titleLabel.text = title
        amountLabel.text = amount
        amountLabel.scaleDecimals()
    }
}

extension EasyPayCardTableViewCell: EasyPayTableViewCellProtocol {
    func setCellInfo(_ info: Any) {
        guard let info = info as? EasyPayCardModelView else { return }
        cardImage.loadImage(urlString: info.imageURL,
                            placeholder: Assets.image(named: info.imagePlaceholder))
        set(title: info.title,
            amount: info.amount)
    }
}
