import UIKit

class TitledTableHeader: BaseViewHeader {
    
    var title: LocalizedStylableText? {
        didSet {
            if let text = title {
                titleLabel.set(localizedStylableText: text)
            } else {
                titleLabel.text = nil
            }
        }
    }
    
    var accessibility: String? {
        didSet {
            self.titleLabel.accessibilityIdentifier = accessibility
        }
    }
    
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var left: NSLayoutConstraint!
    @IBOutlet weak var right: NSLayoutConstraint!
    @IBOutlet weak var top: NSLayoutConstraint!
    @IBOutlet weak var bottom: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        backView.backgroundColor = .uiBackground
    }
    
    override func getContainerView() -> UIView? {
        return nil
    }
    
    override func draw() {
    }
    
    override func configureStyle() {
        super.configureStyle()
        titleLabel.applyStyle(LabelStylist(textColor: .sanGreyDark, font: .latoBold(size: 16.0)))
    }
        
    func applyInsets(insets: Insets) {
        left?.constant = CGFloat(insets.left)
        right?.constant = CGFloat(insets.right)
        top?.constant = CGFloat(insets.top)
        bottom?.constant = CGFloat(insets.bottom)
        layoutSubviews()
    }
    
    func setTitleIdentifier(_ titleIdentifier: String?) {
        titleLabel.accessibilityIdentifier = titleIdentifier
    }
}
