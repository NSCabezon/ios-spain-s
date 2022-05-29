import UI
import CoreFoundationLib

protocol ModeSelectorPresenterProtocol: Presenter {
    func onContinueButtonClicked()
    func didTapFaqs()
    func didTapClose()
    func didTapBack()
    func trackFaqEvent(_ question: String, url: URL?)
}

class ModeSelectorViewController: BaseViewController<ModeSelectorPresenterProtocol> {
    @IBOutlet weak var continueButton: RedButton!
    @IBOutlet weak var continueButtonView: UIView!
    @IBOutlet weak var separtorView: UIView!
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var scrollView: UIScrollView!
    lazy var dataSource: StackDataSource = { StackDataSource(stackView: stackView, delegate: self) }()
    override class var storyboardName: String {
        return "BillAndTaxesOperative"
    }
    @IBAction private func onContinueButtonClicked(_ sender: UIButton) {
        presenter.onContinueButtonClicked()
    }
    var isSideMenuCapable = false
    var showMenuClosure: (() -> Void)?
    var backgroundColorProgressBar: UIColor = .white

    override func prepareView() {
        super.prepareView()
        view.backgroundColor = .uiWhite
        stackView.backgroundColor = .uiBackground
        scrollView.backgroundColor = .uiBackground
        continueButtonView.backgroundColor = .uiWhite
        separtorView.backgroundColor = .lisboaGray
        continueButton.configureHighlighted(font: .latoBold(size: 16))
    }
    
    override var progressBarBackgroundColor: UIColor? {
        return backgroundColorProgressBar
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupNavigationBar()
    }
    
    @objc override func showMenu() {
        showMenuClosure?()
    }
    
    func setupNavigationBar() {
        let builder = NavigationBarBuilder(
            style: .white,
            title: .titleWithHeader(
                titleKey: styledTitle?.text ?? "",
                header: .title(
                    key: localizedSubTitleKey ?? "",
                    style: .default
                )
            )
        )
        builder.setLeftAction(.back(action: #selector(back)))
        builder.setRightActions(
            NavigationBarBuilder.RightAction.close(action: #selector(close)),
            NavigationBarBuilder.RightAction.help(action: #selector(faqs))
        )
        builder.build(on: self, with: nil)
    }
    
    @objc private func faqs() {
        presenter.didTapFaqs()
    }
    
    @objc private func close() {
        presenter.didTapClose()
    }
    
    @objc private func back() {
        presenter.didTapBack()
    }
    
    func showFaqs(_ items: [FaqsItemViewModel]) {
        let data = FaqsViewData(items: items)
        data.show(in: self)
    }
}

extension ModeSelectorViewController: FaqsViewControllerDelegate {
    func didExpandAnswer(question: String) {
        presenter.trackFaqEvent(question, url: nil)
    }
    
    func didTapAnswerLink(question: String, url: URL) {
        presenter.trackFaqEvent(question, url: url)
    }
}

// MARK: - ToolTipDisplayer

extension ModeSelectorViewController: ToolTipDisplayer {}

// MARK: - StackDataSourceDelegate

extension ModeSelectorViewController: StackDataSourceDelegate {
    func scrollToVisible(view: UIView) {
        scrollView.scrollRectToVisible(view.frame, animated: true)
    }
}

extension ModeSelectorViewController: RootMenuController {
    var isSideMenuAvailable: Bool {
        return isSideMenuCapable
    }
}
