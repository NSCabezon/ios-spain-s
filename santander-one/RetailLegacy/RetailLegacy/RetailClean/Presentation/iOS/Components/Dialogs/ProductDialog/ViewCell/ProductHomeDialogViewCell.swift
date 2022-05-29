//

import UIKit
import UI

class ProductHomeDialogViewCell: BaseViewCell {
    
    @IBOutlet weak var productImage: UIImageView!
    @IBOutlet weak var productLabel: UILabel!
    
    public func configOptionCell(_ model: ProductOption) {
        productImage.image = Assets.image(named: model.imageKey)
        productLabel.set(localizedStylableText: model.title)
        productLabel.textColor = .sanGreyDark
        selectionStyle = .none
    }
    
}
