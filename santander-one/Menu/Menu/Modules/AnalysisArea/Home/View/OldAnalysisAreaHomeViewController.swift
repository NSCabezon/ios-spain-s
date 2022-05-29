//
//  AnalysisAreaHomeViewController.swift
//  Menu
//
//  Created by José María Jiménez Pérez on 7/6/21.
//

import UI
import CoreFoundationLib

protocol OldAnalysisAreaHomeViewProtocol: NavigationBarWithSearchProtocol {
    func setSegmentedControlView(list: [String], accessibilityIdentifiers: [String])
    func selectSegmentTo(_ segmentIndex: OldAnalysisAreaHomeViewController.SegmentedType)
}

final class OldAnalysisAreaHomeViewController: UIViewController {

    private let presenter: AnalysisAreaHomePresenterProtocol
    private let dependenciesResolver: DependenciesResolver
    private var currentChildVC: UIViewController?
    @IBOutlet private weak var segmentedControlContainerView: UIView!
    @IBOutlet private weak var segmentedControl: LisboaSegmentedControl!
    @IBOutlet private weak var containerView: UIView!
    
    var isSearchEnabled: Bool = false {
        didSet {
            setUpNavigationBar()
        }
    }
    
    init(dependenciesResolver: DependenciesResolver, presenter: AnalysisAreaHomePresenterProtocol) {
        self.presenter = presenter
        self.dependenciesResolver = dependenciesResolver
        super.init(nibName: "OldAnalysisAreaHomeViewController", bundle: .module)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setUpNavigationBar()
    }
    
    func setUpNavigationBar() {
        let builder = NavigationBarBuilder(
            style: .sky,
            title: .title(key: "toolbar_title_financialHealth")
        )
        builder.setLeftAction(.back(action: #selector(dismissViewController)))
        builder.setRightActions(.menu(action: #selector(openMenu)))
        builder.build(on: self, with: self.presenter)
    }
    
    @objc private func openMenu() {
        self.presenter.didSelectMenu()
    }
    
    @objc private func dismissViewController() {
        self.presenter.didSelectDismiss()
    }
    
    @IBAction func didTapOnSegmented(_ sender: LisboaSegmentedControl) {
        guard let type = SegmentedType(rawValue: sender.selectedSegmentIndex) else { return }
        presenter.didSelectSegment(type)
    }
}

extension OldAnalysisAreaHomeViewController: OldAnalysisAreaHomeViewProtocol {
    func setSegmentedControlView(list: [String], accessibilityIdentifiers: [String]) {
        self.segmentedControlContainerView.backgroundColor = .skyGray
        self.segmentedControl.setup(
            with: list,
            accessibilityIdentifiers: accessibilityIdentifiers,
            withStyle: .financingSegmentedControlStyle
        )
        UILabel.appearance(whenContainedInInstancesOf: [UISegmentedControl.self]).numberOfLines = 0
    }
    
    func selectSegmentTo(_ segmentIndex: SegmentedType) {
        segmentedControl.selectedSegmentIndex = segmentIndex.rawValue
        if let childVC = currentChildVC {
            self.removeChildViewController(childVC)
            currentChildVC = nil
        }
        switch segmentIndex {
        case .expenseAnalysis:
            currentChildVC = dependenciesResolver.resolve(for: ExpensesAnalysisViewController.self)
        case .finantialHealth:
            currentChildVC = dependenciesResolver.resolve(for: OldAnalysisAreaViewController.self)
        }
        guard let currentChildVC = self.currentChildVC else { return }
        self.addChildViewController(currentChildVC, on: self.containerView)
        self.didMove(toParent: self)
    }
}

extension OldAnalysisAreaHomeViewController {
    enum SegmentedType: Int {
        case expenseAnalysis = 0
        case finantialHealth = 1
    }
}

extension OldAnalysisAreaHomeViewController {
    public var searchButtonPosition: Int { return 1 }
    public func isSearchEnabled(_ enabled: Bool) { isSearchEnabled = enabled }
    
    @objc func searchButtonPressed() { presenter.searchButtonPressed() }
}
