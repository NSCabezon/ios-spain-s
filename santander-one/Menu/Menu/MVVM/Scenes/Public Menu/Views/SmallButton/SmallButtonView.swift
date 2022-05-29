import UIKit
import UI
import CoreFoundationLib
import OpenCombine

final class SmallButtonView: XibView {
    @IBOutlet private weak var iconImageView: UIImageView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet weak var spaceElementsConstraint: NSLayoutConstraint!
    
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
    
    func configure(withModel model: PublicMenuOptionRepresentable, buttonType: SmallButtonTypeRepresentable) {
        self.model = model
        if let identifier = model.accessibilityIdentifier {
            self.accessibilityIdentifier = "\(identifier)CardView"
            self.titleLabel.accessibilityIdentifier = "\(identifier)Title"
            self.iconImageView.accessibilityIdentifier = "\(identifier)Icon"
        }
        self.titleLabel.font = buttonType.font
        self.titleLabel.configureText(withKey: model.titleKey, andConfiguration: LocalizedStylableTextConfiguration(lineHeightMultiple: 0.75))
        setNeedsLayout()
        self.iconImageView.image = Assets.image(named: model.iconKey)
    }
    
    public func spaceBetweenElements(_ space: CGFloat) {
        self.spaceElementsConstraint.constant = space
    }
}

private extension SmallButtonView {
    func setupView() {
        self.view?.backgroundColor = .clear
        self.backgroundColor = .white
        self.titleLabel.font = .santander(family: .text, type: .light, size: 18)
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
