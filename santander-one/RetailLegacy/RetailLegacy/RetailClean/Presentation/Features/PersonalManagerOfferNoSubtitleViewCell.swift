//

import UIKit
import UI

class PersonalManagerOfferNoSubtitleViewCell: BaseViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var offerImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundColor = .uiBackground
        
        titleLabel.applyStyle(LabelStylist(textColor: .sanRed, font: .latoBold(size: 15), textAlignment: .left))
    }
    
    func setImage(type: PersonalManagerOfferType) {
        let image: UIImage
        switch type {
        case .clock:
            image = Assets.image(named: "icnClockManager") ?? UIImage()
        case .operative:
            image = Assets.image(named: "icnOperationManager2") ?? UIImage()
        case .devices:
            image = Assets.image(named: "icnDeviceManager") ?? UIImage()
        case .free:
            image = Assets.image(named: "icnFreeManager") ?? UIImage()
        }
        self.offerImageView.image = image
    }
    
}
