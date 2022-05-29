import UIKit
import UI

struct LandingButtonInfo {
    var title: LocalizedStylableText
    var action: (() -> Void)?
}

struct LandingGraphicsInfo {
    var backgroundImage: String
    var phoneImage: String
}

protocol LandingPresenterProtocol: Presenter, SideMenuCapable {
    var title: LocalizedStylableText? { get }
    var descriptionText: LocalizedStylableText? { get }
    var graphics: LandingGraphicsInfo { get }
    var button: LandingButtonInfo? { get }
}

class LandingViewController: BaseViewController<LandingPresenterProtocol> {
    
    @IBOutlet private weak var descriptionLabel: UILabel!
    @IBOutlet private weak var scrollView: UIScrollView!
    @IBOutlet private weak var backgroundImage: UIImageView!
    @IBOutlet private weak var phoneImage: UIImageView!
    @IBOutlet private weak var scrollAndButtonContainerPin: NSLayoutConstraint?
    @IBOutlet private weak var button: RedButton!
    @IBOutlet private weak var dialogImage: UIImageView!
    @IBOutlet weak var iPhoneXView: UIView!
    
    override class var storyboardName: String {
        return "Landings"
    }
    
    override func prepareView() {
        super.prepareView()
        
        styledTitle = presenter.title
        self.dialogImage.image = Assets.image(named: "mpDialogo")

        set(description: presenter.descriptionText ?? .empty)
        set(graphics: presenter.graphics)
        set(button: presenter.button)
    }
    
    @IBAction func actionButtonTouched(_ sender: Any) {
        presenter.button?.action?()
    }
    
    override func showMenu() {
        presenter.toggleSideMenu()
    }
    
    private func set(description: LocalizedStylableText) {
        descriptionLabel.applyStyle(LabelStylist(textColor: .uiWhite, font: .latoRegular(size: UIScreen.main.isIphone4or5 ? 14: 16), textAlignment: .center))
        descriptionLabel.set(localizedStylableText: description)
        descriptionLabel.set(lineSpacing: 5.0)
    }
    
    private func set(graphics: LandingGraphicsInfo) {
        backgroundImage.image = Assets.image(named: presenter.graphics.backgroundImage)
        phoneImage.image = Assets.image(named: presenter.graphics.phoneImage)
    }
    
    private func set(button: LandingButtonInfo?) {
        if let buttonData = button {
            let buttonStyle = ButtonStylist(textColor: .uiWhite, font: .latoMedium(size: 16.0))
            (self.button as UIButton).applyStyle(buttonStyle)
            self.button.set(localizedStylableText: buttonData.title, state: .normal)
            iPhoneXView.isHidden = false
        } else {
            removeButtonContainer()
            iPhoneXView.isHidden = true
        }
    }
    
    private func removeButtonContainer() {
        scrollAndButtonContainerPin?.isActive = false
        let newConstraint: NSLayoutConstraint
        if #available(iOS 11, *) {
            newConstraint = scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        } else {
            newConstraint = scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        }
        newConstraint.isActive = true
        let buttonContainer = button.superview
        buttonContainer?.removeFromSuperview()
    }
}

// MARK: - RootMenuController

extension LandingViewController: RootMenuController {
    var isSideMenuAvailable: Bool {
        return presenter.isSideMenuAvailable
    }
}
