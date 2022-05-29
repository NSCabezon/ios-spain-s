import UIKit

class CustomerServiceTitleHeaderView: BaseViewHeader {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var backView: UIView!
    
    override var contentView: UIView {
        return backView
    }
    
    var title: String? {
        set {
            titleLabel.text = newValue
        }
        get {
            return titleLabel.text
        }
    }
    func setTitle(_ title: LocalizedStylableText) {
        titleLabel.set(localizedStylableText: title)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        titleLabel.applyStyle(LabelStylist(textColor: .sanRed, font: .latoSemibold(size: 22)))
        let background = UIView()
        background.backgroundColor = .uiBackground
        backgroundView = background
    }

    override func getContainerView() -> UIView? {
        return nil
    }
    
    override func draw() {
    }
}
