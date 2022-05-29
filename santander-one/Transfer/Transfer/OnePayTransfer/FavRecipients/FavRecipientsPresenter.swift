//
//  FavRicipientsPresenter.swift
//  Transfer
//
//  Created by Ignacio González Miró on 26/05/2020.
//

import Foundation
import CoreFoundationLib
import Operative
import UI
import TransferOperatives

public protocol FavRecipientsPresenterProtocol: AnyObject {
    var view: FavRecipientsPresenterProtocol? { get set }
    func viewDidLoad()
}

final class FavRecipientsPresenter {
    var view: FavRecipientsPresenterProtocol?
    let dependenciesResolver: DependenciesResolver
    
    var coordinator: TransferHomeModuleCoordinator {
        return self.dependenciesResolver.resolve(for: TransferHomeModuleCoordinator.self)
    }
    var contactsEngine: ContactsEngineProtocol {
        return self.dependenciesResolver.resolve(for: ContactsEngineProtocol.self)
    }
    
    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
    }
}

extension FavRecipientsPresenter: FavRecipientsPresenterProtocol {
    func viewDidLoad() {
    }
}
