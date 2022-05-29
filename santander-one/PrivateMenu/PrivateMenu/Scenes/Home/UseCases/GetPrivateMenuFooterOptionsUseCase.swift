//
//  GetPrivateMenuFooterOptionsUseCase.swift
//  PrivateMenu
//
//  Created by Boris Chirino Fernandez on 21/12/21.
//

import OpenCombine
import CoreDomain

public protocol GetPrivateMenuFooterOptionsUseCase {
    func fetchFooterOptions() -> AnyPublisher<[PrivateMenuFooterOptionRepresentable], Never>
}

struct DefaultMenuFooterOptionsUseCase {}

extension DefaultMenuFooterOptionsUseCase: GetPrivateMenuFooterOptionsUseCase {
    func fetchFooterOptions() -> AnyPublisher<[PrivateMenuFooterOptionRepresentable], Never> {
        return
            Just(defaultOptions())
            .eraseToAnyPublisher()
    }
}

private extension DefaultMenuFooterOptionsUseCase {    
    func defaultOptions() -> [PrivateMenuFooterOptionRepresentable] {
        var options: [PrivateMenuFooterOptionRepresentable] = []
        options.append(PrivateMenuFooterOption(title: "menu_link_HelpCenter",
                                    imageName: "icnSupportMenu",
                                    imageURL: nil,
                                    accessibilityIdentifier: "menuBtnHelpCenter",
                                    optionType: .helpCenter))
        return options
    }
}

struct PrivateMenuFooterOption: PrivateMenuFooterOptionRepresentable {
    var title: String
    var imageName: String
    var imageURL: String?
    var accessibilityIdentifier: String
    var optionType: FooterOptionType
    
    init(option: PrivateMenuFooterOptionRepresentable) {
        self.title = option.title
        self.imageName = option.imageName
        self.imageURL = option.imageURL
        self.accessibilityIdentifier = option.accessibilityIdentifier
        self.optionType = option.optionType
    }
    
    init(title: String,
         imageName: String,
         imageURL: String?,
         accessibilityIdentifier: String,
         optionType: FooterOptionType) {
        self.title = title
        self.imageName = imageName
        self.imageURL = imageURL
        self.accessibilityIdentifier = accessibilityIdentifier
        self.optionType = optionType
    }
}
