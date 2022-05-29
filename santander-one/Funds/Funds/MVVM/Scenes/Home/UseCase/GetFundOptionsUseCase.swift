//
//  GetFundOptionsUsecase.swift
//  Funds
//
import OpenCombine
import CoreFoundationLib
import CoreDomain

public protocol GetFundOptionsUsecase {
    func fetchOptionsPublisher() -> AnyPublisher<[FundOptionRepresentable], Never>
}

struct DefaultGetFundOptionsUsecase {}

extension DefaultGetFundOptionsUsecase: GetFundOptionsUsecase {
    func fetchOptionsPublisher() -> AnyPublisher<[FundOptionRepresentable], Never> {
        return Just([]).eraseToAnyPublisher()
    }
}
