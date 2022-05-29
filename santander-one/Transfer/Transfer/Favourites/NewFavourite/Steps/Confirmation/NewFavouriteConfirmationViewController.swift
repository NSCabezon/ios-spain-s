import Operative
import UI
import CoreFoundationLib

protocol NewFavouriteConfirmationViewProtocol: OperativeConfirmationViewProtocol {
    func showError(_ message: String?)
}

final class NewFavouriteConfirmationViewController: OperativeConfirmationViewController {
    let presenter: NewFavouriteConfirmationPresenterProtocol
    
    init(presenter: NewFavouriteConfirmationPresenterProtocol) {
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

private extension NewFavouriteConfirmationViewController {
    func setupNavigationBar() {
        let builder = NavigationBarBuilder(
            style: .sky,
            title: .titleWithHeader(titleKey: "genericToolbar_title_confirmation",
                                    header: .title(key: "share_title_transfers", style: .default))
        )
        builder.build(on: self, with: nil)
    }
}

extension NewFavouriteConfirmationViewController: NewFavouriteConfirmationViewProtocol {
    func showError(_ message: String?) {
        guard let message = message else { return }
        TopAlertController.setup(TopAlertView.self).showAlert(localized(message), alertType: .failure, position: .bottom)
    }
}
