//
//  NearAtmView.swift
//  Menu
//
//  Created by Cristobal Ramos Laina on 28/10/2020.
//

import Foundation
import UI
import CoreFoundationLib

protocol NearAtmViewDelegate: AnyObject {
    func didTapOnAtm(_ viewModel: AtmViewModel)
}

final class NearAtmView: XibView {
    @IBOutlet private weak var subtitleEmptyLabel: UILabel!
    @IBOutlet private weak var backgroundEmptyImageView: UIImageView!
    @IBOutlet private weak var titleEmptyLabel: UILabel!
    @IBOutlet private weak var emptyView: UIView!
    @IBOutlet private weak var collectionContainerView: UIView!
    @IBOutlet private weak var atmMachinesCollectionView: UICollectionView!
    @IBOutlet private weak var backgorundImageView: UIImageView!
    @IBOutlet weak var contentStackView: UIStackView!
    private let filterView = AtmFilterView()
    weak var delegate: NearAtmViewDelegate?
    private var viewModels: [AtmViewModel] = []
    private var filteredViewModels: [AtmViewModel] = []
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupView()
    }
    
    func setViewModel(_ viewModel: NearAtmViewModel) {
        guard let atmViewModels = viewModel.atmViewModels, !atmViewModels.isEmpty else {
            self.isEmpty()
            return
        }
        self.viewModels = atmViewModels
        self.filteredViewModels = self.viewModels
        self.filterView.setFilterButton(hidden: viewModel.isFilterHidden)
        self.showEmptyViewIfNeeded()
        self.atmMachinesCollectionView.reloadData()
    }
    
    func isEmpty() {
        self.collectionContainerView.isHidden = true
        self.emptyView.isHidden = false
        self.subtitleEmptyLabel.isHidden = true
    }
}

private extension NearAtmView {
    func setupView() {
        self.addFilterView()
        let nearAtmNib = UINib(nibName: "NearAtmViewCell", bundle: Bundle.module)
        self.atmMachinesCollectionView.register(nearAtmNib, forCellWithReuseIdentifier: "NearAtmViewCell")
        self.atmMachinesCollectionView.delegate = self
        self.atmMachinesCollectionView.dataSource = self
        self.setAccessibilityIdentifiers()
        self.backgorundImageView.image = Assets.image(named: "atmImgCarouselAtm")
        self.atmMachinesCollectionView.contentInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        self.setCollectionViewFlowLayout()
        self.atmMachinesCollectionView.showsHorizontalScrollIndicator = false
        self.atmMachinesCollectionView.showsVerticalScrollIndicator = false
        self.collectionContainerView?.drawBorder(cornerRadius: 0, color: UIColor.lightSkyBlue, width: 1)
        self.backgroundEmptyImageView.image = Assets.image(named: "atmImgCarouselAtm")
        self.titleEmptyLabel?.font = .santander(family: .headline, type: .regular, size: 20)
        self.titleEmptyLabel?.textColor = .lisboaGray
        self.titleEmptyLabel.configureText(withKey: "atm_empty_noAtmsFound")
        self.subtitleEmptyLabel?.font = .santander(family: .headline, type: .regular, size: 14)
        self.subtitleEmptyLabel?.textColor = .grafite
        self.subtitleEmptyLabel.configureText(withKey: "atm_empty_modifyFilters")
        self.emptyView?.drawBorder(cornerRadius: 0, color: UIColor.lightSkyBlue, width: 1)
        self.emptyView.isHidden = true
    }

    func addFilterView() {
        self.filterView.setDelegate(self)
        var views = self.contentStackView.arrangedSubviews
        views.insert(filterView, at: 0)
        views.forEach({contentStackView.addArrangedSubview($0)})
    }
    
    func setCollectionViewFlowLayout() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: 180, height: 88)
        layout.minimumInteritemSpacing = 8
        layout.minimumLineSpacing = 8
        self.atmMachinesCollectionView.setCollectionViewLayout(layout, animated: false)
    }
    
    func setAccessibilityIdentifiers() {
        self.atmMachinesCollectionView.accessibilityIdentifier = AccessibilityAtm.NearestAtms.carousel
    }
    
    func showEmptyViewIfNeeded() {
        if self.filteredViewModels.isEmpty {
            self.emptyView.isHidden = false
            self.collectionContainerView.isHidden = true
        } else {
            self.collectionContainerView.isHidden = false
            self.emptyView.isHidden = true
        }
    }
}

extension NearAtmView: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.filteredViewModels.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "NearAtmViewCell", for: indexPath) as? NearAtmViewCell
        cell?.setViewModel(viewModel: (self.filteredViewModels[indexPath.row]))
        cell?.setAccesibilityIdentifier(index: indexPath.row + 1)
        return cell ?? UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.delegate?.didTapOnAtm((self.filteredViewModels[indexPath.row]))
    }
}

extension NearAtmView: AtmFilterViewDelegate {
    func removeFilters() {
        self.filteredViewModels = self.viewModels
        self.atmMachinesCollectionView.reloadData()
        self.showEmptyViewIfNeeded()
    }
    
    func didSelectFilters(_ filters: Set<AtmFilterView.AtmFilter>) {
        self.filteredViewModels =  self.viewModels.filter({ viewModel in
            let serviceAdapter = AtmServiceFilterAdapter(viewModel: viewModel)
            return filters.isSubset(of: Set(serviceAdapter))
        })
        self.atmMachinesCollectionView.reloadData()
        self.showEmptyViewIfNeeded()
    }
}
