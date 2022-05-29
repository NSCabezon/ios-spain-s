import UIKit
import UI
import CoreFoundationLib
import OpenCombine

final class BigButtonView: XibView {
    @IBOutlet private weak var iconImageView: UIImageView!
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
    
    func configure(withModel model: PublicMenuOptionRepresentable, buttonType: BigButtonTypeRepresentable) {
        self.model = model
        if let identifier = model.accessibilityIdentifier {
            self.accessibilityIdentifier = "\(identifier)CardView"
            self.titleLabel.accessibilityIdentifier = "\(identifier)Title"
            self.iconImageView.accessibilityIdentifier = "\(identifier)Icon"
        }
        self.titleLabel.font = buttonType.font
        self.titleLabel.numberOfLines = buttonType.numberOfLines
        self.titleLabel.lineBreakMode = buttonType.lineBreakMode
        self.titleLabel.minimumScaleFactor = buttonType.minimumScaleFactor ?? 0
        self.titleLabel.adjustsFontSizeToFitWidth = buttonType.minimumScaleFactor != nil
        self.titleLabel.configureText(withKey: model.titleKey,
                                 andConfiguration: LocalizedStylableTextConfiguration(lineHeightMultiple: 0.75))
        setNeedsLayout()
        self.iconImageView.loadImage(urlString: model.iconKey,
                                placeholder: Assets.image(named: model.iconKey) ?? Assets.image(named: "icnSantanderPg"))
    }
}

private extension BigButtonView {
    func setupView() {
        self.view?.backgroundColor = .clear
        self.backgroundColor = .white
        self.titleLabel.textColor = .lisboaGray
        self.layer.cornerRadius = 4.0
        self.layer.borderColor = UIColor.mediumSkyGray.cgColor
        self.layer.borderWidth = 1.0
        self.drawShadow(offset: (1, 2), color: UIColor.lightGray.withAlphaComponent(0.3), radius: 2.0)
    }
    
    func addGesture() {
        self.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.didSelectView)))
    }
    
    @objc func didSelectView() {
        guard let model = self.model else { return }
        self.onTouchButtonSubject.send(model)
    }
}
