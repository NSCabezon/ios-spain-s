import UIKit

class SpaceGroupableTableViewCell: GroupableTableViewCell {
    @IBOutlet weak var topSpaceConstraint: NSLayoutConstraint?
    @IBOutlet weak var bottomSpaceConstraint: NSLayoutConstraint?

    override func setPlace(isFirst: Bool, isLast: Bool) {
        super.setPlace(isFirst: isFirst, isLast: isLast)
        topSpaceConstraint?.constant = isFirst ? 5: 0
        bottomSpaceConstraint?.constant = isLast ? 5: 0
    }
}
