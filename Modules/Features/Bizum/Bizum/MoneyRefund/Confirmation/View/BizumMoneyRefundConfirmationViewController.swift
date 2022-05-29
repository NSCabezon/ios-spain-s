import UIKit
import Foundation
import UI
import Operative
import CoreFoundationLib
import ESUI

protocol BizumRefundMoneyConfirmationViewProtocol: OperativeConfirmationViewProtocol {
    func add(_ items: [BizumConfirmationViewModel])
    func setContact(_ viewModels: ConfirmationContactDetailViewModel)
}

class BizumRefundMoneyConfirmationViewController: BizumConfirmationWithCommentViewController {
    
    let presenter: BizumRefundMoneyConfirmationPresenterProtocol
    private var confirmationContainerViewModel: ConfirmationContainerViewModel?

    init(presenter: BizumRefundMoneyConfirmationPresenterProtocol) {
        self.presenter = presenter
        super.init(presenter: presenter)
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureView()
        self.presenter.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setupNavigationBar()
    }
}

extension BizumRefundMoneyConfirmationViewController: BizumRefundMoneyConfirmationViewProtocol {
    
    func add(_ items: [BizumConfirmationViewModel]) {
        for item in items {
            switch item {
            case .confirmation(let viewModel):
                self.add(viewModel)
            case .date(let viewModel):
                self.add(viewModel)
            case .contacts(let viewModel):
                self.confirmationContainerViewModel = viewModel
                self.presenter.getContact()
            case .total(let viewModel):
                self.add(viewModel)
            }
        }
    }
    
    func setContact(_ viewModels: ConfirmationContactDetailViewModel) {
        guard let container = self.confirmationContainerViewModel else { return }
        let views = BizumConfirmationContactView(viewModels)
        views.hidePointLine()
        container.addViewAtModel(views)
        self.add(container)
    }
}

private extension BizumRefundMoneyConfirmationViewController {
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
            title: .titleWithHeaderAndImage(titleKey: "toolbar_title_returnShipment",
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
