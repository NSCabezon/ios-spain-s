//
//  ReuseContactPresenter.swift
//  Bizum
//
//  Created by Margaret López Calderón on 13/11/2020.
//

import CoreFoundationLib

protocol ReuseContactPresenterProtocol {
    var view: ReuseContactViewProtocol? { get set }
    func viewDidLoad()
    func didSelectDismiss()
    func didSelectOption(_ option: BizumHomeOptionViewModel?)
}

final class ReuseContactPresenter {
    weak var view: ReuseContactViewProtocol?
    let dependenciesResolver: DependenciesResolver
    private let contacts: [BizumContactEntity]

    init(dependenciesResolver: DependenciesResolver, contacts: [BizumContactEntity]) {
        self.dependenciesResolver = dependenciesResolver
        self.contacts = contacts
    }
}

extension ReuseContactPresenter: ReuseContactPresenterProtocol {
    func viewDidLoad() {
        let builder = ReuseContactBuilder(contacts: contacts, dependenciesResolver: dependenciesResolver)
        builder.build()
        self.view?.updateView(builder.items)
    }

    func didSelectDismiss() {
        self.coordinator.didSelectDismiss()
    }

    func didSelectOption(_ option: BizumHomeOptionViewModel?) {
        guard let option = option else { return }
        switch option {
        case .donation, .qrCode:
            self.view?.showFeatureNotAvailableToast()
        case .send:
            self.showSendMoney()
        case .request:
            self.showRequestMoney()
        case .payGroup:
            break
        case .fundMoneySent:
            break
        }
    }
}

private extension ReuseContactPresenter {
    var coordinator: ReuseContactCoordinatorProtocol {
         return self.dependenciesResolver.resolve(for: ReuseContactCoordinatorProtocol.self)
     }

    func showSendMoney() {
        let contactsWithIdentifier = contacts.filter { !$0.identifier.isEmpty }
        self.coordinator.didSelectGoToSendMoney(contactsWithIdentifier)
    }

    func showRequestMoney() {
        let contactsWithIdentifier = contacts.filter { !$0.identifier.isEmpty }
        self.coordinator.didSelectGoToRequestMoney(contactsWithIdentifier)
    }
}
