//
//  FractionatePaymentView.swift
//  Cards
//
//  Created by Boris Chirino Fernandez on 30/04/2020.
//

import UI
import CoreFoundationLib

protocol FractionatePaymentViewConformable: AnyObject {
    func didSelectMonthlyFee(_ montlyFee: MontlyPaymentFeeItem)
}

class OldFractionatePaymentView: UIDesignableView {
    @IBOutlet weak private var titleLabel: UILabel!
    @IBOutlet weak private var monthlyFeesCollectionView: UICollectionView?
    @IBOutlet weak private var footerLabel: UILabel!
    @IBOutlet weak private var topHorizontalLine: UIView!
    weak var delegate: FractionatePaymentViewConformable?
    private var viewModel: FractionatePaymentItem? {
        didSet {
            self.updateFooterWithText(viewModel?.minAmount ?? 0)
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
    
    func setViewModel(_ viewModel: FractionatePaymentItem) {
        self.viewModel = viewModel
    }
}

private extension OldFractionatePaymentView {
    var collectionLayout: UICollectionViewFlowLayout {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 130.0, height: 66.0)
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 10
        return layout
    }
    
    func setupView() {
        let nib = UINib(nibName: "FractionatePaymentCell", bundle: Bundle.module)
        self.monthlyFeesCollectionView?.register(nib, forCellWithReuseIdentifier: OldFractionatePaymentCell.cellIdentifier)
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
        let showNoInterestText = self.viewModel?.isAllInOneCard ?? false
        let mainText = showNoInterestText ? "easyPay_label_dividePayNoCommissions" : "easyPay_label_dividePay"
        let footerText = localized(mainText, [StringPlaceholder(.value, "\(text)")])
        self.footerLabel.set(localizedStylableText: footerText)
    }
}

extension OldFractionatePaymentView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        viewModel?.fractionsQuantity ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: OldFractionatePaymentCell.cellIdentifier, for: indexPath) as? OldFractionatePaymentCell
        guard let item = self.viewModel?.textInformationAtIndex(indexPath.row), let optionalCell = cell else {
            return OldFractionatePaymentCell()
        }
        let accessibilityId = isLastCellForIndexPath(indexPath) ? "btnOtherPaymentTerm" : "btnPaymentTerm"
        let showNoInterestText = self.viewModel?.showNoInterestText ?? false
        let showFirstCellBottomLabel = indexPath.row == 0 && showNoInterestText
        optionalCell.configureCellWithTitle(item.title,
                                            subtitle: item.subtitle,
                                            accessibilityId: accessibilityId,
                                            noInterestHidden: showFirstCellBottomLabel)
        return optionalCell
    }
}

extension OldFractionatePaymentView: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let montlyPayment = self.viewModel?.montlyPaymentAtIndex(indexPath.row) {
            delegate?.didSelectMonthlyFee(montlyPayment)
        }
    }
    func isLastCellForIndexPath(_ indexPath: IndexPath) -> Bool {
        self.viewModel?.fractionsQuantity == indexPath.row + 1
    }
}
