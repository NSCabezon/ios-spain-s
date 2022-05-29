//
//  ESPrivateMenuOptionsModifier.swift
//  Santander
//
//  Created by Boris Chirino Fernandez on 7/2/22.
//

import PrivateMenu
import CoreDomain
import OpenCombine
import CoreFoundationLib

struct ESPrivateMenuOptionsUseCase: GetPrivateMenuOptionsUseCase {
    private let featuredOptionsUseCase: GetFeaturedOptionsUseCase
    private let enabledOptionsUseCase: GetPrivateMenuOptionEnabledUseCase
    func fetchMenuOptions() -> AnyPublisher<[PrivateMenuOptionRepresentable], Never> {
        return availableOptionsPublisher()
    }
    
    init(dependencies: PrivateMenuExternalDependenciesResolver) {
        featuredOptionsUseCase = dependencies.resolve()
        enabledOptionsUseCase = dependencies.resolve()
    }
}

extension ESPrivateMenuOptionsUseCase {
    private var options: [PrivateMenuOptions] {
        let options: [PrivateMenuOptions] = [.globalPosition,
                                             .world123,
                                             .santanderOne1,
                                             .myProducts,
                                             .sofiaInvestments,
                                             .financing,
                                             .transfers,
                                             .bills,
                                             .analysisArea,
                                             .contract,
                                             .marketplace,
                                             .myHome,
                                             .santanderOne2,
                                             .otherServices]
        return options
    }
}

private extension ESPrivateMenuOptionsUseCase {
    func menuOptionPublisher() -> AnyPublisher<[PrivateMenuOptionRepresentable], Never> {
        return featuredOptionsUseCase
            .fetchFeaturedOptions()
            .map(buildOptions)
            .eraseToAnyPublisher()
    }

    func enabledOptionsPublisher() -> AnyPublisher<[PrivateMenuOptions], Never> {
        return enabledOptionsUseCase
            .fetchOptionsEnabledVisible()
            .map(\.data)
            .eraseToAnyPublisher()
    }
    
    func availableOptionsPublisher() -> AnyPublisher<[PrivateMenuOptionRepresentable], Never> {
        return Publishers.Zip(
            menuOptionPublisher(),
            enabledOptionsPublisher()
        )
        .map(buildEnabledOptions)
        .eraseToAnyPublisher()
    }
    
    func buildEnabledOptions(_ optionsRepresentable: [PrivateMenuOptionRepresentable],
                             _ notEnabled: [PrivateMenuOptions]) -> [PrivateMenuOptionRepresentable] {
        var availableOption = optionsRepresentable
        optionsRepresentable.forEach { _ in
            availableOption.removeIfFound { option in
                return notEnabled.contains(option.type)
            }
        }
        return availableOption
    }
    
    func evaluateFeaturedOptions(_ featuredOptions: [PrivateMenuOptions: String], with option: PrivateMenuOptions) -> (isFeatured: Bool, message: String) {
        guard let fOption = featuredOptions.filter({$0.key == option}).first else {
            return (false, "")
        }
        return (true, fOption.value)
    }
    
    func buildOptions(featuredOptions: [PrivateMenuOptions: String]) -> [PrivateMenuOptionRepresentable] {
         self.options.map { item in
            let optionEvaluator = evaluateFeaturedOptions(featuredOptions, with: item)
            return PrivateMenuMainOption(imageKey: item.iconKey,
                                           titleKey: item.titleKey,
                                           extraMessageKey: optionEvaluator.isFeatured ? optionEvaluator.message : "",
                                           newMessageKey: optionEvaluator.isFeatured ? "menu_label_newProminent" : "",
                                           imageURL: nil,
                                           showArrow: item.submenuArrow,
                                           isHighlighted: false,
                                           type: item,
                                           isFeatured: optionEvaluator.isFeatured,
                                           accesibilityIdentifier: item.accessibilityIdentifier)
        }
    }
}
