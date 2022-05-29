//
//  BizumDonationNGOSelectorViewController.swift
//  Bizum

import UI
import CoreFoundationLib
import Operative
import ESUI

protocol BizumDonationNGOSelectorViewProtocol: OperativeView, ValidatableFormViewProtocol {
    // Carousel header
    func showOrganizationsCarousel(_ viewModels: [BizumNGOCollectionViewCellViewModel])
    var organizationCode: String? { get }
}

final class BizumDonationNGOSelectorViewController: UIViewController {
    let presenter: BizumDonationNGOSelectorPresenterProtocol
    private var organizationViewModels: [BizumNGOListViewModel] = []
    private var filteredOrganizationViewModels: [BizumNGOListViewModel] = []
    private var searchTerm: String?
    let keyboardManager: KeyboardManager = KeyboardManager()
    @IBOutlet private weak var containerView: UIView!
    @IBOutlet private weak var continueButton: WhiteLisboaButton!
    @IBOutlet private weak var separatorView: UIView! {
        didSet {
            self.separatorView.backgroundColor = .mediumSkyGray
        }
    }
    private var searchHeader: BizumNGOSearchView?
    var organizationCode: String? {
        return self.enterOrganizationCodeView.enterNGOCodeView.text
    }
    
    private lazy var scrollableStackView: ScrollableStackView = {
        let view = ScrollableStackView()
        view.setup(with: self.containerView)
        view.setSpacing(8.0)
        return view
    }()
    
    private lazy var selectOrganizationCarrouselView: BizumSelectedNGOHeaderView = {
        let selectionView = BizumSelectedNGOHeaderView(frame: .zero)
        selectionView.translatesAutoresizingMaskIntoConstraints = false
        return selectionView
    }()

    private lazy var enterOrganizationCodeView: BizumNGOSearchView = {
        let searchView = BizumNGOSearchView(frame: .zero)
        searchView.translatesAutoresizingMaskIntoConstraints = false
        return searchView
    }()

    init(nibName nibNameOrNil: String?, presenter: BizumDonationNGOSelectorPresenterProtocol) {
        self.presenter = presenter
        super.init(nibName: nibNameOrNil, bundle: .module)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupNavigationBar()
        self.configureView()
        self.presenter.viewDidLoad()
        self.keyboardManager.setDelegate(self)
        self.setAccessibilityIdentifiers()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        operativeViewWillDisappear()
    }
    
    func configureView() {
        self.configureScrollableStackView()
        self.configureContinueButton()
    }
    
    func configureScrollableStackView() {
        self.scrollableStackView.addArrangedSubview(selectOrganizationCarrouselView)
        self.scrollableStackView.addArrangedSubview(enterOrganizationCodeView)
        self.selectOrganizationCarrouselView.delegate = self
        self.enterOrganizationCodeView.delegate = self
        self.enterOrganizationCodeView.enableView()
        self.presenter.fields.append(enterOrganizationCodeView.enterNGOCodeView)
        enterOrganizationCodeView.enterNGOCodeView.updatableDelegate = self
    }

    func configureContinueButton() {
        self.continueButton.setTitle(localized("generic_button_continue"), for: .normal)
        self.continueButton.addSelectorAction(target: self, #selector(didSelectContinue))
        self.continueButton.setIsEnabled(false)
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
}

extension BizumDonationNGOSelectorViewController: BizumDonationNGOSelectorViewProtocol {

    var operativePresenter: OperativeStepPresenterProtocol {
        return presenter
    }
    
    func showOrganizationsCarousel(_ viewModels: [BizumNGOCollectionViewCellViewModel]) {
        self.selectOrganizationCarrouselView.setViewModels(viewModels)
    }
}

extension BizumDonationNGOSelectorViewController: ValidatableFormViewProtocol {
    func updateContinueAction(_ enable: Bool) {
        self.continueButton.setIsEnabled(enable)
        self.keyboardManager.setKeyboardButtonEnabled(enable)
    }
}

private extension BizumDonationNGOSelectorViewController {
    
    func setupNavigationBar() {
        let titleImage = TitleImage(image: ESAssets.image(named: "icnBizumHeader"),
                                    topMargin: 4,
                                    width: 16,
                                    height: 16)
        let builder = NavigationBarBuilder(
            style: .sky,
            title: .titleWithHeaderAndImage(titleKey: "toolbar_title_donation",
                                            header: .title(key: "toolbar_title_bizum", style: .default),
                                            image: titleImage)
        )
        builder.setRightActions(
            NavigationBarBuilder.RightAction.close(action: #selector(close))
        )
        builder.build(on: self, with: nil)
    }
    
    @objc func close() {
        self.presenter.didSelectClose()
    }
    
    @objc private func didSelectContinue() {
        self.view.resignFirstResponder()
        self.presenter.updateOrganizationCode(enterOrganizationCodeView.enterNGOCodeView.text ?? "")
        self.presenter.didSelectContinue()
    }
    
    private func didSelectContinueTextfield(_ textfield: EditText) {
        self.didSelectContinue()
    }
    
    func setAccessibilityIdentifiers() {
        self.continueButton.accessibilityIdentifier = AccessibilityBizumDonation.selectorViewBtnContinue
    }
}

extension BizumDonationNGOSelectorViewController: KeyboardManagerDelegate {
    var keyboardButton: KeyboardManager.ToolbarButton? {
        return KeyboardManager.ToolbarButton(title: localized("generic_button_continue"),
                                             accessibilityIdentifier: "",
                                             action: self.didSelectContinueTextfield,
                                             actionType: .continueAction)
    }

    var associatedView: UIView {
        return self.view
    }
}

extension BizumDonationNGOSelectorViewController: UpdatableTextFieldDelegate {
    func updatableTextFieldDidUpdate() {
        self.presenter.validatableFieldChanged()
    }
}

extension BizumDonationNGOSelectorViewController: BizumNGOSearchViewDelegate {
    func launchAllOrganizationsView() {
        self.presenter.didSelectShowAllOrganizations()
    }
}

extension BizumDonationNGOSelectorViewController: BizumSelectedNGOHeaderViewDelegate {
    func didSelectNGOViewModel(_ viewModel: BizumNGOCollectionViewCellViewModel) {
        self.presenter.didSelectNGOViewModel(viewModel)
    }
}
