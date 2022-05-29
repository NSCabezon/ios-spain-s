//

import UIKit
import UI

protocol PersonalManagerCallViewDelegate: class {
    func phoneButtonDidTouched(at index: Int)
}

class PersonalManagerCallViewCell: BaseViewCell {
    @IBOutlet weak var phoneIconView: UIImageView!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var subtitle: UILabel!
    @IBOutlet weak var phoneNumberButton: UIButton!
    @IBOutlet weak var phoneIconButton: UIButton!
    @IBOutlet weak var noteLabel: UILabel!
    weak var delegate: PersonalManagerCallViewDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        phoneIconView.image = Assets.image(named: "icnPhone")
        title.applyStyle(LabelStylist(textColor: .sanGreyDark, font: UIFont.latoBold(size: 16), textAlignment: .left))
        subtitle.applyStyle(LabelStylist(textColor: .sanGreyDark, font: UIFont.latoLight(size: 14), textAlignment: .left))
        phoneNumberButton.applyStyle(ButtonStylist(textColor: .sanRed, font: UIFont.latoBold(size: UIScreen.main.isIphone4or5 ? 19 : 26)))
        phoneIconButton.setImage(Assets.image(named: "icnPhone"), for: .normal)
        phoneIconButton.layer.borderColor = UIColor.sanRed.cgColor
        phoneIconButton.layer.borderWidth = 1
        phoneIconButton.layer.cornerRadius = phoneIconButton.frame.size.height / 2
        noteLabel.applyStyle(LabelStylist(textColor: .sanGreyDark, font: UIFont.latoLightItalic(size: 14), textAlignment: .left))
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        title.applyStyle(LabelStylist(textColor: .sanGreyDark, font: UIFont.latoBold(size: 16), textAlignment: .left))
        subtitle.applyStyle(LabelStylist(textColor: .sanGreyDark, font: UIFont.latoLight(size: 14), textAlignment: .left))
    }
    
    @IBAction func callAction(_ sender: UIButton) {
        delegate?.phoneButtonDidTouched(at: sender.tag)
    }
}
