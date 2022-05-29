import UIKit
import UI
import CoreFoundationLib
import OpenCombine

final class ATMView: XibView {
    @IBOutlet private weak var backgroundImageView: UIImageView!
    @IBOutlet private weak var atmImageView: UIImageView!
    @IBOutlet private weak var titleLabel: UILabel!
    
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
    
    func configure(withModel model: PublicMenuOptionRepresentable, bgImage: String?) {
        self.model = model
        if let identifier = model.accessibilityIdentifier {
            self.accessibilityIdentifier = "\(identifier)CardView"
            self.titleLabel.accessibilityIdentifier = "\(identifier)Title"
            self.atmImageView.accessibilityIdentifier = "\(identifier)Icon"
            self.backgroundImageView.accessibilityIdentifier = "\(identifier)Map"
        }
        if let backImage = bgImage {
            backgroundImageView.image = Assets.image(named: backImage)
        }
        self.titleLabel.configureText(withKey: model.titleKey, andConfiguration: LocalizedStylableTextConfiguration(lineHeightMultiple: 0.7))
        self.atmImageView.image = Assets.image(named: model.iconKey)
    }
}

private extension ATMView {
    func setupView() {
        self.accessibilityIdentifier = "btnFindaATM"
        self.backgroundColor = .clear
        self.view?.backgroundColor = UIColor.clear
        self.view?.clipsToBounds = true
        self.view?.layer.cornerRadius = 4.0
        self.layer.cornerRadius = 4.0
        self.layer.borderColor = UIColor.mediumSkyGray.cgColor
        self.layer.borderWidth = 1.0
        self.drawShadow(offset: (1, 2), color: UIColor.lightGray.withAlphaComponent(0.3), radius: 2.0)
        self.titleLabel.font = .santander(family: .text, type: .regular, size: 20)
        self.titleLabel.textColor = .white
    }
    
    func addGesture() {
        self.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.didSelectView)))
    }
    
    @objc func didSelectView() {
        guard let model = self.model else { return }
        self.onTouchButtonSubject.send(model)
    }
}
