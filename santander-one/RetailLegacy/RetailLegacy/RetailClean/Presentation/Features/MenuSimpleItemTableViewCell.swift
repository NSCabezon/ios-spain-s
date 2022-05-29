import UIKit
import UI

final class MenuSimpleItemTableViewCell: BaseViewCell {

    @IBOutlet weak var selectionView: UIView!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var secondaryIconImageView: UIImageView!
    @IBOutlet weak var submenuArrow: UIImageView!
    @IBOutlet weak var highlightedView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        descriptionLabel.font = UIFont.santanderTextLight(size: 18)
        descriptionLabel.textColor = UIColor.lisboaGrayNew
        highlightedView.backgroundColor = .clear
        setSelectionStyle()
    }
    
    private func setSelectionStyle() {
        selectionStyle = .none
        selectionView.isHidden = true
        
        submenuArrow.image = Assets.image(named: "icnArrowRightSmall")
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        selectionView.isHidden = false
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        selectionView.isHidden = true
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        selectionView.isHidden = true
    }
    
    var itemDescription: String? {
        didSet {
            descriptionLabel.text = itemDescription
        }
    }
    
    func setImage(named name: String) {
        iconImageView.image = Assets.image(named: name)?.withRenderingMode(.alwaysTemplate)
        iconImageView.tintColor = .botonRedLight
    }
    
    func hideImage() {
        iconImageView.isHidden = true
    }
    
    func setSecondaryImage(named name: String?) {
        if let name: String = name, let image: UIImage = Assets.image(named: name) {
            secondaryIconImageView.image = image
        } else {
            secondaryIconImageView.image = nil
        }
    }

    func showSubmenuArrow(showArrow: Bool) {
        submenuArrow.isHidden = !showArrow
    }
}
