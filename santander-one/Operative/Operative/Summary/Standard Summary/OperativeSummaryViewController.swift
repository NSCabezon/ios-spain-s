//
//  OperativeSummaryViewController.swift
//  Bills
//
//  Created by José Carlos Estela Anguita on 22/05/2020.
//

import UIKit
import UI

public protocol OperativeSummaryPresenterProtocol: OperativeStepPresenterProtocol {
    var view: OperativeSummaryViewProtocol? { get set }
    func viewDidLoad()
}

public protocol OperativeSummaryViewProtocol: OperativeView {
    func setupStandardFooterWithTitle(_ title: String, items: [OperativeSummaryStandardFooterItemViewModel])
    func setupStandardHeader(with viewModel: OperativeSummaryStandardHeaderViewModel)
    func setupStandardBody(withItems viewModels: [OperativeSummaryStandardBodyItemViewModel],
                           actions: [OperativeSummaryStandardBodyActionViewModel],
                           collapsableSections: SummaryCollapsable)
    func setupStandardBody(withItems viewModels: [OperativeSummaryStandardBodyItemViewModel],
                           locations: [OperativeSummaryStandardLocationViewModel],
                           actions: [OperativeSummaryStandardBodyActionViewModel],
                           collapsableSections: SummaryCollapsable)
    func build()
    func resetContent()
}

public struct OperativeSummaryStandardViewModel {
    public let header: OperativeSummaryStandardHeaderViewModel
    public let bodyItems: [OperativeSummaryStandardBodyItemViewModel]
    public let bodyActionItems: [OperativeSummaryStandardBodyActionViewModel]
    public let footerItems: [OperativeSummaryStandardFooterItemViewModel]
    
    public init(header: OperativeSummaryStandardHeaderViewModel,
                bodyItems: [OperativeSummaryStandardBodyItemViewModel],
                bodyActionItems: [OperativeSummaryStandardBodyActionViewModel],
                footerItems: [OperativeSummaryStandardFooterItemViewModel]) {
        self.header = header
        self.bodyItems = bodyItems
        self.bodyActionItems = bodyActionItems
        self.footerItems = footerItems
    }
}

open class OperativeSummaryViewController: UIViewController {
    private class Configuration {
        var footer: UIView?
        var header: UIView?
        var body: UIView?
    }
    
    // MARK: - Outlets
    @IBOutlet private weak var scrollView: UIScrollView!
    @IBOutlet private weak var contentView: UIView!
    @IBOutlet private weak var stackView: UIStackView!
    @IBOutlet private weak var footer: UIView!
    
    // MARK: - Private attributes
    private let presenter: OperativeSummaryPresenterProtocol
    private let configuration: Configuration = Configuration()
    
    // MARK: - Public methods
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        self.setupView()
        self.presenter.viewDidLoad()
    }
    
    override open func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setPopGestureEnabled(false)
    }
    
    open override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.setPopGestureEnabled(true)
    }
    
    public init(presenter: OperativeSummaryPresenterProtocol) {
        self.presenter = presenter
        super.init(nibName: "OperativeSummaryViewController", bundle: Bundle.module)
    }
    
    public required init?(coder: NSCoder) {
        fatalError()
    }
    
    public func setupFooter(_ footer: UIView) {
        self.configuration.footer = footer
    }
    
    public func setupHeader(_ header: UIView) {
        self.configuration.header = header
    }
    
    public func setupBody(_ body: UIView) {
        self.configuration.body = body
    }
    
    open func setupView() {
        self.scrollView.backgroundColor = .skyGray
        self.scrollView.delegate = self
        self.contentView.backgroundColor = .skyGray
        self.setupNavigationBar()
    }
    
    open func setupNavigationBar() {
        let builder = NavigationBarBuilder(
            style: .sky,
            title: .title(key: "genericToolbar_title_summary")
        )
        builder.build(on: self, with: nil)
    }
}

extension OperativeSummaryViewController: OperativeSummaryStandardBodyViewDelegate {
    public func didCollapseBody() {}
}

extension OperativeSummaryViewController: OperativeSummaryViewProtocol {
    public var operativePresenter: OperativeStepPresenterProtocol {
        return self.presenter
    }
    
    public func setupStandardFooterWithTitle(_ title: String,
                                             items: [OperativeSummaryStandardFooterItemViewModel]) {
        let footer = OperativeSummaryStandardFooterView(frame: .zero)
        footer.translatesAutoresizingMaskIntoConstraints = false
        footer.setupWithTitle(title, items: items)
        self.setupFooter(footer)
    }
    
    public func setupStandardHeader(with viewModel: OperativeSummaryStandardHeaderViewModel) {
        let header = OperativeSummaryStandardHeaderView(frame: .zero)
        header.translatesAutoresizingMaskIntoConstraints = false
        header.setupWithViewModel(viewModel)
        self.setupHeader(header)
    }
    
    public func setupStandardBody(withItems viewModels: [OperativeSummaryStandardBodyItemViewModel],
                                  actions: [OperativeSummaryStandardBodyActionViewModel],
                                  collapsableSections: SummaryCollapsable) {
        setupStandardBody(
            withItems: viewModels,
            locations: [],
            actions: actions,
            collapsableSections: collapsableSections
        )
    }
    
    public func setupStandardBody(withItems viewModels: [OperativeSummaryStandardBodyItemViewModel],
                                  locations: [OperativeSummaryStandardLocationViewModel],
                                  actions: [OperativeSummaryStandardBodyActionViewModel],
                                  collapsableSections: SummaryCollapsable) {
        let body = OperativeSummaryStandardBodyView(frame: .zero)
        body.translatesAutoresizingMaskIntoConstraints = false
        body.setupWithItems(
            viewModels,
            locations: locations,
            actions: actions,
            collapsableSections: collapsableSections
        )
        body.delegate = self
        self.setupBody(body)
    }
    
    public func build() {
        if let header = self.configuration.header {
            self.stackView.addArrangedSubview(header)
        }
        if let body = self.configuration.body {
            self.stackView.addArrangedSubview(body)
        }
        if let footer = self.configuration.footer {
            self.footer.addSubview(footer)
            footer.fullFit()
            footer.backgroundColor = .blueAnthracita
        }
    }
    
    public func resetContent() {
        self.stackView.removeAllArrangedSubviews()
        self.configuration.header = nil
        self.configuration.body = nil
    }
}

extension OperativeSummaryViewController: UIScrollViewDelegate {
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.scrollView.backgroundColor = scrollView.contentOffset.y > 0 ? .blueAnthracita: .skyGray
    }
}
