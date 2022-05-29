import UIKit
import UI
import CoreFoundationLib
import CoreDomain

final class MenuItemTableViewCell: UITableViewCell {
    private enum Constants {
        static let animationDelay: TimeInterval = 0.2
        static let animationDuration: TimeInterval = 0.3
        static let componentDefaultRadio: CGFloat = 2.0
        static let maxAlpha: CGFloat = 1.0
        static let boldFontSize: CGFloat = 10.0
        static let newTextWithContentBottomConstraint: CGFloat = 8
        static let newTextWithNoContentBottomConstraint: CGFloat = 8
        static let titleHighlightedStyleFontSize: CGFloat = 18
        static let titleDefaultStyleFontSize: CGFloat = 16
        static let featuredCellTouchRadio: CGFloat = 4
        static let featuredContentRadius: CGFloat = 4
        static let newContentRadius: CGFloat = 2
        static let extraMessageFeatured: CGFloat = 13
        static let lineInterSpace: CGFloat = 0.75
    }
    var isFeaturedCell = false
    var isHighlightedCell = false
    private var privateMenuModel: PrivateMenuOptionRepresentable?
    var titleText: LocalizedStylableText? {
        didSet {
            if let text = titleText {
                titleLabel.configureText(withLocalizedString: text)
            } else {
                titleLabel.text = nil
            }
        }
    }
    
    var descriptionText: String? {
        didSet {
            guard let descrText = descriptionText else {
                extraMessageLabel.isHidden = true
                return
            }
            extraMessageLabel.configureText(withKey: descrText,
                                            andConfiguration: LocalizedStylableTextConfiguration(lineHeightMultiple: Constants.lineInterSpace))
        }
    }
    
    var newText: LocalizedStylableText? {
        didSet {
            if let text = newText {
                let font =  UIFont.santander(family: .text, type: .bold, size: Constants.boldFontSize)
                let configuration = LocalizedStylableTextConfiguration(font: font)
                newLabel.configureText(withLocalizedString: text.uppercased(), andConfiguration: configuration)
                newLabel.textColor = .white
                newContainerView.isHidden = false
                messagesStackBottomConstraint.constant = Constants.newTextWithContentBottomConstraint
            } else {
                newLabel.text = nil
                messagesStackBottomConstraint.constant = Constants.newTextWithNoContentBottomConstraint
                newContainerView.isHidden = true
            }
        }
    }

    @IBOutlet private weak var featuredContentView: UIView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var extraMessageLabel: UILabel!
    @IBOutlet private weak var iconImageView: UIImageView!
    @IBOutlet private weak var newContentView: UIView!
    @IBOutlet private weak var newContainerView: UIView!
    @IBOutlet private weak var newLabel: UILabel!
    @IBOutlet private weak var messagesStackBottomConstraint: NSLayoutConstraint!
    @IBOutlet private weak var submenuArrow: UIImageView!
    @IBOutlet private weak var highlightedView: UIView!

    override func awakeFromNib() {
        super.awakeFromNib()
        titleLabel.font = UIFont.santander(family: .text,
                                           type: .regular,
                                           size: Constants.titleDefaultStyleFontSize)
        titleLabel.textColor = UIColor.lisboaGray
        setSelectionStyle()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
        
    private func setSelectionStyle() {
        selectionStyle = .none
        submenuArrow.image = Assets.image(named: "icnArrowRightSmall")
    }

    func setImage(named name: String, tintColor: UIColor? = .bostonRedLight) {
        iconImageView.image = Assets.image(named: name)
    }
    
    func hideImage() {
        iconImageView.isHidden = true
    }
    
    func animateViewCell() {
        self.featuredContentView.backgroundColor = .white
        self.newContentView.alpha = .zero
        UIView.animate(withDuration: Constants.animationDuration,
                       delay: Constants.animationDelay,
                       options: .curveEaseIn, animations: { [weak self] in
            self?.featuredContentView.backgroundColor = .whitesmokes
            self?.newContentView.alpha = Constants.maxAlpha
        }, completion: nil)
    }
    
    func resetAnimationCell() {
        self.featuredContentView.backgroundColor = .white
        self.newContentView.alpha = Constants.maxAlpha
    }
    
    func showSubmenuArrow(showArrow: Bool) {
        submenuArrow.isHidden = !showArrow
    }
    
    func getPrivateMenuOptionType() -> PrivateMenuOptions? {
        return privateMenuModel?.type
    }
}

// MARK: - touch events

extension MenuItemTableViewCell {
     override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
         super.touchesBegan(touches, with: event)
         if isFeaturedCell {
             featuredContentView.backgroundColor = .lightSky
             featuredContentView.layer.cornerRadius = Constants.componentDefaultRadio
         }
     }
     
     override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
         super.touchesEnded(touches, with: event)
         if isFeaturedCell {
             featuredContentView.backgroundColor = .whitesmokes
             featuredContentView.layer.cornerRadius = Constants.featuredCellTouchRadio
         }
     }
     
     override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
         super.touchesCancelled(touches, with: event)
         if isFeaturedCell {
             featuredContentView.backgroundColor = .whitesmokes
             featuredContentView.layer.cornerRadius = Constants.featuredCellTouchRadio
         }
     }
}

extension MenuItemTableViewCell {
    func configureWithModel(_ model: PrivateMenuOptionRepresentable) {
        titleText = localized(model.titleKey)
        if let extraMessage = model.extraMessageKey {
            descriptionText = localized(extraMessage)
        }
        if let newMessageText = model.newMessageKey {
            newText = localized(newMessageText)
        }
        isFeaturedCell = model.isFeatured
        isHighlightedCell = model.isHighlighted
        setFeaturedCell(isFeatured: model.isFeatured)
        setHighlightedCell(isHighlight: model.isHighlighted)
        showSubmenuArrow(showArrow: model.showArrow)
        if let imageURL = model.imageURL, let _ = URL(string: imageURL) {
            imageView?.loadImage(urlString: imageURL)
        } else {
            setImage(named: model.imageKey)
        }
        self.setAccessibilityIdentifiers(model)
        self.privateMenuModel = model
    }
    
    func configureWithModel(_ model: PrivateSubMenuOptionRepresentable) {
        titleText = localized(model.titleKey)
        if let count = model.elementsCount, count != .zero {
            titleText?.text += " (\(count))"
        }
        showSubmenuArrow(showArrow: model.submenuArrow)
        setHighlightedCell(isHighlight: false)
        setFeaturedCell(isFeatured: false)
        if let imageName = model.icon {
            setImage(named: imageName)
        }
        self.setAccessibilityIdentifiers(model)
    }
}

// MARK: - Featured hightlighted style
extension MenuItemTableViewCell {
    func setFeaturedCell(isFeatured: Bool) {
        isFeatured ? self.setFeaturedStyle() : self.hideFeaturedStyle()
    }
    
    func setFeaturedStyle() {
        newLabel.isHidden = false
        extraMessageLabel.isHidden = false
        extraMessageLabel.font = UIFont.santander(family: .text,
                                                  type: .regular,
                                                  size: Constants.extraMessageFeatured)
        extraMessageLabel.textColor = UIColor.lisboaGray
        featuredContentView.backgroundColor = .whitesmokes
        featuredContentView.layer.cornerRadius = Constants.featuredContentRadius
        newContentView.backgroundColor = .darkTorquoise
        newContentView.layer.cornerRadius = Constants.newContentRadius
        newLabel.font = UIFont.santander(family: .text,
                                         type: .bold,
                                         size: Constants.boldFontSize)
        newLabel.textColor = .white
    }
    
    func hideFeaturedStyle() {
        newContainerView.isHidden = true
        newLabel.isHidden = true
        extraMessageLabel.isHidden = true
        newContentView.backgroundColor = .white
        featuredContentView.backgroundColor = .white
    }
    
    func setHighlightedCell(isHighlight: Bool) {
        isHighlight ? setHighlightedStyle() : resetHighlightedStyle()
    }
    
    func setHighlightedStyle() {
        titleLabel.font = UIFont.santander(family: .text,
                                           type: .regular,
                                           size: Constants.titleHighlightedStyleFontSize)
        titleLabel.textColor = UIColor.santanderRed
        highlightedView.backgroundColor = .botonRedLight
    }
    
    func resetHighlightedStyle() {
        titleLabel.font = UIFont.santander(family: .text,
                                           type: .regular,
                                           size: Constants.titleHighlightedStyleFontSize)
        titleLabel.textColor = UIColor.lisboaGray
        highlightedView.backgroundColor = .clear
    }
}

private extension MenuItemTableViewCell {
    func setAccessibilityIdentifiers(_ model: PrivateMenuOptionRepresentable) {
        titleLabel.accessibilityIdentifier = model.titleKey
        extraMessageLabel.accessibilityIdentifier = model.extraMessageKey
        iconImageView.accessibilityIdentifier = model.imageKey
        iconImageView.isAccessibilityElement = true
        newLabel.accessibilityIdentifier = model.newMessageKey
        if model.showArrow {
            submenuArrow.accessibilityIdentifier = "icnArrowRightSmall"
        }
        self.accessibilityIdentifier = model.titleKey + "Cell"
    }
    
    func setAccessibilityIdentifiers(_ model: PrivateSubMenuOptionRepresentable) {
        titleLabel.accessibilityIdentifier = model.titleKey
        iconImageView.isAccessibilityElement = true
        iconImageView.accessibilityIdentifier = model.icon
        if model.submenuArrow {
            submenuArrow.accessibilityIdentifier = "icnArrowRightSmall"
        }
        self.accessibilityIdentifier = model.titleKey + "_cell"
    }
}
