//
//  InternalTransferSummarySharingButtonItem.swift
//  TransferOperatives
//
//  Created by crodrigueza on 15/3/22.
//

import OpenCombine

public final class InternalTransferSummarySharingButtonItem {
    public let imageKey: String
    public let titleKey: String
    public lazy var action: () -> Void = { [weak self] in
        self?.subject.send()
    }
    public let accessibilitySuffix: String?
    public let subject = PassthroughSubject<Void, Never>()

    public init(imageKey: String,
         titleKey: String,
         accessibilitySuffix: String? = nil) {
        self.imageKey = imageKey
        self.titleKey = titleKey
        self.accessibilitySuffix = accessibilitySuffix
    }
}
