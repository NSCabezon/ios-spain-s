//
//  LoadContactsSuperUseCase.swift
//  Transfer
//
//  Created by José Carlos Estela Anguita on 04/02/2020.
//

import CoreFoundationLib
import CoreDomain
import Foundation

protocol LoadContactsSuperUseCaseDelegate: AnyObject {
    func didFinishSuccessfully(with contacts: [PayeeRepresentable])
    func didFinishWithError(_ error: String?)
}

final class LoadContactsSuperUseCaseDelegateHandler: SuperUseCaseDelegate {
    private let sortedHandler: ContactsSortedHandlerProtocol
    var contacts: [PayeeRepresentable] = []
    var favoriteContacts: [String]?
    weak var delegate: LoadContactsSuperUseCaseDelegate?
    
    init(sortedHandler: ContactsSortedHandlerProtocol) {
        self.sortedHandler = sortedHandler
    }
    
    func onSuccess() {
        let favorites: [PayeeRepresentable] = self.sortedHandler.sortContacts(self.contacts)
        let sortedFavoriteContacts = getFavoritesSorted(favorites: favorites, favoriteContacts: favoriteContacts)
        self.delegate?.didFinishSuccessfully(with: sortedFavoriteContacts)
    }
    
    func onError(error: String?) {
        self.delegate?.didFinishWithError(error)
    }
}

private extension LoadContactsSuperUseCaseDelegateHandler {
    func getFavoritesSorted(favorites: [PayeeRepresentable], favoriteContacts: [String]?) -> [PayeeRepresentable] {
        guard let favoriteContacts = favoriteContacts else { return favorites }
        let favoriteContactsNotEmpty =  favoriteContacts.filter {!$0.isEmpty}
        let sortedFavorites = favoriteContactsNotEmpty.compactMap { (contact) -> PayeeRepresentable? in
            return favorites.first { contact == $0.payeeAlias }
        }
        let restFavorites = favorites.filter { favorite in
            return !sortedFavorites.contains {
                favorite.payeeAlias == $0.payeeAlias
            }
        }
        return sortedFavorites + restFavorites
    }
}

final class LoadContactsSuperUseCase: SuperUseCase<LoadContactsSuperUseCaseDelegateHandler> {
    private let dependenciesResolver: DependenciesResolver
    private let contactsSuperUseCaseDelegateHandler: LoadContactsSuperUseCaseDelegateHandler
    
    var delegate: LoadContactsSuperUseCaseDelegate? {
        get {
            return self.contactsSuperUseCaseDelegateHandler.delegate
        }
        set {
            self.contactsSuperUseCaseDelegateHandler.delegate = newValue
        }
    }
    
    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = DependenciesDefault(father: dependenciesResolver)
        
        let sortedHandler: ContactsSortedHandlerProtocol = self.dependenciesResolver.resolve(firstTypeOf: ContactsSortedHandlerProtocol.self)
        self.contactsSuperUseCaseDelegateHandler = LoadContactsSuperUseCaseDelegateHandler(sortedHandler: sortedHandler)
        super.init(useCaseHandler: dependenciesResolver.resolve(for: UseCaseHandler.self),
                   delegate: self.contactsSuperUseCaseDelegateHandler)
    }
    
    // MARK: - Overrided methods
    
    override func setupUseCases() {
        // Gets all contacts
        self.contactsSuperUseCaseDelegateHandler.contacts.removeAll()
        self.add(self.dependenciesResolver.resolve(for: LoadContactsUseCase.self)) { result in
            result.contacts.forEach(self.handleContact)
            self.contactsSuperUseCaseDelegateHandler.favoriteContacts = result.favoriteContacts
        }
    }
    
    // MARK: - Private methods
    
    /// Handle each contact. If the contact is of type No Sepa, we need to fetch the detail
    /// - Parameter contact: The contact to check
    private func handleContact(_ contact: PayeeRepresentable) {
        guard contact.ibanRepresentable?.countryCode == nil || contact.accountType == "C" || contact.accountType == "D" else {
            return self.contactsSuperUseCaseDelegateHandler.contacts.append(contact)
        }
        self.fetchDetail(of: contact)
    }
    
    /// Fetch the detail of the contact
    /// - Parameter contact: The contact to load the No Sepa Detail
    private func fetchDetail(of contact: PayeeRepresentable) {
        let useCase = self.dependenciesResolver.resolve(for: GetNoSepaPayeeDetailUseCase.self)
        let useCaseInput = GetNoSepaPayeeDetailUseCaseInput(favorite: contact)
        self.add(useCase.setRequestValues(requestValues: useCaseInput), isMandatory: false) { result in
            self.handleNoSepaPayeeDetail(of: contact, result: result)
        }
    }
    
    /// Method to handle the result of the No Sepa Detail request. Once we have the result, we have to update the `countryCode` of the Favorite.
    /// - Parameters:
    ///   - contact: The contact
    ///   - result: The result of the detail request
    private func handleNoSepaPayeeDetail(of contact: PayeeRepresentable, result: GetNoSepaPayeeDetailUseCaseOkOutput) {
        let destinationCountryCode: String = {
            guard let bankCountryCode = result.payee.bankCountryCode, !bankCountryCode.isEmpty else {
                return result.payee.countryCode ?? ""
            }
            return bankCountryCode
        }()
        var contact = contact
        contact.countryCode = destinationCountryCode
        self.contactsSuperUseCaseDelegateHandler.contacts.append(contact)
    }
}
