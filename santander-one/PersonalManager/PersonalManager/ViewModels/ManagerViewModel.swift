import CoreFoundationLib

enum ManagerType {
    case personal
    case office
    case banker
    
    func position() -> String {
        switch self {
        case .personal:
            return "manager_title_personalManager"
        case .office:
            return "manager_title_officeManager"
        case .banker:
            return "manager_title_banker"
        }
    }
    
    func tracker() -> String {
        switch self {
        case .personal:
            return "personal"
        case .office:
            return "oficina"
        case .banker:
            return "banquero"
        }
    }
}

struct ManagerViewModel {
    let type: ManagerType
    let image: String?
    let managerCode: String
    var position: String {
        type.position()
    }
    let name: String
    let formattedName: String
    let actions: [ManagerActionViewModel]
    let phone: String
    let email: String
    let hasHobbies: Bool
    var nameInitials: String {
        let formatter = PersonNameComponentsFormatter()
        guard let components = formatter.personNameComponents(from: name) else { return "" }
        formatter.style = .abbreviated
        return formatter.string(from: components)
    }
    
    static func initWith(_ dtos: ManagerList,
                         type: ManagerType,
                         managerWallEnabled: Bool,
                         videoCallEnabled: Bool,
                         calendarEnabled: Bool = false,
                         hobbies: [ManagerHobbieEntity],
                         baseUrl: String? = nil) -> [ManagerViewModel] {
        func actionsFrom(manager: Manager) -> [ManagerActionViewModel] {
            var actions = [ManagerActionViewModel]()
            if !manager.phone.isEmpty {
                actions.append(ManagerActionViewModel(action: .phone))
            }
            switch type {
            case .banker:
                if !manager.email.isEmpty {
                    actions.append(ManagerActionViewModel(action: .email))
                }
                if managerWallEnabled {
                    actions.append(ManagerActionViewModel(action: .chat))
                }
                if videoCallEnabled {
                    actions.append(ManagerActionViewModel(action: .videoCall))
                }
            case .office:
                if calendarEnabled {
                    actions.append(ManagerActionViewModel(action: .calendar))
                }
                if !manager.email.isEmpty {
                    actions.append(ManagerActionViewModel(action: .email))
                }
            case .personal:
                if videoCallEnabled {
                    actions.append(ManagerActionViewModel(action: .videoCall))
                }
                if managerWallEnabled {
                    actions.append(ManagerActionViewModel(action: .chat))
                }
                if !manager.email.isEmpty {
                    actions.append(ManagerActionViewModel(action: .email))
                }
            }
            return actions
        }
        return dtos.managers.map { manager in
            var image: String?
            if let baseUrl = baseUrl, !baseUrl.isEmpty {
                image = baseUrl + manager.relativeImageUrl
            }
            return ManagerViewModel(
                type: type,
                image: image,
                managerCode: manager.codGest ,
                name: manager.nameGest,
                formattedName: manager.formattedName,
                actions: actionsFrom(manager: manager),
                phone: manager.phone,
                email: manager.email,
                hasHobbies: hobbies.contains(where: { $0.managerId == manager.codGest})
            )
        }
    }
}

enum ManagerAction {
    case phone
    case email
    case videoCall
    case chat
    case calendar
    
    func icon() -> String {
        switch self {
        case .phone:
            return "icnTelephone"
        case .email:
            return "icnManagerMail"
        case .videoCall:
            return "icnVideocall"
        case .chat:
            return "icnChat"
        case .calendar:
            return "icnCalendar"
        }
    }
    
    func title() -> String {
        switch self {
        case .phone:
            return "manager_label_call"
        case .email:
            return "manager_label_sendEmail"
        case .videoCall:
            return "manager_label_videoCall"
        case .chat:
            return "manager_label_chatManage"
        case .calendar:
            return "manager_label_requestDate"
        }
    }
    
    func alternativeTitle() -> String {
        switch self {
        case .phone:
            return "manager_label_call"
        case .email:
            return "manager_label_sendEmail"
        case .videoCall:
            return "manager_button_videoCall"
        case .chat:
            return "manager_label_chatManage"
        case .calendar:
            return "manager_label_requestDate"
        }
    }
    
    func subtitle() -> String {
        switch self {
        case .phone:
            return "manager_label_24h"
        case .email:
            return "manager_label_descriptionSendEmail"
        case .videoCall:
            return "manager_label_scheduleVideoCall"
        case .chat:
            return "manager_label_chat"
        case .calendar:
            return ""
        }
    }
    
    func accessibilityId() -> String {
        switch self {
        case .phone:
            return "btnPhone"
        case .email:
            return "btnEmail"
        case .videoCall:
            return "btnVideocall"
        case .chat:
            return "btnChat"
        case .calendar:
            return "btnCalendar"
        }
    }
}
