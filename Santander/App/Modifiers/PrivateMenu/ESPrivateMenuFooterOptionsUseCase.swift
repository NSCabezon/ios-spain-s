//
//  ESPrivateMenuFooterModifier.swift
//  Santander
//
//  Created by Boris Chirino Fernandez on 3/2/22.
//

import PrivateMenu
import OpenCombine
import CoreDomain

struct ESPrivateMenuFooterOptionsUseCase: GetPrivateMenuFooterOptionsUseCase {
    struct ESPrivateMenuFooterOptions: PrivateMenuFooterOptionRepresentable {
        let title: String
        let imageName: String
        let imageURL: String?
        let accessibilityIdentifier: String
        let optionType: FooterOptionType
    }
    
    private let personalManagerRepository: PersonalManagerReactiveRepository
    init(dependency: PrivateMenuExternalDependenciesResolver) {
        personalManagerRepository = dependency.resolve()
    }
    
    func fetchFooterOptions() -> AnyPublisher<[PrivateMenuFooterOptionRepresentable], Never> {
        return personalManagerRepository
            .getPersonalManagers()
            .replaceError(with: [])
            .map(buildOptions)
            .eraseToAnyPublisher()
    }
    
    func buildOptions(manager: [PersonalManagerRepresentable]) -> [PrivateMenuFooterOptionRepresentable] {
        var options: [PrivateMenuFooterOptionRepresentable] = []
        let isManagerPresent = manager.isNotEmpty
        options.append(ESPrivateMenuFooterOptions(title: "menu_link_security",
                                    imageName: "icnSecurity",
                                    imageURL: nil,
                                    accessibilityIdentifier: "menuBtnSecurity",
                                    optionType: .security))
        options.append(ESPrivateMenuFooterOptions(title: "menu_link_atm",
                                    imageName: "icnAtmMenuBlack",
                                    imageURL: nil,
                                    accessibilityIdentifier: "menuBtnAtm",
                                    optionType: .atm))
        options.append(ESPrivateMenuFooterOptions(title: "menu_link_HelpCenter",
                                    imageName: "icnSupportMenu",
                                    imageURL: nil,
                                    accessibilityIdentifier: "menuBtnHelpCenter",
                                    optionType: .helpCenter))
        options.append(ESPrivateMenuFooterOptions(title: "menu_link_menuMyManage",
                                    imageName: isManagerPresent ? "icnMyManagerDefault" : "icnMyManager",
                                    imageURL: nil,
                                    accessibilityIdentifier: "menuBtnMyManager",
                                    optionType: .myManager))
        return options
    }
}
