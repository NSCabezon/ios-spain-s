//
//  EmittedTransferDetailPresenter.swift
//  Account
//
//  Created by Alvaro Royo on 17/6/21.
//

import CoreFoundationLib
import PDFKit
import WebKit
import PdfCommons

protocol TransferDetailPresenterProtocol: MenuTextGetProtocol {
    var transferDetailType: TransferDetailType { get }
    var view: EmittedTransferDetailViewProtocol? { get set }
    var configuration: [TransferDetailConfigurationProtocol] { get }
    var isExpanded: Bool { get }
    var maxViewsNotExpanded: Int { get }
    func close()
    func viewDidLoad()
    func proceedToDeleteTransfer()
}

final class TransferDetailPresenter: TransferDetailPresenterProtocol {
    var dependenciesResolver: DependenciesResolver
    weak var view: EmittedTransferDetailViewProtocol?
    private var appConfig: LocalAppConfig {
        dependenciesResolver.resolve(for: LocalAppConfig.self)
    }
    
    private var isEmitted: Bool {
        switch transferDetailType {
        case .emitted: return true
        case .received: return false
        case .scheduled: return false
        }
    }
    
    private lazy var pdfCreator = PDFCreator()
    
    var coordinator: TransferDetailCoordinatorProtocol {
        dependenciesResolver.resolve()
    }
    
    var configuration: [TransferDetailConfigurationProtocol] {
        dependenciesResolver.resolve(for: TransferDetailConfiguration.self).config.compactMap {$0}
    }
    
    var transferConfiguration: TransferDetailConfiguration {
        dependenciesResolver.resolve(for: TransferDetailConfiguration.self)
    }
    
    var maxViewsNotExpanded: Int {
        dependenciesResolver.resolve(for: TransferDetailConfiguration.self).maxViewsNotExpanded
    }
    
    var isExpanded: Bool {
        dependenciesResolver.resolve(for: TransferDetailConfiguration.self).isExpanded
    }
    
    var transferDetailType: TransferDetailType {
        transferConfiguration.transferType
    }
    
    private var scheduledTransferActionsNavigator: TransferHomeModuleCoordinatorDelegate? {
        dependenciesResolver.resolve(forOptionalType: TransferHomeModuleCoordinatorDelegate.self)
    }
    
    private var transferDetailTypeActionsModifier: TransferDetailTypeActionsModifierProtocol? {
        dependenciesResolver.resolve(forOptionalType: TransferDetailTypeActionsModifierProtocol.self)
    }
    
    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
    }
    
    func close() {
        coordinator.dismiss()
    }
    
    func viewDidLoad() {
        let actions: [TransferDetailActionViewModel]
        if let customActions = transferDetailTypeActionsModifier?.customActionsFor(type: self.transferDetailType, delegate: self) {
            actions = customActions
        } else {
            actions = self.transferDetailType.actionsWith(delegate: self)
        }
        view?.showActionsWithModels(actions)
    }
}

extension TransferDetailPresenter: MenuTextWrapperProtocol {}

extension TransferDetailPresenter: TransferDetailTypeDelegate {
    
    func editTransfer() {
        guard self.appConfig.isScheduledTransferDetailEditButtonEnabled,
              let nav = scheduledTransferActionsNavigator
        else {
            return coordinator.showComingSoonToast()
        }
        
        switch transferDetailType {
        case .scheduled(let account, let transfer, let transferDetail, _):
            guard let transferDTO = transfer?.transfer,
                  let transferDetailDTO = transferDetail?.transferDetailDTO
            else { return }
            let transferEntity = TransferScheduledEntity(dto: transferDTO)
            let transferDetailEntity = ScheduledTransferDetailEntity(dto: transferDetailDTO)
            if transfer?.isPeriodic ?? false {
                nav.modifyPeriodicTransfer(account: account,
                                           transfer: transferEntity,
                                           transferDetail: transferDetailEntity)
            } else {
                nav.modifyDeferredTransfer(account: account,
                                           transfer: transferEntity,
                                           transferDetail: transferDetailEntity)
            }
        case .emitted, .received: break
        }
    }
    
    func deleteTransfer() {
        view?.showConfirmDialog()
    }
    
    func proceedToDeleteTransfer() {
        guard self.appConfig.isScheduledTransferDetailDeleteButtonEnabled else {
            return self.coordinator.showComingSoonToast()
        }
        switch transferConfiguration.transferType {
        case .scheduled(let account, let order, let transferDetail, _):
            guard let transferDetailDTO = transferDetail?.transferDetailDTO,
                  let transfer = order as ScheduledTransferRepresentable?
            else { return }
            let transferDetailEntity = ScheduledTransferDetailEntity(dto: transferDetailDTO)
            self.coordinator.deleteStandingOrder(transfer,
                                                 account: account,
                                                 detail: transferDetailEntity)
        case .emitted, .received: break
        }
    }
    
    func showPDF() {
        guard self.appConfig.isTransferDetailPDFButtonEnabled else {
            return self.coordinator.showComingSoonToast()
        }
        let pdfGenerator = dependenciesResolver.resolve(forOptionalType: GenerateTransferPDFContentProtocol.self) ?? GenerateTransferPDFContent()
        let transferType = dependenciesResolver.resolve(for: TransferDetailConfiguration.self).transferType
        switch transferType {
        case .emitted(transferDetail: let transferDetail, transfer: let transfer, account: let account):
            let pdfData = pdfGenerator.generateEmittedSepaPfdContent(transferDetail: transferDetail, transfer: transfer, account: account)
            generatePDF(pdfData, titleKey: "toolbar_title_detailOnePay", source: .transferSummary)
        case .received(transfer: let transferReceived, fromAccount: _, account: _):
            guard self.dependenciesResolver.resolve(forOptionalType: GetTransferUseCaseProtocol.self) == nil
            else { return self.coordinator.showComingSoonToast() }
            let pdfData = pdfGenerator.generateReceivedTransfer(transferReceived: transferReceived)
            generatePDF(pdfData, titleKey: "toolbar_title_detailOnePay", source: .transferSummary)
        case .scheduled: break
        }
    }
    
    func generatePDF(_ data: String?, titleKey: String, source: PdfSource) {
        guard let pdfData = data else { return }
        pdfCreator.createPDF(html: pdfData, completion: { [weak self]  data in
            let pdfLauncher = self?.dependenciesResolver.resolve(for: PDFCoordinatorLauncher.self)
            pdfLauncher?.openPDF(data, title: titleKey, source: source)
        }, failed: { })
    }
    
    func shareAction() {
        guard !self.isEmitted  else {
            return self.coordinator.showComingSoonToast()
        }
        view?.performShare(with: self)
    }
    
    func reuseTransfer() {
        guard self.appConfig.isTransferDetailReuseButtonEnabled else {
            self.coordinator.showComingSoonToast()
            return
        }
        guard case .emitted(let pdfDetail, _, let account) = transferConfiguration.transferType else {
            return
        }
        
        let iban = IBANEntity.create(fromText: pdfDetail?.beneficiaryIBAN ?? "")
        let name = pdfDetail?.beneficiaryName ?? ""
        self.coordinator.reuseTransferFromAccount(account, destination: iban, beneficiary: name)
    }
    
    func buildShareableContent() -> String {
        guard case .received(let transfer, _, _) = transferConfiguration.transferType,
              let receivedTransferEntity = transfer
        else { return "" }
        var builder = TransferReceivedDetailStringBuilder(transfer: receivedTransferEntity)
        builder.addAmount()
        builder.addAliasAccountBeneficiary()
        builder.addDescription()
        builder.addTransferType()
        builder.addAnnotationDate()
        return builder.build()
    }
}

extension TransferDetailPresenter: Shareable {
    func getShareableInfo() -> String {
        buildShareableContent()
    }
}

// extension TransferDetailPresenter: ReemittedTransferLauncher {}
