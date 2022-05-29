//

import Foundation
import CoreFoundationLib

protocol AppInfoNavigatorProtocol: MenuNavigator, AppStoreNavigatable {}

class AppInfoPresenter: PrivatePresenter<AppInfoViewController, AppInfoNavigatorProtocol, AppInfoPresenterProtocol>, SingleSignOn {
    
    let appInfo: AppInfoDO
    
    var appName: String {
        return Bundle.main.infoDictionary?["CFBundleDisplayName"] as? String ?? "Desconocido"
    }
    
    init(_ dependencies: PresentationComponent, sessionManager: CoreSessionManager, navigator: AppInfoNavigatorProtocol, appInfo: AppInfoDO) {
        self.appInfo = appInfo
        super.init(dependencies: dependencies, sessionManager: sessionManager, navigator: navigator)
        self.barButtons = [.menu]
    }
    
    override func loadViewData() {
        super.loadViewData()
        view.title = stringLoader.getString("toolbar_title_appInformation").text

        let iconSection = TableModelViewSection()
        let iconItem = ChangeLogIconViewModel(title: appName, iconName: "appSan", buttonText: stringLoader.getString("appInformation_button_update").text, showUpgrade: needsUpgrade(), buttonCallback: { [weak self] () -> Void in
            
            guard let strongSelf = self else { return }
            strongSelf.openAppStore()

        }, dependencies: dependencies)
        iconSection.items = [iconItem]
        
        let versionSection = TableModelViewSection()
        let versionSectionHeader = TitledTableModelViewHeader()
        versionSectionHeader.title = stringLoader.getString("appInformation_title_version")
        versionSection.setHeader(modelViewHeader: versionSectionHeader)
        let appVersionItem = ChangeLogVersionViewModel(title: stringLoader.getString("appInformation_label_appVersion"), value: "v"+appInfo.appVersion, isFirst: true, isLast: false, dependencies: dependencies)
        versionSection.items.append(appVersionItem)
        
        let osVersionItem = ChangeLogVersionViewModel(title: stringLoader.getString("appInformation_label_osVersion"), value: appInfo.osVersion, isFirst: false, isLast: true, dependencies: dependencies)
        versionSection.items.append(osVersionItem)
        
        let orderedVersions = appInfo.dto.getVersions.filter({$0.key != ""}).sorted(by: {$0.key.compare($1.key, options: .numeric) == .orderedDescending})
        if orderedVersions.count > 0 {
            let changeLogSection = TableModelViewSection()
            let changeLogSectionHeader = TitledTableModelViewHeader()
            changeLogSectionHeader.title = stringLoader.getString("appInformation_label_newsLastUpdate")
            changeLogSection.setHeader(modelViewHeader: changeLogSectionHeader)
            
            var i = 0
            
            for (key, value) in orderedVersions {
                let elementHeader = ChangeLogFirstViewModel(title: "V"+key, dependencies: dependencies, isFirst: i == 0, isLast: false)
                changeLogSection.add(item: elementHeader)
                
                let element = ChangeLogViewModel(description: value["changeLog"] ?? "", dependencies: dependencies, isFirst: false, isLast: i == appInfo.dto.getVersions.count-1)
                changeLogSection.add(item: element)
                i += 1
            }
            
            view.sections = [iconSection, versionSection, changeLogSection]
        } else {
            view.sections = [iconSection, versionSection]
        }
    }
    
    func needsUpgrade() -> Bool {
        let orderedVersions = appInfo.dto.getVersions.filter({$0.key != ""}).sorted(by: {$0.key.compare($1.key, options: .numeric) == .orderedDescending})
        if let lastAvailableVersion = orderedVersions.first?.key, orderedVersions.first?.value["minVersion"] != nil {
            if lastAvailableVersion.compare(appInfo.appVersion, options: .numeric) == .orderedDescending {
                return true
            }
        }

        return false
    }
    
    var appStoreNavigator: AppStoreNavigatable {
        return navigator
    }
    
    var usecaseProvider: UseCaseProvider {
        return dependencies.useCaseProvider
    }
}

extension AppInfoPresenter: AppInfoPresenterProtocol {
    var isSideMenuAvailable: Bool {
        return true
    }
    
    func toggleSideMenu() {
        navigator.toggleSideMenu()
    }
}

extension AppInfoPresenter: Presenter {}
