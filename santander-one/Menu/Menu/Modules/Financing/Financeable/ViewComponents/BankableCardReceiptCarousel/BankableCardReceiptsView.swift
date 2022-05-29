//
//  BankableCardReceiptsView.swift
//  Menu
//
//  Created by Sergio Escalante Ordoñez on 13/1/22.
//

import UIKit
import UI

protocol BankableCardReceiptsViewDelegate: AnyObject {
    func didSelectReceiptCard(_ viewModel: BankableCardReceiptViewModel)
}

final class BankableCardReceiptsView: XibView {
    
    // MARK: IBOutlets
    
    @IBOutlet private weak var headerLabel: UILabel!
    @IBOutlet private weak var cardCollectionView: BankableCardReceiptsCollectionView!
    @IBOutlet private weak var loadingImageView: UIImageView!
    
    private let emptyView = FinanceableEmptyView()
    
    // MARK: Variables
    
    weak var delegate: BankableCardReceiptsViewDelegate?
    
    // MARK: Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    func configView(_ viewModels: [BankableCardReceiptViewModel],
                    with delegate: BankableCardReceiptsViewDelegate) {
        self.delegate = delegate
        loadingImageView.isHidden = true
        loadingImageView.stopAnimating()
        setupHeaderLabel()
        if viewModels.count > 0 {
            cardCollectionView.setCollectionViewData(viewModels)
            reloadCollectionData()
        } else {
            setupEmptyView()
        }
    }
}

private extension BankableCardReceiptsView {
    
    func setupEmptyView() {
        view?.addSubview(emptyView)
        emptyView.translatesAutoresizingMaskIntoConstraints = false
        emptyView.leftAnchor.constraint(equalTo: leftAnchor, constant: 16.0).isActive = true
        rightAnchor.constraint(equalTo: emptyView.rightAnchor, constant: 16.0).isActive = true
        emptyView.topAnchor.constraint(equalTo: headerLabel.bottomAnchor, constant: 12.0).isActive = true
        bottomAnchor.constraint(equalTo: emptyView.bottomAnchor, constant: 0.0).isActive = true
        emptyView.setDescriptionLabelHidden()
    }
    
    func setupView() {
        setupHeaderLabel()
        setupCollectionView()
        setupLoadingView()
    }
    
    func setupHeaderLabel() {
        let font: UIFont = .santander(family: .headline, type: .regular, size: 18)
        let configuration = LocalizedStylableTextConfiguration(font: font)
        headerLabel.textColor = .lisboaGray
        headerLabel.configureText(withKey: "financing_label_nextBill",
                                  andConfiguration: configuration)
    }
    
    func setupLoadingView() {
        loadingImageView.setPointsLoader()
        loadingImageView.startAnimating()
    }
    
    func setupCollectionView() {
        cardCollectionView.setDelegate(delegate: self)
    }
    
    func reloadCollectionData() {
        self.cardCollectionView.reloadData()
    }
}

// MARK: BankableCardReceiptsCollectionViewDelegate

extension BankableCardReceiptsView: BankableCardReceiptsCollectionDataSourceDelegate {
    func didSelectCell(_ viewModel: BankableCardReceiptViewModel) {
        delegate?.didSelectReceiptCard(viewModel)
    }
}
