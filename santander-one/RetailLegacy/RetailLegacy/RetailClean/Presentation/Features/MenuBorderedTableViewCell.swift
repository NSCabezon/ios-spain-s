import UIKit
import UI

class MenuBorderedTableViewCell: BaseViewCell {
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var borderView: UIView!
    
    var title: LocalizedStylableText? {
        didSet {
            if let text = title {
                titleLabel.set(localizedStylableText: text)
            } else {
                titleLabel.text = nil
            }
        }
    }
    
    var iconImage: UIImage? {
        set {
            iconImageView.image = newValue
        }
        get {
            return iconImageView.image
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        titleLabel.font = UIFont.latoRegular(size: 17.0)
        borderView.layer.borderWidth = 1.0
        borderView.layer.borderColor = UIColor.lisboaGrayNew.cgColor
        
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        borderView.layer.cornerRadius = 5
    }
    
    func setImage(named name: String?) {
        guard let name = name else { return }
        iconImage = Assets.image(named: name)
    }
}
