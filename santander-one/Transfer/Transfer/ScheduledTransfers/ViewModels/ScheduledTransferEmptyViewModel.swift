//
//  ScheduledTransferEmptyViewModel.swift
//  Transfer
//
//  Created by Daniel Gómez Barroso on 18/11/21.
//

public final class ScheduledTransferEmptyViewModel {
    public let titleLabelKey: String
    public let descriptionLabelKey: String
    
    public init(titleLabelKey: String,
                descriptionLabelKey: String) {
        self.titleLabelKey = titleLabelKey
        self.descriptionLabelKey = descriptionLabelKey
    }
}
