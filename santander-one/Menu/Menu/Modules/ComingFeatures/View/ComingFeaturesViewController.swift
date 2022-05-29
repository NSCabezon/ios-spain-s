import UIKit
import UI
import CoreFoundationLib
import CoreDomain

protocol ComingFeaturesViewProtocol: AnyObject, LoadingViewPresentationCapable {
    func showFeatures(from dataSource: FeatureDataSourceType, viewModel: FeaturesViewModel)
    func update(from dataSource: FeatureDataSourceType, viewModel: FeaturesViewModel)
}

final class ComingFeaturesViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var footerView: ComingFeaturesFooterView!
    let presenter: ComingFeaturesPresenterProtocol
    var strategy: FeaturesStrategyDataSource?
    var headerView: ComingFeaturesHeaderView?
    init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?,
         presenter: ComingFeaturesPresenterProtocol) {
        self.presenter = presenter
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupTableView()
        self.view.backgroundColor = .lightSky
        self.footerView.delegate = self
        presenter.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setUpNavigationBar()
    }
    
    private func setupTableView() {
        self.tableView.dataSource = self
        self.setHeaderToTableView()
        self.tableView.tableFooterView = UIView()
        self.tableView.separatorStyle = .none
        self.registerCell()
    }
    
    private func registerCell() {
        self.tableView.register(ComingFeatureTableViewCell.self, bundle: .module)
        self.tableView.register(ImplementedFeatureTableViewCell.self, bundle: .module)
    }
    
    private func setHeaderToTableView() {
        let header = ComingFeaturesHeaderView(frame: .zero)
        header.delegate = self
        self.tableView.tableHeaderView = header
        self.headerView = header
    }
    
    private func setUpNavigationBar() {
        let builder = NavigationBarBuilder(
            style: .custom(background: .color(.lightSky), tintColor: .santanderRed),
            title: .title(key: "toolbar_title_shortly")
        )
        builder.setLeftAction(.back(action: #selector(dismissViewController)))
        builder.setRightActions(.menu(action: #selector(openMenu)))
        builder.build(on: self, with: self.presenter)
    }
    
    @objc private func openMenu() {
        self.presenter.didSelectMenu()
    }
    
    @objc private func searchButtonPressed() {
        self.presenter.didSelectSearch()
    }
    
    @objc private func dismissViewController() {
        self.presenter.didSelectDismiss()
    }
}

extension ComingFeaturesViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return strategy?.tableView(tableView, numberOfRowsInSection: section) ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return strategy?.tableView(tableView, cellForRowAt: indexPath) ?? UITableViewCell()
    }
}

extension ComingFeaturesViewController: ComingFeaturesViewProtocol {
    var associatedLoadingView: UIViewController {
        return self
    }
    
    func showFeatures(from dataSource: FeatureDataSourceType, viewModel: FeaturesViewModel) {
        self.headerView?.hideEmptyView()
        switch dataSource {
        case .coming:
            if viewModel.comingFeatureViewModels.isEmpty {
                self.headerView?.setEmptyViewTitle("shortly_title_emptyIdea")
            }
            self.strategy = ComingFeaturesStrategy(items: viewModel.comingFeatureViewModels, delegate: self)
        case .implemented:
            if viewModel.implementedFeatureViewModels.isEmpty {
                self.headerView?.setEmptyViewTitle("shortly_title_emptyMadeIdea")
            }
            self.strategy = ImplementedFeaturesStrategy(items: viewModel.implementedFeatureViewModels, delegate: self)
        }
        self.tableView.reloadData()
        self.tableView.updateHeaderWithAutoLayout()
    }
    
    func update(from dataSource: FeatureDataSourceType, viewModel: FeaturesViewModel) {
        switch dataSource {
        case .coming:
            self.strategy = ComingFeaturesStrategy(items: viewModel.comingFeatureViewModels, delegate: self)
        case .implemented:
            self.strategy = ImplementedFeaturesStrategy(items: viewModel.implementedFeatureViewModels, delegate: self)
        }
        UIView.performWithoutAnimation {
            self.tableView.beginUpdates()
            self.tableView.endUpdates()
        }
    }
}

extension ComingFeaturesViewController: ComingFeaturesHeaderProtocol {
    func didSelectedIndexChanged(_ index: Int) {
        presenter.didSelectedIndexChanged(index)
    }
    
    func didSelectTryFeatures() {
        self.presenter.didSelectTryFeatures()
    }
}

extension ComingFeaturesViewController: ComingFeaturesFooterViewDelegate {
    func didSelectNewFeature() {
        self.presenter.didSelectNewFeature()
    }
}

extension ComingFeaturesViewController: ComingFeatureCellDelegate {
    func didUpdateComingFeatureOfferImageAspectRatio(_ ratio: CGFloat, for viewModel: ComingFeatureViewModel) {
        self.presenter.comingFeatureViewModelUpdated(viewModel, with: .offerLoaded(ratio: Float(ratio)))
    }
    
    func didSelectComingFeatureOffer(_ offer: OfferEntity?) {
        self.presenter.didSelectOffer(offer)
    }
    
    func didSelectComingFeatureVote(_ viewModel: ComingFeatureVoteViewModel) {
        self.presenter.didSelectVoteButton(viewModel)
    }
}

extension ComingFeaturesViewController: ImplementedFeatureCellDelegate {
    func didUpdateImplementedFeatureOfferImageAspectRatio(_ ratio: CGFloat, for viewModel: ImplementedFeatureViewModel) {
        self.presenter.implementedFeatureViewModelUpdated(viewModel, with: .offerLoaded(ratio: Float(ratio)))
    }
    
    func didSelectImplementedFeatureOffer(_ offer: OfferEntity?) {
        self.presenter.didSelectOffer(offer)
    }
}

extension ComingFeaturesViewController: RootMenuController {
    var isSideMenuAvailable: Bool {
        return true
    }
}

extension ComingFeaturesViewController: HighlightedMenuProtocol {
    func getOption() -> PrivateMenuOptions? {
        return .otherServices
    }
}
