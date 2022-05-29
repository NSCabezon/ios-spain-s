//

import UIKit
import UI

protocol PersonalManagerDefaultDelegate: class {
    func mailButtonDidTouched(at index: Int)
    func dateButtonDidTouched(at index: Int)
    func chatButtonDidTouched(at index: Int)
    func videoCallButtonDidTouched(at index: Int)
}

class PersonalManagerDefaultViewCell: BaseViewCell {
    
    @IBOutlet weak var iconImage: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var defaultButton: UIButton!
    @IBOutlet weak var bottomSeparatorView: UIView!
    var setImage: String? {
        didSet {
            iconImage.image = Assets.image(named: setImage ?? "")
        }
    }
    
    weak var delegate: PersonalManagerDefaultDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        titleLabel.applyStyle(LabelStylist(textColor: .sanGreyDark, font: UIFont.latoBold(size: 16), textAlignment: .left))
        titleLabel.numberOfLines = 0
        subtitleLabel.applyStyle(LabelStylist(textColor: .sanGreyDark, font: UIFont.latoLight(size: 14), textAlignment: .left))
        defaultButton.applyStyle(ButtonStylist(textColor: .sanRed, font: UIFont.latoMedium(size: 13), borderColor: .sanRed, borderWidth: 1, backgroundColor: nil))
        defaultButton.layer.cornerRadius = defaultButton.frame.size.height / 2
    }
    
    @objc func mailButtonAction() {
        delegate?.mailButtonDidTouched(at: defaultButton.tag)
    }
    
    @objc func dateAction() {
        delegate?.dateButtonDidTouched(at: defaultButton.tag)
    }
    
    @objc func chatAction() {
        delegate?.chatButtonDidTouched(at: defaultButton.tag)
    }
    
    @objc func videoCallAction() {
        delegate?.videoCallButtonDidTouched(at: defaultButton.tag)
    }

}
