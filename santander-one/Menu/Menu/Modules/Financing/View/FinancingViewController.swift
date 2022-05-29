//
//  FinancingViewController.swift
//  Menu
//
//  Created by Cristobal Ramos Laina on 23/06/2020.
//

import UIKit
import UI
import CoreFoundationLib
import CoreDomain
import UIOneComponents

protocol FinancingViewProtocol: AnyObject {
    func showFinanceableView()
    func showFinancingDistribution()
    func setSegmentedControlView(list: [String])
    func addFinancingView()
}

final class FinancingViewController: UIViewController {
    
    @IBOutlet weak var segmentedControlContainerView: UIView!
    @IBOutlet weak var segmentedControl: OneFilterView!
    @IBOutlet weak var containerView: UIView!
    
    private let presenter: FinancingPresenterProtocol
    private let dependenciesResolver: DependenciesResolver
    private lazy var financeableViewController: FinanceableViewController = {
        self.dependenciesResolver.resolve()
    }()
    private lazy var financingDistributionViewController: FinancingDistributionViewController = {
        self.dependenciesResolver.resolve(for: FinancingDistributionViewController.self)
    }()
    
    private weak var lastTooltipViewSender: UIView?

    public var isSearchEnabled: Bool = true {
         didSet { self.setupNavigationBar() }
    }

    enum SegmentedItems: Int {
        case forFinance = 0
        case yourFinancing = 1
        case updateFinancing = 2
    }
    
    init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?,
         presenter: FinancingPresenterProtocol, dependenciesResolver: DependenciesResolver) {
        self.presenter = presenter
        self.dependenciesResolver = dependenciesResolver
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        self.segmentedControlContainerView.isHidden = true
        self.presenter.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.segmentedControl.selectedSegmentIndex = self.presenter.getCurrentSelectedOption()
        self.setupNavigationBar()
    }
        
    @IBAction func didTapInSegmented(_ sender: OneFilterView) {
        let segment = SegmentedItems(rawValue: sender.selectedSegmentIndex)
        switch segment {
        case .forFinance:
            self.presenter.setCurrentSelectedOption(0)
            showFinanceableView()
        case .yourFinancing:
            self.presenter.setCurrentSelectedOption(1)
            showFinancingDistribution()
        case .updateFinancing:
            presenter.executeOffer()
        default: break
        }
    }
}

private extension FinancingViewController {
    func setupView() {
        self.segmentedControlContainerView.isHidden = false
        self.segmentedControlContainerView.backgroundColor = .white
    }
    
    func setupNavigationBar() {
        OneNavigationBarBuilder(.whiteWithRedComponents)
            .setTitle(withKey: "toolbar_title_financing")
            .setLeftAction(.back, customAction: {
                self.presenter.didSelectDismiss()
            })
            .setRightAction(.search) {
                self.presenter.didSelectSearch()
            }
            .setRightAction(.menu) {
                self.presenter.didSelectMenu()
            }
            .build(on: self)
    }
}

extension FinancingViewController: RootMenuController {
    var isSideMenuAvailable: Bool {
        return true
    }
}

extension FinancingViewController: HighlightedMenuProtocol {
    public func getOption() -> PrivateMenuOptions? {
        return .financing
    }
}

extension FinancingViewController: FinancingViewProtocol {
    func addFinancingView() {
        self.addChildViewController(self.financeableViewController, on: self.containerView)
    }
    
    func showFinancingDistribution() {
        self.removeChildViewController(self.financeableViewController)
        self.addChildViewController(self.financingDistributionViewController, on: self.containerView)
    }
    
    func showFinanceableView() {
        self.removeChildViewController(self.financingDistributionViewController)
        self.addChildViewController(self.financeableViewController, on: self.containerView)
    }

    func setSegmentedControlView(list: [String]) {
        self.setupView()
        self.segmentedControl.setupDouble(
            with: list,
            withStyle: .defaultOneFilterStyle,
            withIndex: SegmentedItems.forFinance.rawValue
        )
    }
}

extension FinancingViewController: NavigationBarWithSearchProtocol {
    public var searchButtonPosition: Int {
        1
    }
    
    public func searchButtonPressed() {
        presenter.didSelectSearch()
    }
    
    func setIsSearchEnabled(_ enabled: Bool) {
        isSearchEnabled = enabled
    }
}

private extension FinancingViewController {
    
}
