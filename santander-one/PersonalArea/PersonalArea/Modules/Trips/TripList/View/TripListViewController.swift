import UIKit
import UI
import CoreFoundationLib

protocol TripListViewProtocol: UIViewController, NavigationBarWithSearchProtocol {
    func setViewModels(_ viewModels: [TripViewModel])
    func setForeignCurrencyVieModel(_ viewModel: ForeignCurrencyVieModel)
    func showAddNewTrip()
    func showLoadingView(_ completion: (() -> Void)?)
    func hideLoadingView(_ completion: (() -> Void)?)
}

final class TripListViewController: UIViewController {
    private let presenter: TripListPresenterProtocol
    @IBOutlet weak var addNewTripView: UIView!
    @IBOutlet weak var addNewTripButton: RedLisboaButton!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var contentViewBottomConstraint: NSLayoutConstraint!
    private let scrollableStackView = ScrollableStackView()
    public var isSearchEnabled: Bool = false {
        didSet { self.configureNavigationBar() }
    }
    
    init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?,
         presenter: TripListPresenterProtocol) {
        self.presenter = presenter
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.skyGray
        self.contentView.backgroundColor = UIColor.skyGray
        self.scrollableStackView.setSpacing(15)
        self.scrollableStackView.setup(with: self.contentView)
        self.addNewTripButton.setTitle(localized("yourTrips_button_addNewTrip"), for: .normal)
        self.addNewTripButton.addSelectorAction(target: self, #selector(didSelectAddNewTrip))
        self.presenter.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.configureNavigationBar()
        self.presenter.viewWillAppear()
    }
    
    private func configureNavigationBar() {
        let builder = NavigationBarBuilder(
            style: .sky,
            title: .tooltip(
                titleKey: "toolbar_title_yourTrips",
                type: .red,
                action: { [weak self] sender in
                    self?.didSelectToollTip(sender)
                }
            )
        )
        builder.setLeftAction(.back(action: #selector(dismissViewController)))
        builder.setRightActions(.menu(action: #selector(openMenu)))
        builder.build(on: self, with: self.presenter)
    }
    
    @objc private func dismissViewController() {
        self.presenter.didSelectGoBack()
    }
    
    @objc func searchButtonPressed() {
        self.presenter.doSearch()
    }
    
    @objc private func openMenu() {
        self.presenter.openMenu()
    }
    
    @objc private func didSelectToollTip(_ sender: UIView) {
        TripModeInfoTooltip().showTooltip(in: self, from: sender)
    }
    
    @objc func didSelectAddNewTrip(_ sender: Any) {
        self.presenter.didSelectAddNewTrip()
    }
}

extension TripListViewController: TripListViewProtocol {
    func setViewModels(_ viewModels: [TripViewModel]) {
        self.removeTripViews()
        self.addSpace()
        viewModels.forEach { viewModel in
            self.addTripViewForViewModel(viewModel)
        }
    }
    
    private func addSpace() {
        self.scrollableStackView.addArrangedSubview(UIView(frame: CGRect.zero))
    }
    
    private func removeTripViews() {
        self.scrollableStackView.getArrangedSubviews().forEach {
            $0.removeFromSuperview()
        }
    }
    
    private func addTripViewForViewModel(_ viewModel: TripViewModel) {
        let tripView = TripView()
        tripView.setViewModel(viewModel)
        tripView.setDelegate(self)
        self.scrollableStackView.addArrangedSubview(tripView)
    }
    
    func setForeignCurrencyVieModel(_ viewModel: ForeignCurrencyVieModel) {
        let foreignCurrency = ForeignCurrency()
        foreignCurrency.setViewModel(viewModel)
        foreignCurrency.setDelegate(self)
        self.scrollableStackView.addArrangedSubview(foreignCurrency)
    }
    
    func showAddNewTrip() {
        self.addNewTripView.isHidden = false
        self.contentViewBottomConstraint.constant = 62
    }
    
    public var searchButtonPosition: Int {
        return 1
    }
    
    public func isSearchEnabled(_ enabled: Bool) {
        self.isSearchEnabled = enabled
    }
}

extension TripListViewController: TripViewDelegate {
    func didSelectTrip(_ viewModel: TripViewModel) {
        self.presenter.didSelectTrip(viewModel)
    }
}

extension TripListViewController: ForeignCurrencyDelegate {
    func didSelectScheduleDate(_ viewModel: ForeignCurrencyVieModel) {
        self.presenter.didSelectScheduleDate(viewModel)
    }
    
    func didSelectRemoveTrip(_ viewModel: TripViewModel) {
        self.presenter.didSelectRemoveTrip(viewModel)
    }
}

extension TripListViewController: LoadingViewPresentationCapable {
    var associatedLoadingView: UIViewController {
        return self
    }
    
    func showLoadingView(_ completion: (() -> Void)?) {
        self.showLoading(completion: completion)
    }
    
    func hideLoadingView(_ completion: (() -> Void)?) {
        self.dismissLoading(completion: completion)
    }
}

extension TripListViewController: RootMenuController {
    var isSideMenuAvailable: Bool {
        return true
    }
}
