import UIKit

class ToolTipViewController: UIViewController {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var separatorView: UIView!
    @IBOutlet weak var titleView: UIView!
    @IBOutlet weak var descriptionView: UIView!
    private let sidesPadding: CGFloat = 24
    private let minPopOverInsets: CGFloat = 20
    private let decimalMargin: CGFloat = 1
    private let titleMargins: CGFloat = 18
    private let descriptionMargins: CGFloat = 16
    private let separatorHeight: CGFloat = 1
    private let titleFont = UIFont.latoRegular(size: 15)
    private let descriptionFont = UIFont.latoLight(size: 14)

    var maxWidth: CGFloat? {
        didSet {
            guard let maxWidth = maxWidth else { return }
            titleLabel.preferredMaxLayoutWidth = maxWidth - sidesPadding
            descriptionLabel.preferredMaxLayoutWidth = maxWidth - sidesPadding
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        titleLabel.font = titleFont
        descriptionLabel.font = descriptionFont
        titleLabel.textColor = .sanRed
        separatorView.backgroundColor = .sanRed
    }
    
    var popoverTitle: LocalizedStylableText? {
        didSet {
            titleLabel.font = titleFont
            if let text = popoverTitle {
                titleLabel.set(localizedStylableText: text)
                titleView.isHidden = false
            } else {
                titleLabel.text = nil
                titleView.isHidden = true
            }
        }
    }
    
    var popoverDescription: String? {
        get {
            return descriptionLabel.text
        }
        set {
            descriptionLabel.font = descriptionFont
            descriptionView.isHidden = newValue == nil
            separatorView.isHidden = newValue == nil && popoverTitle == nil
            descriptionLabel.text = newValue
        }
    }
    
    func setPopoverDescriptionLocalized(text: LocalizedStylableText) {
        descriptionLabel.font = UIFont.latoLight(size: 14)
        descriptionLabel.set(localizedStylableText: text)
        descriptionView.isHidden = false
        separatorView.isHidden = popoverTitle == nil
    }

    func preferedSize() -> CGSize {
        titleLabel.sizeToFit()
        descriptionLabel.sizeToFit()
        view.layoutIfNeeded()
        let maxWidthAvailable = (self.maxWidth ?? view.bounds.width) - sidesPadding - decimalMargin - minPopOverInsets
        let maxHeight = CGFloat.greatestFiniteMagnitude
        let lab1 = descriptionLabel.sizeThatFits(CGSize(width: maxWidthAvailable, height: maxHeight))
        let lab2 = titleLabel.sizeThatFits(CGSize(width: maxWidthAvailable, height: maxHeight))
        let widthLabelRequired = max(lab1.width, lab2.width)
        let widthRequired = widthLabelRequired + sidesPadding + decimalMargin
        var extraPaddingSpace: CGFloat = 0
        if !titleView.isHidden {
            extraPaddingSpace += titleMargins + decimalMargin
        }
        if !descriptionView.isHidden {
            extraPaddingSpace += descriptionMargins + decimalMargin
        }
        if !titleView.isHidden && !descriptionView.isHidden {
            extraPaddingSpace += separatorHeight
        }
        let heightRequired = lab1.height + lab2.height + extraPaddingSpace
        return CGSize(width: widthRequired, height: heightRequired)
    }
    
    func setAccessibilityIdentifier(identifier: String) {
        self.view.accessibilityIdentifier = identifier + "_view"
        titleLabel.accessibilityIdentifier = identifier + "_title"
        descriptionLabel.accessibilityIdentifier = identifier + "_description"
    }
}
