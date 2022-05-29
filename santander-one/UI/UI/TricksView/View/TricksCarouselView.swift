//
//  TricksCarouselView.swift
//  UI
//
//  Created by Carlos Monfort Gómez on 09/07/2020.
//

import Foundation
import CoreFoundationLib

public final class TricksCarouselView: XibView {
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var tricksCollectionView: UICollectionView!
    
    private var collectionViewController: TricksCollectionViewController?

    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.setAppearance()
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setAppearance()
    }
    
    public func setTitle(_ localizedKey: String) {
        self.titleLabel.configureText(withLocalizedString: localized(localizedKey))
        self.titleLabel.accessibilityIdentifier = localizedKey
    }
    
    public func setTipsViewModels(_ viewModels: [TrickViewModel]) {
        self.collectionViewController?.setViewModels(viewModels)
    }
    
    public func scrollToIndex(_ index: Int, animated: Bool = true) {
        self.tricksCollectionView.layoutIfNeeded()
        self.tricksCollectionView.scrollToItem(at: IndexPath(row: index, section: 0), at: .centeredHorizontally, animated: animated)
    }
    
    public func setControllerDelegate(_ delegate: TricksCollectionViewControllerDelegate?) {
        self.collectionViewController?.controllerDelegate = delegate
    }

    public func setCollectionViewDelegate(_ delegate: TricksCollectionViewDelegate?) {
        self.collectionViewController?.collectionViewDelegate = delegate
    }
}

private extension TricksCarouselView {
    
    func setAppearance() {
        self.view?.backgroundColor = .blueAnthracita
        self.setCollectionView()
        self.setLabel()
    }
    
    func setCollectionView() {
        self.collectionViewController = TricksCollectionViewController(collectionView: self.tricksCollectionView)
        self.tricksCollectionView?.backgroundColor = .clear
        self.tricksCollectionView.accessibilityIdentifier = "areaFooter"
    }
    
    func setLabel() {
        self.titleLabel.textColor = .white
        self.titleLabel.font = .santander(family: .text, size: 18.0)
    }
}
