//

import UIKit

protocol CustomizeAvatarPresenterProtocol: SideMenuCapable {
    func changeAvatar()
}

class CustomizeAvatarViewController: BaseViewController<CustomizeAvatarPresenterProtocol> {
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var avatarLabel: UILabel!
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var changeButton: UIButton!
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var headerSeparatorView: UIView!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var bottomSeparatorView: UIView!
    override class var storyboardName: String {
        return "PersonalArea"
    }
    
    override func prepareView() {
        super.prepareView()
        headerLabel.applyStyle(LabelStylist(textColor: .sanGreyDark, font: .latoLight(size: 14), textAlignment: .left))
        avatarLabel.applyStyle(LabelStylist(textColor: .sanGreyDark, font: .latoBold(size: 14), textAlignment: .center))
        avatarImageView.layer.cornerRadius = avatarImageView.frame.size.width / 2
        avatarImageView.layer.borderColor = UIColor.sanRed.cgColor
        avatarImageView.clipsToBounds = true
        headerView.backgroundColor = .white
        headerSeparatorView.backgroundColor = .lisboaGray
        bottomSeparatorView.backgroundColor = .lisboaGray
        bottomView.backgroundColor = .white
        view.backgroundColor = .uiBackground
    }
    
    @objc override func showMenu() {
        presenter.toggleSideMenu()
    }
    
    @IBAction func touchChnageAvatar(_ sender: Any) {
        presenter.changeAvatar()
    }
    
    func setTitleHeader(text: LocalizedStylableText) {
        headerLabel.set(localizedStylableText: text)
    }
    
    func setTitleAvatar(text: LocalizedStylableText) {
        avatarLabel.set(localizedStylableText: text)
    }
    
    func setTitleButton(tex: LocalizedStylableText) {
        changeButton.set(localizedStylableText: tex, state: .normal)
    }
    
    func setImage(data: Data) {
        let image = UIImage(data: data)
        avatarImageView.image = image
        avatarImageView.layer.borderWidth = 1
    }
}

// MARK: - RootMenuController

extension CustomizeAvatarViewController: RootMenuController {
    var isSideMenuAvailable: Bool {
        return presenter.isSideMenuAvailable
    }
}
