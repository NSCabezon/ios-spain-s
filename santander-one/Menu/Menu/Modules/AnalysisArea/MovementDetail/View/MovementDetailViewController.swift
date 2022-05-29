//
//  MovementDetailViewController.swift
//  Menu
//
//  Created by Boris Chirino Fernandez on 24/06/2020.
//

import UI
import CoreFoundationLib

protocol MovementDetailViewControllerViewProtocol: AnyObject {
    func updateViewModel(_ viewModel: MovementDetailViewModel, selectedIndex: Int)
}

class MovementDetailViewController: UIViewController {
    @IBOutlet weak private var collectionView: UICollectionView!
    
    private let presenter: MovementDetailPresenterProtocol
    private var viewModel: MovementDetailViewModel?
    init(presenter: MovementDetailPresenterProtocol) {
        self.presenter = presenter
        super.init(nibName: "MovementDetailViewController", bundle: Bundle.module)
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.commonInit()
        presenter.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.configureNavigationBar()
    }
}

extension MovementDetailViewController: MovementDetailViewControllerViewProtocol {
    func updateViewModel(_ viewModel: MovementDetailViewModel, selectedIndex: Int) {
        self.viewModel = viewModel
        perform(#selector(scrollToRow(_:)), with: NSNumber(value: selectedIndex), afterDelay: 0.2)
    }
}

private extension MovementDetailViewController {
    @objc func scrollToRow(_ rowNumber: NSNumber) {
        guard rowNumber.intValue <= collectionView.numberOfItems(inSection: 0) else {
            return
        }
        self.collectionView.scrollToItem(at: IndexPath(row: rowNumber.intValue, section: 0), at: .centeredHorizontally, animated: false)
    }
    
    private var getProportionalItemSizeWidth: CGFloat {
        UIScreen.main.bounds.size.width * 0.80
    }
        
    func commonInit() {
        configureCollectionView()
        self.view.backgroundColor = .skyGray
    }
    
    func configureNavigationBar() {
        NavigationBarBuilder(style: .sky,
                             title: .title(key: "toolbar_title_moveDetail"))
            .setLeftAction(.back(action: #selector(dismissSelected)))
            .setRightActions(.menu(action: #selector(menuSelected)))
            .build(on: self, with: self.presenter)
    }

    func configureCollectionView() {
        registerCell()
        collectionView.backgroundColor = .clear
        collectionView.dataSource = self
        collectionView.showsHorizontalScrollIndicator = false
        let layout = ZoomAndSnapFlowLayout()
        let itemWidth = getProportionalItemSizeWidth
        layout.setItemSize(CGSize(width: itemWidth, height: 230.0))
        layout.setMinimumLineSpacing(16)
        layout.setZoom(0)
        layout.sectionInset = UIEdgeInsets(top: 16, left: 0, bottom: 0, right: 0)
        self.collectionView.collectionViewLayout = layout
    }
    
    private func registerCell() {
        let nib = UINib(nibName: "AnalysisZoneMovementDetailCell", bundle: Bundle.module)
        self.collectionView.register(nib, forCellWithReuseIdentifier: AnalysisZoneMovementDetailCell.cellIdentifier)
    }
    
    @objc func menuSelected() {
        self.presenter.didSelectMenu()
    }
    
    @objc func dismissSelected() {
        self.presenter.didSelectDismiss()
    }
}

extension MovementDetailViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        viewModel?.movementsCount ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: AnalysisZoneMovementDetailCell.cellIdentifier, for: indexPath) as? AnalysisZoneMovementDetailCell, let item = viewModel?.itemAtIndexPath(indexPath) else {
            return UICollectionViewCell()
        }
        cell.configureCellWithEntity(item)
        return cell
    }
}
