//

import UIKit

class GenericHeaderViewCell: BaseViewCell {
    @IBOutlet weak var cellView: UIView!    
    @IBOutlet weak var separatorView: UIView!
    var isDraggable = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
        separatorView.backgroundColor = .lisboaGray
        selectionStyle = UITableViewCell.SelectionStyle.none
        isUserInteractionEnabled = false
    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        showsReorderControl = isDraggable
    }
}
