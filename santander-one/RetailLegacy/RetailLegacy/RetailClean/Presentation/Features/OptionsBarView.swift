import UIKit
import CoreFoundationLib

final class OptionsBarView: UIView {
    
    private let containerStackView: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        stack.isLayoutMarginsRelativeArrangement = true
        stack.spacing = 2
        
        return stack
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setupViews()
    }
    
    private func setupViews() {
        containerStackView.embedInto(container: self)
    }
    
    func setOptions(_ options: [PrivateMenuOption]) {
        for view in containerStackView.arrangedSubviews {
            view.removeFromSuperview()
        }
        var previousButton: PressFXView?
        for var option in options {
            let button = PressFXView()
            button.translatesAutoresizingMaskIntoConstraints = false
            button.setTitle(option.title)
            button.setIcon(option.iconKey)
            button.action = option.action
            button.isAccessibilityElement = true
			button.accessibilityIdentifier = (option as? AccessibilityProtocol)?.accessibilityIdentifier
            button.setLabelAccessibilityIdentifier(AccessibilitySideMenu.exitLabel)
            button.setCoachmarkId(option.coachmarkId)
            if let stringURL = option.imageURL, let url = URL(string: stringURL) {
                button.updateImageWith(url)
            }
            option.didUpdateImageURL = { stringURL in
                if let url = URL(string: stringURL) {
                    button.updateImageWith(url)
                }
            }
            button.accessibilityLabel = option.title.text
            button.accessibilityTraits = .button
            containerStackView.addArrangedSubview(button)
            if previousButton != nil {
                previousButton?.contentTopAnchor.constraint(equalTo: button.contentTopAnchor).isActive = true
            } else {
                previousButton = button
            }
        }
    }
    
    func setNotificationBadgeVisible(_ visible: Bool, inCoachmark id: CoachmarkIdentifier?) {
        containerStackView.arrangedSubviews.forEach {
            guard let button = $0 as? PressFXView, button.coachmarkId == id else { return }
            button.showNotificationBadge(visible)
        }
    }
}
