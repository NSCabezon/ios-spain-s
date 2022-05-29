import UIKit
import UI

final class MenuOfferTableViewCell: BaseViewCell {
    @IBOutlet weak private var roundedView: UIView!
    @IBOutlet weak private var imageOfferView: UIImageView!
    @IBOutlet weak private var titleLabel: UILabel!
    
    var title: LocalizedStylableText? {
        didSet {
            if let text = title {
                self.titleLabel.set(localizedStylableText: text)
            } else {
                self.titleLabel.text = nil
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.configureView()
    }
    
    func setImage(_ name: String) {
        imageOfferView.image = Assets.image(named: name)?.withRenderingMode(.alwaysTemplate)
        imageOfferView.tintColor = .botonRedLight
    }
    
    func hideImage() {
        imageOfferView.isHidden = true
    }
}

private extension MenuOfferTableViewCell {
    func setSelectionStyle() {
        selectionStyle = .none
    }
    
    func configureView() {
        self.titleLabel.setSantanderTextFont(type: .regular, size: 18.0, color: .lisboaGrayNew)
        self.setSelectionStyle()
        self.roundedView.drawBorder(color: .mediumSkyGray)
    }
}
