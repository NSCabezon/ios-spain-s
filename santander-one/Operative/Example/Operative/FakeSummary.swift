import Operative
import CoreFoundationLib
import UIKit
import UI

public final class FakeSummaryStepViewController: UIViewController, OperativeView {
    public var operativePresenter: OperativeStepPresenterProtocol
    private weak var summaryViewController: SummaryStepViewController?
    
    public init(presenter: OperativeStepPresenterProtocol) {
        self.operativePresenter = presenter
        super.init(nibName: "FakeSummaryStepViewController", bundle: .main)
        self.title = localized("genericToolbar_title_summary")
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        let summaryViewController: SummaryStepViewController = SummaryStepViewController()
        self.view.addSubview(summaryViewController.view)
        summaryViewController.view.translatesAutoresizingMaskIntoConstraints = false
        summaryViewController.view.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        summaryViewController.view.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
        summaryViewController.view.leftAnchor.constraint(equalTo: self.view.leftAnchor).isActive = true
        summaryViewController.view.rightAnchor.constraint(equalTo: self.view.rightAnchor).isActive = true
        self.addChild(summaryViewController)
        summaryViewController.didMove(toParent: self)
        self.summaryViewController = summaryViewController
    }
    
    override public func viewDidLoad() {
        setupViews()
        super.viewDidLoad()
    }
    
    override public func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        setPopGestureEnabled(true)
    }
    
    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setPopGestureEnabled(false)
        self.configureView(title: localized("summary_title_deviceRightRegister"),
                           header: [
                            HeaderInfoSummaryModel(title: "Terminal", info: "iPhone X"),
                            HeaderInfoSummaryModel(title: "Alias", info: "Móvil empresa María"),
                            HeaderInfoSummaryModel(title: "Fecha de registro", info: "13 jun 2019")
            ],
                           footer: [
                            FooterInfoSummaryModel(title: "Ir a la posición global", image: "icnCancelReceipt", action: nil),
                            FooterInfoSummaryModel(title: "Emitir una opinión", image: "icnCancelReceipt", action: nil)
        ])
    }
    
    func configureView(title: String, header: [HeaderInfoSummaryModel], footer: [FooterInfoSummaryModel]) {
        summaryViewController?.configureView(title: title, header: header, footer: footer)
    }
}

public struct SummaryStep: OperativeStep {
 
    private let dependencies: DependenciesDefault
    public weak var view: OperativeView? {
        self.dependencies.resolve(for: FakeSummaryStepViewController.self)
    }
    public var presentationType: OperativeStepPresentationType {
        .inNavigation(showsBack: false, showsCancel: true)
    }
    
    public init(dependenciesResolver: DependenciesResolver) {
        self.dependencies = DependenciesDefault(father: dependenciesResolver)
        self.setupDependencies()
    }
    
    func setupDependencies() {
        self.dependencies.register(for: FakeSummaryPresenter.self) { _ in
            let presenter = FakeSummaryPresenter()
            return presenter
        }
        self.dependencies.register(for: FakeSummaryStepViewController.self) { resolver in
            let presenter = resolver.resolve(for: FakeSummaryPresenter.self)
            let viewController = FakeSummaryStepViewController(presenter: presenter)
            return viewController
        }
    }
}

public class FakeSummaryPresenter: OperativeStepPresenterProtocol {
    public var number: Int = 0
    public var isBackButtonEnabled: Bool = false
    public var isCancelButtonEnabled: Bool = true
    public var container: OperativeContainerProtocol?
    public init() {}
}
