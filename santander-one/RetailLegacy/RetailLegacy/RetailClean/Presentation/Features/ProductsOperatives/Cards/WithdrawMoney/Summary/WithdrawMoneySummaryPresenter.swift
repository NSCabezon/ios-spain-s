//
//  WithdrawMoneySummaryPresenter.swift
//  RetailClean
//
//  Created by David Gálvez Alonso on 24/02/2020.
//  Copyright © 2020 Ciber. All rights reserved.
//

import CoreFoundationLib

protocol WithdrawMoneySummaryPresenterProtocol: OperativeStepPresenterProtocol, Presenter {
    func finishOperativeSelected()
}
extension WithdrawMoneySummaryPresenterProtocol {
    var shouldShowProgressBar: Bool {
        false
    }
}

class WithdrawMoneySummaryPresenter: OperativeStepPresenter<WithdrawMoneySummaryViewController, WithdrawMoneySummaryNavigatorProtocol, WithdrawMoneySummaryPresenterProtocol>, WithdrawMoneySummaryPresenterProtocol {
    
    override var screenId: String? {
        return container?.operative.screenIdSummary
    }
    override var isBackable: Bool {
        return false
    }
    override var isProgressBarVisible: Bool {
        return false
    }
    
    override func loadViewData() {
        super.loadViewData()

        addFooter()
        addActionButtons()
        addSummaryData()
        createSharingText()
    }
    
    override func getTrackParameters() -> [String: String]? {
        return container?.operative.getTrackParametersSummary()
    }
    
    private var sharingText = ""

    private func addFooter() {
        let footer = [FooterWithdrawSummaryModel(title: "generic_button_anotherSendMoney", image: "icnEnviarDinero", identifier: "withdrawMoneySummary_footer_sendMoney", action: { self.goToSendMoney() }),
                      FooterWithdrawSummaryModel(title: "generic_button_globalPosition", image: "icnPg", identifier: "withdrawMoneySummary_footer_gp", action: { self.goToPG() }),
                      FooterWithdrawSummaryModel(title: "generic_button_improve", image: "icnHelpUsMenu", identifier: "withdrawMoneySummary_footer_improve", action: { self.goToOpinator() })]
        view.configureView(footer: footer)
    }
    
    private func addActionButtons() {
        let viewModels = [
            SummaryActionViewModel(image: "icnAtmCard",
                                   title: localized(key: "generic_button_atm").text,
                                   identifier: "withdrawMoneySummary_atmButton",
                                   action: goToATM),
            SummaryActionViewModel(image: "icnShare",
                                   title: localized(key: "cardsOption_button_share").text,
                                   identifier: "withdrawMoneySummary_shareButton",
                                   action: goToShare)]
        self.view.addActions(viewModels)
    }
    
    private func addSummaryData() {
        guard let container = container else {
            return
        }
        let operativeData: WithdrawalWithCodeOperativeData = container.provideParameter()
        guard let cashWithDrawal = operativeData.cashWithDrawal, let amountDO = operativeData.amount else {
            return
        }
        let code = cashWithDrawal.code
        let amount = amountDO.getFormattedAmountUI()
        let date = dependencies.timeManager.toString(input: cashWithDrawal.date, inputFormat: .YYYYMMDD_T_HHMM, outputFormat: .d_MMM_yyyy) ?? cashWithDrawal.date
        let fee = cashWithDrawal.fee.getAbsFormattedAmountUIWith1M()
        let phone = cashWithDrawal.phone.obfuscateNumber(withNumberOfAsterisks: 5)
        let codQR = cashWithDrawal.codQR ?? ""
        self.view.setSummaryData(code: code, amount: amount, date: date, fee: fee, phone: phone, codQR: codQR)
    }
    
    private func createSharingText() {
        guard let container = container else {
            return
        }
        var info = [SummaryItemData]()
        if let data = container.operative.getSummaryInfo() {
            info = data
        }
        
        sharingText = info.reduce("", { (text, data) in
            if data.isShareable {
                return text + data.description + "\n"
            } else {
                return text
            }
        })
        
        if let subtitle = container.operative.getSummarySubtitle() {
            sharingText = container.operative.getSummaryTitle().text + "\n" + subtitle.text + "\n\n" + sharingText
        } else {
            sharingText = container.operative.getSummaryTitle().text + "\n\n" + sharingText
        }
    }
    
    private func goToPG() {
        guard let container = container else {
            return
        }
        navigator.goToPG(container: container)
    }
    
    private func goToSendMoney() {
        finishOperativeSelected()
        navigator.goToTransfers()
    }
    
    private func goToOpinator() {
        guard let container = container, let opinatorPage = container.operative.opinatorPage else {
            return
        }
        let parameters = container.operative.getExtraTrackShareParametersSummary() ?? [:]
        trackEvent(eventId: TrackerPagePrivate.Generic.Action.help.rawValue, parameters: parameters)
        openOpinator(forRegularPage: opinatorPage, onError: { [weak self] errorDescription in
            self?.showError(keyDesc: errorDescription)
        })
    }
    
    func finishOperativeSelected() {
        guard let container = container else {
            return
        }
        navigator.goToInitialView(container: container)
    }
    
    func goToATM() {
        let completion: () -> Void = { [weak self] in
            self?.container?.presenterProvider.sessionManager.sessionStarted(completion: {
                self?.dependencies.navigatorProvider.withdrawMoneyNavigator.goToAtmLocator()
            })
        }
        let completionError: (String?) -> Void = { [weak self] error in
            self?.container?.presenterProvider.sessionManager.finishWithReason(.failedGPReload(reason: error))
        }
        container?.reloadPG(onSuccess: completion, onError: completionError)
    }
    
    func goToShare() {
        let share: ShareCase = .share(content: sharingText)
        share.show(from: view)
        if let screenId = screenId {
            dependencies.trackerManager.trackEvent(screenId: screenId, eventId: TrackerPagePrivate.Generic.Action.share.rawValue, extraParameters: container?.operative.getExtraTrackShareParametersSummary() ?? [:])
        }
    }
}

extension WithdrawMoneySummaryPresenter: OpinatorLauncher {
    var baseWebViewNavigatable: BaseWebViewNavigatable {
        return navigator
    }
}

public struct FooterWithdrawSummaryModel {
    let title: String
    let image: String
    let identifier: String?
    let action: (() -> Void)?
    
    public init(title: String, image: String, identifier: String? = nil, action: (() -> Void)?) {
        self.title = title
        self.image = image
        self.action = action
        self.identifier = identifier
    }
}

struct SummaryActionViewModel: ActionButtonFillViewModelProtocol {
    let viewType: ActionButtonFillViewType
    let action: () -> Void
    
    init(image: String, title: String, identifier: String? = nil, action: @escaping () -> Void) {
        if let identifier = identifier {
            self.viewType = .defaultButton(DefaultActionButtonViewModel(
                title: title,
                imageKey: image,
                titleAccessibilityIdentifier: identifier + "_title",
                imageAccessibilityIdentifier: image
            ))
        } else {
            self.viewType = .defaultButton(DefaultActionButtonViewModel(
                title: title,
                imageKey: image,
                titleAccessibilityIdentifier: "summaryActionTitle",
                imageAccessibilityIdentifier: image
            ))
        }
        self.action = action
    }
}
