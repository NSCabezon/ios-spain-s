import UIKit
import CoreFoundationLib
import UI

protocol TripDetailViewProtocol: UIViewController {
    func setFaqsViewModels(_ viewModels: [TripFaqViewModel])
    func configureView(with viewModel: TripViewModel)
    func setEmbassy(_ embassy: EmbassyViewModel, reportInfo: EmergencyReportViewModel)
    func setSmartLock(countryName: String)
    func setSecurityTips(_ viewModels: [HelpCenterTipViewModel])
}

final class TripDetailViewController: UIViewController {
    
    @IBOutlet weak var headerView: TripDetailHeaderView!
    @IBOutlet weak var scrollableView: UIView!
    private let presenter: TripDetailPresenterProtocol
    private var scrollableStackView = ScrollableStackView(frame: .zero)
    private var smartLockView = SmartLockView()
    private var tripFaqsView = TripFaqsView()
    private var emergencyView = EmergencyView()
    private var tripAtmsView = TripDetailATMsView()
    private lazy var tipsView: HelpCenterTipsView = {
        let view = HelpCenterTipsView(frame: .zero)
        view.tipDelegate = self
        view.translatesAutoresizingMaskIntoConstraints = false
        view.heightAnchor.constraint(equalToConstant: 320).isActive = true
        let style = HelpCenterTipsViewStyle()
        style.numberOfSections = 1
        style.seeAllTipsColor = .clear
        view.setStyle(style)
        view.setTitle(localized("security_title_securityTips"))
        return view
    }()
    
    public override var prefersStatusBarHidden: Bool { false }
    
    public override var preferredStatusBarStyle: UIStatusBarStyle {
        if #available(iOS 13.0, *) {
            return .darkContent
        } else {
            return .default
        }
    }
    
    init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?,
         presenter: TripDetailPresenterProtocol) {
        self.presenter = presenter
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        self.setupViews()
        self.presenter.viewDidLoad()
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.setupNavigationBar()
    }
    
    // MARK: - privateMethods
    
    private func setupViews() {
        self.view.backgroundColor = UIColor.skyGray
        self.scrollableView.backgroundColor = .white
        self.scrollableStackView.setup(with: self.scrollableView)
        self.scrollableStackView.setBounce(enabled: false)
        self.scrollableStackView.addArrangedSubview(self.smartLockView)
        self.scrollableStackView.addArrangedSubview(self.tripFaqsView)
        self.scrollableStackView.addArrangedSubview(self.emergencyView)
        self.scrollableStackView.addArrangedSubview(self.tripAtmsView)
        self.tripAtmsView.delegate = self
        self.tripAtmsView.setNeedsLayout()
        self.tripAtmsView.layoutIfNeeded()
        self.tripAtmsView.layoutSubviews()
    }
    
    private func setupNavigationBar() {
        let builder = NavigationBarBuilder(
            style: .sky,
            title: .tooltip(
                titleKey: "toolbar_title_yourTrips",
                type: .red,
                action: { [weak self] sender in
                    self?.showGeneralTooltip(sender)
                }
            )
        )
        builder.setLeftAction(.back(action: #selector(dismissViewController)))
        builder.setRightActions(.close(action: #selector(dismissViewController)))
        builder.build(on: self, with: nil)
    }
    
    @objc private func dismissViewController() {
        self.presenter.didSelectDismiss()
    }
    
    private func showGeneralTooltip(_ sender: UIView) {
        TripModeInfoTooltip().showTooltip(in: self, from: sender)
    }
}

extension TripDetailViewController: TripDetailViewProtocol {
    func configureView(with viewModel: TripViewModel) {
        self.headerView.setViewInfo(with: viewModel)
        self.headerView.setNeedsLayout()
    }
    
    func setFaqsViewModels(_ viewModels: [TripFaqViewModel]) {
        self.tripFaqsView.setupVieModels(viewModels)
    }
    
    func setSmartLock(countryName: String) {
        self.smartLockView.countryName = countryName
        self.smartLockView.delegate = self
    }
    
    func setEmbassy(_ embassy: EmbassyViewModel, reportInfo: EmergencyReportViewModel) {
        emergencyView.setEmbassyInfo(embassy)
        emergencyView.setReportInfo(reportInfo)
        emergencyView.setDelegate(self)
        emergencyView.widthAnchor.constraint(equalTo: self.scrollableView.widthAnchor).isActive = true
    }
    
    func setSecurityTips(_ viewModels: [HelpCenterTipViewModel]) {
        defer {
            self.scrollableStackView.updateScrollBackground()
        }
        guard !viewModels.isEmpty else { return }
        self.scrollableView.backgroundColor = .blueAnthracita
        self.tipsView.setViewModels(viewModels)
        self.scrollableStackView.addArrangedSubview(self.tipsView)
    }
}

extension TripDetailViewController: EmergencyViewDelegate {
    func didSelectCardReportCall(_ phoneNumber: String) {
        presenter.didSelectCardReportCall(phoneNumber)
    }
    
    func didSelectFraudReportCall(_ phoneNumber: String) {
        presenter.didSelectFraudReportCall(phoneNumber)
    }
    
    func unlockSignatureKeyDidPress() {
        presenter.didPressUnlockSignature()
    }
    
    func embassyHeightDidChange() {
        self.view.layoutIfNeeded()
        scrollableStackView.layoutIfNeeded()
    }
}

extension TripDetailViewController: SmartLockViewDelegate {
    func didPressSmartLockButton() {
        self.presenter.didSelectSmartLock()
    }
}

extension TripDetailViewController: TripDetailATMsViewProtocol {
    func didTapImage() {
        self.presenter.didSelectAtmsMap()
    }
}

extension TripDetailViewController: HelpCenterTipsViewDelegate {
    func didSelectTip(_ viewModel: Any) {
        guard let viewModel = viewModel as? HelpCenterTipViewModel else { return }
        self.presenter.didSelectTip(viewModel.entity.offer)
    }
    func scrollViewDidEndDecelerating() {
        self.presenter.didSwipeTips()
    }
    
    func didSelectSeeAllTips() {}
}
