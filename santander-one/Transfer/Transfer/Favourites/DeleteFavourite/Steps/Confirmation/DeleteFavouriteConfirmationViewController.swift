import Operative
import UI
import CoreFoundationLib

protocol DeleteFavouriteConfirmationViewProtocol: OperativeConfirmationViewProtocol {
    func showError(_ message: String?)
}

final class DeleteFavouriteConfirmationViewController: OperativeConfirmationViewController {
    let presenter: DeleteFavouriteConfirmationPresenterProtocol
    
    init(presenter: DeleteFavouriteConfirmationPresenterProtocol) {
        self.presenter = presenter
        super.init(presenter: presenter)
    }
    
    @available(*, unavailable)
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

private extension DeleteFavouriteConfirmationViewController {
    func setupNavigationBar() {
        let builder = NavigationBarBuilder(
            style: .sky,
            title: .titleWithHeader(titleKey: "toolbar_title_deleteContact",
                                    header: .title(key: "share_title_transfers", style: .default))
        )
        builder.build(on: self, with: nil)
    }
}

extension DeleteFavouriteConfirmationViewController: DeleteFavouriteConfirmationViewProtocol {
    func showError(_ message: String?) {
        guard let message = message else { return }
        TopAlertController.setup(TopAlertView.self).showAlert(localized(message), alertType: .failure, position: .bottom)
    }
}
