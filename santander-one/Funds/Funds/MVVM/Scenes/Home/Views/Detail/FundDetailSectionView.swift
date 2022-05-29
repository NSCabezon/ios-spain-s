//
//  FundDetailSectionView.swift
//  Funds
//
//  Created by Ernesto Fernandez Calles on 10/3/22.
//

import Foundation
import OpenCombine
import CoreFoundationLib
import UI

protocol FundDetailSectionViewDelegate: AnyObject {
    func didTapOnShare(_ item: Shareable)
}

final class FundDetailSectionView: XibView {

    @IBOutlet private weak var separatorView: DottedLineView!
    @IBOutlet private weak var titleView: UIView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var stackView: UIStackView!

    weak var delegate: FundDetailSectionViewDelegate?

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupView()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setupView()
    }

    func setViewModel(_ viewModel: FundDetailSectionModel) {
        self.separatorView.isHidden = !viewModel.hasSeparator
        self.titleView.isHidden = viewModel.title?.isEmpty ?? true
        self.titleLabel.text = viewModel.title
        self.setupStackView(with: viewModel.infos)
    }
}

private extension FundDetailSectionView {

    func setupView() {
        titleLabel.font = .santander(family: .micro, type: .bold, size: 16)
    }

    func setupStackView(with infoModels: [FundDetailInfoModel]) {
        for info in infoModels {
            let infoView = FundDetailInfoView()
            stackView.addArrangedSubview(infoView)
            infoView.setViewModel(info)
            infoView.delegate = self
        }
    }
}

extension FundDetailSectionView: FundDetailInfoViewDelegate {
    func didTapOnShare(_ item: Shareable) {
        delegate?.didTapOnShare(item)
    }
}
