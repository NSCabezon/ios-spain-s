import UI
import CoreFoundationLib

enum ReuseContactItemsViewModel {
    case initials(_ item: BizumInitialsViewModel)
    case simple(_ item: ReuseSimpleContactViewModel)
    case multiple(_ items: ReuseMultipleContactViewModel)
    case options(_ items: [BizumHomeOptionViewModel])
}

final class ReuseContactBuilder {
    private let contacts: [BizumContactEntity]
    private let dependenciesResolver: DependenciesResolver
    private (set) var items: [ReuseContactItemsViewModel] = []

    init(contacts: [BizumContactEntity], dependenciesResolver: DependenciesResolver) {
        self.contacts = contacts
        self.dependenciesResolver = dependenciesResolver
    }

    func build() {
        self.addContacts()
        self.addOptions()
    }
}

private extension  ReuseContactBuilder {
    func addInitials() {
        guard contacts.count == 1, let contact = contacts.first else { return }
        let color = getColor(contact.identifier)
        let item = BizumInitialsViewModel(colorModel: color, initials: contact.alias?.nameInitials ?? "")
        self.items.append(.initials(item))
    }

    func addContacts() {
        if contacts.count == 1 {
            self.addInitials()
            self.buildSimpleContactItem()
        } else {
            self.buildMultipleContactItem()
        }
    }

    func buildSimpleContactItem() {
        guard let contact = contacts.first else { return }
        if let alias = contact.alias, !alias.isEmpty {
            let value = TextWithAccessibility(text: alias,
                                              accessibility: AccessibilityBizumReuseContact.reuseContactLabelAlias,
                                              style: LocalizedStylableTextConfiguration(font: UIFont.santander(family: .text,
                                                                                                               type: .bold,
                                                                                                               size: 16)))
            let phone = TextWithAccessibility(text: contact.phone.tlfFormatted(),
                                              accessibility: AccessibilityBizumReuseContact.reuseContactLabelIdentifier,
                                              style: LocalizedStylableTextConfiguration(font: .santander(family: .text,
                                                                                                         type: .regular,
                                                                                                         size: 14)))
            let item = ReuseSimpleContactViewModel(title: value, info: phone)
            self.items.append(.simple(item))
        } else {
            let value = TextWithAccessibility(text: contact.identifier.tlfFormatted(),
                                              accessibility: AccessibilityBizumReuseContact.reuseContactLabelIdentifier,
                                              style: LocalizedStylableTextConfiguration(font: UIFont.santander(family: .text,
                                                                                                               type: .bold,
                                                                                                               size: 16)))
            let item = ReuseSimpleContactViewModel(title: value, info: nil)
            self.items.append(.simple(item))
        }
    }

    func addOptions() {
        self.items.append(.options([.send, .request]))
    }

    func buildMultipleContactItem() {
        var viewModels: [BizumInitialsViewModel] = []
        contacts.forEach { contact in
            let color = getColor(contact.identifier)
            let viewModel = BizumInitialsViewModel(colorModel: color, initials: contact.name?.nameInitials ?? "")
            viewModels.append(viewModel)
        }
        let viewModel = ReuseMultipleContactViewModel(initialsViewModel: viewModels)
        self.items.append(.multiple(viewModel))
    }

    func getColor(_ identifier: String) -> ColorsByNameViewModel {
        let colorsEngine: ColorsByNameEngine = self.dependenciesResolver.resolve()
        let colorType = colorsEngine.get(identifier)
        return ColorsByNameViewModel(colorType)
    }
}
