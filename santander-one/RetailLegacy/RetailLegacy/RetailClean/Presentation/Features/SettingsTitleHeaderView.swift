import UIKit

class SettingsTitleHeaderView: BaseViewHeader {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var backView: UIView!
    
    override var contentView: UIView {
        return backView
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        titleLabel.applyStyle(LabelStylist(textColor: .sanGreyDark, font: .latoBold(size: 14.0)))
        let background = UIView()
        background.backgroundColor = .uiBackground
        backgroundView = background
    }
    
    func setTitle(_ text: LocalizedStylableText) {
        titleLabel.set(localizedStylableText: text)
    }

    override func getContainerView() -> UIView? {
        return nil
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        backgroundView?.bounds = bounds
    }
    
    override func draw() {
    }
    
}
