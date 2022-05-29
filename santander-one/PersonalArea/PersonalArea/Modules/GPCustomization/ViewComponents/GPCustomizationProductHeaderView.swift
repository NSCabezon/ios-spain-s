import UIKit
import CoreFoundationLib
import UI

final class GPCustomizationProductHeaderView: UITableViewHeaderFooterView {

    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var separatorView: UIView!
    @IBOutlet weak var dragIcon: UIImageView!
    @IBOutlet weak var dragIconTrailingConstraint: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        containerView.backgroundColor = UIColor.white
        separatorView.backgroundColor = .mediumSky
        titleLabel.textColor = UIColor.lisboaGray
        dragIcon.image = Assets.image(named: "icnDragLine")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        guard dragIconTrailingConstraint != nil else { return }
        dragIconTrailingConstraint.constant = UIScreen.main.bounds.width < 400 ? 4.6 : 8.0
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        titleLabel.text = nil
    }
    
    func set(title: LocalizedStylableText?) {
        guard let title = title else { return }
        titleLabel.configureText(withLocalizedString: title,
                                 andConfiguration: LocalizedStylableTextConfiguration(font: .santander(family: .text, type: .bold, size: 16.0)))
        setAccessibility(title.plainText)
    }
    
    func setAccessibility(_ title: String) {
        self.titleLabel.accessibilityIdentifier = "basket_\(title.lowercased())_tittle"
        self.dragIcon.accessibilityIdentifier = "basket_\(title.lowercased())_drag"
    }
}
