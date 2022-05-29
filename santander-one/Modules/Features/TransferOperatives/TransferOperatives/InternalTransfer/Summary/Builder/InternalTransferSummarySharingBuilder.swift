//
//  InternalTransferSummarySharingBuilder.swift
//  TransferOperatives
//
//  Created by crodrigueza on 15/3/22.
//

import CoreFoundationLib
import CoreDomain
import OpenCombine

final class InternalTransferSummarySharingBuilder {
    private var sharingItems: [InternalTransferSummarySharingButtonItem] = []
    private var subscriptions = Set<AnyCancellable>()

    init(subscriptions: inout Set<AnyCancellable>) {
        self.subscriptions = subscriptions
    }

    func addDownloadPDF(_ action: @escaping () -> Void) {
        let item = InternalTransferSummarySharingButtonItem(
                imageKey: "oneIcnPdf",
                titleKey: "summary_button_downloadPDF",
                accessibilitySuffix: AccessibilityInternalTransferSummary.ShareButton.pdfSuffix
            )
        item.subject
            .sink(receiveValue: action)
            .store(in: &subscriptions)
        sharingItems.append(item)
    }

    func addShareImage(_ action: @escaping () -> Void) {
        let item = InternalTransferSummarySharingButtonItem(
            imageKey: "oneIcnShare",
            titleKey: "generic_button_shareImage",
            accessibilitySuffix: AccessibilityInternalTransferSummary.ShareButton.imageSuffix
        )
        item.subject
            .sink(receiveValue: action)
            .store(in: &subscriptions)
        sharingItems.append(item)
    }

    func build() -> [InternalTransferSummarySharingButtonItem] {
        return sharingItems
    }
}
