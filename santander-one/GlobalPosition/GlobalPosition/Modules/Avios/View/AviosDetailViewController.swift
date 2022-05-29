import CoreFoundationLib
import UIKit
import UI

protocol AviosDetailViewProtocol: AnyObject {
    func setAviosDetail(model: AviosDetailComponentViewModel)
    func setUnavailableData()
    func startLoading(completion: @escaping (() -> Void))
    func stopLoading(completion: @escaping (() -> Void))
}

final class AviosDetailViewController: UIViewController {
    @IBOutlet private weak var scrollView: UIScrollView!
    @IBOutlet private weak var stackView: UIStackView!
    
    private let presenter: AviosDetailPresenterProtocol
    
    init(presenter: AviosDetailPresenterProtocol) {
        self.presenter = presenter
        super.init(nibName: "AviosDetailView", bundle: Bundle(for: AviosDetailViewController.self))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        scrollView.backgroundColor = .clear
        view.backgroundColor = .skyGray
        presenter.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureNavigationBar()
    }
}

extension AviosDetailViewController: AviosDetailViewProtocol {
    func startLoading(completion: @escaping (() -> Void)) {
        showLoading(completion: completion)
    }
    
    func stopLoading(completion: @escaping (() -> Void)) {
        dismissLoading(completion: completion)
    }
    
    func setAviosDetail(model: AviosDetailComponentViewModel) {
        stackView.addArrangedSubview(AviosDetailComponentView(viewModel: model))
    }
    
    func setUnavailableData() {
        stackView.addArrangedSubview(AviosUnavailableDataLabelView(frame: .zero))
    }
}

extension AviosDetailViewController: LoadingViewPresentationCapable {}

private extension AviosDetailViewController {
    @objc func close() {
        presenter.didTapClose()
    }
    
    private func configureNavigationBar() {
        NavigationBarBuilder(style: .sky, title: .title(key: "toolbar_title_aviosConsultation"))
            .setLeftAction(NavigationBarBuilder.LeftAction.none)
            .setRightActions(.close(action: #selector(close)))
            .build(on: self, with: presenter)
    }
}
