//
//  CategoriesDetailViewController.swift
//  Menu
//
//  Created by David Gálvez Alonso on 29/06/2021.
//

import UI
import CoreFoundationLib

protocol CategoriesDetailViewProtocol: AnyObject {
    func setListViewModel(_ viewModel: CategoriesDetailViewModel)
    func setHeaderTexts(_ titleText: String, subtitleText: String)
}

final class CategoriesDetailViewController: UIViewController {
    
    @IBOutlet private weak var calendarImg: UIImageView!
    @IBOutlet private weak var headerTitleLabel: UILabel!
    @IBOutlet private weak var headerSubtitleLabel: UILabel!
    @IBOutlet private weak var arrowImg: UIImageView!
    @IBOutlet private weak var listView: CategoriesDetailListView!
    @IBOutlet private weak var configContainer: UIView!
    @IBOutlet private weak var configImg: UIImageView!
    @IBOutlet private weak var configLabel: UILabel!
    @IBOutlet private weak var separatorView: UIView!
    @IBOutlet private weak var periodSelectorView: UIView!

    let presenter: CategoriesDetailPresenterProtocol
    private var filterViewModel: CategoryDetailFilterViewModel?

    init(presenter: CategoriesDetailPresenterProtocol) {
        self.presenter = presenter
        super.init(nibName: "CategoriesDetailViewController", bundle: Bundle.module)
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupView()
        self.setupLabels()
        self.setupGestures()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setUpNavigationBar()
        self.presenter.viewWillAppear()
    }
}

extension CategoriesDetailViewController: CategoriesDetailViewProtocol {
    func setListViewModel(_ viewModel: CategoriesDetailViewModel) {
        self.listView.setViewModel(viewModel)
        self.filterViewModel = viewModel.filter
        if viewModel.filter.filtersCount > 0 {
            self.setTagsOnHeader()
        } else {
            self.filterViewModel = nil
            self.tagsContainerView?.removeFromSuperview()
        }
    }
    
    func setHeaderTexts(_ titleText: String, subtitleText: String) {
        self.headerTitleLabel.configureText(withKey: titleText)
        self.headerSubtitleLabel.text = subtitleText
    }
}

private extension CategoriesDetailViewController {
    func setUpNavigationBar() {
        let builder = NavigationBarBuilder(
            style: .sky,
            title: .title(key: "toolbar_title_analysis")
        )
        builder.setLeftAction(.back(action: #selector(dismissViewController)))
        builder.setRightActions(.menu(action: #selector(openMenu)))
        builder.build(on: self, with: self.presenter)
    }
    
    @objc func dismissViewController() {
        self.presenter.didSelectDismiss()
    }
    
    @objc func openMenu() {
        self.presenter.didSelectMenu()
    }
    
    func setupView() {
        self.view.backgroundColor = .skyGray
        self.calendarImg.image = Assets.image(named: "icnCalendarGreen")
        self.calendarImg.tintColor = .darkTorquoise
        self.arrowImg.image = Assets.image(named: "icnArrowRightPeq")
        self.configImg.image = Assets.image(named: "icnSettingsBlue")
        self.separatorView.backgroundColor = .lightSkyBlue
        self.listView.filterDelegate = self
        self.listView.setDelegate()
        self.listView.delegate = self
        self.periodSelectorView.isUserInteractionEnabled = true
        self.periodSelectorView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapOnPeriodSelector)))
    }
    
    func setupLabels() {
        self.headerTitleLabel.font = .santander(family: .text, type: .regular, size: 18)
        self.headerTitleLabel.textColor = .lisboaGray
        self.headerSubtitleLabel.font = .santander(family: .text, type: .regular, size: 12)
        self.headerSubtitleLabel.textColor = .darkTorquoise
        self.headerTitleLabel.configureText(withKey: "analysis_label_mensualFilter", andConfiguration: nil)
        self.headerTitleLabel.accessibilityIdentifier = AccesibilityCategoryDetailType.mensualFilter
        self.headerSubtitleLabel.accessibilityIdentifier = AccesibilityCategoryDetailType.detailMonth
        self.configLabel.font = .santander(family: .text, type: .regular, size: 10)
        self.configLabel.textColor = .darkTorquoise
        self.configLabel.text = localized("analysis_button_settings")
        self.configLabel.accessibilityIdentifier = AccesibilityCategoryDetailType.buttonSettings
    }
    
    func setupGestures() {
        self.configContainer.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapOnConfig)))
    }
    
    @objc func didTapOnConfig() {
        self.presenter.didTapOnConfig()
    }
    
    @objc func didTapOnPeriodSelector() {
        self.presenter.didTapOnPeriodSelector()
    }
    
    func setTagsOnHeader() {
        guard let filterViewModel = filterViewModel else { return }
        self.tagsContainerView?.removeFromSuperview()
        let tagsMetadata = filterViewModel.buildTags()
        self.listView.addTagContainer(withTags: tagsMetadata, delegate: self)
    }
    
    var tagsContainerView: TagsContainerView? {
        return self.listView.getHeaderView().getTagsContainerView()
    }
}

extension CategoriesDetailViewController: CategoriesFilterDelegate {
    func didSelectedTimePeriod(_ periodViewModel: TimePeriodTotalAmountFilterViewModel) {
        self.presenter.didSelectedTimePeriod(periodViewModel)
    }
    
    func didSelectedSubcategory(_ subcategory: String) {
        self.presenter.didSelectedSubcategory(subcategory)
    }
}

extension CategoriesDetailViewController: CategoriesDetailListViewDelegate {
    func didTapOnFilter() {
        self.presenter.didTapOnFilter()
    }
}

extension CategoriesDetailViewController: TagsContainerViewDelegate {
    func didRemoveFilter(_ remaining: [TagMetaData]) {
        guard remaining.count > 0 else {
            self.tagsContainerView?.removeFromSuperview()
            self.listView.updateHeader()
            self.presenter.removeFilter(nil)
            return
        }
        if let remove = filterViewModel?.filterActivesFrom(remainingFilters: remaining) {
            self.presenter.removeFilter(remove)
        }
    }
}
