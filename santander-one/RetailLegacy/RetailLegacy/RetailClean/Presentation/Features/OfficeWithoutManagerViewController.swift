//

import UIKit

protocol OfficeWithoutManagerPresenterProtocol {
    var title: LocalizedStylableText { get }
    var subtitle: LocalizedStylableText { get }
    var signUpTitlebutton: LocalizedStylableText { get }
    var stackViewOneConfig: PersonalManagerStackViewConfig { get }
    var stackViewTwoConfig: PersonalManagerStackViewConfig { get }
}

protocol OfficeWithoutManagerDelegate: class {
    func signUpButtonDidTouched()
}

class OfficeWithoutManagerViewController: BaseViewController<OfficeWithoutManagerPresenterProtocol> {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var stackViewOne: StackOptionsView!
    @IBOutlet weak var stackViewTwo: StackOptionsView!
    
    weak var delegate: OfficeWithoutManagerDelegate?
    
    override class var storyboardName: String {
        return "PersonalManager"
    }
    
    override func prepareView() {
        super.prepareView()
        setupViews()
    }
    
    func setupViews() {
        titleLabel.applyStyle(LabelStylist(textColor: .sanRed, font: UIFont.latoHeavy(size: UIScreen.main.isIphone4or5 ? 24 : 31), textAlignment: .center))
        titleLabel.set(localizedStylableText: presenter.title)
        subtitleLabel.applyStyle(LabelStylist(textColor: .sanGreyDark, font: UIFont.latoRegular(size: UIScreen.main.isIphone4or5 ? 14 : 15.6), textAlignment: .center))
        subtitleLabel.set(localizedStylableText: presenter.subtitle)
        signUpButton.applyStyle(ButtonStylist(textColor: UIColor.uiWhite, font: UIFont.latoHeavy(size: UIScreen.main.isIphone4or5 ? 17 : 18.7)))
        signUpButton.backgroundColor = .sanRed
        signUpButton.layer.cornerRadius = 25
        signUpButton.set(localizedStylableText: presenter.signUpTitlebutton, state: .normal)
        stackViewOne.setup(withConfig: presenter.stackViewOneConfig)
        stackViewTwo.setup(withConfig: presenter.stackViewTwoConfig)
    }

    @IBAction func signUpManager(_ sender: UIButton) {
        delegate?.signUpButtonDidTouched()
    }
}

extension OfficeWithoutManagerViewController: ManagerProfileProtocol {}
