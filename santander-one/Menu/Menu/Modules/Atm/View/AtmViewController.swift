//
//  AtmViewController.swift
//  Menu
//
//  Created by Cristobal Ramos Laina on 31/08/2020.
//

import UIKit
import UI
import CoreFoundationLib

protocol AtmViewProtocol: AnyObject, LoadingViewPresentationCapable {
    func setOfferBannerForLocation(_ location: AtmLocations, viewModel: OfferEntityViewModel)
    func showTips(_ atmTips: [AtmTipViewModel]?)
    func showGetMoneyWithCodeView()
    func showCardLimitManagemetView()
    func showLastWithdrawal(_ lastWithdrawal: [(Date, [AtmMovementViewModel])]?)
    func showAtmCashierView(_ viewModel: NearAtmViewModel)
    func showSearchAtmView()
    func setOfferBannerLocation(_ offerViewModel: OfferBannerViewModel?)
}

class AtmViewController: UIViewController {
    @IBOutlet private weak var containerView: UIView!
    private let presenter: AtmPresenterProtocol
    private let withdrawMoneyAtmView = WithdrawMoneyAtmView()
    private let atmCustomizationOfferView =  OfferBannerView()
    private let cardLimitManagementAtmView = CardLimitManagementAtmView()
    private let reportView = ReportAtmBugView()
    private let searchAtmView = SearchAtmView()
    private let lastAtmMovementsView = LastAtmMovementsView()
    private let sheetView = SheetView()
    private let atmMachinesView = NearAtmView()
    private let officeAppointmentView = OfficeAppointmentView()
    public var isSearchEnabled: Bool = true {
            didSet { self.setupNavigationBar() }
    }
    
    private lazy var atmTipsView: AtmTipsView = {
        let view = AtmTipsView(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.heightAnchor.constraint(equalToConstant: 320).isActive = true
        return view
    }()
    
    private lazy var scrollableStackView: ScrollableStackView = {
        let view = ScrollableStackView()
        view.setup(with: self.containerView)
        view.setSpacing(16)
        return view
    }()

    init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?,
         presenter: AtmPresenterProtocol) {
        self.presenter = presenter
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.presenter.viewDidLoad()
        self.setDelegates()
        self.addAccessibilityIdentifiers()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setupNavigationBar()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.sheetView.closeWithoutAnimation()
        self.sheetView.removeFromSuperview()
    }
    
    private func setupNavigationBar() {
        let builder = NavigationBarBuilder(
            style: .white,
            title: .title(key: "toolbar_title_atmAndOffice")
        )
        builder.setLeftAction(.back(action: #selector(dismissViewController)))
        builder.setRightActions(.menu(action: #selector(openMenu)))
        builder.build(on: self, with: self.presenter as? MenuTextGetProtocol)
    }
    
    func addAtmTipsView(atmTips: [AtmTipViewModel]?) {
        guard let atmTips = atmTips, !atmTips.isEmpty else { return }
        atmTipsView.setViewModels(atmTips)
        self.scrollableStackView.addArrangedSubview(self.atmTipsView)
    }
    
    private func doSearch() {
        self.presenter.didSelectSearch()
    }
    
    @objc private func openMenu() {
        self.presenter.didSelectMenu()
    }

    @objc private func dismissViewController() {
        self.presenter.didSelectDismiss()
    }
}

private extension AtmViewController {
    func setDelegates() {
        self.withdrawMoneyAtmView.delegate = self
        self.cardLimitManagementAtmView.delegate = self
        self.reportView.delegate = self
        self.searchAtmView.delegate = self
        self.atmTipsView.tipDelegate = self
        self.lastAtmMovementsView.delegate = self
        self.atmMachinesView.delegate = self
        self.officeAppointmentView.delegate = self
    }
    
    func didSelectAtm(viewModel: AtmViewModel) {
        self.sheetView.removeContent()
        let builder = AtmSheetContentBuilder(viewModel: viewModel)
        builder.addDelegate(self)
        self.sheetView.addScrollableContent(builder.build())
        self.sheetView.showDragIdicator()
        self.sheetView.show()
    }
    
    func addAccessibilityIdentifiers() {
        self.sheetView.accessibilityIdentifier = AccessibilityAtm.AtmDetail.viewDetail
    }
}

extension AtmViewController: CardLimitManagementViewDelegate {
    func didSelectedCardLimitManagement() {
        self.presenter.didSelectedCardLimitManagement()
    }
}

extension AtmViewController: WithdrawMoneyAtmViewDelegate {
    func didSelectedGetMoneyWithCode() {
        self.presenter.didSelectedGetMoneyWithCode()
    }
}

extension AtmViewController: ReportAtmBugViewDelegate {
    func didSelectedReportAtmBug(_ viewModel: OfferEntityViewModel?) {
        self.presenter.didSelectedReportAtmBug(viewModel)
    }
}

extension AtmViewController: NearAtmViewDelegate {
    func didTapOnAtm(_ viewModel: AtmViewModel) {
        self.didSelectAtm(viewModel: viewModel)
    }
}

extension AtmViewController: SearchAtmViewDelegate {
    func didSelectedSearchAtm() {
        self.presenter.didSelectSearchAtm()
    }
}

extension AtmViewController: LastAtmMovementsViewDelegate {
    func formatDate(_ date: Date) -> LocalizedStylableText {
        return self.presenter.formatDate(date)
    }
}

extension AtmViewController: AtmTipsViewDelegate {
    func didSelectTip(_ viewModel: AtmTipViewModel) {
        self.presenter.didSelectTip(viewModel)
    }
}

extension AtmViewController: RootMenuController {
    var isSideMenuAvailable: Bool {
        return true
    }
}

extension AtmViewController: AtmViewProtocol {
    
    func showAtmCashierView(_ viewModel: NearAtmViewModel) {
        self.scrollableStackView.addArrangedSubview(self.atmMachinesView)
        self.atmMachinesView.setViewModel(viewModel)
    }
    
    func showCardLimitManagemetView() {
        self.scrollableStackView.addArrangedSubview(self.cardLimitManagementAtmView)
    }
    
    func showGetMoneyWithCodeView() {
        self.scrollableStackView.addArrangedSubview(self.withdrawMoneyAtmView)
    }

    func setOfferBannerForLocation(_ location: AtmLocations, viewModel: OfferEntityViewModel) {
        switch location {
        case .report:
            self.reportView.setImageWithUrl(viewModel.url)
            self.reportView.viewModel = viewModel
            self.scrollableStackView.addArrangedSubview(self.reportView)
        case .officeAppointment:
            self.officeAppointmentView.viewModel = viewModel
            self.scrollableStackView.addArrangedSubview(self.officeAppointmentView)
        }
    }
    
    func showTips(_ atmTips: [AtmTipViewModel]?) {
        self.addAtmTipsView(atmTips: atmTips)
    }
    
    func showLastWithdrawal(_ lastWithdrawal: [(Date, [AtmMovementViewModel])]?) {
        guard let lastWithdrawal = lastWithdrawal else { return }
        self.lastAtmMovementsView.setViewModels(lastWithdrawal)
        self.scrollableStackView.addArrangedSubview(self.lastAtmMovementsView)
    }
    
    func showSearchAtmView() {
        self.scrollableStackView.addArrangedSubview(self.searchAtmView)
    }
    
    func setOfferBannerLocation(_ offerViewModel: OfferBannerViewModel?) {
        guard let offerViewModelUnwraped = offerViewModel else { return }
        let heightConstraint = NSLayoutConstraint(item: self.atmCustomizationOfferView,
                                                  attribute: NSLayoutConstraint.Attribute.height,
                                                  relatedBy: NSLayoutConstraint.Relation.equal,
                                                  toItem: nil,
                                                  attribute: NSLayoutConstraint.Attribute.notAnAttribute,
                                                  multiplier: 1,
                                                  constant: 0)
        self.atmCustomizationOfferView.addConstraint(heightConstraint)
        self.atmCustomizationOfferView.setOfferBannerForLocation(
            viewModel: offerViewModelUnwraped,
            updateConstraint: heightConstraint
        )
        self.atmCustomizationOfferView.delegate = self
        self.scrollableStackView.addArrangedSubview(self.atmCustomizationOfferView)
    }
    
}

extension AtmViewController: NavigationBarWithSearchProtocol {
    public var searchButtonPosition: Int {
        1
    }
    
    public func searchButtonPressed() {
        doSearch()
    }
    
    func setIsSearchEnabled(_ enabled: Bool) {
        isSearchEnabled = enabled
    }
}

extension AtmViewController: AtmMachineViewDelegate {
    func didSelectAtmMachineAddress(_ viewModel: AtmViewModel) {
        self.presenter.didSelectAtmMachineAddress(viewModel)
    }
}

extension AtmViewController: OfficeAppointmentViewDelegate {
    func didSelectedOfficeAppointment(_ viewModel: OfferEntityViewModel?) {
        self.presenter.didSelectedOfficeAppointment(viewModel)
    }
}

extension AtmViewController: OfferBannerViewProtocol {
    func didSelectBanner(_ viewModel: OfferBannerViewModel?) {
        self.presenter.didSelectedBanner(viewModel)
    }
}
