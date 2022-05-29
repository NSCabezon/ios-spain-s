//
//  SavingTipsView.swift
//  Menu
//
//  Created by David Gálvez Alonso on 23/03/2020.
//

import UI
import CoreFoundationLib

final class SavingTipsView: UIDesignableView {
    
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var savingTipsCollectionView: UICollectionView!
    
    private var controller: SavingTipCollectionViewController?
    
    override func getBundleName() -> String { return "Menu" }

    override func commonInit() {
        super.commonInit()
        
        configureViews()
        configureLabel()
        configureCollectionView()
    }
    
    func setDelegate(_ delegate: SavingTipCollectionViewControllerDelegate?) {
        controller?.delegate = delegate
    }
    
    func setCollectionViewDelegate(_ delegate: SavingTipCollectionViewDelegate?) {
        controller?.collectionViewDelegate = delegate
    }
    
    func setSavingTips(_ savingTips: [SavingTipViewModel]) {
        controller?.setCellInfo(savingTips: savingTips)
    }
    
    func scrollToIndex(_ index: Int, animated: Bool = true) {
        savingTipsCollectionView.layoutIfNeeded()
        savingTipsCollectionView.scrollToItem(at: IndexPath(row: index, section: 0), at: .centeredHorizontally, animated: animated)
    }
}

// MARK: - Private methods

private extension SavingTipsView {
    
    func configureViews() {
        backgroundColor = .blueAnthracita
        savingTipsCollectionView.backgroundColor = .clear
    }
    
    func configureCollectionView() {
        controller = SavingTipCollectionViewController(collectionView: savingTipsCollectionView)
        savingTipsCollectionView?.backgroundColor = UIColor.clear
    }
    
    func configureLabel() {
        titleLabel.textColor = UIColor.white
        titleLabel.configureText(withKey: "analysis_title_tricks",
                                 andConfiguration: LocalizedStylableTextConfiguration(font: .santander(family: .text, size: 18.0)))
    }
}
