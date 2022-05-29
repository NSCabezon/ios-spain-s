import UIKit
import UI

enum PersonalManagerOfferType {
    case clock, operative, devices, free
}

class PersonalManagerOfferViewCellWithSubtitle: BaseViewCell {

    @IBOutlet weak var offerImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.backgroundColor = .uiBackground
        
        titleLabel.applyStyle(LabelStylist(textColor: .sanRed, font: .latoBold(size: 15), textAlignment: .left))
        subtitleLabel.applyStyle(LabelStylist(textColor: .sanGreyDark, font: .latoRegular(size: 14), textAlignment: .left))
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
