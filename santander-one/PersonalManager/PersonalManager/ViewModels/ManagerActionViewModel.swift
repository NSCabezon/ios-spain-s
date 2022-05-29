//
//  PersonalManagerAction.swift
//  PersonalManager
//
//  Created by alvola on 10/02/2020.
//

struct ManagerActionViewModel {
    let action: ManagerAction
    var icon: String {
        action.icon()
    }
    var title: String {
        action.title()
    }
    var subtitle: String {
        action.subtitle()
    }
    var accessibilityId: String {
        action.accessibilityId()
    }
}
