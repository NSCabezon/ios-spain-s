import CoreFoundationLib
import UIKit
import UI
import CoreDomain

protocol GPCustomizationViewProtocol: UIViewController, ChangedGPSectionProtocol {
    var presenter: GPCustomizationPresenterProtocol? { get }
    
    func isSameAsDefault(_ bool: Bool)
    func setModels(_ models: [[GPCustomizationProductViewModel]])
    func showComingSoon()
}

final class GPCustomizationViewController: UIViewController {
    private let cellWidth: CGFloat = UIScreen.main.bounds.width - 28
    private let productCellHeight: CGFloat = 56
    private let cellHeaderHeight: CGFloat = 40
    
    @IBOutlet private weak var collectionView: UICollectionView!
    @IBOutlet private weak var buttonsContainer: UIView!
    @IBOutlet private weak var buttonsStackView: UIStackView!
    @IBOutlet private weak var separatorView: UIView!
    @IBOutlet private weak var initialConfigurationButton: UIButton!
    @IBOutlet private weak var saveButton: WhiteLisboaButton!
    
    private var models: [[GPCustomizationProductViewModel]] = []
    private var sizes: [CGSize] = []
    let presenter: GPCustomizationPresenterProtocol?
    
    init(presenter: GPCustomizationPresenterProtocol) {
        self.presenter = presenter
        super.init(nibName: "GPCustomization", bundle: Bundle.module)
    }
    
    required init?(coder: NSCoder) {
        presenter = nil
        super.init(coder: coder)
    }
    
    override var prefersStatusBarHidden: Bool {
        return false
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        if #available(iOS 13.0, *) {
            return .darkContent
        } else {
            return .default
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureNavigationBar()
        setAccessibility()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
        configureButtons()
        configureCollectionView()
        presenter?.viewDidLoad()
    }
    
    private func configureNavigationBar() {
        let builder = NavigationBarBuilder(
            style: .white,
            title: .title(key: "toolbar_title_orderChangeName")
        )
        builder.setLeftAction(.back(action: #selector(didPressBack)))
        builder.setRightActions(.close(action: #selector(didPressClose)))
        builder.build(on: self, with: nil)
    }
    
    private func configureView() {
        buttonsContainer.backgroundColor = .white
        separatorView.backgroundColor = .mediumSkyGray
        view.applyGradientBackground(colors: [UIColor.white, UIColor.bg])
        let gesture = UITapGestureRecognizer(target: self, action: #selector(hideAllEditingFields))
        view.addGestureRecognizer(gesture)
    }
    
    private func configureButtons() {
        initialConfigurationButton.setTitleColor(.santanderRed, for: .normal)
        initialConfigurationButton.titleLabel?.font = UIFont.santander(family: .text, type: .regular, size: 15)
        initialConfigurationButton.titleLabel?.numberOfLines = 1
        initialConfigurationButton.titleLabel?.adjustsFontSizeToFitWidth = true
        initialConfigurationButton.titleLabel?.minimumScaleFactor = 0.2
        initialConfigurationButton.setTitle(localized("pgCustomize_button_initialSetting"), for: .normal)
        saveButton.setTitle(localized("generic_button_save"), for: .normal)
        saveButton.addSelectorAction(target: self, #selector(didPressSave))
    }
    
    private func configureCollectionView() {
        collectionView.backgroundColor = .clear
        let productNib = UINib(nibName: String(describing: GPCustomizationProductSectionCollectionViewCell.self), bundle: Bundle.module)
        collectionView.register(productNib, forCellWithReuseIdentifier: String(describing: GPCustomizationProductSectionCollectionViewCell.self))
        collectionView.register(GPCustomizationHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: String(describing: GPCustomizationHeaderView.self))
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.bounces = true
        collectionView.showsVerticalScrollIndicator = false
        collectionView.isScrollEnabled = true
        
        let flowLayout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout
        flowLayout?.itemSize = CGSize(width: cellWidth, height: 1.0)
        flowLayout?.scrollDirection = .vertical
        flowLayout?.minimumLineSpacing = 15.0
        flowLayout?.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 15, right: 0)
        
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongGesture))
        longPressGesture.minimumPressDuration = 0.5
        longPressGesture.delegate = self
        self.collectionView.addGestureRecognizer(longPressGesture)
    }
    
    @objc private func didPressBack() { presenter?.didPressBack(with: models) }
    @objc private func didPressClose() { presenter?.didPressClose(with: models) }
    @objc private func didPressSave() { self.presenter?.saveConfiguration(for: models) }
    
    @IBAction func didPressInitialConfigurationButton(_ sender: Any) {
        self.presenter?.returnToDefaultConfiguration()
    }
}

private extension GPCustomizationViewController {
    func setAccessibility() {
        self.navigationItem.titleView?.accessibilityIdentifier = "gpCustomization_title"
        self.saveButton.accessibilityIdentifier = "gpCustomization_save"
    }
}

extension GPCustomizationViewController: GPCustomizationViewProtocol {
    func setModels(_ models: [[GPCustomizationProductViewModel]]) {
        self.models = models
        for products in models {
            sizes.append(CGSize(width: cellWidth, height: productCellHeight * CGFloat(products.count) + cellHeaderHeight))
        }
        collectionView.reloadData()
    }
    
    func updateModel(_ info: [GPCustomizationProductViewModel]) {
        guard let productType = info.first?.productType,
              let productTypeIndex = models.firstIndex(where: { $0.first?.productType == productType }) else { return }
        models[productTypeIndex] = info
    }
    
    func trackMoved(_ info: GPCustomizationProductViewModel) {
        presenter?.didMoveProduct(info)
    }
    
    func trackChangedSwitch(_ info: GPCustomizationProductViewModel) {
        presenter?.didChangedSwitch(info)
    }
    
    func isSameAsDefault(_ bool: Bool) {
        self.initialConfigurationButton.isHidden = bool
    }
    
    @objc func hideAllEditingFields() {
        collectionView.visibleCells.compactMap({ $0 as? GPCustomizationProductSectionCollectionViewCell }).forEach { (cell) in
            cell.tableView.visibleCells.compactMap({ $0 as? GPCustomizationProductTableViewCell }).forEach { $0.disableEditingMode() }
        }
    }
    
    func didUpdateAlias(_ info: GPCustomizationProductViewModel) {
        presenter?.didUpdateAlias(info)
    }
    
    func showComingSoon() {
        Toast.show(localized("generic_alert_notAvailableOperation"))
    }
}

extension GPCustomizationViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return sizes[indexPath.item]
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return GPCustomizationHeaderView.calculateSize(withWidth: collectionView.frame.width)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return models.count
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind {
        case UICollectionView.elementKindSectionHeader:
            return collectionView.dequeueReusableSupplementaryView(
                ofKind: kind,
                withReuseIdentifier: String(describing: GPCustomizationHeaderView.self),
                for: indexPath
            )
        default:
            return UICollectionReusableView()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "GPCustomizationProductSectionCollectionViewCell", for: indexPath) as? GPCustomizationProductSectionCollectionViewCell else {
            return UICollectionViewCell()
        }
        let model = models[indexPath.row]
        cell.products = model
        cell.tableView.reloadData()
        cell.delegate = self
        if let productType = model.first?.productType {
            cell.productAliasConfiguration = presenter?.getProductAlias(for: productType)
        }
        cell.layoutIfNeeded()
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let temp = models.remove(at: sourceIndexPath.item)
        models.insert(temp, at: destinationIndexPath.item)
        self.collectionView.reloadData()
        presenter?.didMoveSection(temp)
    }
    
    func collectionView(_ collectionView: UICollectionView, canMoveItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func collectionView(_ collectionView: UICollectionView, targetIndexPathForMoveFromItemAt originalIndexPath: IndexPath, toProposedIndexPath proposedIndexPath: IndexPath) -> IndexPath {
        guard originalIndexPath != proposedIndexPath else { return originalIndexPath }
        let size = sizes.remove(at: originalIndexPath.item)
        sizes.insert(size, at: proposedIndexPath.item)
        return proposedIndexPath
    }
    
    // MARK: - Gesture recogniser
    @objc func handleLongGesture(gesture: UILongPressGestureRecognizer) {
        hideAllEditingFields()
        switch gesture.state {
        case .began:
            guard let selectedIndexPath = self.collectionView.indexPathForItem(at: gesture.location(in: self.collectionView)) else { break }
            self.collectionView.beginInteractiveMovementForItem(at: selectedIndexPath)
        case .changed:
            var point = gesture.location(in: self.collectionView)
            guard point.y >= 0 else { break }
            point.x = UIScreen.main.bounds.width / 2.0
            self.collectionView.updateInteractiveMovementTargetPosition(point)
        case .ended:
            self.collectionView.endInteractiveMovement()
        default:
            self.collectionView.cancelInteractiveMovement()
        }
    }
}

extension GPCustomizationViewController: UIGestureRecognizerDelegate {
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        guard let selectedIndexPath = self.collectionView.indexPathForItem(at: gestureRecognizer.location(in: self.collectionView)),
              let cell = collectionView.cellForItem(at: selectedIndexPath)
        else { return true }
        let gestureLocationOnCell = gestureRecognizer.location(in: cell)
        return gestureLocationOnCell.y <= cellHeaderHeight
    }
}
