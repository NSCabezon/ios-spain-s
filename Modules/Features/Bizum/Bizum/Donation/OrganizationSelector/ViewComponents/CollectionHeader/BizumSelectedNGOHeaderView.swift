//
//  BizumSelectedNGOHeaderView.swift
//  Bizum

import Foundation
import UI
import CoreFoundationLib

protocol BizumSelectedNGOHeaderViewDelegate: class {
    func didSelectNGOViewModel(_ viewModel: BizumNGOCollectionViewCellViewModel)
}

final class BizumSelectedNGOHeaderView: XibView {
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet private weak var separatorView: UIView!
    @IBOutlet private weak var bizumSelectedNgoCollectionView: BizumSelectedNGOCollectionView!
    private let emptyView = BizumSelectedNGOEmptyView()
    
    weak var delegate: BizumSelectedNGOHeaderViewDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupView()
    }
    
    func setViewModels(_ viewModels: [BizumNGOCollectionViewCellViewModel]) {
        if !viewModels.isEmpty {
            self.bizumSelectedNgoCollectionView.setCollectionViewData(viewModels)
        } else {
            self.bizumSelectedNgoCollectionView.isHidden = true
            self.stackView.addArrangedSubview(self.emptyView)
            self.setNeedsLayout()
        }
    }
}

private extension BizumSelectedNGOHeaderView {
    func setupView() {
        self.setTitleLabel()
        self.setViews()
        self.setCollectionView()
    }
    
    func setViews() {
        self.view?.backgroundColor = .lightSky
        self.separatorView.backgroundColor = .mediumSkyGray
    }
    
    func setTitleLabel() {
        let textConfiguration = LocalizedStylableTextConfiguration(font: .santander(size: 22))
        self.titleLabel.configureText(withLocalizedString: localized("bizum_title_toWho"),
                            andConfiguration: textConfiguration)
        self.titleLabel.textColor = .lisboaGray
    }
    
    func setCollectionView() {
        self.bizumSelectedNgoCollectionView.backgroundColor = .clear
        self.bizumSelectedNgoCollectionView.setDelegate(delegate: self)
        self.bizumSelectedNgoCollectionView.accessibilityIdentifier = AccessibilityBizumDonation.selectedNgoCollectionView
    }
}

extension BizumSelectedNGOHeaderView: BizumSelectedNGOCollectionDataSourceDelegate {
    func didSelectBizumSelectedNGO(_ viewModel: BizumNGOCollectionViewCellViewModel) {
        self.delegate?.didSelectNGOViewModel(viewModel)
    }
}
