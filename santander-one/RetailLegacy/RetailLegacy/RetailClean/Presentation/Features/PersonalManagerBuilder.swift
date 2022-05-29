//

import Foundation
import CoreFoundationLib

struct PersonalManagerFactory {
    var typeManager: ManagerType
    var managers: [Manager]?
    var otherManagers: [Manager]?
    var emptyViewConfig: Bool?
    var dependencies: PresentationComponent

    func makeViews() -> ManagerProfileProtocol? {
        switch typeManager {
        case .withoutManager:
            return dependencies.navigatorProvider.presenterProvider.personalWithoutManagerPresenter(isEmptyView: true,
                                                                                                    otherManagers: otherManagers ?? []).view
        case .withoutOfficeManager:
            return dependencies.navigatorProvider.presenterProvider.officeWithoutManagerPresenter(otherManagers: otherManagers ?? []).view
        case .withOfficeManager:
            guard managers != nil else { return nil }
            return dependencies.navigatorProvider.presenterProvider.officeWithManagerPresenter(officeManagers: managers!,
                                                                                               otherManagers: otherManagers ?? []).view
        case .withoutPersonalManager:
            return dependencies.navigatorProvider.presenterProvider.personalWithoutManagerPresenter(isEmptyView: emptyViewConfig ?? true,
                                                                                                    otherManagers: otherManagers ?? []).view
        case .withPersonalManager:
            guard managers != nil else { return nil }
            return dependencies.navigatorProvider.presenterProvider.personalWithManagerPresenter(personalManagers: managers!,
                                                                                                 otherManagers: otherManagers ?? []).view
        }   
    }

}
