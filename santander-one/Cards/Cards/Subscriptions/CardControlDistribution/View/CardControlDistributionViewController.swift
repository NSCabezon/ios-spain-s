import UI
import CoreFoundationLib
import Foundation

protocol CardControlDistributionViewProtocol: AnyObject {
    func addButtons(_ viewModel: [CardControlDistributionItemViewModel])
    func showLoadingView(_ completion: (() -> Void)?)
    func hideLoadingView()
}

final class CardControlDistributionViewController: UIViewController {
    @IBOutlet private weak var containerView: UIView!
    
    private let dependenciesResolver: DependenciesResolver
    private let presenter: CardControlDistributionPresenterProtocol
    
    private lazy var scrollableStackView: ScrollableStackView = {
        let view = ScrollableStackView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.setup(with: containerView)
        view.setScrollInsets(UIEdgeInsets(top: 0.0, left: 0.0, bottom: 8.0, right: 0.0))
        view.setSpacing(0.0)
        view.backgroundColor = .red
        return view
    }()
    
    init(dependenciesResolver: DependenciesResolver, presenter: CardControlDistributionPresenterProtocol) {
        self.dependenciesResolver = dependenciesResolver
        self.presenter = presenter
        super.init(nibName: "CardControlDistributionViewController", bundle: .module)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.presenter.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setNavigationBar()
    }
    
    func setNavigationBar() {
        NavigationBarBuilder(style: .clear(tintColor: .bostonRed), title: .title(key: "toolbar_title_m4m"))
            .setLeftAction(.back(action: #selector(didSelectDismiss)))
            .setRightActions(.menu(action: #selector(didSelectMenu)))
            .build(on: self, with: nil)
    }
}

extension CardControlDistributionViewController: CardControlDistributionViewProtocol {
    func addButtons(_ viewModel: [CardControlDistributionItemViewModel]) {
        viewModel.forEach { viewModelItem in
            let cardControlDistributionItem = CardControlDistributionItemView()
            cardControlDistributionItem.configView(viewModelItem, delegate: self)
            scrollableStackView.addArrangedSubview(cardControlDistributionItem)
        }
        scrollableStackView.stackView.spacing = 16
    }
}

extension CardControlDistributionViewController: LoadingViewPresentationCapable {
    public var associatedLoadingView: UIViewController {
        return self
    }

    func showLoadingView(_ completion: (() -> Void)?) {
        self.showLoading(completion: completion)
    }

    func hideLoadingView() {
        self.dismissLoading()
    }
}

extension CardControlDistributionViewController: CardControlDistributionItemViewDelegate {
    func cardControlDistributionItemPressed(_ itemView: CardControlDistributionItemView) {
        presenter.didSelectItem(itemView.model)
    }
}

private extension CardControlDistributionViewController {
    @objc func didSelectDismiss() {
        self.presenter.didSelectDismiss()
    }
    
    @objc func didSelectMenu() {
        self.presenter.didSelectMenu()
    }
}
