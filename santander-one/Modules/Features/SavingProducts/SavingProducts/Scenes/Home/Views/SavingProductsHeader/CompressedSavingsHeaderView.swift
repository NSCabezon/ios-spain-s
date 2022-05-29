//
//  CompressedSavingsHeaderView.swift
//  Savings
//
//  Created by Juan Carlos López Robles on 10/11/19.
//
import UI
import Foundation
import CoreFoundationLib
import OpenCombine

final class CompressedSavingsHeaderView: XibView {
    @IBOutlet private weak var savingAliasLabel: UILabel!
    @IBOutlet private weak var savingAmountLabel: UILabel!
    @IBOutlet private weak var filterButton: UIButton!
    @IBOutlet private weak var filterLabel: UILabel!
    @IBOutlet private weak var pdfButton: UIButton!
    @IBOutlet private weak var pdfLabel: UILabel!
    @IBOutlet private weak var filtersView: UIView!
    @IBOutlet private weak var pdfView: UIView!

    private var saving: Savings?
    private var anySubscriptions = Set<AnyCancellable>()
    let selectSavingSubject = PassthroughSubject<Savings, Never>()
    let didSelectActionButton = PassthroughSubject<SavingHeaderAction, Never>()
    let transactionsButtonsSubject = CurrentValueSubject<[SavingProductsTransactionsButtonsType], Never>([])

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        setupAccessibilityIds()
        bind()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
        setupAccessibilityIds()
        bind()
    }
}

private extension CompressedSavingsHeaderView {
    func setupView() {
        self.setupGradientLayer()
        self.savingAliasLabel.scaledFont = .santander(family: .text, type: .bold, size: 18)
        self.savingAliasLabel.textColor = .lisboaGray
        self.savingAmountLabel.scaledFont = .santander(family: .text, type: .regular, size: 14)
        self.savingAmountLabel.textColor = .lisboaGray
        self.filterButton.setImage(Assets.image(named: "icnFilter"), for: .normal)
        self.filterButton.tintColor = .darkTorquoise
        self.filterLabel.text = localized("generic_button_filters")
        self.filterLabel.font = .santander(family: .text, type: .regular, size: 12)
        self.filterLabel.textColor = UIColor.darkTorquoise
        self.pdfButton.setImage(Assets.image(named: "icnDownload"), for: .normal)
        self.pdfButton.tintColor = .darkTorquoise
        self.pdfLabel.text = localized("generic_button_downloadPDF")
        self.pdfLabel.font = .santander(family: .text, type: .regular, size: 12)
        self.pdfLabel.textColor = UIColor.darkTorquoise
        self.filtersView.isUserInteractionEnabled = true
        self.filtersView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(filterAction)))
        self.pdfView.isUserInteractionEnabled = true
        self.pdfView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(pdfAction)))
    }
    
    private func setupAccessibilityIds() {
        self.filterLabel.accessibilityIdentifier = "generic_button_filters"
        self.filterButton.accessibilityIdentifier = "icn_filter"
        self.pdfLabel.accessibilityIdentifier = "generic_button_downloadPDF"
        self.pdfButton.accessibilityIdentifier = "icn_download"
        self.savingAliasLabel.accessibilityIdentifier = "savingProductLabelScrollTopAlias"
        self.savingAmountLabel.accessibilityIdentifier = "savingPorductLabelScrollTopAmount"
    }
    
    private func setupGradientLayer() {
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [UIColor.white.cgColor, UIColor.skyGray.cgColor]
        gradientLayer.frame = view?.bounds ?? .zero
        self.view?.layer.insertSublayer(gradientLayer, at: 0)
    }
    
    func bind() {
        bindSelectSaving()
        bindTransactionsButtons()
    }
    
    func bindSelectSaving() {
        selectSavingSubject
            .sink { [unowned self] saving in
                self.saving = saving
                self.savingAliasLabel.text = saving.alias
                self.savingAmountLabel.text = saving.amount
            }.store(in: &anySubscriptions)
    }
    
    func bindTransactionsButtons() {
        transactionsButtonsSubject
            .sink { [unowned self] options in
            self.setupActionsHeader(options: options)
        }.store(in: &anySubscriptions)
    }
    
    @objc func filterAction() {
        didSelectActionButton.send(.filter)
    }
    
    @objc func pdfAction() {
        didSelectActionButton.send(.download)
    }
    
    func setupActionsHeader(options: [SavingProductsTransactionsButtonsType]) {
        pdfView.isHidden = options.contains(.downloadPDF) == false
        filtersView.isHidden = options.contains(.filter) == false
    }
}
