import UI
import Operative
import CoreFoundationLib
import ESUI

protocol BizumCancelConfirmationViewProtocol: OperativeConfirmationViewProtocol {
    func add(_ items: [BizumCancelItemViewModel])
}

final class BizumCancelConfirmationViewController: OperativeConfirmationViewController {
    let presenter: BizumCancelConfirmationPresenterProtocol
    private var confirmationContainerViewModel: ConfirmationContainerViewModel?
    
    init(presenter: BizumCancelConfirmationPresenterProtocol) {
        self.presenter = presenter
        super.init(presenter: presenter)
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        self.configureView()
        self.presenter.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setupNavigationBar()
    }
}

extension BizumCancelConfirmationViewController: BizumCancelConfirmationViewProtocol {
    func add(_ items: [BizumCancelItemViewModel]) {
        for item in items {
            switch item {
            case .confirmation(let viewModel):
                self.add(viewModel)
            case .total(let viewModel):
                self.add(viewModel)
            }
        }
    }
}

private extension BizumCancelConfirmationViewController {
    func configureView() {
        self.view.backgroundColor = .skyGray
        self.view.layer.borderColor = UIColor.mediumSkyGray.cgColor
        self.view.layer.borderWidth = 1
    }
    
    func setupNavigationBar() {
        let titleImage = TitleImage(image: ESAssets.image(named: "icnBizumHeader"),
                                    topMargin: 4,
                                    width: 16,
                                    height: 16)
        let builder = NavigationBarBuilder(
            style: .sky,
            title: .titleWithHeaderAndImage(titleKey: "toolbar_title_cancelShipping",
                                            header: .title(key: "toolbar_title_bizum", style: .default),
                                            image: titleImage)
        )
        builder.setRightActions(
            NavigationBarBuilder.RightAction.close(action: #selector(close))
        )
        builder.build(on: self, with: nil)
    }
    
    // MARK: - Actions
    @objc func close() {
        self.presenter.didTapClose()
    }
}
