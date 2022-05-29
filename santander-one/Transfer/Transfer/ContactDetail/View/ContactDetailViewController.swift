import UIKit
import UI

protocol ContactDetailViewProtocol: AnyObject {
    func setContactDetailViewModel(_ viewModel: ContactDetailViewModel)
}

public class ContactDetailViewController: UIViewController {
    @IBOutlet private weak var detailFooterView: ContactDetailFooterView!
    @IBOutlet private weak var detailsView: ContactDetailView!
    private let presenter: ContactDetailPresenterProtocol
    
    init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?,
         presenter: ContactDetailPresenterProtocol) {
        self.presenter = presenter
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    public override func viewDidLoad() {
        self.setupView()
        self.presenter.viewDidLoad()
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setupNavigationBar()
    }
    
    public override var prefersStatusBarHidden: Bool {
        return false
    }
    
    public override var preferredStatusBarStyle: UIStatusBarStyle {
        guard #available(iOS 13.0, *) else { return .default }
        return .darkContent
    }
}

private extension ContactDetailViewController {
    func setupView() {
        self.detailsView.delegate = self
        self.detailFooterView.delegate = self
        self.detailFooterView.addShadow(location: .bottom, color: .clear, opacity: 0.7, height: 0.5)
        self.view.backgroundColor = .skyGray
    }
    
    func setupNavigationBar() {
        let builder = NavigationBarBuilder(
            style: .sky,
            title: .title(key: "toolbar_title_favoriteRecipients")
        )
        builder.setLeftAction(.back(action: #selector(dismissViewController)))
        builder.setRightActions(.close(action: #selector(dismissViewController)))
        builder.build(on: self, with: nil)
    }
    
    @objc func dismissViewController() {
        self.presenter.didSelectDismiss()
    }
}

extension ContactDetailViewController: ContactDetailViewProtocol {
    func setContactDetailViewModel(_ viewModel: ContactDetailViewModel) {
        self.detailsView.setViewModel(viewModel)
    }
}

extension ContactDetailViewController: ContactDetailViewDelegate {
    func didSelectShareAccount(_ viewModel: ContactDetailItemViewModel) {
        self.presenter.didSelectShareAccount(viewModel)
    }
    
    func didSelectNewTransfer() {
        self.presenter.didSelectNewTransfer()
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.detailFooterView.layer.shadowColor =
            scrollView.contentOffset.y > 0.0 ? UIColor.black.withAlphaComponent(0.7).cgColor : UIColor.clear.cgColor
    }
}

extension ContactDetailViewController: ContactDetailFooterDelegate {
    func didSelectEditContact() {
        self.presenter.didSelectEditContact()
    }
    
    func didSelectDeleteContact() {
        self.presenter.didSelectDeleteContact()
    }
}
