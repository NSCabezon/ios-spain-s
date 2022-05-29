//
//  OneInputDateViewModel.swift
//  Models
//
//  Created by Daniel Gómez Barroso on 29/9/21.
//

public final class OneInputDateViewModel {
    public let dependenciesResolver: DependenciesResolver
    public let status: OneStatus
    public let firstDate: Date?
    public let placeholderKey: String?
    public let minDate: Date?
    public let maxDate: Date?
    public let accessibilitySuffix: String?
    public let accessibilityLabelKey: String?
    public let accessibilityInputKey: String?

    public init(dependenciesResolver: DependenciesResolver,
                status: OneStatus = .inactive,
                firstDate: Date? = nil,
                placeholderKey: String? = nil,
                minDate: Date? = nil,
                maxDate: Date? = nil,
                accessibilitySuffix: String? = nil,
                accessibilityLabelKey: String? = nil,
                accessibilityInputKey: String? = nil) {
        self.dependenciesResolver = dependenciesResolver
        self.status = status
        self.firstDate = firstDate
        self.placeholderKey = placeholderKey
        self.minDate = minDate
        self.maxDate = maxDate
        self.accessibilitySuffix = accessibilitySuffix
        self.accessibilityLabelKey = accessibilityLabelKey
        self.accessibilityInputKey = accessibilityInputKey
    }
}
