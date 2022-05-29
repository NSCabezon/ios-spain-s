import UIKit
import UI
import CoreFoundationLib
import OpenCombine

final class BigCallButtonView: XibView {
    @IBOutlet private weak var frameView: UIView!
    @IBOutlet private weak var iconImageView: UIImageView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var callImageView: UIImageView!
    
    var model: PublicMenuOptionRepresentable?
    let onTouchButtonSubject = PassthroughSubject<PublicMenuOptionRepresentable, Never>()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupView()
        self.addGesture()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setupView()
        self.addGesture()
    }
    
    func configure(withModel model: PublicMenuOptionRepresentable) {
        self.model = model
        if let identifier = model.accessibilityIdentifier {
            self.accessibilityIdentifier = "\(identifier)View"
            self.titleLabel.accessibilityIdentifier = "\(identifier)Title"
            self.iconImageView.accessibilityIdentifier = "\(identifier)Icon"
            self.callImageView.accessibilityIdentifier = "\(identifier)CornerIcon"
        }
        
        self.titleLabel.configureText(withLocalizedString: localized(model.titleKey),
                                      andConfiguration: LocalizedStylableTextConfiguration(font: .santander(family: .text, type: .light, size: 20), lineHeightMultiple: 0.94))
        self.iconImageView.image = Assets.image(named: model.iconKey)
        self.callImageView.image = Assets.image(named: "icnCornerPhone")
    }
}

private extension BigCallButtonView {
    
    func setupView() {
        self.view?.backgroundColor = .clear
        self.backgroundColor = .clear
        self.view?.backgroundColor = UIColor.clear
        self.frameView.backgroundColor = .white
        self.frameView.layer.cornerRadius = 4.0
        self.frameView.layer.borderColor = UIColor.mediumSkyGray.cgColor
        self.frameView.layer.borderWidth = 1.0
        self.frameView.drawShadow(offset: (1, 2), color: UIColor.lightGray.withAlphaComponent(0.3), radius: 2.0)
        self.titleLabel.textColor = .lisboaGray
    }

    func addGesture() {
        self.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.didSelectView)))
    }
    
    @objc func didSelectView() {
        guard let model = self.model else { return }
        self.onTouchButtonSubject.send(model)
    }
}
