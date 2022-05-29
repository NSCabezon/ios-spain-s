//
//  AnalysisCarouselCollectionView.swift
//  Menu
//
//  Created by Laura González on 20/03/2020.
//

import UIKit
import UI
import CoreFoundationLib

class AnalysisCarouselCollectionView: UICollectionView {
    private var layout = ZoomAndSnapFlowLayout()
    private var viewModels: [AnalysisCarouselViewCellModel] = []
    
    let cellIndentifiers = ["AnalysisCarouselCollectionViewCell", "CreateBudgetCollectionViewCell"]

    weak var budgetDelegate: CreateBudgetCollectionViewCellDelegate?
    weak var budgetCellDelegate: AnalysisCarouselCollectionViewCellDelegate?
    
    // MARK: - Public
    
    init(frame: CGRect) {
        super.init(frame: frame, collectionViewLayout: layout)
        self.setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupView()
    }
    
    public func setViewModel(_ viewModel: AnalysisCarouselViewModel, delegateBudget: CreateBudgetCollectionViewCellDelegate?, delegateBudgetCell: AnalysisCarouselCollectionViewCellDelegate?) {
        self.viewModels = viewModel.getCellEntitys()
        self.budgetDelegate = delegateBudget
        self.budgetCellDelegate = delegateBudgetCell
        self.reloadData()
    }
}

// MARK: - Private

private extension AnalysisCarouselCollectionView {
    private func setupView() {
        self.registerCells()
        self.setupCollectionViewFlowLayout()
        self.backgroundColor = .lisboaGray
        self.dataSource = self
        self.delegate = self
        self.showsHorizontalScrollIndicator = false
        self.showsVerticalScrollIndicator = false
    }
    
    private func registerCells() {
        cellIndentifiers.forEach {
            let nib = UINib(nibName: $0, bundle: Bundle.module)
            self.register(nib, forCellWithReuseIdentifier: $0)
        }
    }
    
    private func setupCollectionViewFlowLayout() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 16
        layout.minimumLineSpacing = 16
        self.collectionViewLayout = layout
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension AnalysisCarouselCollectionView: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModels.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let viewModel = self.viewModels[indexPath.row]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: getCellIdentifier(modelType: viewModel.modelType), for: indexPath)
        (cell as? AnalysisCarouselCollectionViewCell)?.configure(viewModel)
        (cell as? AnalysisCarouselCollectionViewCell)?.setDelegate(budgetCellDelegate)
        (cell as? CreateBudgetCollectionViewCell)?.setDelegate(budgetDelegate)

        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 200, height: 200)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
    }
}

private extension AnalysisCarouselCollectionView {

    func getCellIdentifier(modelType: AnalysisCarouselViewModelType) -> String {
        switch modelType {
        case .savings, .budget:
            return "AnalysisCarouselCollectionViewCell"
        case .editBudget:
            return "CreateBudgetCollectionViewCell"
        }
    }
}
