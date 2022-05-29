//

import Foundation

class CustomizeAppPresenter: PrivatePresenter<CustomizeAppViewController, PersonalAreaNavigatorProtocol, CustomizeAppPresenterProtocol> {

    // MARK: - TrackerManager

    override var screenId: String? {
        return nil
    }

    // MARK: -

    override func loadViewData() {
        super.loadViewData()
        view.styledTitle = stringLoader.getString("toolbar_title_appSetting")
        makeSections()
    }

    private func makeSections() {
        let sectionViewModel = TableModelViewSection()
        let stringLoader = dependencies.stringLoader
        let title = SettingsTitleHeaderViewModel(title: stringLoader.getString("appSetting_title_appCustomize"))
        sectionViewModel.setHeader(modelViewHeader: title)
        let optionsModelView = PersonalAreaOneLineViewModel(text: stringLoader.getString("appSetting_label_displayOptions"), dependencies: dependencies)
        optionsModelView.isFirst = true
        optionsModelView.isLast = false
        optionsModelView.isSeparatorVisible = true
        optionsModelView.didSelect = { [weak self] in
            self?.navigator.navigateToVisualOptions()
        }
        sectionViewModel.add(item: optionsModelView)
        let avatarModelView = PersonalAreaOneLineViewModel(text: stringLoader.getString("appSetting_label_customizeAvatar"), dependencies: dependencies)
        avatarModelView.isFirst = false
        avatarModelView.isLast = true
        avatarModelView.didSelect = { [weak self] in
            guard let presenter = self else { return }
            presenter.navigator.navigateToCustomizeAvatar()
        }
        sectionViewModel.add(item: avatarModelView)
        view.sections = [sectionViewModel]
    }
}

extension CustomizeAppPresenter: ToolTipablePresenter {
    var toolTipBackView: ToolTipBackView {
        return view
    }
}

extension CustomizeAppPresenter: CustomizeAppPresenterProtocol {
    func selected(indexPath: IndexPath) {
        let actionableItem = view.sections[indexPath.section].items[indexPath.row] as? Executable
        actionableItem?.execute()
    }
}

extension CustomizeAppPresenter: Presenter {}

extension CustomizeAppPresenter: SideMenuCapable {
    func toggleSideMenu() {
        navigator.toggleSideMenu()
    }
    var isSideMenuAvailable: Bool {
        return true
    }
}

extension CustomizeAppPresenter: CustomizeAppSwitchAndToolTipDelegate {
    func switchValueChanged(inViewModel viewModel: CustomizeAppSwitchAndToolTipModelView) {
    }
}
