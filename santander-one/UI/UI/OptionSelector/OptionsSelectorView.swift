//
//  OptionsSelectorView.swift
//  UI
//
//  Created by Boris Chirino Fernandez on 26/05/2020.
//

import CoreFoundationLib

public struct OptionsSelectorViewItems {
    public let title: String
    public let subtitle: String
    
    public init(title: String, subtitle: String) {
        self.title = title
        self.subtitle = subtitle
    }
}

public protocol OptionsSelectorViewDelegate: AnyObject {
    func didSelectItem(_ item: OptionsSelectorViewItems)
}

public class OptionsSelectorView: UIDesignableView, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    @IBOutlet weak private var collectionView: UICollectionView!
    @IBOutlet weak private var bottomSeparator: UIView!
    private var items: [OptionsSelectorViewItems] = [OptionsSelectorViewItems]()
    private var subtitleEnabled: Bool = true
    private var selectedCode: String = ""
    weak public var delegate: OptionsSelectorViewDelegate?
 
    override public func commonInit() {
        super.commonInit()
        setupView()
    }
        
    public func setItems(_ items: [OptionsSelectorViewItems], showSubtitle: Bool = true, selectedCode: String) {
        self.subtitleEnabled = showSubtitle
        self.items.removeAll()
        self.items.append(contentsOf: items)
        self.collectionView.reloadData()
        self.selectedCode = selectedCode
    }
}

private extension OptionsSelectorView {
    var collectionLayout: UICollectionViewFlowLayout {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 104.0, height: 64.0)
        layout.minimumInteritemSpacing = 8
        layout.minimumLineSpacing = 8
        layout.scrollDirection = .vertical
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 8, right: 0)
        return layout
    }
    
    func setupView() {
        let nib = UINib(nibName: "LisboaCollectionSelectCell", bundle: Bundle.module)
        self.collectionView.register(nib, forCellWithReuseIdentifier: LisboaCollectionSelectCell.reuseID)
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
        self.collectionView.collectionViewLayout = self.collectionLayout
        self.collectionView.contentInset = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8)
        self.collectionView.isScrollEnabled = false
        self.backgroundColor = .white
        self.bottomSeparator.backgroundColor = .mediumSkyGray
    }
    
    var defaultSelectedIndexPath: IndexPath? {
        if let tobeSelectedItemIndex = self.items.firstIndex(where: {$0.subtitle == self.selectedCode}) {
            return IndexPath(row: tobeSelectedItemIndex, section: 0)
        }
        return nil
    }
}

extension OptionsSelectorView {
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        items.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: LisboaCollectionSelectCell.reuseID, for: indexPath) as? LisboaCollectionSelectCell
        guard let optionalCell = cell else {
            return LisboaCollectionSelectCell()
        }
        let item = items[indexPath.row]
        optionalCell.configureCellWithTitle(item.title, subtitle: item.subtitle, showSubtitle: subtitleEnabled)
        optionalCell.accessibilityIdentifier = subtitleEnabled ? AccessibilityTransfers.btnCurrency.rawValue : AccessibilityTransfers.btnCountry.rawValue
        return optionalCell
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        guard let flowLayout = collectionViewLayout as? UICollectionViewFlowLayout else { return CGSize() }
        let numberOfItem: CGFloat = 3
        let collectionViewWidth = self.collectionView.bounds.width
        let extraSpace = (numberOfItem - 1) * flowLayout.minimumInteritemSpacing
        let inset = self.collectionView.contentInset.right + self.collectionView.contentInset.left
        let width = (collectionViewWidth - extraSpace - inset) / numberOfItem
        return CGSize(width: width, height: 64.0)
    }
}

extension OptionsSelectorView {
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let item = items[indexPath.row]
        delegate?.didSelectItem(item)
        if let cell = collectionView.cellForItem(at: indexPath) as? LisboaCollectionSelectCell {
            cell.selectedState()
        }
    }
    
    public func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        if let cell = collectionView.cellForItem(at: indexPath) as? LisboaCollectionSelectCell {
            cell.unselectedState()
        }
    }
    
    public func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if indexPath == defaultSelectedIndexPath {
            (cell as? LisboaCollectionSelectCell)?.selectedState()
        }
    }
}
