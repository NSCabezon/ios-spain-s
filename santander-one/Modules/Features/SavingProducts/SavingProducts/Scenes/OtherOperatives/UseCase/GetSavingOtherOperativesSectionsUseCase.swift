//
//  GetSavingOtherOperativesSectionsUseCase.swift
//  SavingProducts

import OpenCombine
import CoreDomain
import CoreFoundationLib

public protocol GetSavingOtherOperativesSectionsUseCase {
    func fetchOtherOperativesSection(for option: SavingProductOptionRepresentable) -> AnyPublisher<SavingsActionSection, Never>
}
