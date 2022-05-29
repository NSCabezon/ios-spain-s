//
//  CompressedLoansHeaderView.swift
//  Loans
//
//  Created by Juan Carlos López Robles on 10/11/19.
//
import UI
import Foundation
import CoreFoundationLib
import OpenCombine

final class CompressedLoansHeaderView: XibView {
    @IBOutlet private weak var loanAliasLabel: UILabel!
    @IBOutlet private weak var loanAmountLabel: UILabel!
    @IBOutlet private weak var filterButton: UIButton!
    @IBOutlet private weak var filterLabel: UILabel!
    private var loan: Loan?
    private var anySubscriptions = Set<AnyCancellable>()
    let selectLoanSubject = PassthroughSubject<Loan, Never>()
    let didSelectFilter = PassthroughSubject<Loan, Never>()
    let hideFilterSubject = PassthroughSubject<Bool, Never>()
    var isFilterDisabled = true

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        bind()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
        bind()
    }
}

private extension CompressedLoansHeaderView {
    func setupView() {
        self.view?.backgroundColor = .skyGray
        self.loanAliasLabel.font = .santander(family: .text, type: .bold, size: 16)
        self.loanAliasLabel.textColor = .lisboaGray
        self.loanAmountLabel.font = .santander(family: .text, type: .regular, size: 14)
        self.loanAmountLabel.textColor = .lisboaGray
        self.filterButton.setImage(Assets.image(named: "icnFilter"), for: .normal)
        self.filterButton.tintColor = .darkTorquoise
        self.filterLabel.text = localized("generic_button_filters")
        self.filterLabel.font = .santander(family: .text, type: .regular, size: 12)
        self.filterLabel.textColor = UIColor.darkTorquoise
        self.filterButton.accessibilityIdentifier = "icn_filter"
        self.filterButton.isHidden = true
        self.filterLabel.isHidden = true
        self.loanAliasLabel.accessibilityIdentifier = AccessibilityIDLoansHome.scrollTopAlias.rawValue
        self.loanAmountLabel.accessibilityIdentifier = AccessibilityIDLoansHome.scrollTopAmount.rawValue
    }
    
    func bind() {
        selectLoanSubject
            .sink { [unowned self] loan in
                self.loan = loan
                self.loanAliasLabel.text = loan.alias
                self.loanAmountLabel.text = loan.amount
                self.hideFilterSubject.send(true)
            }.store(in: &anySubscriptions)
        
        hideFilterSubject
            .filter {[unowned self] _ in
                !self.isFilterDisabled
            }.sink {[unowned self] hide in
                self.filterButton.isHidden = hide
                self.filterLabel.isHidden = hide
            }.store(in: &anySubscriptions)
    }
    
    @IBAction func filterAction() {
        guard let loan = self.loan else { return }
        didSelectFilter.send(loan)
    }
}
