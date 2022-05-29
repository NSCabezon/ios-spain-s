import Foundation
import OpenCombine
import CoreDomain
import CoreFoundationLib

public protocol GetUserCommercialSegmentUseCase {
    func filterUserCommercialSegmentElem(_ elementsToFilter: [[PublicMenuElementRepresentable]]) -> AnyPublisher<[[PublicMenuElementRepresentable]], Never>
}

struct DefaultGetUserCommercialSegmentUseCase {
    private let segmentedUserRepository: SegmentedUserRepository
    private var elementsToFilter: [[PublicMenuElementRepresentable]] = []
    
    private typealias NewMenuOption = (type: PublicMenuOptionType?, action: PublicMenuAction?)
    
    init(dependencies: PublicMenuDependenciesResolver) {
        self.segmentedUserRepository = dependencies.external.resolve()
    }
}

extension DefaultGetUserCommercialSegmentUseCase: GetUserCommercialSegmentUseCase {
    func filterUserCommercialSegmentElem(_ elementsToFilter: [[PublicMenuElementRepresentable]]) -> AnyPublisher<[[PublicMenuElementRepresentable]], Never> {
        return segmentedUserRepository
            .getCommercialSegment()
            .map({
                filterOptions(elementsToFilter, commercialSegment: $0)
            })
            .eraseToAnyPublisher()
    }
}

private extension DefaultGetUserCommercialSegmentUseCase {
    func filterOptions(_ options: [[PublicMenuElementRepresentable]], commercialSegment: CommercialSegmentRepresentable?) -> [[PublicMenuElementRepresentable]] {
        let availableNumbers = commercialSegment?.contactRepresentable?.fraudFeedbackRepresentable?.numbers
        let newMenuOption = phonesMenuOptionTypeWithNumbers(availableNumbers ?? [])
        return options.map { (config) in
            config.map {
                return self.filterCommercialSegment($0, newMenuOption)
            }
        }
    }
    
    private func filterCommercialSegment(_ option: PublicMenuElementRepresentable, _ menuOption: NewMenuOption) -> PublicMenuElementRepresentable {
        var evaluatedOption = option
        evaluatedOption.top = evaluateMenuOption(option.top, newType: menuOption)
        evaluatedOption.bottom = evaluateMenuOption(option.bottom, newType: menuOption)
        return evaluatedOption
    }
    
    private func evaluateMenuOption(_ menuOption: PublicMenuOptionRepresentable?, newType: NewMenuOption) -> PublicMenuOptionRepresentable? {
        var option = menuOption
        switch menuOption?.type {
        case let .flipButton(principalItem: principalItem, secondaryItem: secondaryItem, time: time):
            option?.type = .flipButton(principalItem: (evaluateMenuOption(principalItem,
                                                                          newType: newType) ?? principalItem),
                                       secondaryItem: (evaluateMenuOption(secondaryItem,
                                                                          newType: newType) ?? secondaryItem),
                                       time: time)
        default:
            if menuOption?.kindOfNode == .commercialSegment {
                guard let type = newType.type else { return nil }
                option?.type = type
                if let newAction = newType.action {
                    option?.action = newAction
                }
            }
        }
        return option
    }
    
    private func phonesMenuOptionTypeWithNumbers(_ numbers: [String]) -> NewMenuOption {
        if let number = numbers.first, numbers.count == 1 {
            return (PublicMenuOptionType.callNow(phone: number),
                    PublicMenuAction.callPhone(number: number.notWhitespaces()))
        }
        if numbers.count > 1 {
            return (PublicMenuOptionType.phonesButton(top: numbers[0],
                                                     bottom: numbers[1]),
                    nil)
        }
        return (nil, nil)
    }
}
