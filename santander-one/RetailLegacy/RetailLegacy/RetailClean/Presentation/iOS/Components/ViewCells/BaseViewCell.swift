import UIKit

class BaseViewCell: UITableViewCell {
    
    var indexPath: IndexPath?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        configureStyle()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        configureStyle()
    }
    
    func configureStyle() {}

    func didTapCell(_ sender: UITapGestureRecognizer) {
    }

}
