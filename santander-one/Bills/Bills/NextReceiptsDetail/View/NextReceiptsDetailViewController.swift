//
//  NextReceiptsDetailViewController.swift
//  Bills
//
//  Created by alvola on 03/06/2020.
//

import UI
import CoreFoundationLib

protocol NextReceiptsDetailViewProtocol: AnyObject {
    var presenter: NextReceiptsDetailPresenterProtocol { get }
    func showNextReceipts(_ viewModels: [FutureBillDetailViewModel], withSelectedIndex index: Int)
}

final class NextReceiptsDetailViewController: UIViewController {
    
    @IBOutlet private weak var nextReceiptsCollectionView: UICollectionView!
    @IBOutlet private weak var authorizeButton: ActionButton!
    @IBOutlet private weak var rejectButton: ActionButton!
    @IBOutlet private weak var bottomBackgroungView: UIView!
    @IBOutlet private weak var relatedReceiptsLabel: UILabel!
    @IBOutlet private weak var collectionViewHeightConstraint: NSLayoutConstraint!
    
    private var layout = ZoomAndSnapFlowLayout()
    
    internal var presenter: NextReceiptsDetailPresenterProtocol
    
    private let mainCollectionCellIdentifier = "ReceiptCollectionViewCell"
    private var viewModels: [FutureBillDetailViewModel] = []
    
    init(presenter: NextReceiptsDetailPresenterProtocol) {
        self.presenter = presenter
        super.init(nibName: "NextReceiptsDetailViewController", bundle: Bundle.module)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        commonInit()
        presenter.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureNavigationBar()
    }
}

private extension NextReceiptsDetailViewController {
    
    func commonInit() {
        configureView()
        configureCollectionView()
        configureActionButtons()
        configureBottomView()
        configureAccessibilityIds()
    }
    
    func configureNavigationBar() {
        let builder = NavigationBarBuilder(style: .sky,
                                           title: .title(key: "toolbar_title_detailReceipt"))
            .setRightActions(.menu(action: #selector(didSelectDrawer)))
            .setLeftAction(.back(action: #selector(didSelectBack)))
        builder.build(on: self, with: self.presenter)
    }
    
    func configureView() {
        view.backgroundColor = .skyGray
        bottomBackgroungView.backgroundColor = .blueAnthracita
        bottomBackgroungView.isHidden = true
    }
    
    func configureCollectionView() {
        nextReceiptsCollectionView.delegate = self
        nextReceiptsCollectionView.dataSource = self
        nextReceiptsCollectionView.showsHorizontalScrollIndicator = false
        addLayout()
        registerCell()
    }
    
    func addLayout() {
        layout.itemSize = CGSize(width: UIScreen.main.bounds.size.width * 0.80,
                                          height: 196.0)
        layout.setMinimumLineSpacing(16)
        layout.setZoom(0)
        nextReceiptsCollectionView.collectionViewLayout = layout
    }
    
    func updateCollectionHeight(_ indexPath: IndexPath) {
        guard let indexPath = self.layout.indexPathForCenterRect() else { return }
        let cell = self.nextReceiptsCollectionView.cellForItem(at: indexPath)
        
        let newHeight = cell?.systemLayoutSizeFitting(layout.estimatedItemSize).height ?? 196.0
        if self.collectionViewHeightConstraint.constant != newHeight {
            self.collectionViewHeightConstraint.constant = cell?.systemLayoutSizeFitting(layout.estimatedItemSize).height ?? 196.0
            self.nextReceiptsCollectionView.collectionViewLayout.invalidateLayout()
            self.nextReceiptsCollectionView.layoutIfNeeded()
        }
    }
    
    func registerCell() {
        nextReceiptsCollectionView.register(UINib(nibName: mainCollectionCellIdentifier,
                                                  bundle: Bundle.module),
                                            forCellWithReuseIdentifier: mainCollectionCellIdentifier)
    }
    
    func configureActionButtons() {
        authorizeButton.setViewModel(NextReceiptsDetailActionButtonViewModel(
            viewType: .defaultButton(DefaultActionButtonViewModel(
                title: localized("detailReceipt_button_authorizeReceipt"),
                imageKey: "icnAuthorizeReceipt",
                titleAccessibilityIdentifier: "",
                imageAccessibilityIdentifier: "icnAuthorizeReceipt"))
            )
        )
        authorizeButton.addSelectorAction(target: self, #selector(didPressAuthorizeButton))
        authorizeButton.drawShadow(offset: (x: 1, y: 1),
                                   opacity: 0.3,
                                   color: .skyGray,
                                   radius: 2.0)
        authorizeButton.isHidden = true
        
        rejectButton.setViewModel(NextReceiptsDetailActionButtonViewModel(
            viewType: .defaultButton(DefaultActionButtonViewModel(
                title: localized("detailReceipt_button_rejectReceipt"),
                imageKey: "icnCancelReceipt",
                titleAccessibilityIdentifier: "",
                imageAccessibilityIdentifier: "icnCancelReceipt"))
            )
        )
        rejectButton.addSelectorAction(target: self, #selector(didPressRejectButton))
        rejectButton.drawShadow(offset: (x: 1, y: 1),
                                opacity: 0.3,
                                color: .skyGray,
                                radius: 2.0)
        rejectButton.isHidden = true
    }
    
    func configureBottomView() {
        relatedReceiptsLabel.font = UIFont.santander(type: .bold, size: 15.0)
        relatedReceiptsLabel.textColor = .white
        relatedReceiptsLabel.text = localized("detailReceipt_title_related")   
    }
    
    func configureAccessibilityIds() {
        authorizeButton.accessibilityIdentifier = "btnAutorizeReceipt"
        rejectButton.accessibilityIdentifier = "btnRejectReceipt"
        bottomBackgroungView.accessibilityIdentifier = "areaRelatedReceipts"
    }
    
    func reloadCollectionViewData(_ completion: @escaping () -> Void) {
        nextReceiptsCollectionView.reloadData()
        DispatchQueue.main.async(execute: completion)
    }
    
    @objc func didSelectBack() {
        presenter.didSelectBack()
    }
    
    @objc func didSelectDrawer() {
        presenter.didSelectDrawer()
    }
    
    @objc func didPressAuthorizeButton() {
        Toast.show("Próximamente")
    }
    
    @objc func didPressRejectButton() {
        Toast.show("Próximamente")
    }
}

extension NextReceiptsDetailViewController: NextReceiptsDetailViewProtocol {
    func showNextReceipts(_ viewModels: [FutureBillDetailViewModel], withSelectedIndex index: Int) {
        self.viewModels = viewModels
        self.reloadCollectionViewData {
            self.nextReceiptsCollectionView.scrollToItem(at: IndexPath(row: index, section: 0), at: .centeredHorizontally, animated: false)
        }
    }
}

extension NextReceiptsDetailViewController: RootMenuController {
    public var isSideMenuAvailable: Bool { true }
}

extension NextReceiptsDetailViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let indexPath = self.layout.indexPathForCenterRect() else { return }
        let viewModel = self.viewModels[indexPath.item]
        self.presenter.didSelectFutureBillViewModel(viewModel)
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        guard let indexPath = self.layout.indexPathForCenterRect() else { return }
        self.updateCollectionHeight(indexPath)
        self.presenter.didFocusOnBillIndex(indexPath.row)
    }
}

extension NextReceiptsDetailViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: UIScreen.main.bounds.size.width * 0.80,
                      height: collectionView.frame.height)
    }
}

extension NextReceiptsDetailViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.viewModels.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: mainCollectionCellIdentifier,
                                                      for: indexPath) as? ReceiptCollectionViewCell
        cell?.setInfo(self.viewModels[indexPath.row])
        
        if let indexPath = self.layout.indexPathForCenterRect() {
            self.updateCollectionHeight(indexPath)
            cell?.layoutIfNeeded()
        }
        
        return cell ?? UICollectionViewCell()
    }
}
