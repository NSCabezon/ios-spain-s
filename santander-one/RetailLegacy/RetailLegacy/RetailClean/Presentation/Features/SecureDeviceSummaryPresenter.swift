import Operative

class SecureDeviceSummaryPresenter: OperativeStepPresenter<LisboaSummaryViewController, VoidNavigator, LisboaSummaryPresenterProtocol> {
    override var screenId: String? {
        return container?.operative.screenIdSummary
    }
    override var isBackable: Bool {
        return false
    }
    override var shouldShowProgress: Bool {
        return false
    }
    
    override func loadViewData() {
        super.loadViewData()
        guard let operativeData: EnableOtpPushOperativeData = container?.provideParameter() else {
            return
        }
        let header = [
            HeaderInfoSummaryModel(title: "summary_item_terminal",
                                   info: operativeData.deviceModel ?? ""),
            HeaderInfoSummaryModel(title: "summary_item_alias",
                                   info: operativeData.alias ?? ""),
            HeaderInfoSummaryModel(title: "summary_item_registrationDate",
                                   info: dependencies.timeManager.toString(date: Date(),
                                                                           outputFormat: TimeFormat.d_MMM_yyyy) ?? "")]
        let footer = [FooterInfoSummaryModel(title: "generic_button_globalPosition",
                                             image: "icnPg",
                                             action: { [weak self] in self?.goToPG() })]
        view.configureView(title: "summary_title_deviceRightRegister",
                           header: header,
                           footer: footer)
    }
    
    override func getTrackParameters() -> [String: String]? {
        return container?.operative.getTrackParametersSummary()
    }
    
    private func goToPG() {
        self.dependencies.trackerManager.trackEvent(screenId: TrackerPagePrivate.OtpPushOperativeSummary().page, eventId: TrackerPagePrivate.OtpPushOperativeSummary.Action.goToPG.rawValue, extraParameters: [:])
        if var operativeData: EnableOtpPushOperativeData = container?.provideParameter() {
            operativeData.closeReason = .globalPosition
            container?.saveParameter(parameter: operativeData)
        }
        container?.stepFinished(presenter: self)
    }
}

extension SecureDeviceSummaryPresenter: Presenter {}

extension SecureDeviceSummaryPresenter: LisboaSummaryPresenterProtocol {
    func didTapClose() {
        if var operativeData: EnableOtpPushOperativeData = container?.provideParameter() {
            operativeData.closeReason = .exit
            container?.saveParameter(parameter: operativeData)
        }
        container?.stepFinished(presenter: self)
    }
}
