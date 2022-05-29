//
//  FundDetailView.swift
//  Funds
//
//  Created by Ernesto Fernandez Calles on 9/3/22.
//

import CoreFoundationLib
import OpenCombine
import UI

protocol FundDetailViewDelegate: AnyObject {
    func didTapOnShare(_ shareable: Shareable)
}

final class FundDetailView: XibView {
    @IBOutlet private weak var stackView: UIStackView!

    weak var delegate: FundDetailViewDelegate?

    private var anySubscriptions: Set<AnyCancellable> = []
    let detailSubject = PassthroughSubject<Fund, Never>()
    let detailIsLoadingSubject = PassthroughSubject<Bool, Never>()
    var fund: Fund?

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupView()
        self.bind()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupView()
        self.bind()
    }
}

private extension FundDetailView {
    func setupView() {
    }

    func bind() {
        self.detailSubject
            .sink { [unowned self] fund in
                self.setupSections(fund)
            }.store(in: &self.anySubscriptions)
        self.detailIsLoadingSubject
            .sink { [unowned self] isLoading in
                if isLoading {
                    self.addLoadingView()
                }
            }.store(in: &self.anySubscriptions)
    }

    func setupSections(_ fund: Fund?) {
        guard let fund = fund else {
            addEmptyList()
            return
        }
        let detailViewModel = FundDetailModel(fund: fund.fundRepresentable,
                                              detail: fund.fundDetailRepresentable,
                                              modifier: fund.fundsDetailFieldsModifier)
        guard detailViewModel.sections.isNotEmpty else {
            addEmptyList()
            return
        }
        addSections(detailViewModel.sections)
    }

    func addSections(_ sections: [FundDetailSectionModel]) {
        emptyStack()
        for section in sections {
            let sectionView = FundDetailSectionView()
            stackView.addArrangedSubview(sectionView)
            sectionView.setViewModel(section)
            sectionView.delegate = self
        }
    }

    func addEmptyList() {
        emptyStack()
        let emptyListView = FundSectionEmptyView()
        stackView.addArrangedSubview(emptyListView)
    }

    func addLoadingView() {
        emptyStack()
        let loadingView = FundSectionLoadingView()
        stackView.addArrangedSubview(loadingView)
    }

    func emptyStack() {
        stackView.arrangedSubviews.forEach {  removeView($0) }
    }

    func removeView(_ view: UIView) {
        stackView.removeArrangedSubview(view)
        view.removeFromSuperview()
    }
}

extension FundDetailView: FundDetailSectionViewDelegate {
    func didTapOnShare(_ item: Shareable) {
        delegate?.didTapOnShare(item)
    }
}
