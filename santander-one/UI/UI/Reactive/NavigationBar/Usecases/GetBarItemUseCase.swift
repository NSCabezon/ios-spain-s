//
//  MenuXXUseCase.swift
//  Commons
//
//  Created by Juan Carlos López Robles on 12/3/21.
//
import OpenCombine
import Foundation
import CoreFoundationLib
import RxCombine

protocol GetBarItemUseCase {
    func fechBarItems() -> AnyPublisher<[MenuTextModel: String], Never>
}

struct DefaultGetBarItemUseCase {
    private let repository: AppConfigRepositoryProtocol
    
    init(dependencies: NavigationBarDependenciesResolver) {
        self.repository = dependencies.external.resolve()
    }
}

extension DefaultGetBarItemUseCase: GetBarItemUseCase {
    func fechBarItems() -> AnyPublisher<[MenuTextModel: String], Never> {
        let menuPublisher = repository.value(for: MenuTextModel.menu.rawValue, defaultValue: "")
        let mailBoxPublisher = repository.value(for: MenuTextModel.mailBox.rawValue, defaultValue: "")
        let searchPublisher = repository.value(for: MenuTextModel.search.rawValue, defaultValue: "")

       return menuPublisher
            .zip(mailBoxPublisher, searchPublisher) { (menu, mailBox, search)  in
                return [
                    MenuTextModel.menu: menu,
                    MenuTextModel.mailBox: mailBox,
                    MenuTextModel.search: search
                ]
            }.eraseToAnyPublisher()
    }
}
