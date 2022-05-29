import CoreFoundationLib
import UIKit
import UI

public enum BigButtonOldType {
    case stockholders
    case publicProducts
    case publicMenu
    
    var font: UIFont {
        switch self {
        case .publicMenu:
            return UIFont.santander(type: .light, size: 19.0)
        case .stockholders, .publicProducts:
            return UIFont.santander(type: .regular, size: 20)
        }
    }
    
    var lineBreakMode: NSLineBreakMode {
        switch self {
        case .publicMenu, .stockholders, .publicProducts:
            return .byTruncatingTail
        }
    }
    
    var numberOfLines: Int {
        switch self {
        case .publicMenu, .stockholders, .publicProducts:
            return 2
        }
    }
    
    var minimumScaleFactor: CGFloat? {
        switch self {
        case .publicMenu:
            return 0.45
        case .stockholders, .publicProducts:
            return nil
        }
    }
}

public final class BigButtonOldView: XibView {
    @IBOutlet private weak var iconImageView: UIImageView!
    @IBOutlet private weak var titleLabel: UILabel!
    public var action: (() -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.configureStyle()
        self.addGesture()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.configureStyle()
        self.addGesture()
    }
    
    public func setInfo(_ model: ButtonViewModel, withType type: BigButtonOldType) {
        titleLabel.font = type.font
        titleLabel.numberOfLines = type.numberOfLines
        titleLabel.lineBreakMode = type.lineBreakMode
        titleLabel.minimumScaleFactor = type.minimumScaleFactor ?? 0
        titleLabel.adjustsFontSizeToFitWidth = type.minimumScaleFactor != nil
        titleLabel.configureText(withKey: model.titleKey,
                                 andConfiguration: LocalizedStylableTextConfiguration(lineHeightMultiple: 0.94))
        setNeedsLayout()
        iconImageView.loadImage(urlString: model.iconKey,
                                placeholder: Assets.image(named: model.iconKey) ?? Assets.image(named: "icnSantanderPg"))
    }
}

private extension BigButtonOldView {
    func configureStyle() {
        view?.backgroundColor = .clear
        backgroundColor = .white
        titleLabel.textColor = .lisboaGray
        layer.cornerRadius = 4.0
        layer.borderColor = UIColor.mediumSkyGray.cgColor
        layer.borderWidth = 1.0
        drawShadow(offset: (1, 2), color: UIColor.lightGray.withAlphaComponent(0.3), radius: 2.0)
    }
    
    func addGesture() {
        self.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.didSelectView)))
    }
    
    @objc func didSelectView() {
        self.action?()
    }
}
