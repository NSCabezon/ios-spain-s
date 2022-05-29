//

import UIKit
import UI

class DraggableBasicTableViewCell: BaseViewCell {

    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var enabledSwitch: CoachmarkUISwitch!
    @IBOutlet weak var roundedView: UIView!
    @IBOutlet weak var reorderImageView: UIImageView!
    weak var reorderControl: UIView?
    @IBOutlet weak var leadingSpaceConstraint: NSLayoutConstraint!
    @IBOutlet weak var imageWidthConstraint: NSLayoutConstraint!
    
    private let smallLeadingSpace = CGFloat(6.0)
    private let bigLeadingSpace = CGFloat(20.0)
    
    var isDraggable = false {
        didSet {
            leadingSpaceConstraint.constant = isDraggable ? smallLeadingSpace : bigLeadingSpace
        }
    }
    
    var title: String? {
        set {
            titleLabel.text = newValue
        }
        get {
            return titleLabel.text
        }
    }
    
    func  setTitle(_ title: LocalizedStylableText) {
        titleLabel.set(localizedStylableText: title)
    }
    
    var subtitle: String? {
        set {
            subtitleLabel.isHidden = subtitle == nil
            subtitleLabel.text = newValue
        }
        get {
            return subtitleLabel.text
        }
    }
    
    var isSwitchOn: Bool {
        set {
            enabledSwitch.isOn = newValue
        }
        get {
            return enabledSwitch.isOn
        }
    }
    
    var switchValueDidChange: ((Bool) -> Void)?
    
    var switchCoachmarkId: CoachmarkIdentifier? {
        get {
            return self.enabledSwitch.coachmarkId
        } set {
            self.enabledSwitch.coachmarkId = newValue
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        titleLabel.applyStyle(LabelStylist(textColor: .sanGreyDark, font: .latoRegular(size: 15)))
        subtitleLabel.applyStyle(LabelStylist(textColor: .sanGreyMedium, font: .latoRegular(size: 14)))
        deactive()
        hideImage()
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        applyRoundedStyle()
    }
    
    override func layoutSubviews() {
        showsReorderControl = isDraggable
        super.layoutSubviews()
        //This is a hacky workaround to avoid space used in cell to display the drag control
        if isDraggable, let parentView = contentView.superview?.frame.size.width {
            let difference = contentView.frame.size.width - parentView
            contentView.frame = contentView.frame.inset(by: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: difference))
        }
        applyRoundedStyle()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        deactive()
        hideImage()
    }

    private func applyRoundedStyle() {
        StylizerNonCollapsibleViewCells.applyAllCornersViewCellStyle(view: roundedView)
    }
    
    func setImageKey(_ imageKey: String?) {
        iconImageView?.isHidden = imageKey == nil
        imageWidthConstraint.constant = 51
        if let imageKey = imageKey {
            iconImageView.image = Assets.image(named: imageKey)
        } else {
            iconImageView.image = nil
        }
    }

    @IBAction func switchValueChanged(_ sender: UISwitch) {
        switchValueDidChange?(sender.isOn)
    }
}

extension DraggableBasicTableViewCell: DraggableBasicViewModelProtocol {

    func active() {
        iconImageView.alpha = 1.0
    }

    func deactive() {
        iconImageView.alpha = 0.5
    }

    func showImage() {
        iconImageView.isHidden = false
    }

    func hideImage() {
        iconImageView.isHidden = true
    }

}
