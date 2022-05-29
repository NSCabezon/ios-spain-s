import CoreFoundationLib
import XCTest
@testable import Bizum

class ReuseContactBuilderTests: XCTestCase {
    private let dependencies: DependenciesResolver & DependenciesInjector =  DependenciesDefault()
    private var presenter: ReuseContactPresenterProtocol?

    override func setUp() {
        self.dependencies.register(for: ColorsByNameEngine.self, with: { _ in
            return ColorsByNameEngine()
        })
        self.presenter = ReuseContactPresenter(dependenciesResolver: dependencies, contacts: self.generateContacts())
    }

    func testReuseContactBuilderShouldHasThreeContacts() {
        self.dependencies.register(for: BizumDetailOperationConfiguration.self, with: { _ in
            return BizumDetailOperationConfiguration(contacts: self.generateContacts())
        })
        let presenterConfiguration: BizumDetailOperationConfiguration = dependencies.resolve()
        let contacts = presenterConfiguration.contacts
        let builder = ReuseContactBuilder(contacts: contacts, dependenciesResolver: dependencies)
        builder.build()
        let items = builder.items
        var initialsViewModel: [BizumInitialsViewModel] = []
        items.forEach { (item) in
            switch item {
            case .multiple(let items): initialsViewModel = items.initialsViewModel
            default: break
            }
        }
        XCTAssert(initialsViewModel.count == contacts.count)
    }

    func testReuseContactBuilderShouldHasInitialName() {
        let contact = BizumContactEntity(identifier: "+34625312027", name: "Estela Isabel D. A.", phone: "+34625312027", alias: "Estela Isabel D. A.")
        self.dependencies.register(for: BizumDetailOperationConfiguration.self, with: { _ in
            return BizumDetailOperationConfiguration(contacts: [contact])
        })
        let presenterConfiguration: BizumDetailOperationConfiguration = dependencies.resolve()
        let contacts = presenterConfiguration.contacts
        let builder = ReuseContactBuilder(contacts: contacts, dependenciesResolver: dependencies)
        builder.build()
        let items = builder.items
        guard let firstContact = items.first else { return XCTFail("Builder fail") }
        var initials: String?
        switch firstContact {
        case .initials(let item): initials = item.initials
        default: break
        }
        XCTAssert(initials == contact.name?.nameInitials)
    }

    func testReuseContactBuilderShouldHasTitle() {
        let contact = BizumContactEntity(identifier: "+34625312027", name: "Estela Isabel D. A.", phone: "+34625312027", alias: "Estela Isabel D. A.")
        self.dependencies.register(for: BizumDetailOperationConfiguration.self, with: { _ in
            return BizumDetailOperationConfiguration(contacts: [contact])
        })
        let presenterConfiguration: BizumDetailOperationConfiguration = dependencies.resolve()
        let contacts = presenterConfiguration.contacts
        let builder = ReuseContactBuilder(contacts: contacts, dependenciesResolver: dependencies)
        builder.build()
        let items = builder.items
        let simpleViewModel = items[1]
        var title: String?
        switch simpleViewModel {
        case .simple(let item): title = item.title.text
        default:break
        }
        XCTAssert(title == contact.name)
    }

    func testReuseContactBuilderShouldHasPhone() {
        let contact = BizumContactEntity(identifier: "+34625312027", name: "Estela Isabel D. A.", phone: "+34625312027", alias: "Estela Isabel D. A.")
        self.dependencies.register(for: BizumDetailOperationConfiguration.self, with: { _ in
            return BizumDetailOperationConfiguration(contacts: [contact])
        })
        let presenterConfiguration: BizumDetailOperationConfiguration = dependencies.resolve()
        let contacts = presenterConfiguration.contacts
        let builder = ReuseContactBuilder(contacts: contacts, dependenciesResolver: dependencies)
        builder.build()
        let items = builder.items
        let simpleViewModel = items[1]
        var info: String?
        switch simpleViewModel {
        case .simple(let item): info = item.info?.text
        default: break
        }
        XCTAssert(info == contact.phone.tlfFormatted())
    }

    func testReuseContactBuilderShouldHasOneContactWithoutName() {
        let contact = BizumContactEntity(identifier: "+34625312027", name: nil, phone: "+34625312027", alias: nil)
        self.dependencies.register(for: BizumDetailOperationConfiguration.self, with: { _ in
            return BizumDetailOperationConfiguration(contacts: [contact])
        })
        let presenterConfiguration: BizumDetailOperationConfiguration = dependencies.resolve()
        let contacts = presenterConfiguration.contacts
        let builder = ReuseContactBuilder(contacts: contacts, dependenciesResolver: dependencies)
        builder.build()
        let items = builder.items
        let initialViewModel = items[0]
        var emptyInitials: Bool = false
        switch initialViewModel {
        case .initials(let item):
            emptyInitials = item.initials.isEmpty
        default:
            break
        }
        XCTAssert(emptyInitials)
    }

    func testReuseContactBuilderShouldHasOneContactWithOnlyTitle() {
        let contact = BizumContactEntity(identifier: "+34625312027", name: nil, phone: "+34625312027", alias: nil)
        self.dependencies.register(for: BizumDetailOperationConfiguration.self, with: { _ in
            return BizumDetailOperationConfiguration(contacts: [contact])
        })
        let presenterConfiguration: BizumDetailOperationConfiguration = dependencies.resolve()
        let contacts = presenterConfiguration.contacts
        let builder = ReuseContactBuilder(contacts: contacts, dependenciesResolver: dependencies)
        builder.build()
        let items = builder.items
        let simpleViewModel = items[1]
        var title = String()
        switch simpleViewModel {
        case .simple(let item): title = item.title.text
        default: break
        }
        XCTAssert(title == contact.phone.tlfFormatted())
    }

    func generateContacts() -> [BizumContactEntity] {
        let contact1 = BizumContactEntity(identifier: "+34693003729", name: "contact1", phone: "34693003729")
        let contact2 = BizumContactEntity(identifier: "+34687894552", name: "contact2", phone: "34687894552")
        let contact3 = BizumContactEntity(identifier: "+34625312027", name: "contact3", phone: "34625312027")
        return [contact1, contact2, contact3]
    }

    func getColor(_ identifier: String) -> ColorsByNameViewModel {
        let colorsEngine: ColorsByNameEngine = self.dependencies.resolve()
        let colorType = colorsEngine.get(identifier)
        return ColorsByNameViewModel(colorType)
    }
}
