import UIKit
import OpenCombine
import UI
import CoreFoundationLib

final class PublicMenuViewController: UIViewController {
    @IBOutlet private weak var containerView: UIView!
    private let viewModel: PublicMenuViewModel
    private let dependencies: PublicMenuDependenciesResolver
    private var publicMenuViewContainer: PublicMenuViewContainer
    private var anySubscriptions: Set<AnyCancellable> = []

    init(dependencies: PublicMenuDependenciesResolver) {
        self.dependencies = dependencies
        self.viewModel = dependencies.resolve()
        self.publicMenuViewContainer = PublicMenuViewContainer(dependencies: dependencies)
        super.init(nibName: "PublicMenuViewController", bundle: .module)
        bind()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .skyGray
        navigationController?.isNavigationBarHidden = true
        viewModel.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureNavigationBar()
    }
}

private extension PublicMenuViewController {
    
    func configureNavigationBar() {
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    func bind() {
        bindOptions()
        bindComponentEvents()
    }
    
    func bindOptions() {
        viewModel
            .state
            .case(PublicMenuState.optionsLoaded)
            .sink { [unowned self] items in
                self.composeView(data: items)
            }.store(in: &anySubscriptions)
    }
    
    func bindComponentEvents() {
        self.publicMenuViewContainer
            .onDidSelectActionSubject
            .sink { [unowned self] action in
                self.viewModel.didSelectAction(action)
            }.store(in: &anySubscriptions)
        self.publicMenuViewContainer
            .onDidSelectOfferSubject
            .sink { [unowned self] offer in
                self.viewModel.didSelectOffer(offer: offer)
            }.store(in: &anySubscriptions)
        self.publicMenuViewContainer
            .trackEventSubject
            .sink { event in
                self.viewModel.trackEvent(event)
            }.store(in: &anySubscriptions)
    }

    func composeView(data: [[PublicMenuElementRepresentable]]) {
        let view = self.publicMenuViewContainer.composeView(data: data)
        self.setContainer(view: view)
    }
    
    func setContainer(view: UIView) {
        self.containerView.subviews.forEach { $0.removeFromSuperview() }
        self.containerView.addSubview(view)
        view.leadingAnchor.constraint(equalTo: self.containerView.leadingAnchor, constant: 16.0).isActive = true
        view.trailingAnchor.constraint(equalTo: self.containerView.trailingAnchor, constant: -16.0).isActive = true
        view.topAnchor.constraint(equalTo: self.containerView.topAnchor, constant: 17.0).isActive = true
        view.bottomAnchor.constraint(equalTo: self.containerView.bottomAnchor, constant: -17.0).isActive = true
    }
}
