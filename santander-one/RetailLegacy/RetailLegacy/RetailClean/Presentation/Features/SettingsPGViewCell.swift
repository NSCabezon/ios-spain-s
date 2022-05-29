import UIKit

class SettingsPGViewCell: BaseViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var content: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        titleLabel.applyStyle(LabelStylist.pgProductSubName)
        content.backgroundColor = .uiBackground
        selectionStyle = .none
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        titleLabel.applyStyle(LabelStylist.pgProductSubName)
    }
    
    func setTitle(_ title: LocalizedStylableText) {
        titleLabel.set(localizedStylableText: title)
    }
}
