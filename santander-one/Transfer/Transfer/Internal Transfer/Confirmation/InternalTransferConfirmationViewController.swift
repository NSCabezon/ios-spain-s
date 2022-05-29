import UIKit
import Operative
import CoreFoundationLib
import UI

protocol InternalTransferConfirmationViewProtocol: OperativeConfirmationViewProtocol {
    func addTotalOperationAmount(_ amount: AmountEntity)
    func showFaqs(_ items: [FaqsItemViewModel])
}

class InternalTransferConfirmationViewController: OperativeConfirmationViewController {
    
    let presenter: InternalTransferConfirmationPresenterProtocol
    
    init(presenter: InternalTransferConfirmationPresenterProtocol) {
        self.presenter = presenter
        super.init(presenter: presenter)
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupNavigationBar()
        self.presenter.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
}

extension InternalTransferConfirmationViewController: InternalTransferConfirmationViewProtocol {
    func addTotalOperationAmount(_ amount: AmountEntity) {
        let view = InternalTransferConfirmationTotalOperationItemView(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.setup(with: amount)
        self.addConfirmationItemView(view)
    }
    func showFaqs(_ items: [FaqsItemViewModel]) {
        let data = FaqsViewData(items: items)
        data.show(in: self)
    }
}

extension InternalTransferConfirmationViewController: FaqsViewControllerDelegate {
    func didExpandAnswer(question: String) {
        presenter.trackFaqEvent(question, url: nil)
    }
    
    func didTapAnswerLink(question: String, url: URL) {
        presenter.trackFaqEvent(question, url: url)
    }
}

private extension InternalTransferConfirmationViewController {
    
    func setupNavigationBar() {
        let builder = NavigationBarBuilder(
            style: .sky,
            title: .titleWithHeader(titleKey: "genericToolbar_title_confirmation",
                                    header: .title(key: "toolbar_title_transfer", style: .default))
        )
        builder.setRightActions(
            NavigationBarBuilder.RightAction.close(action: #selector(close)),
            NavigationBarBuilder.RightAction.help(action: #selector(faqs))
        )
        builder.build(on: self, with: nil)
    }
    
    @IBAction func faqs() {
        self.presenter.faqs()
    }
    
    @IBAction func close() {
        self.presenter.close()
    }
}
