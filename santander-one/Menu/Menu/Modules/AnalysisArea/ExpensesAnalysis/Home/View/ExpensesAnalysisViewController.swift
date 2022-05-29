//
//  ExpensesAnalysisViewController.swift
//  Menu
//
//  Created by José María Jiménez Pérez on 8/6/21.
//

import UIKit
import UI
import CoreFoundationLib

protocol ExpensesAnalysisViewProtocol: AnyObject {
    func setTimeText(_ titleText: String, subtitleText: String)
}

final class ExpensesAnalysisViewController: UIViewController {

    private let presenter: ExpensesAnalysisPresenterProtocol
    
    @IBOutlet private weak var headerContainer: UIView!
    @IBOutlet private weak var filterContainer: UIView!
    @IBOutlet private weak var calendarImg: UIImageView!
    @IBOutlet private weak var headerTitleLabel: UILabel!
    @IBOutlet private weak var headerSubtitleLabel: UILabel!
    @IBOutlet private weak var arrowImg: UIImageView!
    @IBOutlet private weak var configContainer: UIView!
    @IBOutlet private weak var configImg: UIImageView!
    @IBOutlet private weak var configLabel: UILabel!
    @IBOutlet private weak var separatorView: UIView!
    @IBOutlet private weak var scrollableStackViewContainer: UIView!
    
    private lazy var expensesIncomeCategoriesView: ExpensesIncomeCategoriesView = {
        return ExpensesIncomeCategoriesView()
    }()
    
    private lazy var scrollableStackView: ScrollableStackView = {
        let view = ScrollableStackView()
        view.setup(with: self.scrollableStackViewContainer)
        return view
    }()
    
    init(presenter: ExpensesAnalysisPresenterProtocol) {
        self.presenter = presenter
        super.init(nibName: "ExpensesAnalysisViewController", bundle: .module)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.presenter.viewDidLoad()
        self.setupUI()
        self.setupGestures()
        self.headerTitleLabel.configureText(withKey: "analysis_label_mensualFilter", andConfiguration: nil)
        self.configLabel.text = localized("analysis_button_settings")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.presenter.viewWillAppear()
    }
}

extension ExpensesAnalysisViewController: ExpensesAnalysisViewProtocol {
    func setTimeText(_ titleText: String, subtitleText: String) {
        self.headerTitleLabel.configureText(withKey: titleText)
        self.headerSubtitleLabel.text = subtitleText
    }
}

private extension ExpensesAnalysisViewController {
    func setupUI() {
        self.view.backgroundColor = .skyGray
        self.headerContainer.backgroundColor = .skyGray
        self.headerTitleLabel.font = .santander(family: .text, type: .regular, size: 18)
        self.headerTitleLabel.textColor = .lisboaGray
        self.headerSubtitleLabel.font = .santander(family: .text, type: .regular, size: 12)
        self.headerSubtitleLabel.textColor = .darkTorquoise
        self.calendarImg.image = Assets.image(named: "icnCalendarGreen")
        self.calendarImg.tintColor = .darkTorquoise
        self.arrowImg.image = Assets.image(named: "icnArrowRightPeq")
        self.configImg.image = Assets.image(named: "icnSettingsBlue")
        self.configLabel.font = .santander(family: .text, type: .regular, size: 10)
        self.configLabel.textColor = .darkTorquoise
        self.separatorView.backgroundColor = .mediumSkyGray
        self.scrollableStackView.addArrangedSubview(expensesIncomeCategoriesView)
        self.expensesIncomeCategoriesView.delegate = self
        self.scrollableStackView.isUserInteractionEnabled = true
    }
    
    func setupGestures() {
        self.filterContainer.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapOnFilter)))
        self.configContainer.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapOnConfig)))
    }
    
    @objc func didTapOnFilter() {
        self.presenter.didTapOnFilter()
    }
    
    @objc func didTapOnConfig() {
        self.presenter.didTapOnConfig()
    }
}

extension ExpensesAnalysisViewController: ExpensesIncomeCategoriesDelegate {
    func didSelectSegmentType(_ type: ExpensesIncomeCategoriesView.AnalysisCategoryType) {
        self.presenter.didSelectSegmentType(type)
    }
    
    func expensesIncomeListDidExpand(_ expensesIncomeListView: ExpensesIncomeListView, scrollHeight: CGFloat) {
        self.scrollableStackView.setContentOffset(CGPoint(x: scrollableStackView.scrollView.contentOffset.x, y: scrollableStackView.scrollView.contentOffset.y + scrollHeight), animated: true)
    }
    
    func expensesIncomeList(_ expensesIncomeListView: ExpensesIncomeListView, didSelectCategory category: ExpensesIncomeCategoryType, chartType: ExpensesIncomeCategoriesChartType) {
        self.presenter.didSelectCategoryDetail(category, chartType: chartType)
    }
    
    func categoryChartsDidSwipeWith(chartType: ExpensesIncomeCategoriesChartType) {
        self.presenter.trackSwipeFor(chartType: chartType)
    }
}
