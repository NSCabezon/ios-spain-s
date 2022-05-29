//
//  OpenWebviewNewContactsCapable.swift
//  RetailLegacy
//
//  Created by José María Jiménez Pérez on 7/5/21.
//

import CoreFoundationLib
import WebViews

protocol OpenWebviewNewContactsCapable: class {
    var storeManager: ContactsStoreManager { get }
    var delegate: WebViewLinkHandlerDelegate? { get }
    var stringLoader: StringLoader { get }
    var webContactsListLimit: Int { get }
    var serializedTag: String { get }
    var oldJavascriptFunction: String { get }
    var newJavascriptFunction: String { get }
    func handleNewContactsVersion()
    func handleOldContactsVersion()
}

extension OpenWebviewNewContactsCapable {
    var webContactsListLimit: Int {
        return 999
    }
    
    var serializedTag: String {
        return "[SERIALIZED]"
    }
    
    var oldJavascriptFunction: String {
        return "setContact(decodeURIComponent('\(self.serializedTag)').replace(new RegExp(/\\+/, 'gi'), ' '));"
    }
    var newJavascriptFunction: String {
        return "setContacts(decodeURIComponent('\(self.serializedTag)').replace(new RegExp(/\\+/, 'gi'), ' '));"
    }
    
    func handleNewContactsVersion() {
        storeManager.scanContacts { [weak self] contacts, status in
            switch status {
            case .success: break
            case .failure(let error):
                self?.handle(error: error)
                return
            }
            guard let contacts = contacts, !contacts.isEmpty, let self = self else {
                return
            }
            if contacts.count > self.webContactsListLimit {
                self.handleOldContactsVersion()
            } else {
                self.injectInWeb(javascriptFunction: self.newJavascriptFunction, contacts: contacts, forVersion: .v2)
            }
        }
    }
    
    func handleOldContactsVersion() {
        delegate?.showContacts(selected: { [weak self] contacts in
            guard let self = self else { return }
            let mappedContacts = contacts.map { UserContact(identifier: $0.identifier, name: $0.name, surname: $0.surname, phones: $0.phonesRepresentable.map { UserContactPhone(alias: $0.alias, number: $0.number) }, thumbnail: $0.thumbnail)}
            self.injectInWeb(javascriptFunction: self.oldJavascriptFunction, contacts: mappedContacts, forVersion: .v1)
        })
    }
}

private extension OpenWebviewNewContactsCapable {
    func handle(error: ContactsPersmissionError) {
        if case .denied = error {
            delegate?.displayError(title: stringLoader.getString("generic_title_permissionsDenied"), message: stringLoader.getString("permissionsAlert_text_contact"), action: .goToSettings, showCancel: true)
        }
    }
    
    func injectInWeb(javascriptFunction: String, contacts: [UserContact]?, forVersion version: ContactsSerializationVersion) {
        guard let contacts = contacts, let serialization = storeManager.serialize(contacts: contacts, forVersion: version), let encoded = serialization.urlCombinedEncoded else {
            return
        }
        delegate?.inject(javascript: javascriptFunction.replace(serializedTag, encoded))
    }
}
