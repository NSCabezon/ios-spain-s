//
//  TransferPDFGenerator.swift
//  PdfCommons
//
//  Created by alvola on 24/06/2021.
//
import CoreFoundationLib

public protocol GenerateTransferPDFContentProtocol {
    func generateEmittedSepaPfdContent(transferDetail: EmittedTransferDetailForPDFProtocol?, transfer: TransferEmittedEntity, account: AccountEntity) -> String?
    func generateReceivedTransfer(transferReceived: TransferReceivedEntity?) -> String?
}

public final class GenerateTransferPDFContent: GenerateTransferPDFContentProtocol {
    public init() { }
    
    public func generateEmittedSepaPfdContent(transferDetail: EmittedTransferDetailForPDFProtocol?, transfer: TransferEmittedEntity, account: AccountEntity) -> String? {
        guard let originAccountAlias = account.alias,
              let originAccountIBAN = transferDetail?.originAsteriskIBAN,
              let destinationIBAN = transferDetail?.destinyAsteriskIBAN else {
            return nil
        }
        
        let builder = TransferPDFBuilder()
        builder.addHeader(title: "pdf_title_summaryOnePay",
                          office: nil,
                          date: transferDetail?.emisionDate)
        builder.addAccounts(originAccountAlias: originAccountAlias,
                            originAccountIBAN: originAccountIBAN,
                            destinationAccountAlias: transferDetail?.beneficiaryName ?? "",
                            destinationAccountIBAN: destinationIBAN)
        builder.addTransferInfo([
            (key: "summary_item_amount", value: transfer.amountEntity),
            (key: "summary_item_concept", value: transferConcept(currentConcept: transfer.concept)),
            (key: "summary_item_periodicity", value: transferPeriodicity(transferDetail)),
            (key: "summary_item_transactionDate", value: dateToString(date: transfer.executedDate, outputFormat: .dd_MMM_yyyy))
        ])
        
        if transferDetail?.amountToDebit ?? false {
            builder.addExpenses([
                (key: "summary_item_commission", value: transferDetail?.feesEntity ?? transferDetail?.fees),
                (key: "summary_item_amountToDebt", value: transferDetail?.totalAmountEntity ?? transferDetail?.totalAmount)
            ])
        }
        return builder.build()
    }
    
    public func generateReceivedTransfer(transferReceived: TransferReceivedEntity?) -> String? {
        let builder = TransferPDFBuilder()
        builder.addHeader(title: "pdf_title_summaryOnePay", office: nil, date: transferReceived?.operationDate)
        builder.addTransferInfo([
            (key: "summary_item_amount", value: transferReceived?.amountEntity.getStringValue()),
            (key: "summary_item_concept", value: transferReceived?.description),
            (key: "summary_item_transactionDate", value: dateToString(date: transferReceived?.executedDate, outputFormat: .dd_MMM_yyyy))
        ])
        return builder.build()
    }
}

private extension GenerateTransferPDFContent {
    func transferPeriodicity(_ transferDetail: EmittedTransferDetailForPDFProtocol?) -> String? {
        guard let periodicity = transferDetail?.periodicity else {
            return nil
        }
        return localized(periodicity).text
    }
    
    func transferConcept(currentConcept: String?) -> String {
        let concept: String
        if let transferConcept = currentConcept, !transferConcept.isEmpty {
            concept = transferConcept
        } else {
            concept = localized("onePay_label_notConcept").text
        }
        return concept
    }
}
