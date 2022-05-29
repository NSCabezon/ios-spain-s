//
//  FractionatePaymentView.swift
//  Pods
//
//  Created by Hernán Villamil on 6/4/22.
//

import CoreFoundationLib
import OpenCombine
import UI

final class FractionatePaymentView: UIDesignableView {
    @IBOutlet weak private var titleLabel: UILabel!
    @IBOutlet weak private var monthlyFeesCollectionView: UICollectionView?
    @IBOutlet weak private var footerLabel: UILabel!
    @IBOutlet weak private var topHorizontalLine: UIView!
    let didSelectMonthlyFee = PassthroughSubject<MontlyPaymentFeeItem?, Never>()
    var item: FractionatePaymentItem? {
        didSet {
            self.updateFooterWithText(item?.minAmount ?? 0)
            self.monthlyFeesCollectionView?.reloadData()
        }
    }
    
    override func getBundleName() -> String {
        return "Cards"
    }
    
    override func commonInit() {
        super.commonInit()
        setupView()
    }

}

private extension FractionatePaymentView {
    var collectionLayout: UICollectionViewFlowLayout {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 130.0, height: 66.0)
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 10
        return layout
    }
    
    func setupView() {
        let nib = UINib(nibName: "FractionatePaymentCell", bundle: Bundle.module)
        self.monthlyFeesCollectionView?.register(nib, forCellWithReuseIdentifier: FractionatePaymentCell.cellIdentifier)
        self.monthlyFeesCollectionView?.dataSource = self
        self.monthlyFeesCollectionView?.delegate = self
        self.monthlyFeesCollectionView?.collectionViewLayout = self.collectionLayout
        self.monthlyFeesCollectionView?.contentInset = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 5)
        self.monthlyFeesCollectionView?.showsHorizontalScrollIndicator = false
        self.backgroundColor = .white
        self.topHorizontalLine.backgroundColor = .mediumSkyGray
        self.titleLabel.textColor = .lisboaGray
        self.titleLabel.accessibilityIdentifier = "transactios_title_fractionate"
        self.titleLabel.configureText(withKey: "transaction_title_fractionate",
                                      andConfiguration: LocalizedStylableTextConfiguration(font: .santander(family: .text, type: .bold, size: 15)))
        self.footerLabel.setSantanderTextFont(type: .regular, size: 13.0, color: .grafite)
        self.footerLabel.accessibilityIdentifier = "easyPay_label_dividePay"
    }
    
    func updateFooterWithText(_ text: Int) {
        let showNoInterestText = self.item?.isAllInOneCard ?? false
        let mainText = showNoInterestText ? "easyPay_label_dividePayNoCommissions" : "easyPay_label_dividePay"
        let footerText = localized(mainText, [StringPlaceholder(.value, "\(text)")])
        self.footerLabel.set(localizedStylableText: footerText)
    }
}

extension FractionatePaymentView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        item?.fractionsQuantity ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: FractionatePaymentCell.cellIdentifier, for: indexPath) as? FractionatePaymentCell
        guard let item = self.item?.textInformationAtIndex(indexPath.row), let optionalCell = cell else {
            return FractionatePaymentCell()
        }
        let accessibilityId = isLastCellForIndexPath(indexPath) ? "btnOtherPaymentTerm" : "btnPaymentTerm"
        let showNoInterestText = self.item?.showNoInterestText ?? false
        let showFirstCellBottomLabel = indexPath.row == 0 && showNoInterestText
        optionalCell.configuration = FractionatePaymentCellConfiguration(title: item.title,
                                                                         subtitle: item.subtitle,
                                                                         accessibilityId: accessibilityId,
                                                                         noInterestIsHidden: showFirstCellBottomLabel)
        return optionalCell
    }
}

extension FractionatePaymentView: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let montlhyPayment = self.item?.montlyPaymentAtIndex(indexPath.row) {
            didSelectMonthlyFee.send(montlhyPayment)
        }
    }
    func isLastCellForIndexPath(_ indexPath: IndexPath) -> Bool {
        self.item?.fractionsQuantity == indexPath.row + 1
    }
}
