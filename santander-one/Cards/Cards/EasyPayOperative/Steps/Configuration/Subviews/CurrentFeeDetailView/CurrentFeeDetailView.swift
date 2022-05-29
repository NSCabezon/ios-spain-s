//
//  CurrentFeeDetailView.swift
//  Cards
//
//  Created by Luis Escámez Sánchez on 03/12/2020.
//

import UI
import CoreFoundationLib

public final class CurrentFeeDetailView: XibView {
    
    @IBOutlet private weak var headerView: UIView!
    @IBOutlet private weak var monthlyFeeTitleLabel: UILabel!
    @IBOutlet private weak var monthlyFeeAmountLabel: UILabel!
    @IBOutlet private weak var monthsTitleLabel: UILabel!
    @IBOutlet private weak var monthsAmountLabel: UILabel!
    @IBOutlet private weak var firstSeparatorView: UIView!
    @IBOutlet private weak var firstFeeInfoStackView: UIStackView!
    @IBOutlet private weak var secondSeparatorView: UIView!
    @IBOutlet private weak var totalAmountStackView: UIStackView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupView()
    }
    
    public func setViewInfo(with viewModel: CurrentFeeDetailViewModel) {
        resetStackViews()
        setHeaderInfo(from: viewModel)
        setFirstFeeStackViewInfo(from: viewModel)
        setTotalAmountStackViewInfo(from: viewModel)
    }
}

// MARK: - Private Methods
private extension CurrentFeeDetailView {
    
    func configureHeader() {
        self.headerView.backgroundColor = .whitesmokes
        [monthsTitleLabel, monthlyFeeTitleLabel]
            .forEach { $0?.font = UIFont.santander(family: .text, type: .regular, size: 14) }
        [monthlyFeeAmountLabel, monthsAmountLabel, monthlyFeeTitleLabel, monthsTitleLabel]
            .forEach { $0?.textColor = .lisboaGray }
    }
    
    func setupView() {
        configureHeader()
        [firstSeparatorView, secondSeparatorView].forEach { $0?.backgroundColor = .mediumSkyGray }
        [firstFeeInfoStackView, totalAmountStackView].forEach { $0?.spacing = 8 }
        self.roundView()
    }
    
    func roundView() {
        self.drawBorder(cornerRadius: 4, color: .darkTorquoise, width: 2)
    }
    
    func setMonthlyFeeInfo(monthlyFeeTitle: String, monthlyFeeAmount: NSAttributedString) {
        monthlyFeeTitleLabel.text = monthlyFeeTitle
        monthlyFeeAmountLabel.attributedText = monthlyFeeAmount
    }
    
    func setMonthsAmountInfo(totalMonthsTitle: String, totalMonthsAmount: LocalizedStylableText) {
        monthsTitleLabel.text = totalMonthsTitle
        monthsAmountLabel.configureText(withLocalizedString: totalMonthsAmount)
    }
    
    func setHeaderInfo(from viewModel: CurrentFeeDetailViewModel) {
        setMonthlyFeeInfo(monthlyFeeTitle: viewModel.monthlyFeeInfo.title,
                          monthlyFeeAmount: viewModel.monthlyFeeInfo.amount)
        setMonthsAmountInfo(totalMonthsTitle: viewModel.totalMonthsInfo.title,
                            totalMonthsAmount: viewModel.totalMonthsInfo.amount)
    }
    
    func addFirstFeeArrangedSubview(title: String, data: String?, tooltipText: String? = nil, accesibilityId: CurrentFeeViewAccesibilityIds) {
        let view = CurrentFeeDetailDataView()
        view.setFonts(titleSize: 16, dataSize: 16)
        view.setInfo(titletext: title, dataText: data, tooltipText: tooltipText)
        view.setAccesibilityIds(title: accesibilityId.title, description: accesibilityId.description)
        firstFeeInfoStackView.addArrangedSubview(view)
    }
    
    func addTotalAmountArrangedSubview(title: String, data: String, accesibilityId: CurrentFeeViewAccesibilityIds) {
        let view = CurrentFeeDetailDataView()
        view.setFonts(titleSize: 13, dataSize: 14)
        view.setInfo(titletext: title, dataText: data)
        view.setAccesibilityIds(title: accesibilityId.title, description: accesibilityId.description)
        totalAmountStackView.addArrangedSubview(view)
    }
    
    func setFirstFeeStackViewInfo(from viewModel: CurrentFeeDetailViewModel) {
        addFirstFeeArrangedSubview(title: viewModel.firstFeeInfo.title,
                                   data: viewModel.firstFeeInfo.date,
                                   accesibilityId: .firstFee)
        addFirstFeeArrangedSubview(title: viewModel.comissionInfo.title,
                                   data: viewModel.comissionInfo.amount,
                                   accesibilityId: .comission)
        addFirstFeeArrangedSubview(title: viewModel.interestInfo.title,
                                    data: viewModel.interestInfo.amount,
                                    tooltipText: viewModel.interestInfo.tootltiptext,
                                    accesibilityId: .interests)
    }
    
    func setTotalAmountStackViewInfo(from viewModel: CurrentFeeDetailViewModel) {
        addTotalAmountArrangedSubview(title: viewModel.TAEInfo.title,
                                       data: viewModel.TAEInfo.percentage,
                                       accesibilityId: .tae)
        addTotalAmountArrangedSubview(title: viewModel.totalAmountInfo.title,
                                       data: viewModel.totalAmountInfo.amount,
                                       accesibilityId: .totalAmount)
    }
    
    func resetStackViews() {
        firstFeeInfoStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        totalAmountStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
    }
    
    func setHeaderAccesibilityIds() {
        monthsTitleLabel.accessibilityIdentifier = CurrentFeeViewAccesibilityIds.totalMonths.title
        monthsAmountLabel.accessibilityIdentifier = CurrentFeeViewAccesibilityIds.totalMonths.description
        monthlyFeeTitleLabel.accessibilityIdentifier = CurrentFeeViewAccesibilityIds.monthlyFee.title
        monthlyFeeTitleLabel.accessibilityIdentifier = CurrentFeeViewAccesibilityIds.monthlyFee.description
    }
}
