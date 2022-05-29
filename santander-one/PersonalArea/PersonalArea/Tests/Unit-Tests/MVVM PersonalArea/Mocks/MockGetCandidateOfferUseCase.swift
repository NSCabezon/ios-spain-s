//
//  MockGetCandidateOfferUseCase.swift
//  PersonalArea-Unit-Tests
//
//  Created by alvola on 20/4/22.
//

import Foundation
import CoreFoundationLib
import CoreDomain
import OpenCombine

struct MockGetCandidateOfferUseCase: GetCandidateOfferUseCase {
    func fetchCandidateOfferPublisher(location: PullOfferLocationRepresentable) -> AnyPublisher<OfferRepresentable, Error> {
        return Just(OfferMock()).setFailureType(to: Error.self).eraseToAnyPublisher()
    }
}

private extension MockGetCandidateOfferUseCase {
    struct OfferMock: OfferRepresentable {
        var pullOfferLocation: PullOfferLocationRepresentable?
        var bannerRepresentable: BannerRepresentable?
        var action: OfferActionRepresentable?
        var id: String?
        var identifier: String = ""
        var transparentClosure: Bool = true
        var productDescription: String = ""
        var rulesIds: [String] = []
        var startDateUTC: Date?
        var endDateUTC: Date?
    }
}
