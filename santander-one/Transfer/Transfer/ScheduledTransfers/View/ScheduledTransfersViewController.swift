import UIKit
import CoreFoundationLib
import UI

protocol ScheduledTransfersViewProtocol: AnyObject {
    func showEmptyResultView()
    func showScheduledTransfer(_ viewModels: [ScheduledTransferViewModelProtocol])
    func showPeriodicTransfer(_ viewModels: [PeriodicTransferViewModelProtocol])
    func showErrorDialogWithMessage(_ message: String)
    func presentLoading()
    func hideLoading(_ completion: (() -> Void)?)
    func setEmptyPeriodicViewModel(_ viewModel: ScheduledTransferEmptyViewModel)
    func setEmptyScheduledViewModel(_ viewModel: ScheduledTransferEmptyViewModel)
}

final class ScheduledTransfersViewController: UIViewController {
    
    @IBOutlet weak var segmentedControlView: SegmentedControlView!
    @IBOutlet weak var newScheduledTransferView: NewScheduledTransferButtonView!
    @IBOutlet weak var scrollContainerView: UIView!
    
    let presenter: ScheduledTransfersPresenterProtocol
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.isPagingEnabled = true
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        return scrollView
    }()
    
    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.alignment = .fill
        stackView.distribution = .fillEqually
        stackView.axis = .horizontal
        stackView.spacing = 0
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private lazy var scheduledTableView: ScheduledTransfersTableView = {
        let scheduledTableView = ScheduledTransfersTableView(frame: .zero)
        scheduledTableView.translatesAutoresizingMaskIntoConstraints = false
        scheduledTableView.delegate = self
        scheduledTableView.tableView.contentInset.bottom = 13.0
        return scheduledTableView
    }()
    
    private lazy var periodicTableView: PeriodicTransfersTableView = {
        let periodicTableView = PeriodicTransfersTableView(frame: .zero)
        periodicTableView.translatesAutoresizingMaskIntoConstraints = false
        periodicTableView.delegate = self
        periodicTableView.tableView.contentInset.bottom = 13.0
        return periodicTableView
    }()
    
    init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?,
         presenter: ScheduledTransfersPresenterProtocol) {
        self.presenter = presenter
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        self.configureView()
        self.presenter.viewDidLoad()
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.setupNavigationBar()
    }
    
    private func configureView() {
        let segmentKeys = ["transfer_tab_periodic", "transfer_tab_scheduled"]
        let segmentAccessibilityIds: [String] = [
            ScheduledTransfersListAccessibilityIdentifier.scheduledTransfersSegmentedPeriodic,
            ScheduledTransfersListAccessibilityIdentifier.scheduledTransfersSegmentedScheduled
        ]
        self.segmentedControlView.setSegmentKeys(segmentKeys, accessibilityIdentifiers: segmentAccessibilityIds)
        self.segmentedControlView.delegate = self
        self.newScheduledTransferView.delegate = self
        self.configureScrollView()
    }
    
    private func configureScrollView() {
        self.stackView.addArrangedSubview(self.periodicTableView)
        self.stackView.addArrangedSubview(self.scheduledTableView)
        
        self.scrollView.delegate = self
        self.scrollView.addSubview(self.stackView)
        self.scrollContainerView.addSubview(self.scrollView)
        
        self.scheduledTableView.widthAnchor.constraint(equalTo: self.scrollView.widthAnchor).isActive = true
        self.scheduledTableView.heightAnchor.constraint(equalTo: self.scrollView.heightAnchor).isActive = true
        self.periodicTableView.widthAnchor.constraint(equalTo: self.scrollView.widthAnchor).isActive = true
        self.periodicTableView.heightAnchor.constraint(equalTo: self.scrollView.heightAnchor).isActive = true
        
        self.scrollView.translatesAutoresizingMaskIntoConstraints = false
        self.scrollView.fullFit()
        
        self.stackView.heightAnchor.constraint(equalTo: self.scrollView.heightAnchor).isActive = true
        self.stackView.fullFit()
    }
    
    private func scrollToPage(page: Int, animated: Bool) {
        var frame: CGRect = self.scrollView.frame
        frame.origin.x = frame.size.width * CGFloat(page)
        frame.origin.y = 0
        self.scrollView.scrollRectToVisible(frame, animated: animated)
    }
    
    private func setupNavigationBar() {
        let builder = NavigationBarBuilder(
            style: .white,
            title: .title(key: "toolbar_title_periodicTransfers")
        )
        builder.setLeftAction(.back(action: #selector(dismissViewController)))
        builder.setRightActions(.menu(action: #selector(didSelectMenu)))
        builder.build(on: self, with: self.presenter)
    }
    
    public override var prefersStatusBarHidden: Bool {
        return false
    }
    
    public override var preferredStatusBarStyle: UIStatusBarStyle {
        if #available(iOS 13.0, *) {
            return .darkContent
        } else {
            return .default
        }
    }
    
    @objc private func dismissViewController() {
        self.presenter.didSelectDismiss()
    }
    
    @objc private func didSelectMenu() {
        self.presenter.didSelectMenu()
    }
}

extension ScheduledTransfersViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y > 0 || scrollView.contentOffset.y < 0 {
            scrollView.contentOffset.y = 0
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.x < self.view.frame.width {
            self.segmentedControlView.setSegmentedIndex(0)
        } else if scrollView.contentOffset.x >= self.view.frame.width {
            self.segmentedControlView.setSegmentedIndex(1)
        }
    }
}

extension ScheduledTransfersViewController: ScheduledTransfersViewProtocol {
    func setEmptyPeriodicViewModel(_ viewModel: ScheduledTransferEmptyViewModel) {
        self.periodicTableView.setEmptyViewModel(viewModel)
    }
    
    func setEmptyScheduledViewModel(_ viewModel: ScheduledTransferEmptyViewModel) {
        self.scheduledTableView.setEmptyViewModel(viewModel)
    }
    
    func showErrorDialogWithMessage(_ message: String) {
        let acceptAction = Dialog.Action(title: "generic_button_accept",
                                         style: .red,
                                         action: {})
        let messageStyleConfiguration = LocalizedStylableTextConfiguration(font: .santander(family: .micro,
                                                                                            type: .regular,
                                                                                            size: 16),
                                                                           textStyles: nil,
                                                                           alignment: .center,
                                                                           lineHeightMultiple: 0.82,
                                                                           lineBreakMode: .byWordWrapping)
        self.showDialog(title: localized("generic_title_alertError"),
                        items: [ Dialog.Item.styledConfiguredText(LocalizedStylableText(text: message,
                                                                                        styles: nil),
                                                                  configuration: messageStyleConfiguration)],
                                image: nil,
                                action: acceptAction,
                                closeButton: .none)
    }
    
    func showEmptyResultView() {
        self.periodicTableView.setEmptyResultView()
        self.scheduledTableView.setEmptyResultView()
    }
    
    func showScheduledTransfer(_ viewModels: [ScheduledTransferViewModelProtocol]) {
        self.scheduledTableView.setData(viewModels)
    }
    
    func showPeriodicTransfer(_ viewModels: [PeriodicTransferViewModelProtocol]) {
        self.periodicTableView.setData(viewModels)
    }
    
    func presentLoading() {
        self.showLoading()
    }
    
    func hideLoading(_ completion: (() -> Void)? = nil) {
        self.dismissLoading(completion: completion)
    }
}

extension ScheduledTransfersViewController: SegmentedControlViewDelegate {
    func didSelectedIndexChanged(_ index: Int) {
        presenter.didChangeType(index)
        self.scrollToPage(page: index, animated: true)
    }
}

extension ScheduledTransfersViewController: NewScheduledTransferButtonDelegate {
    func didSelectNewShipment() {
        self.presenter.didSelectNewShipment()
    }
}

extension ScheduledTransfersViewController: ScheduledTransfersTableViewDelegate {
    func didSelectScheduledTransfer(_ viewModel: ScheduledTransferViewModelProtocol) {
        self.presenter.didSelectScheduledTransfer(viewModel)
    }
}

extension ScheduledTransfersViewController: PeriodicTransfersTableViewDelegate {
    func didSelectPeriodicTransfer(_ viewModel: PeriodicTransferViewModelProtocol) {
        self.presenter.didSelectPeriodicTransfer(viewModel)
    }
}

extension ScheduledTransfersViewController: RootMenuController {
    var isSideMenuAvailable: Bool {
        return true
    }
}

extension ScheduledTransfersViewController: DialogViewPresentationCapable {
    var associatedDialogView: UIViewController {
        self
    }
}

extension ScheduledTransfersViewController: LoadingViewPresentationCapable { }
