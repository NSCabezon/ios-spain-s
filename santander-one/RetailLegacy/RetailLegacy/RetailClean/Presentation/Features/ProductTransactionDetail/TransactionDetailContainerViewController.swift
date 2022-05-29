import UIKit
import UI
import CoreFoundationLib

protocol TransactionDetailContainerPresenterProtocol: Presenter {
    func toggleSideMenu()
    var isSideMenuAvailable: Bool { get }
}

class TransactionDetailContainerViewController: BaseViewController<TransactionDetailContainerPresenterProtocol> {
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var previousButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    
    override class var storyboardName: String {
        return "TransactionDetail"
    }
    
    lazy var transactionDetailPageViewController: TransactionDetailPageViewController = {
        return TransactionDetailPageViewController.create()
    }()
    
    var pages: [TransactionDetailViewController]!
    
    func addPages(pages: [TransactionDetailViewController], selectedPosition: Int) {
        setViewController(transactionDetailPageViewController)
        transactionDetailPageViewController.pages = pages
        transactionDetailPageViewController.selectedViewController(pages[selectedPosition])
    }
    
    override func prepareView() {
        super.prepareView()
        view.backgroundColor = .uiBackground
        if presenter.isSideMenuAvailable == true {
            self.show(barButton: .menu)
        }
        nextButton.isExclusiveTouch = true
        nextButton.setImage(
            Assets.image(named: "icnArrowRightMadridHomeCarousel"),
            for: .normal
        )
        previousButton.isExclusiveTouch = true
        previousButton.setImage(
            Assets.image(named: "icnArrowLeft"),
            for: .normal
        )
    }
        
    func setTitle(title: String) {
        self.title = title
    }
    
    private func setViewController(_ viewController: UIViewController) {
        guard let newView = viewController.view else {
                return
        }
        addChild(viewController)
        newView.frame = containerView.bounds
        containerView.addSubview(newView)
        viewController.didMove(toParent: self)
    }
    
    @objc override func showMenu() {
        presenter.toggleSideMenu()
    }
    
    @IBAction func nextButtonPressed(_ sender: UIButton) {
        transactionDetailPageViewController.goToNextPage()
    }
    
    @IBAction func previousButtonPressed(_ sender: UIButton) {
        transactionDetailPageViewController.goToPreviousPage()
    }
  
}

// MARK: - RootMenuController
extension TransactionDetailContainerViewController: RootMenuController {
    
    var isSideMenuAvailable: Bool {
        return true
    }
    
}

extension TransactionDetailContainerViewController {
    
    func showInsuranceBillEmitterDialog(onAction: @escaping (() -> Void), cancelAction: @escaping (() -> Void)) {
        let allowAction = LisboaDialogAction(title: localized(key: "generic_link_yes"), type: .white, margins: (left: 16.0, right: 8.0)) {
            onAction()
        }
        let refuseAction = LisboaDialogAction(title: localized(key: "generic_link_no"), type: .red, margins: (left: 16.0, right: 8.0)) {
            cancelAction()
        }
        let items = [.margin(20),
                     self.returnReceiptTitle,
                     .margin(16),
                     self.subtitle,
                     .margin(14),
                     .horizontalActions(HorizontalLisboaDialogActions(left: allowAction, right: refuseAction))]
        LisboaDialog(items: items, closeButtonAvailable: false).showIn(self)
    }

    private var returnReceiptTitle: LisboaDialogItem {
        return .styledText(.init(text: localized(key: "receiptsAndTaxes_alert_title_cancelInsurance"),
                                 font: .santander(family: .headline, type: .regular, size: 28),
                                 color: .black,
                                 alignament: .center, margins: (30,30),
                                 accesibilityIdentifier: "receiptsAndTaxes_alert_title_cancelInsurance")
        )
    }

    private var subtitle: LisboaDialogItem {
        return .styledText(.init(text: localized(key: "receiptsAndTaxes_alert_text_cancelInsurance"),
                                 font: .santander(family: .micro, type: .regular, size: 16),
                                 color: .lisboaGrayNew,
                                 alignament: .center,
                                 margins: (24,24),
                                 accesibilityIdentifier: "receiptsAndTaxes_alert_text_cancelInsurance")
        )
    }
}
