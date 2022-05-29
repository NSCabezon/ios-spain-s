//
//  BizumDonationConfirmationViewController.swift
//  Bizum
//
//  Created by Carlos Monfort Gómez on 23/02/2021.
//

import Foundation
import UI
import Operative
import CoreFoundationLib
import ESUI

protocol BizumDonationConfirmationViewProtocol: OperativeConfirmationViewProtocol {
    func add(_ items: [BizumConfirmationItemViewModel])
    func setOrganization(_ viewModel: ConfirmationOrganizationDetailViewModel)
}

final class BizumDonationConfirmationViewController: OperativeConfirmationViewController {
    let presenter: BizumDonationConfirmationPresenterProtocol
    private var confirmationContainerViewModel: ConfirmationContainerViewModel?

    init(presenter: BizumDonationConfirmationPresenterProtocol) {
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

extension BizumDonationConfirmationViewController: BizumDonationConfirmationViewProtocol {
    func add(_ items: [BizumConfirmationItemViewModel]) {
        for item in items {
            switch item {
            case .confirmation(let viewModel):
                self.add(viewModel)
            case .multimedia(let viewModels):
                if !viewModels.isEmpty {
                    self.add(self.createMedia(viewModels))
                }
            case .contacts(let viewModel):
                self.confirmationContainerViewModel = viewModel
                self.presenter.getOrganization()
            case .total(let viewModel):
                self.add(viewModel)
            }
        }
    }
    
    func setOrganization(_ viewModel: ConfirmationOrganizationDetailViewModel) {
        guard let container = self.confirmationContainerViewModel else { return }
        let view = ConfirmationOrganizationDetailView()
        view.setView(viewModel)
        container.addViewAtModel(view)
        self.add(container)
    }
}

private extension BizumDonationConfirmationViewController {
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
            title: .titleWithHeaderAndImage(titleKey: "genericToolbar_title_confirmation",
                                            header: .title(key: "toolbar_title_bizum", style: .default),
                                            image: titleImage)
        )
        builder.setRightActions(
            NavigationBarBuilder.RightAction.close(action: #selector(close))
        )
        builder.build(on: self, with: nil)
    }
    
    func createMedia(_ viewModels: [ImageLabelViewModel]) -> [UIView] {
        var views: [UIView] = []
        let view = UIView(frame: .zero)
        view.heightAnchor.constraint(equalToConstant: 15.0).isActive = true
        views.append(view)
        viewModels.forEach { viewModel in
            let view = ImageLabelView()
            view.setup(viewModel)
            views.append(view)
        }
        (views.last as? ImageLabelView)?.showSeparator()
        return views
    }
    
    // MARK: - Actions
    @objc func close() {
        self.presenter.didTapClose()
    }
}
