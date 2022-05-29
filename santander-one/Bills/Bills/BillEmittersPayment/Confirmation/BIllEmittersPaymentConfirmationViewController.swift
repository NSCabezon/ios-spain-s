import UIKit
import Operative
import UI
import CoreFoundationLib

protocol BillEmittersPaymentConfirmationViewProtocol: OperativeConfirmationViewProtocol {
    func showFaqs(_ items: [FaqsItemViewModel])
}

class BillEmittersPaymentConfirmationViewController: OperativeConfirmationViewController {
    
    let presenter: BillEmittersPaymentConfirmationPresenterProtocol
    
    init(presenter: BillEmittersPaymentConfirmationPresenterProtocol) {
        self.presenter = presenter
        super.init(presenter: presenter)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.presenter.viewDidLoad()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        operativeViewWillDisappear()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setupNavigationBar()
    }
}

extension BillEmittersPaymentConfirmationViewController: BillEmittersPaymentConfirmationViewProtocol {
    func showFaqs(_ items: [FaqsItemViewModel]) {
        let data = FaqsViewData(items: items)
        data.show(in: self)
    }
}

extension BillEmittersPaymentConfirmationViewController: FaqsViewControllerDelegate {
    func didExpandAnswer(question: String) {
        presenter.trackFaqEvent(question, url: nil)
    }
    
    func didTapAnswerLink(question: String, url: URL) {
        presenter.trackFaqEvent(question, url: url)
    }
}

private extension BillEmittersPaymentConfirmationViewController {
    
    func setupNavigationBar() {
        let builder = NavigationBarBuilder(
            style: .sky,
            title: .titleWithHeader(titleKey: "genericToolbar_title_confirmation",
                                    header: .title(key: "toolbar_title_paymentOther", style: .default))
        )
        builder.setRightActions(
            NavigationBarBuilder.RightAction.close(action: #selector(close)),
            NavigationBarBuilder.RightAction.help(action: #selector(faqs))
        )
        builder.build(on: self, with: self.presenter)
    }
    
    @objc func faqs() {
        presenter.didTapFaqs()
    }
    
    @objc func close() {
        presenter.didTapClose()
    }
}
