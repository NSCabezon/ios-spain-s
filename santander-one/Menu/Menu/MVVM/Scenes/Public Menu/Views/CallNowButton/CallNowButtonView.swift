import Foundation
import UI
import CoreFoundationLib
import OpenCombine

final class CallNowButtonView: XibView {
    @IBOutlet weak var numberLabel: UILabel!
    @IBOutlet weak var iconPhoneImage: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    
    var model: PublicMenuOptionRepresentable?
    var phone: String?
    let onTouchButtonSubject = PassthroughSubject<(model: PublicMenuOptionRepresentable, phone: String), Never>()

    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupView()
        self.addGesture()
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupView()
        self.addGesture()
    }
    
    func configure(withModel model: PublicMenuOptionRepresentable, phone: String) {
        self.model = model
        if let identifier = model.accessibilityIdentifier {
            self.accessibilityIdentifier = "\(identifier)OneView"
            self.titleLabel.accessibilityIdentifier = "\(identifier)OneTitle"
            self.numberLabel.accessibilityIdentifier = "\(identifier)OneBody"
            self.iconPhoneImage.accessibilityIdentifier = "\(identifier)OneIcon"
        }
        self.phone = phone
        titleLabel.text = localized(model.titleKey)
        iconPhoneImage.image = Assets.image(named: model.iconKey)
        numberLabel.text = phone
    }
}

private extension CallNowButtonView {

    func setupView() {
        self.view?.drawRoundedAndShadowedNew(radius: 4,
                                        borderColor: .mediumSky,
                                        widthOffSet: 1,
                                        heightOffSet: 2)
        titleLabel.textColor = .white
        titleLabel.font = .santander(family: .text, type: .light, size: 20.0)
        
        numberLabel.textColor = .white
        numberLabel.font = .santander(family: .text, type: .bold, size: 20.0)
        
        self.view?.backgroundColor = UIColor.darkTorquoise
    }
    
    func addGesture() {
        self.view?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapOnCallNow)))
    }
    
    @IBAction func didTapOnCallNow() {
        guard let model = self.model,
              let phone = self.phone else { return }
        self.onTouchButtonSubject.send((model: model, phone: phone))
    }
}
