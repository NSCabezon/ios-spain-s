//
//  OneOperativeSummaryFooterViewModel.swift
//  Models
//
//  Created by Daniel Gómez Barroso on 14/10/21.
//

import OpenCombine

public struct OneFooterNextStepViewModel {
    public let titleKey: String
    public let elements: [OneFooterNextStepItemViewModel]

    public init(titleKey: String,
                elements: [OneFooterNextStepItemViewModel]) {
        self.titleKey = titleKey
        self.elements = elements
    }
}

public class OneFooterNextStepItemViewModel {
    public let titleKey: String
    public let imageName: String
    public lazy var action: () -> Void = {
        return {
            self.subject.send()
        }
    }()
    public let accessibilitySuffix: String?
    public let subject = PassthroughSubject<Void, Never>()
    
    public init(titleKey: String,
                imageName: String,
                action: @escaping (() -> Void),
                accessibilitySuffix: String? = nil) {
        self.titleKey = titleKey
        self.imageName = imageName
        self.accessibilitySuffix = accessibilitySuffix
        self.action = action
    }
    
    public init(titleKey: String,
                imageName: String,
                accessibilitySuffix: String? = nil) {
        self.titleKey = titleKey
        self.imageName = imageName
        self.accessibilitySuffix = accessibilitySuffix
    }
}
