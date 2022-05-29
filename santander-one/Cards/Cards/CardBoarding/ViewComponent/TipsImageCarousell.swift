//
//  ImageOffersCarousell.swift
//  Cards
//
//  Created by Boris Chirino Fernandez on 19/10/2020.
//

import UI
import CoreFoundationLib

protocol TipsImageCarrouselDelegate: AnyObject {
    func didSelectTip(_ tip: OfferTipViewModel)
}

final class TipsImageCarousell: UIDesignableView {
    @IBOutlet weak private var collectionView: UICollectionView!
    weak var delegate: TipsImageCarrouselDelegate?
    
    private var tips: [OfferTipViewModel]? {
        didSet {
            self.collectionView.reloadData()
        }
    }
    
    override func getBundleName() -> String {
        "Cards"
    }
    
    override func commonInit() {
        super.commonInit()
        self.setupCollectionView()
    }
    
    func setTips(_ tipsViewModel: [OfferTipViewModel]) {
        self.tips = tipsViewModel
    }
}

// MARK: - UICollectionViewDataSource
extension TipsImageCarousell: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        tips?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CardBoardingTipCell.identifier, for: indexPath) as? CardBoardingTipCell
        guard let model = self.tips?[indexPath.row], let optionalCell = cell else {
            return CardBoardingTipCell()
        }
        optionalCell.configureCellWithModel(model)
        optionalCell.setAccesibilityIdentifier(index: indexPath.row)
        return optionalCell
    }
}

// MARK: - UICollectionViewDelegate
extension TipsImageCarousell: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let selectedTip = self.tips?[indexPath.row] {
            self.delegate?.didSelectTip(selectedTip)
        }
    }
}

// MARK: - private
private extension TipsImageCarousell {
    func setupCollectionView() {
        let nib = UINib(nibName: CardBoardingTipCell.identifier, bundle: .module)
        self.collectionView.register(nib, forCellWithReuseIdentifier: CardBoardingTipCell.identifier)
        self.collectionView.backgroundColor = .clear
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
        self.collectionView.backgroundColor = .clear
        self.collectionView.showsVerticalScrollIndicator = false
        self.collectionView.showsHorizontalScrollIndicator = false
        self.collectionView.contentInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        self.setCollectionViewFlowLayout()
        self.collectionView.accessibilityIdentifier = AccesibilityCardsCardBoardingActivation.offersCollectionViewActivateCard
    }
    
    func setCollectionViewFlowLayout() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: 192, height: 152)
        layout.minimumInteritemSpacing = 8
        layout.minimumLineSpacing = 8
        self.collectionView.setCollectionViewLayout(layout, animated: false)
    }
}
