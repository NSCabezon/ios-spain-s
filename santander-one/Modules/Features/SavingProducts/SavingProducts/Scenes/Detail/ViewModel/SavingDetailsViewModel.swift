//
//  SavingDetailsViewModel.swift
//  SavingProducts
//
//  Created by Marcos Álvarez Mesa on 25/4/22.
//

import CoreFoundationLib
import OpenCombine
import CoreDomain

enum SavingDetailState: State {
    case idle
    case dataLoaded(Savings)
    case dataDetailsInfoLoaded([SavingDetailsInfoRepresentable])
    case bottomSheet(titleKey: String, infoKey: String)
    case bottomSheetInterest(titleKey: String, infoKey: String)
}

final class SavingDetailViewModel: DataBindable {
    private let dependencies: SavingDetailDependenciesResolver
    private let stateSubject = CurrentValueSubject<SavingDetailState, Never>(.idle)
    private var anySubscriptions: Set<AnyCancellable> = []
    var state: AnyPublisher<SavingDetailState, Never>
    @BindingOptional var savingRepresentable: SavingProductRepresentable?

    var dataBinding: DataBinding {
        return dependencies.resolve()
    }

    private var coordinator: SavingDetailCoordinator {
        return dependencies.resolve()
    }

    init(dependencies: SavingDetailDependenciesResolver) {
        self.dependencies = dependencies
        state = stateSubject.eraseToAnyPublisher()
    }

    func viewDidLoad() {
        loadDetails()
        trackScreen()
    }

    func didSelectMenu() {
        coordinator.didSelectMenu()
    }

    func didSelectBack() {
        coordinator.dismiss()
    }

    func didSelectShareId(_ savings: Savings) {
        UIPasteboard.general.string = savings.identification
        trackEvent(.copySavingProductNumber)
    }

    func didSelectShare() {
        guard let savingRepresentable = self.savingRepresentable else { return }
        let saving = Savings(savings: savingRepresentable)
        coordinator.share(saving, type: .text)
        trackEvent(.shareAccountNumber)
    }

    func didSelectChangeAlias() {
        trackEvent(.changeAlias)
    }

    func didSelectBalanceInfo(_ savings: Savings) {
        stateSubject.send(.bottomSheet(titleKey: "savings_title_balances", infoKey: "savings_label_balanceInfo"))
        trackEvent(.tapTooltipBalance)
    }

    func didSelectInterestInfo() {
        stateSubject.send(.bottomSheetInterest(titleKey: "savingsHome_label_interestRate", infoKey: "savingsTooltip_text_interestRate"))
        trackEvent(.tapTooltipInterestRate)
    }

    func didSelectInterestRateLink(_ savings: Savings) {
        guard let url = savings.interestRateLinkRepresentable?.url else { return }
        coordinator.open(url: url)
    }
}

private extension SavingDetailViewModel {

    func loadDetails() {
        guard let savingRepresentable = self.savingRepresentable else { return }
        let saving = Savings(savings: savingRepresentable)
        saving.didSelectShare = self.didSelectShareId(_:)
        saving.didSelectBalanceInfo = self.didSelectBalanceInfo(_:)
        saving.didSelectInterestInfo = didSelectInterestInfo
        saving.didSelectInterestRateLink = self.didSelectInterestRateLink(_:)

        let complementaryDataUseCase: GetSavingProductComplementaryDataUseCase = dependencies.external.resolve()
        complementaryDataUseCase.fechComplementaryDataPublisher()
            .receive(on: Schedulers.main)
            .sink { [weak self] complementaryData in
                guard let self = self else { return }
                let matchData = complementaryData.filter(by: saving.accountSubtype)
                saving.complementaryData = matchData
                saving.totalNumberOfFields = matchData.count
                self.stateSubject.send(.dataLoaded(saving))
                self.loadSavingDetailsInfo(saving: saving)
            }.store(in: &anySubscriptions)
    }

    func loadSavingDetailsInfo(saving: Savings) {
        let detailsInfoUseCase: GetSavingDetailsInfoUseCase = dependencies.external.resolve()
        detailsInfoUseCase.fechDetailElementsPublisher(saving: saving.savings)
            .sink { _ in
                return
            } receiveValue: { [weak self] elements in
                guard let self = self else { return }
                self.stateSubject.send(.dataDetailsInfoLoaded(elements))
            }
            .store(in: &anySubscriptions)
    }
}

// MARK: Dictionary extension
private extension Dictionary where Key == String, Value == [DetailTitleLabelType] {
    func filter(by subtype: String) -> [DetailTitleLabelType] {
        let filteredData = self.filter { $0.key == subtype }
        guard filteredData.count > 0, let result = filteredData[subtype] else { return [] }
        return result
    }
}

// MARK: Analytics
extension SavingDetailViewModel: AutomaticScreenActionTrackable {
    var trackerManager: TrackerManager {
        dependencies.external.resolve()
    }

    var trackerPage: SavingDetailPage {
        SavingDetailPage()
    }
}
