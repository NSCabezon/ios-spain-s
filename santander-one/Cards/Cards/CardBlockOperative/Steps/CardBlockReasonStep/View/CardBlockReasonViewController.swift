//
//  CardBlockReasonViewController.swift
//  Cards
//
//  Created by Iván Estévez Nieto on 26/5/21.
//

import UI
import CoreFoundationLib
import Operative

protocol CardBlockReasonViewProtocol: OperativeView {
    func setupHeader(_ cardBlockReasonViewModel: CardBlockReasonViewModel)
}

final class CardBlockReasonViewController: UIViewController {
    @IBOutlet private weak var scrollView: UIScrollView!
    @IBOutlet private weak var containerStackView: UIStackView!
    @IBOutlet private weak var confirmButton: RedLisboaButton!
    @IBOutlet private weak var bottomSeparatorView: UIView!
    private let headerView = CardSectionHeaderView()
    private let reasonsView = CardBlockReasonsView()
    private let presenter: CardBlockReasonPresenterProtocol
    
    init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?, presenter: CardBlockReasonPresenterProtocol) {
        self.presenter = presenter
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupView()
        self.presenter.viewDidLoad()
    }
}

private extension CardBlockReasonViewController {
    func setupView() {
        self.setupNavigationBar()
        self.setupButtons()
        self.bottomSeparatorView.backgroundColor = .mediumSkyGray
        self.addSubviews()
    }
    
    func setupNavigationBar() {
        let builder = NavigationBarBuilder(
            style: .sky,
            title: .title(key: "toolbar_title_blockCard")
        )
        builder.setLeftAction(.back(action: #selector(didSelectBack)))
        builder.setRightActions(
            NavigationBarBuilder.RightAction.close(action: #selector(didSelectClose))
        )
        builder.build(on: self, with: nil)
    }
    
    @objc func didSelectClose() {
        self.presenter.didSelectClose()
    }
    
    @objc func didSelectBack() {
        self.presenter.didSelectBack()
    }
    
    func setupButtons() {
        self.confirmButton.setTitle(localized("generic_button_confirm"), for: .normal)
        self.confirmButton.addAction { [weak self] in
            self?.presenter.confirmButtonPressed()
        }
        self.disableConfirmButton()
    }
    
    func addSubviews() {
        self.containerStackView.addArrangedSubview(headerView)
        self.reasonsView.setup(delegate: self, showCommentReason: self.presenter.showCommentReason)
        self.containerStackView.addArrangedSubview(reasonsView)
    }
    
    func disableConfirmButton() {
        self.confirmButton.isEnabled = false
        self.confirmButton.backgroundColor = .lightSanGray
        self.confirmButton.layer.borderColor = UIColor.lightSanGray.cgColor
    }
    
    func enableConfirmButton() {
        self.confirmButton.isEnabled = true
        self.confirmButton.backgroundColor = .santanderRed
        self.confirmButton.layer.borderColor = UIColor.santanderRed.cgColor
    }
}

extension CardBlockReasonViewController: CardBlockReasonViewProtocol {
    var operativePresenter: OperativeStepPresenterProtocol {
        presenter
    }
    
    func setupHeader(_ cardBlockReasonViewModel: CardBlockReasonViewModel) {
        let model = CardSectionHeaderViewModel(url: cardBlockReasonViewModel.imageUrl, defaultImage: Assets.image(named: "defaultCard"), title: cardBlockReasonViewModel.title, subtitle: cardBlockReasonViewModel.subtitle)
        self.headerView.setViewModel(model)
    }
}

extension CardBlockReasonViewController: CardBlockReasonsViewDelegate {
    func newSelectedView(option: CardBlockReasonOption?) {
        guard let option = option else { return }
        self.enableConfirmButton()
        self.presenter.newOptionSelected(option)
        self.presenter.getCommentReason(option.reason)
    }
}
