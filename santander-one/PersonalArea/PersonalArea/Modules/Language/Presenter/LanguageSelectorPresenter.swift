//
//  LanguageSelectorPresenter.swift
//  PersonalArea
//
//  Created by alvola on 09/03/2020.
//

import CoreFoundationLib

protocol LanguageSelectorPresenterProtocol: AnyObject {
    var view: LanguageSelectorViewProtocol? { get set }
    var dataManager: PersonalAreaDataManagerProtocol? { get set }
    var moduleCoordinator: LanguageSelectorModuleCoordinator? { get set }
    
    func viewDidLoad()
    func backDidPress()
    func closeDidPress()
    func saveCurrentLanguage(_ language: LanguageType)
}

final class LanguageSelectorPresenter {
    weak var view: LanguageSelectorViewProtocol?
    weak var dataManager: PersonalAreaDataManagerProtocol?
    weak var moduleCoordinatorNavigator: PersonalAreaMainModuleNavigator?
    weak var moduleCoordinator: LanguageSelectorModuleCoordinator?
    
    private let dependenciesResolver: DependenciesResolver
    private var personalAreaModuleCoordinator: PersonalAreaMainModuleCoordinatorDelegate? {
        return dependenciesResolver.resolve(for: PersonalAreaMainModuleCoordinatorDelegate.self)
    }
    
    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
    }
    
    // MARK: - privateMethods
    
    private func getCurrentLanguage() {
        dataManager?.getCurrentLanguage({ [weak self] (response) in
            guard let languages = response.languages, let current = response.currentLanguage else { return }
            self?.view?.setCurrentLanguage(current)
            self?.view?.setLanguages(languages)
            }, failure: { _ in })
    }
    
    private func setCurrentLanguage(language: LanguageType) {
        dataManager?.updateCurrentLanguage(language: language, { [weak self] (result) in
            self?.personalAreaModuleCoordinator?.didChangeLanguage(language: result.language)
        }, failure: { [weak self] _ in
            self?.view?.showAlert(localized("generic_error_txt"))
        })
    }
}

extension LanguageSelectorPresenter: LanguageSelectorPresenterProtocol {
    func viewDidLoad() {
        getCurrentLanguage()
        self.trackScreen()
    }
    func backDidPress() { moduleCoordinator?.end() }
    func closeDidPress() { moduleCoordinator?.end() }
    func saveCurrentLanguage(_ language: LanguageType) {
        self.trackEvent(.change, parameters: [.language: language.rawValue])
        setCurrentLanguage(language: language)
        moduleCoordinator?.end()
    }
}

extension LanguageSelectorPresenter: AutomaticScreenActionTrackable {
    var trackerManager: TrackerManager {
        return dependenciesResolver.resolve(for: TrackerManager.self)
    }
    
    var trackerPage: PersonalAreaConfigurationLanguagePage {
        return PersonalAreaConfigurationLanguagePage()
    }
}
