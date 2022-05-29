//
//  ExpensesContainerView.swift
//  GlobalPosition
//
//  Created by Boris Chirino Fernandez on 24/12/2019.
//

import UI
import CoreFoundationLib

class ExpensesContainerView: DesignableView, UICollectionViewDelegate {
    
    let bundleModule = Bundle(for: ExpensesContainerView.self)
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var pageControl: UIPageControl!
    
    private var currentBalanceData: CurrentBalanceGraphData?
    private var currentPage: Int = 0
    private var data: ExpensesGraphViewModel? {
        didSet {
            updatePageController()
        }
    }
    private var discreteMode: Bool = false
    weak var delegate: ExpensesGraphViewPortActionsDelegate?
    
    override func commonInit() {
        super.commonInit()
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(UINib(nibName: "SmartExpensesCrossLinearGraphCollectionViewCell", bundle: bundleModule), forCellWithReuseIdentifier: SmartExpensesCrossLinearGraphCollectionViewCell.cellIdentifier)
        collectionView.register(UINib(nibName: "SmartExpensesLinearGraphCollectionViewCell", bundle: bundleModule), forCellWithReuseIdentifier: SmartExpensesLinearGraphCollectionViewCell.cellIdentifier)

        let collectionViewFlowLayout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout
        collectionViewFlowLayout?.itemSize = CGSize(width: Screen.resolution.width, height: self.frame.size.height)
        collectionViewFlowLayout?.minimumInteritemSpacing = 20.0
        collectionViewFlowLayout?.minimumLineSpacing = 0.0
        collectionViewFlowLayout?.sectionInset = UIEdgeInsets.zero
        updatePageController()
    }
    
    func updateExpensesGraph(withData data: ExpensesGraphViewModel) {
        self.data = data
        self.discreteMode = data.isDiscreteMode
        self.collectionView.reloadData()
    }
        
    func updateCurrentBalanceGraph(data: CurrentBalanceGraphData) {
        self.currentBalanceData = data
        self.discreteMode = data.discreteModeActivated
        self.collectionView.reloadData()
    }
    
    private func setupPageControl() {
        pageControl.isHidden = true
        pageControl.hidesForSinglePage = true
        pageControl.currentPage = 0
        pageControl.currentPageIndicatorTintColor = .mediumSkyGray
        pageControl.pageIndicatorTintColor = .white
        if #available(iOS 14.0, *) {
            pageControl.backgroundStyle = .minimal
        }
    }
 
    fileprivate func updatePageController() {
        pageControl.numberOfPages = 2
        pageControl.setNeedsDisplay()
        pageControl.isHidden = true
    }
}

// MARK: - UICollectionViewDataSource
extension ExpensesContainerView: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        var cell: UICollectionViewCell = UICollectionViewCell()
        
        switch indexPath.row {
        case 0:
            guard let expensesGraph = collectionView.dequeueReusableCell(withReuseIdentifier: SmartExpensesLinearGraphCollectionViewCell.cellIdentifier, for: indexPath) as? SmartExpensesLinearGraphCollectionViewCell else {
                return cell
            }
            if let validData = data {
                expensesGraph.configure(with: validData)
            } else {
                expensesGraph.startLoading()
            }
            expensesGraph.graphViewPortDelegate = delegate
            expensesGraph.setDiscreteMode(self.discreteMode)
            if let validData = currentBalanceData {
                expensesGraph.setup(data: validData)
            }
            cell = expensesGraph
            
        case 1:
            guard let crossLinearGraph = collectionView.dequeueReusableCell(withReuseIdentifier: SmartExpensesCrossLinearGraphCollectionViewCell.cellIdentifier, for: indexPath) as? SmartExpensesCrossLinearGraphCollectionViewCell else {
                return cell
            }
            crossLinearGraph.setDiscreteMode(self.discreteMode)
            if let validData = currentBalanceData {
                crossLinearGraph.setup(data: validData)
            }
            cell = crossLinearGraph
        default:
            break
        }
        
        return cell
    }

}
