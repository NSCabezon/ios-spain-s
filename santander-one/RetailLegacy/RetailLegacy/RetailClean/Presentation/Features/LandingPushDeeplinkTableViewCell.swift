import UIKit
import UI

class LandingPushDeeplinkTableViewCell: BaseViewCell {
    @IBOutlet weak var deeplinkNameLabel: UILabel!
    @IBOutlet weak var icnImageView: UIImageView!
    @IBOutlet weak var separatorView: UIView!
    
    func setImage(image: String?) {
        icnImageView.image = Assets.image(named: image ?? "")
    }
    
    func setBold(isBold: Bool?) {
        if let bold = isBold, bold == true {
            deeplinkNameLabel.applyStyle(LabelStylist(textColor: .sanGreyDark, font: .santanderTextBold(size: 21.0)))
        } else {
            deeplinkNameLabel.applyStyle(LabelStylist(textColor: .sanGreyDark, font: .santanderTextLight(size: 21.0)))
        }
    }
    
    func setDeeplinkName(name: LocalizedStylableText) {
       deeplinkNameLabel.set(localizedStylableText: name)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()        
        backgroundColor = .clear
        separatorView.backgroundColor = .lisboaGray
    }
}
