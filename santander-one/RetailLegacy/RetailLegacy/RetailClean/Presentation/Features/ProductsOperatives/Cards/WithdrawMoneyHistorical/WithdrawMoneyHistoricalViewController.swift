import UIKit

protocol WithdrawMoneyHistoricalPresenterProtocol: Presenter {
    var listPresenter: ProductHomeTransactionsPresenter { get }
}

class WithdrawMoneyHistoricalViewController: BaseViewController<WithdrawMoneyHistoricalPresenterProtocol> {
    override class var storyboardName: String {
        return "CardsOperatives"
    }
    
    var headerViewModel: CardSearchHeaderViewModel? {
        didSet {
            if let genericView = GenericOperativeCardHeaderView.instantiateFromNib() {
                genericView.embedInto(container: headerView)
                headerViewModel?.configureView(genericView)
            }
        }
    }

    @IBOutlet private weak var headerView: UIView!
    @IBOutlet weak var dispositionsContainer: UIView!
    
    override func prepareView() {
        super.prepareView()
        view.backgroundColor = .uiBackground
        self.navigationController?.navigationBar.setNavigationBarColor(.white)
        setAccessibilityIdentifiers()
    }
    
    func installListPresenter() {
        plugIn(viewController: presenter.listPresenter.view, inContainer: dispositionsContainer)
    }
    
    private func setAccessibilityIdentifiers() {
        titleIdentifier = "withdrawHistorical_title"
    }
}

extension WithdrawMoneyHistoricalViewController: PluggerViewController {}

protocol PluggerViewController where Self: UIViewController {
    func plugIn(viewController: UIViewController, inContainer container: UIView)
}

extension PluggerViewController {
    func plugIn(viewController: UIViewController, inContainer container: UIView) {
        guard let newView = viewController.view else {
            return
        }
        addChild(viewController)
        newView.frame = container.bounds
        container.addSubview(newView)
        viewController.didMove(toParent: self)
    }
}
