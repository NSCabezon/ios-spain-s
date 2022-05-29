import UIKit
import CoreFoundationLib
import UI

protocol FormPresenterProtocol: Presenter {
    func onContinueButtonClicked()
}

protocol BackablePresenterProtocol {
    func didTapBack()
}

class FormViewController: BaseViewController<FormPresenterProtocol> {
    @IBOutlet weak var continueButton: RedButton!
    @IBOutlet weak var continueButtonView: UIView!
    @IBOutlet weak var separtorView: UIView!
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var scrollView: UIScrollView!
    lazy var dataSource: StackDataSource = { StackDataSource(stackView: stackView, delegate: self) }()
    override class var storyboardName: String {
        return "Form"
    }
    @IBAction private func onContinueButtonClicked(_ sender: UIButton) {
        presenter.onContinueButtonClicked()
    }
    var isSideMenuCapable = false
    var showMenuClosure: (() -> Void)?
    var backgroundColorProgressBar: UIColor = .uiWhite
    
    override func prepareView() {
        super.prepareView()
        view.backgroundColor = .uiWhite
        stackView.backgroundColor = .uiBackground
        scrollView.backgroundColor = .uiBackground
        continueButtonView.backgroundColor = .uiWhite
        separtorView.backgroundColor = .lisboaGray
        continueButton.configureHighlighted(font: .latoBold(size: 16))
        self.navigationController?.navigationBar.setNavigationBarColor(.uiWhite)
        setAccessibilityIdentifiers()
    }
    
    private func setAccessibilityIdentifiers() {
        titleIdentifier = AccessibilityCardChargeDischarge.titleChargeOrDischarge
        self.continueButton.accessibilityIdentifier = AccessibilityOthers.btnContinue.rawValue
    }
    
    override var progressBarBackgroundColor: UIColor? {
        return self.navigationController?.navigationBar.barTintColor ?? backgroundColorProgressBar
    }
    
    @objc override func showMenu() {
        showMenuClosure?()
    }
    
    public func setTitle(_ title: String, subtitle: String) {
        let builder = NavigationBarBuilder(
            style: .sky,
            title: .titleWithHeader(titleKey: title,
                                    header: .title(key: subtitle, style: .default))
        )
        if !self.hidesBackButton {
            builder.setLeftAction(.back(action: #selector(didTapBack)))
        }
        builder.build(on: self, with: nil)
    }
    
    @objc func didTapBack() {
        (presenter as? BackablePresenterProtocol)?.didTapBack()
    }
}

// MARK: - ToolTipDisplayer

extension FormViewController: ToolTipDisplayer {}

// MARK: - StackDataSourceDelegate

extension FormViewController: StackDataSourceDelegate {
    func scrollToVisible(view: UIView) {
        scrollView.scrollRectToVisible(view.frame, animated: true)
    }
}

extension FormViewController: RootMenuController {
    var isSideMenuAvailable: Bool {
        return isSideMenuCapable
    }
}
