//
//  CategoriesDetailHeaderView.swift
//  Menu
//
//  Created by David Gálvez Alonso on 30/06/2021.
//

import UI
import CoreFoundationLib

protocol CategoriesDetailHeaderViewDelegate: AnyObject {
    func didChangeHeaderHeight()
    func didTapOnFilter()
}

protocol CategoriesFilterDelegate: AnyObject {
    func didSelectedSubcategory(_ subcategory: String)
    func didSelectedTimePeriod(_ periodViewModel: TimePeriodTotalAmountFilterViewModel)
}

class CategoriesDetailHeaderView: XibView {
    
    @IBOutlet private weak var movementsLabel: UILabel!
    @IBOutlet private weak var emptyView: SingleEmptyView!
    @IBOutlet private weak var categoryFilterImage: UIImageView!
    @IBOutlet private weak var categoryLabel: UILabel!
    @IBOutlet private weak var collectionContainerView: UIView!
    @IBOutlet private var separatorViews: [UIView]!
    @IBOutlet private weak var totalFilterView: UIView!
    @IBOutlet private weak var totalFilterHeight: NSLayoutConstraint!
    @IBOutlet private weak var filterArrowView: UIImageView!
    @IBOutlet private weak var totalCollectionView: UICollectionView!
    @IBOutlet private weak var gestureView: UIView!
    @IBOutlet private weak var filterButton: PressableButton!
    @IBOutlet private weak var filterLabel: UILabel!
    @IBOutlet private weak var tagsContainer: UIView!
    @IBOutlet private weak var detailChartView: CategoriesDetailChartView!
    
    weak var delegate: CategoriesDetailHeaderViewDelegate?
    weak var filterDelegate: CategoriesFilterDelegate?
    
    private var subcategoriesFilter: [SubcategoriesFilterViewModel] = []
    private let totalFilterHeightValue: CGFloat = 61.0
    private let cellIdentifier = "TotalDetailCollectionViewCell"
    private var tagsContainerView: TagsContainerView?
    
    func setupView() {
        self.setupLabels()
        self.setupOtherViews()
        self.setupAccessibilityIdentifiers()
    }
    
    func setMovements(_ movements: Int) {
        self.emptyView.isHidden = movements > 0
        self.movementsLabel.text = localized("analysis_label_movements") + " (\(movements))"
    }
    
    func setViewModel(_ viewModel: CategoriesDetailViewModel) {
        self.categoryFilterImage.image = Assets.image(named: viewModel.category.iconKey)
        self.categoryLabel.text = localized(viewModel.category.localizedKey)
        self.subcategoriesFilter = viewModel.subcategoriesFilter
        self.detailChartView.delegate = self
        self.detailChartView.setViewModel(viewModel)
        UIView.setAnimationsEnabled(false)
        self.totalCollectionView.reloadSections([self.totalCollectionView.numberOfSections - 1])        
        UIView.setAnimationsEnabled(true)
    }
    
    @IBAction private func didTapOnFilter(_ sender: UIButton) {
        delegate?.didTapOnFilter()
    }
    
    func addTagContainer(withTags tags: [TagMetaData], delegate: TagsContainerViewDelegate) {
        let tagsContainerView = TagsContainerView()
        tagsContainerView.delegate = delegate
        tagsContainerView.addTags(from: tags)
        tagsContainerView.backgroundColor = .white
        self.tagsContainer.addSubview(tagsContainerView)
        tagsContainerView.fullFit()
        self.tagsContainerView = tagsContainerView
        self.delegate?.didChangeHeaderHeight()
    }
    
    func getTagsContainerView() -> TagsContainerView? {
        return self.tagsContainerView
    }
}

private extension CategoriesDetailHeaderView {
    func setupLabels() {
        self.movementsLabel.font = .santander(family: .text, type: .bold, size: 16)
        self.movementsLabel.textColor = .lisboaGray
        self.movementsLabel.text = localized("analysis_label_movements")
        self.emptyView.updateTitle(localized("analysis_label_emptyMovements"))
        self.categoryLabel.setSantanderTextFont(type: .bold, size: 20, color: .lisboaGray)
        self.filterLabel.text = localized("generic_button_filters")
        self.filterLabel.textColor = .darkTorquoise
    }
    
    func setupOtherViews() {
        self.separatorViews.forEach { $0.backgroundColor = .lightSkyBlue }
        self.filterArrowView.image = Assets.image(named: "icnArrowUp")
        self.totalCollectionView.dataSource = self
        self.totalCollectionView.delegate = self
        self.gestureView.isUserInteractionEnabled = true
        self.gestureView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didPressed)))
        let nib = UINib(nibName: cellIdentifier, bundle: Bundle.module)
        self.totalCollectionView.register(nib, forCellWithReuseIdentifier: cellIdentifier)
        self.filterButton.setImage(Assets.image(named: "icnFilter"), for: .normal)
    }
    
    func setupAccessibilityIdentifiers() {
        self.movementsLabel.accessibilityIdentifier = AccesibilityCategoryDetailType.detailMovements
        self.emptyView.accessibilityIdentifier = AccesibilityCategoryDetailType.empty
        self.categoryLabel.accessibilityIdentifier = AccesibilityCategoryDetailType.category
        self.categoryFilterImage.accessibilityIdentifier = AccesibilityCategoryDetailType.categoryImage
        self.filterArrowView.accessibilityIdentifier = AccesibilityCategoryDetailType.arrow
    }
    
    @objc func didPressed(_ sender: UITapGestureRecognizer) {
        let arrowUp = Assets.image(named: "icnArrowUp")
        let arrowDown = Assets.image(named: "icnArrowDown")
        switch sender.view {
        case gestureView:
            totalFilterHeight.constant = collectionContainerView.isHidden ? totalFilterHeightValue : 0
            collectionContainerView.isHidden = totalFilterHeight.constant == 0
            filterArrowView.image = collectionContainerView.isHidden ? arrowDown : arrowUp
        default:
            break
        }
        self.delegate?.didChangeHeaderHeight()
    }
}

extension CategoriesDetailHeaderView: CategoriesDetailChartViewDelegate {
    func didSelectedTimePeriod(_ timePeriodViewModel: TimePeriodTotalAmountFilterViewModel) {
        self.filterDelegate?.didSelectedTimePeriod(timePeriodViewModel)
    }
}

extension CategoriesDetailHeaderView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.subcategoriesFilter.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: TotalDetailCollectionViewCell = collectionView.dequeue(type: TotalDetailCollectionViewCell.self, at: indexPath)
        let data = subcategoriesFilter[indexPath.row]
        cell.setViewModel(data.title, amountText: data.amount, isSelected: data.selected)
        return cell
    }
}

extension CategoriesDetailHeaderView: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.filterDelegate?.didSelectedSubcategory(subcategoriesFilter[indexPath.row].title)
    }
}
