import UIKit
import CoreFoundationLib

public class LabelArrowTableViewCell: UITableViewCell {
    
    @IBOutlet weak private var titleLabel: UILabel!
    @IBOutlet weak private var arrowImageView: UIImageView!
    @IBOutlet weak var containerView: UIView!
    private var open: Bool = false {
        didSet {
            self.updateArrow()
        }
    }
    
    override public func awakeFromNib() {
        super.awakeFromNib()
        self.configureCell()
        self.setAccessibilityIdentifiers("")
    }
    
    override public func prepareForReuse() {
        super.prepareForReuse()
        titleLabel?.text = ""
    }
    
    override public func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        self.open = !self.open
    }
    
    public static var bundle: Bundle? {
        return .module
    }
    
    public static var identifier: String {
        String(describing: self)
    }
    
    private func configureCell() {
        self.titleLabel.font = .santander(family: .text, type: .regular, size: 16.0)
        self.titleLabel.textColor = .darkTorquoise
        self.arrowImageView?.image = Assets.image(named: "icnExpandMore")
    }
    
    public func setAccountCellInfo(_ item: LabelArrowViewItem?, backgroundColor: UIColor? = nil) {
        guard let item = item else { return }
        self.titleLabel.configureText(withLocalizedString: localized("originAccount_label_seeHiddenAccounts",
                                                                     [StringPlaceholder(.number, String(item.numberPlaceHolder ))]))
        self.containerView.backgroundColor = backgroundColor
    }
    
    public func setCardCellInfo(_ item: LabelArrowViewItem?, backgroundColor: UIColor? = nil) {
        guard let item = item else { return }
        self.titleLabel.configureText(withLocalizedString: localized("pt_cross_link_seeHiddenCards",
                                                                     [StringPlaceholder(.value, String(item.numberPlaceHolder ))]))
        self.containerView.backgroundColor = backgroundColor
    }
    
    public func setAccessibilityIdentifiersWithindex(_ index: String) {
        setAccessibilityIdentifiers(index)
    }
    
    private func updateArrow() {
        let rotation = self.open ? self.transform.rotated(by: CGFloat.pi) : CGAffineTransform.identity
        UIView.animate(withDuration: 0.2) { [weak self] in
            self?.arrowImageView?.transform = rotation
        }
    }
    
    private func setAccessibilityIdentifiers(_ index: String) {
        self.titleLabel.accessibilityIdentifier = AccesibilityTransferAccountSelection.btnHiddenAccount + index
        self.imageView?.accessibilityIdentifier = AccesibilityTransferAccountSelection.icnArrowDown + index
    }
}
