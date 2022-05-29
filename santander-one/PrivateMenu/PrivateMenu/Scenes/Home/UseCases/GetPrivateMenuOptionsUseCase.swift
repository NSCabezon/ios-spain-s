//
//  GetMenuItemsUseCase.swift
//  PrivateMenu
//
//  Created by Boris Chirino Fernandez on 18/1/22.
//

import OpenCombine
import CoreDomain
import CoreFoundationLib

public protocol GetPrivateMenuOptionsUseCase {
    func fetchMenuOptions() -> AnyPublisher<[PrivateMenuOptionRepresentable],Never>
}

struct DefaultPrivateMenuOptionsUseCase {
    private static var options: [PrivateMenuOptions] {
        let defaultOptions: [PrivateMenuOptions] = [.globalPosition]
        return defaultOptions
    }
}

extension DefaultPrivateMenuOptionsUseCase: GetPrivateMenuOptionsUseCase {
    func fetchMenuOptions() -> AnyPublisher<[PrivateMenuOptionRepresentable], Never> {
        return Just(getDefaultOptions()).eraseToAnyPublisher()
    }
}

private extension DefaultPrivateMenuOptionsUseCase {
    func getDefaultOptions() -> [PrivateMenuOptionRepresentable] {
        let defOptions = DefaultPrivateMenuOptionsUseCase.options.map { item in
            return PrivateMenuMainOption(imageKey: item.iconKey,
                                           titleKey: item.titleKey,
                                           extraMessageKey: "",
                                           newMessageKey: "",
                                           imageURL: nil,
                                           showArrow: item.submenuArrow,
                                           isHighlighted: true,
                                           type: item,
                                           isFeatured: false,
                                           accesibilityIdentifier: item.accessibilityIdentifier)
        }
        return defOptions
    }
}
