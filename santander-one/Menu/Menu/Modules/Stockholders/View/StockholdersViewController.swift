//
//  StockholdersViewController.swift
//  Menu
//
//  Created by alvola on 28/04/2020.
//

import UI
import CoreFoundationLib
import CoreDomain

protocol StockholdersViewProtocol: UIViewController {
    var presenter: StockholdersPresenterProtocol { get }
    func setStockholdersModels(_ models: [ButtonViewModel])
    func setLoadingView(completion: (() -> Void)?)
    func hideLoadingView(completion: (() -> Void)?)
}

final class StockholdersViewController: UIViewController {
    @IBOutlet private weak var scrollableView: UIView!
    @IBOutlet private weak var fakeNavbarView: UIView!
    private var scrollableStackView = ScrollableStackView(frame: .zero)
    internal var presenter: StockholdersPresenterProtocol
    
    init(presenter: StockholdersPresenterProtocol) {
        self.presenter = presenter
        super.init(nibName: "StockholdersViewController", bundle: Bundle.module)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
        presenter.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureNavigationBar()
    }
}

private extension StockholdersViewController {
    
    func configureNavigationBar() {
        let builder = NavigationBarBuilder(style: .sky, title: .title(key: localized("toolbar_title_stockholders")))
        builder.setLeftAction(.back(action: #selector(didPressClose)))
        builder.setRightActions(.menu(action: #selector(didPressDrawer)))
        builder.build(on: self, with: self.presenter)
    }
    
    func configureView() {
        self.view.backgroundColor = .skyGray
        self.scrollableView.backgroundColor = .skyGray
        self.scrollableStackView.setup(with: self.scrollableView)
        self.scrollableStackView.setBounce(enabled: false)
        self.scrollableStackView.setScrollDelegate(self)
        self.scrollableStackView.setScrollInsets(UIEdgeInsets(top: 24.0, left: 0.0, bottom: 24.0, right: 0.0))
        
        self.fakeNavbarView.backgroundColor = .skyGray
        self.fakeNavbarView.layer.masksToBounds = false
        self.fakeNavbarView.layer.shadowColor = UIColor.black.cgColor
        self.fakeNavbarView.layer.shadowOpacity = 0.3
        self.fakeNavbarView.layer.shadowOffset = CGSize.zero
        self.fakeNavbarView.layer.shadowRadius = 0
    }
    
    func addDoubleViewWithLeftInfo(_ leftModel: ButtonViewModel?,
                                   rightModel: ButtonViewModel?,
                                   leftIdx: Int?, rightIdx: Int?) {
        let doubleView = DoubleBigButtonView(frame: .zero)
        doubleView.translatesAutoresizingMaskIntoConstraints = false
        doubleView.delegate = self
        doubleView.setLeftInfo(leftSide: leftModel == nil ? nil: (leftModel!, .stockholders),
                               rightSide: rightModel == nil ? nil: (rightModel!, .stockholders))
        doubleView.setLeftIndex(leftIdx, rightIndex: rightIdx)
        scrollableStackView.addArrangedSubview(doubleView)
    }
    
    @objc func didPressDrawer() {
        presenter.didPressDrawer()
    }
    
    @objc func didPressClose() {
        presenter.didPressClose()
    }
}

extension StockholdersViewController: StockholdersViewProtocol {
    func setStockholdersModels(_ models: [ButtonViewModel]) {
        stride(from: 0, to: models.endIndex, by: 2).forEach {
            addDoubleViewWithLeftInfo(models[$0],
                                      rightModel: $0 < models.index(before: models.endIndex) ? models[$0.advanced(by: 1)] : nil,
                                      leftIdx: $0,
                                      rightIdx: $0.advanced(by: 1))
        }
    }
}

extension StockholdersViewController: DoubleBigButtonViewDelegate {
    func didSelect(_ idx: Int) {
        presenter.didSelectIndex(idx)
    }
}

extension StockholdersViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.fakeNavbarView.layer.shadowRadius = scrollView.contentOffset.y > 3.0 ? 2.0 : 0.0
    }
}

extension StockholdersViewController: RootMenuController {
    public var isSideMenuAvailable: Bool { true }
}

extension StockholdersViewController: LoadingViewPresentationCapable {
    var associatedLoadingView: UIViewController {
        return self
    }
    
    func setLoadingView(completion: (() -> Void)?) {
        self.showLoading(completion: completion)
    }
    
    func hideLoadingView(completion: (() -> Void)?) {
        self.dismissLoading(completion: completion)
    }
}

extension StockholdersViewController: HighlightedMenuProtocol {
    func getOption() -> PrivateMenuOptions? {
        .sofiaInvestments
    }    
}
