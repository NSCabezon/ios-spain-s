//
//  OtherOperativesViewController.swift
//  Card
//
//  Created by Boris Chirino Fernandez on 04/12/2019.
//

import UIKit
import CoreFoundationLib
import UI

protocol OtherOperativesViewProtocol: AnyObject {
    func addActions(_ actions: [CardActionViewModel], sectionTitle: String, sectionTitleIdentifier: String?)
}

final class OtherOperativesViewController: UIViewController {
    
    lazy var stackView: ActionButtonsScrollableStackView<CardActionViewModel> = {
        let stackView = ActionButtonsScrollableStackView<CardActionViewModel>()
        return stackView
    }()
    @IBOutlet weak var topTitle: UILabel!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var containerView: UIView!
    
    var presenter: OtherOperativesPresenterProtocol
    
    init(nibName: String?, bundle: Bundle?, presenter: OtherOperativesPresenterProtocol) {
        self.presenter = presenter
        super.init(nibName: nibName, bundle: bundle)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
        self.presenter.viewDidLoad()
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    // MARK: - Orientation. Only using shouldAutorotate because of the UINavigationController extension in UI
    override var shouldAutorotate: Bool {
        return false
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
    private func setupUI() {
        self.topTitle.text = localized("cardsOption_label_moreOptions")
        self.topTitle.font = UIFont.santander(family: FontFamily.headline, type: FontType.bold, size: 16.0)
        self.topTitle.textColor = UIColor.santanderRed
        self.closeButton.setImage(Assets.image(named: "icnClose"), for: .normal)
        self.stackView.setup(with: self.containerView)
        self.view.backgroundColor = .skyGray
        self.setAccessibilityIdentifiers()
    }
    
    private func setAccessibilityIdentifiers() {
        self.topTitle.accessibilityIdentifier = "cardsOption_label_title"
        self.closeButton.accessibilityIdentifier = "cardsOption_image_closeMoreOptions"
    }
    
    @IBAction func closeButtonAction(sender: UIButton) {
        self.presenter.finishAndDismissView()
    }
}

extension OtherOperativesViewController: OtherOperativesViewProtocol {
    func addActions(_ actions: [CardActionViewModel], sectionTitle: String, sectionTitleIdentifier: String? = nil) {
        self.stackView.addActions(actions, sectionTitle: sectionTitle, sectionTitleIdentifier: sectionTitleIdentifier, allowDisable: true)
    }
}
