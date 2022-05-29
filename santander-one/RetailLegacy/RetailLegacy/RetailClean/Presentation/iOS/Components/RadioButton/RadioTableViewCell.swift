//

import UIKit

class RadioTableViewCell: BaseViewCell, RadioComponentProtocol {
    
    var isChecked: Bool = false
    @IBOutlet weak var insideHeghtConstraint: NSLayoutConstraint!
    @IBOutlet private weak var borderView: UIView!
    @IBOutlet private weak var containerView: UIView!
    @IBOutlet private weak var viewGray: UIView!
    @IBOutlet private weak var viewRed: UIView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var buttonInfo: UIButton!
    private var selectedHeight: CGFloat = 0
    private let normalHeight: CGFloat = 51
    private weak var containedView: UIView?
    private var insets: UIEdgeInsets = .zero
    weak var actionDelegate: RadioTableActionDelegate?
    weak var toolTipDelegate: ToolTipDisplayer?

    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        selectionStyle = .none
        viewGray.layer.cornerRadius = viewGray.frame.size.width / 2
        viewGray.layer.borderColor = UIColor.lisboaGray.cgColor
        viewGray.layer.borderWidth = 1
        viewRed.clipsToBounds = true
        viewRed.layer.cornerRadius = viewRed.frame.size.width / 2
        viewRed.backgroundColor = .sanRed
        titleLabel.applyStyle(LabelStylist(textColor: .sanGreyDark, font: .latoBold(size: 16)))
        containerView?.backgroundColor = .clear
        borderView.backgroundColor = .clear
        
        updateMarked()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        isChecked = false
        buttonInfo?.setImage(nil, for: .normal)
        buttonInfo?.sizeToFit()
        updateMarked()
    }

    func setupBorder() {
        borderView.backgroundColor = .uiWhite
        containerView.drawBorder(cornerRadius: 5.0, color: .clear)
        borderView.drawRoundedAndShadowed()
    }
    
    func showResponder() {
        containedView?.becomeFirstResponder()
    }
    
    func addInsideView(view: UIView?) {
        defer {
            containedView = view
        }
        
        guard let view = view else {
            return
        }
        if containerView.subviews.contains(view) {
            return
        }
        view.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(view)
        let left = NSLayoutConstraint(item: containerView as UIView, attribute: .leading, relatedBy: .equal, toItem: view, attribute: .leading, multiplier: 1, constant: -insets.left)
        left.priority = .required
        left.isActive = true
        let right = NSLayoutConstraint(item: containerView as UIView, attribute: .trailing, relatedBy: .equal, toItem: view, attribute: .trailing, multiplier: 1, constant: insets.right)
        right.priority = .required
        right.isActive = true
        let bottom = NSLayoutConstraint(item: containerView as UIView, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1, constant: insets.bottom)
        bottom.priority = .defaultLow
        bottom.isActive = true
        let top = NSLayoutConstraint(item: containerView as UIView, attribute: .top, relatedBy: .equal, toItem: view, attribute: .top, multiplier: 1, constant: -insets.top)
        top.priority = .defaultHigh
        top.isActive = true
        containerView.superview?.addConstraints([left, right, bottom, top])
        containedView = view
        layoutIfNeeded()
    }
    
    func configureInsideView(necesaryHeight: CGFloat = 0, insets: UIEdgeInsets = .zero) {
        self.insets = insets
        selectedHeight = insets.top + necesaryHeight + insets.bottom
    }
    
    func setTitle(text: LocalizedStylableText) {
        titleLabel.set(localizedStylableText: text)
    }
    
    func addActionButton(image: UIImage?, tag: Int) {
        buttonInfo.tag = tag
        buttonInfo.setImage(image, for: .normal)
        buttonInfo.sizeToFit()
    }
    
    private func updateMarked() {
        insideHeghtConstraint?.constant = isChecked ? selectedHeight: 0
        viewRed.isHidden = !isChecked
        titleLabel.textColor = isChecked ? .sanGreyDark : .sanGreyMedium
        layoutIfNeeded()
    }
    
    @IBAction private func actionInfo(_ sender: UIButton) {
        actionDelegate?.auxiliaryButtonAction(tag: sender.tag, completion: { [weak self] (action) in
            switch action {
            case .toolTip(let title, let text, let localizedText, let identifier, let delegate):
                if let cell = self {
                    cell.toolTipDelegate = delegate
                    if let localized = localizedText {
                        cell.toolTipDelegate?.displayPermanentToolTip(with: title, descriptionLocalized: localized, identifier: identifier, inView: cell.buttonInfo, withSourceRect: cell.buttonInfo.bounds, forcedDirection: UIPopoverArrowDirection.up)
                    } else {
                        cell.toolTipDelegate?.displayToolTip(with: title, description: text, inView: cell.buttonInfo, withSourceRect: cell.buttonInfo.bounds)
                    }
                }
            default:
                break
            }
        })
    }
    
    var isMark: Bool {
        return isChecked
    }
    
    func setMarked(isMarked: Bool) {
        isChecked = isMarked
        updateMarked()
    }
    
    func setAccessibilityIdentifiers(identifier: String) {
        self.accessibilityIdentifier = identifier + "_view"
        titleLabel.accessibilityIdentifier = identifier + "_title"
        buttonInfo.accessibilityIdentifier = identifier + "_infoBtn"
        viewRed.accessibilityIdentifier = identifier + "_redView"
        viewGray.accessibilityIdentifier = identifier + "_grayView"
    }
}
