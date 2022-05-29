//
//  AppInfoModulePresenter.swift
//  PersonalArea
//
//  Created by alvola on 21/04/2020.
//

import CoreFoundationLib

protocol AppInfoPresenterProtocol: AnyObject {
    var view: AppInfoViewProtocol? { get set }
    var moduleCoordinatorNavigator: PersonalAreaMainModuleNavigator? { get set }
    var moduleCoordinator: AppInfoModuleCoordinator? { get set }
    
    func didLoadView()
    func didPressBack()
    func didPressClose()
    func didPressUpdate()
}

final class AppInfoModulePresenter {
    
    weak var view: AppInfoViewProtocol?
    weak var moduleCoordinatorNavigator: PersonalAreaMainModuleNavigator?
    weak var moduleCoordinator: AppInfoModuleCoordinator?
    
    private let dependenciesResolver: DependenciesResolver
    private var personalAreaModuleCoordinator: PersonalAreaMainModuleCoordinatorDelegate? {
        return dependenciesResolver.resolve(for: PersonalAreaMainModuleCoordinatorDelegate.self)
    }
    private var datasource: AppInfoDataSourceProtocol {
        return dependenciesResolver.resolve(for: AppInfoDataSourceProtocol.self)
    }
    
    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
    }
    
    // MARK: - privateMethods
    
    private func getAppVersionNameAndSO() {
        view?.setAppName(Bundle.main.infoDictionary?["CFBundleDisplayName"] as? String ?? "")
        view?.setAppVersion("v" + (Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""),
                            soVersion: UIDevice.current.systemVersion)
    }
    
    private func needsUpgrade(_ currentVersion: String, minVersion: String) -> Bool {
        return currentVersion.compare((Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""),
                                      options: .numeric) == .orderedDescending
            && UIDevice.current.systemVersion.compare(minVersion, options: .numeric) != .orderedAscending
    }
}

extension AppInfoModulePresenter: AppInfoPresenterProtocol {
    func didLoadView() {
        self.view?.showLoading { [weak self] in
            self?.getAppVersionNameAndSO()
            self?.datasource.getAppInfo({ [weak self] (resp) in
                DispatchQueue.global(qos: .userInitiated).async {
                    let versionsShorted = resp.versions.sorted {
                        $0.key.compare($1.key, options: .numeric) == .orderedDescending
                    }
                    let currentVersion = versionsShorted.first?.key ?? ""
                    let minVersion = versionsShorted.first?.value["minVersion"] ?? ""
                    guard !versionsShorted.isEmpty else {
                        self?.view?.dismissLoading(completion: nil)
                        return
                    }
                    let history: [VersionViewModel] = versionsShorted.map {
                        let desc = $0.value["changeLog"] ?? ""
                        let attrib = desc.htmlToAttributedStringWithOptions([.font: UIFont.santander(type: .light,
                                                                                                      size: 15.0),
                                                                             .foregroundColor: UIColor.lisboaGray])
                        
                        return VersionViewModel(number: "V" + $0.key,
                                                description: attrib)
                    }
                    DispatchQueue.main.async {
                        self?.view?.setVersionHistory(history)
                        self?.view?.dismissLoading { [weak self] in
                            self?.view?.showUpdate(self?.needsUpgrade(currentVersion, minVersion: minVersion) ?? true)
                        }
                    }
                }
            })
        }
    }
    
    func didPressBack() {
        moduleCoordinator?.end()
    }
    
    func didPressClose() {
        moduleCoordinator?.end()
    }
    
    func didPressUpdate() {
        personalAreaModuleCoordinator?.openAppStore()
    }
}
