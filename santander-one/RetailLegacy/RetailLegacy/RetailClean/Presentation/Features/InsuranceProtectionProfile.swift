import CoreFoundationLib
import UIKit
import CoreDomain

class InsuranceProtectionProfile: BaseProductHomeProfile<InsuranceProtection, Void, GetInsuranceDataUseCaseInput, GetInsuranceDataUseCaseOkOutput, GetInsuranceDataUseCaseErrorOutput, InsuranceData>, ProductProfile {
    
    private var insurancesWithOffers: [InsuranceFamily] {
        return [.hoFamily,
                .vnFamily,
                .itFamily,
                .saFamily,
                .agFamily,
                .deFamily,
                .ceFamily,
                .auFamily,
                .muFamily,
                .sdFamily]
    }
    
    var menuOptionSelected: PrivateMenuOptions? {
        return .myProducts
    }
    
    var locations: [PullOfferLocation] {
        return PullOffersLocationsFactory().insuranceHome
    }
    
    var insuranceData: InsuranceData?
    var insuranceDataCompletionHandler: (([DateProvider]) -> Void)?
    var insuranceDateProviderList = [DateProvider]()
    // Necessary in order to get the external reference
    var insuranceProtections = [InsuranceProtection]()
    var headersData: [ProductInsuranceHeader] = []
    
    private lazy var options = [ProductOption]()
    
    override func convertToProductHeader(element: InsuranceProtection, position: Int) -> CarouselItem {
        let headerData = ProductInsuranceHeader(insuranceFamily: nil,
                                          insuranceName: nil,
                                          policy: element.getDetailUI(),
                                          info: nil,
                                          copyTag: 1,
                                          isBigSeparator: needsExtraBottomSpace,
                                          shareDelegate: self)
        insuranceProtections.append(element)
        headersData.append(headerData)
        return CarouselInsuranceCell(data: headerData)
    }
    
    var loadingPlaceholder: Placeholder {
        return Placeholder("insurancePlaceholderFake", 14)
    }
    
    override var loadingTopInset: Double {
        return 0
    }
    
    var showNavigationInfo: Bool {
        return false
    }
    
    var productTitle: LocalizedStylableText {
        return dependencies.stringLoader.getString("toolbar_title_insurance")
    }
    
    override var transactionHeaderTitle: LocalizedStylableText? {
        return LocalizedStylableText(text: "", styles: nil)
    }
    
    var isFilterIconVisible: Bool {
        return false
    }
    
    override var isHeaderCellHidden: Bool {
        return true
    }
    
    override var hasDefaultRows: Bool {
        return false
    }

    // MARK: - TrackerScreenProtocol

    var screenId: String? {
        return TrackerPagePrivate.Insurance().page
    }

    // MARK: -

    private var presenterOffers: [PullOfferLocation: Offer] = [:]
    
    override func extractProductList(globalPosition: GlobalPositionWrapper) -> [InsuranceProtection] {
        return globalPosition.insuranceProtection.get(ordered: true, visibles: true)
    }
    
    override func requestTransactions(fromBeginning isFromBeginning: Bool, completion: @escaping ([DateProvider]) -> Void) {
        guard let currentPosition = currentPosition else { return }
        transactionsCompletionHandler = completion
        guard let uc: UseCase<GetInsuranceDataUseCaseInput, GetInsuranceDataUseCaseOkOutput, GetInsuranceDataUseCaseErrorOutput> = useCaseForTransactions() else { return }
        UseCaseWrapper(with: uc, useCaseHandler: dependencies.useCaseHandler, errorHandler: errorHandler, onSuccess: { [weak self] (result) in
            guard
                let strongSelf = self,
                strongSelf.currentPosition == currentPosition
                else { return }
            let generalData = strongSelf.transactionsFrom(response: result)
            strongSelf.receivedGeneralData(generalData: generalData)
            }, onGenericErrorType: { [weak self] (_) in
                guard
                    let strongSelf = self,
                    strongSelf.currentPosition == currentPosition
                    else { return }
                strongSelf.receivedGeneralData(generalData: nil)
        })
    }
    
    func startSecondaryRequest() {
        insuranceDateProviderList.removeAll()
        guard
            let familyId = insuranceData?.familyId,
            ![InsuranceFamily.hoFamily.rawValue,
              InsuranceFamily.ceFamily.rawValue,
              InsuranceFamily.agFamily.rawValue,
              InsuranceFamily.saFamily.rawValue,
              InsuranceFamily.deFamily.rawValue,
              InsuranceFamily.auFamily.rawValue,
              InsuranceFamily.muFamily.rawValue]
                .contains(familyId) else { return }
        requestCoverages()
    }
    
    private func requestCoverages() {
        guard let currentPosition = currentPosition else { return }
        guard let uc: UseCase<GetInsuranceCoveragesUseCaseInput, GetInsuranceCoveragesUseCaseOkOutput, GetInsuranceCoveragesUseCaseErrorOutput> = useCaseForCoverages()
            else { return }
        UseCaseWrapper(with: uc, useCaseHandler: dependencies.useCaseHandler, errorHandler: errorHandler, onSuccess: { [weak self] (result) in
            guard
                let strongSelf = self,
                strongSelf.currentPosition == currentPosition
                else { return }
            let coverages = result.coverageList
            strongSelf.receivedCoverages(coverages: coverages)
            }, onGenericErrorType: { [weak self] (_) in
                guard
                    let strongSelf = self,
                    strongSelf.currentPosition == currentPosition
                    else { return }
                strongSelf.requestParticipants()
        })
    }
    
    private func requestParticipants() {
        guard let currentPosition = currentPosition else { return }
        guard let uc: UseCase<GetInsuranceParticipantsUseCaseInput, GetInsuranceParticipantsUseCaseOkOutput, GetInsuranceParticipantsUseCaseErrorOutput> = useCaseForParticipants()
            else { return }
        UseCaseWrapper(with: uc, useCaseHandler: dependencies.useCaseHandler, errorHandler: errorHandler, onSuccess: { [weak self] (result) in
            guard
                let strongSelf = self,
                strongSelf.currentPosition == currentPosition
                else { return }
            let participants = result.participantList
            strongSelf.receivedParticipants(participants: participants)
            }, onGenericErrorType: { [weak self] (_) in
                guard
                    let strongSelf = self,
                    strongSelf.currentPosition == currentPosition
                    else { return }
                strongSelf.requestBeneficiaries()
        })
    }
    
    private func requestBeneficiaries() {
        guard let currentPosition = currentPosition else { return }
        guard let uc: UseCase<GetInsuranceBeneficiariesUseCaseInput, GetInsuranceBeneficiariesUseCaseOkOutput, GetInsuranceBeneficiariesUseCaseErrorOutput> = useCaseForBeneficiaries()
            else { return }
        UseCaseWrapper(with: uc, useCaseHandler: dependencies.useCaseHandler, errorHandler: errorHandler, onSuccess: { [weak self] (result) in
            guard
                let strongSelf = self,
                strongSelf.currentPosition == currentPosition
                else { return }
            let beneficiaries = result.beneficiaryList
            strongSelf.receivedBeneficiaries(beneficiaries: beneficiaries)
            }, onGenericErrorType: { [weak self] (_) in
                guard
                    let strongSelf = self,
                    strongSelf.currentPosition == currentPosition
                    else { return }
                strongSelf.delegate?.addExtraRequestResponse(using: [])
        })
    }
    
    func useCaseForTransactions<Input, Response, Error: StringErrorOutput>() -> UseCase<Input, Response, Error>? {
        let insurance = productList[currentPosition!]
        let input = GetInsuranceDataUseCaseInput(insurance: insurance)
        return dependencies.useCaseProvider.getInsuranceDataUseCase(input: input) as? UseCase<Input, Response, Error>
    }
    
    func useCaseForParticipants<Input, Response, Error: StringErrorOutput>() -> UseCase<Input, Response, Error>? {
        guard let insuranceData = insuranceData else { return nil }
        let insurance = productList[currentPosition!]
        let input = GetInsuranceParticipantsUseCaseInput(insurance: insurance, insuranceData: insuranceData)
        return dependencies.useCaseProvider.getInsuranceParticipantsUseCase(input: input) as? UseCase<Input, Response, Error>
    }
    
    func useCaseForBeneficiaries<Input, Response, Error: StringErrorOutput>() -> UseCase<Input, Response, Error>? {
        guard let insuranceData = insuranceData else { return nil }
        let insurance = productList[currentPosition!]
        let input = GetInsuranceBeneficiariesUseCaseInput(insurance: insurance, insuranceData: insuranceData)
        return dependencies.useCaseProvider.getInsuranceBeneficiariesUseCase(input: input) as? UseCase<Input, Response, Error>
    }
    
    func useCaseForCoverages<Input, Response, Error: StringErrorOutput>() -> UseCase<Input, Response, Error>? {
        guard let insuranceData = insuranceData else { return nil }
        let insurance = productList[currentPosition!]
        let input = GetInsuranceCoveragesUseCaseInput(insurance: insurance, insuranceData: insuranceData)
        return dependencies.useCaseProvider.getInsuranceCoveragesUseCase(input: input) as? UseCase<Input, Response, Error>
    }
    
    func transactionsFrom(response: GetInsuranceDataUseCaseOkOutput) -> InsuranceData? {
        return response.insuranceData
    }
    
    func receivedGeneralData(generalData: InsuranceData?) {
        defer {
            transactionsCompletionHandler = nil
        }
        
        guard let generalData = generalData else {
            transactionsCompletionHandler?([DateProvider]())
            return
        }
        insuranceData = generalData
        updateHeader(with: generalData)
        let element = getDateProvider(from: generalData)
        transactionsCompletionHandler?(element)
        setOffer()
    }
    
    func setOffer() {
        if !options.isEmpty { options.removeAll() }
        guard let familyId = insuranceData?.familyId else { return }
        if insurancesWithOffers.map({ $0.rawValue }).contains(familyId) {
            self.getCandidateOffers { [weak self] candidates in
                guard let strongSelf = self else { return }
                strongSelf.presenterOffers = candidates
                let isPRInsuranceSetup = candidates[PullOfferLocation.PR_INSURANCE_SETUP] != nil
                if isPRInsuranceSetup {
                    strongSelf.options.append(InsuranceOptionsHandler.buildPolicyGestion(strongSelf.dependencies,
                                                                                         with: "insurances_label_myPolicy"))
                }
                strongSelf.completionOptions?(strongSelf.options)
            }
        }
    }
    
    func optionDidSelected(at index: Int) {
        guard let insuranceOption = ProductsOptions.InsuranceProtectionOptions(rawValue: index),
              let familyId = insuranceData?.familyId
              else { return }
        switch insuranceOption {
        case .policyGestion:
            if let offer = presenterOffers[.PR_INSURANCE_SETUP], let action = offer.action {
                delegate?.executePullOfferAction(action: action, offerId: offer.id, location: .PR_INSURANCE_SETUP)
            }
        }
    }
    
    func receivedCoverages(coverages: InsuranceCoverageList?) {
        if let coverages = coverages, let coveragesData = getCoveragesData(from: coverages) {
            insuranceDateProviderList.append(contentsOf: coveragesData)
        }
        requestParticipants()
    }
    
    func receivedParticipants(participants: InsuranceParticipantList?) {
        if let participants = participants, let participantsData = getParticipantsData(from: participants) {
            insuranceDateProviderList.append(contentsOf: participantsData)
        }
        requestBeneficiaries()
    }
    
    func receivedBeneficiaries(beneficiaries: InsuranceBeneficiaryList?) {
        if let beneficiaries = beneficiaries, let beneficiariesData = getBeneficiariesData(from: beneficiaries) {
            insuranceDateProviderList.append(contentsOf: beneficiariesData)
        }        
        delegate?.addExtraRequestResponse(using: insuranceDateProviderList)
    }
    
    func getDateProvider(from transaction: InsuranceData) -> [DateProvider] {
        guard let currentPosition = currentPosition else { return [] }
        let familyId = transaction.familyId
        switch familyId {
        case InsuranceFamily.hoFamily.rawValue:
            return HomeInsuranceDataBuilder(dependencies: dependencies, shareDelegate: self).getDataForHomeInsurance(transaction, insuranceProtection: insuranceProtections[currentPosition])
        case InsuranceFamily.vnFamily.rawValue,
             InsuranceFamily.vrFamily.rawValue,
             InsuranceFamily.vvFamily.rawValue,
             InsuranceFamily.acFamily.rawValue:
            return LifeInsuranceDataBuilder(dependencies: dependencies, shareDelegate: self).getDataForLifeInsurance(transaction, insuranceProtection: insuranceProtections[currentPosition])
        case InsuranceFamily.saFamily.rawValue:
            return HealthInsuranceDataBuilder(dependencies: dependencies, shareDelegate: self).getDataForHealthInsurance(transaction, insuranceProtection: insuranceProtections[currentPosition])
        case InsuranceFamily.deFamily.rawValue:
            return DeathInsuranceDataBuilder(dependencies: dependencies, shareDelegate: self).getDataForDeathInsurance(transaction, insuranceProtection: insuranceProtections[currentPosition])
        case InsuranceFamily.ceFamily.rawValue:
            return CEInsuranceDataBuilder(dependencies: dependencies, shareDelegate: self).getDataForCEInsurance(transaction, insuranceProtection: insuranceProtections[currentPosition])
        case InsuranceFamily.agFamily.rawValue:
            return AGInsuranceDataBuilder(dependencies: dependencies, shareDelegate: self).getDataForAccidentInsurance(transaction, insuranceProtection: insuranceProtections[currentPosition])
        case InsuranceFamily.auFamily.rawValue:
            return AUInsuranceDataBuilder(dependencies: dependencies, shareDelegate: self).getGeneralData(transaction, insuranceProtection: insuranceProtections[currentPosition])
        case InsuranceFamily.muFamily.rawValue:
            return MUInsuranceDataBuilder(dependencies: dependencies, shareDelegate: self).getGeneralData(transaction, insuranceProtection: insuranceProtections[currentPosition])
        default:
            return DefaultInsuranceDataBuilder(dependencies: dependencies, shareDelegate: self).getDataForDefaultInsurance(transaction, insuranceProtection: insuranceProtections[currentPosition])
        }
        
    }
    
    func getCoveragesData(from coverages: InsuranceCoverageList) -> [DateProvider]? {
        guard !coverages.list.isEmpty, let insuranceData = insuranceData else { return nil }
        switch insuranceData.familyId {
        case InsuranceFamily.vnFamily.rawValue,
             InsuranceFamily.vrFamily.rawValue,
             InsuranceFamily.vvFamily.rawValue,
             InsuranceFamily.acFamily.rawValue:
            return LifeInsuranceDataBuilder(dependencies: dependencies, shareDelegate: self).getCoverageDataForLifeInsurance(coverages)
        case InsuranceFamily.auFamily.rawValue,
             InsuranceFamily.muFamily.rawValue:
            return DefaultInsuranceDataBuilder(dependencies: dependencies, shareDelegate: self).getDefaultCoverageData(coverages)
        default:
            return nil
        }
    }
    
    func getParticipantsData(from participants: InsuranceParticipantList) -> [DateProvider]? {
        guard !participants.list.isEmpty, let insuranceData = insuranceData else { return nil }
        switch insuranceData.familyId {
        case InsuranceFamily.hoFamily.rawValue,
             InsuranceFamily.vnFamily.rawValue,
             InsuranceFamily.vrFamily.rawValue,
             InsuranceFamily.acFamily.rawValue,
             InsuranceFamily.saFamily.rawValue,
             InsuranceFamily.deFamily.rawValue,
             InsuranceFamily.agFamily.rawValue,
             InsuranceFamily.ceFamily.rawValue:
            return nil
        default:
            return DefaultInsuranceDataBuilder(dependencies: dependencies, shareDelegate: self).getParticipantsDataForDefaultHealthInsurance(participants)
        }
        
    }
    
    func getBeneficiariesData(from beneficiaries: InsuranceBeneficiaryList) -> [DateProvider]? {
        guard !beneficiaries.list.isEmpty, let insuranceData = insuranceData else { return nil }
        switch insuranceData.familyId {
        case InsuranceFamily.hoFamily.rawValue,
             InsuranceFamily.vnFamily.rawValue,
             InsuranceFamily.vrFamily.rawValue,
             InsuranceFamily.acFamily.rawValue,
             InsuranceFamily.saFamily.rawValue,
             InsuranceFamily.deFamily.rawValue,
             InsuranceFamily.agFamily.rawValue,
             InsuranceFamily.ceFamily.rawValue,
             InsuranceFamily.auFamily.rawValue,
             InsuranceFamily.muFamily.rawValue:
            return nil
        default:
            return DefaultInsuranceDataBuilder(dependencies: dependencies, shareDelegate: self).getBeneficiariesDataForDefaultInsurance(beneficiaries)
        }
    }
    
    func updateHeader(with generalData: InsuranceData) {
        guard let currentPosition = currentPosition else { return }
        let familyId = generalData.familyId
        let extraInfo: ProductInsuranceHeader.ExtraInfo
        switch familyId {
        case InsuranceFamily.hoFamily.rawValue:
            extraInfo = HomeInsuranceDataBuilder(dependencies: dependencies, shareDelegate: self).getHeaderInfo(generalData)
        case InsuranceFamily.vnFamily.rawValue,
             InsuranceFamily.vrFamily.rawValue,
             InsuranceFamily.vvFamily.rawValue,
             InsuranceFamily.acFamily.rawValue:
            extraInfo = LifeInsuranceDataBuilder(dependencies: dependencies, shareDelegate: self).getHeaderInfo(generalData)
        case InsuranceFamily.saFamily.rawValue:
            let request = IsSameClientUseCaseInput(clientDO: productList[currentPosition].client)
            UseCaseWrapper(with: useCaseProvider.getIsSameClientUseCase(input: request), useCaseHandler: useCaseHandler, errorHandler: errorHandler, onSuccess: { [weak self] _ in
                guard let self = self else { return }
                let newInfo = HealthInsuranceDataBuilder(dependencies: self.dependencies, shareDelegate: self).getHeaderInfo(generalData, addHealthCard: true)
                self.headersData[currentPosition].extraInfo = newInfo
                self.headersData[currentPosition].updateHeaderView?()
                }, onError: { [weak self] _ in
                    guard let self = self else { return }
                    let newInfo = HealthInsuranceDataBuilder(dependencies: self.dependencies, shareDelegate: self).getHeaderInfo(generalData, addHealthCard: false)
                    self.headersData[currentPosition].extraInfo = newInfo
                    self.headersData[currentPosition].updateHeaderView?()
            })
            return
        default:
            extraInfo = DefaultInsuranceDataBuilder(dependencies: dependencies, shareDelegate: self).getHeaderInfo(generalData)
        }
        headersData[currentPosition].extraInfo = extraInfo
        headersData[currentPosition].updateHeaderView?()
    }
    
    override func infoToShareWithCode(_ code: Int?) -> String? {
        guard let copyTag = code else { return nil }
        switch copyTag {
        case 1:
            guard let currentPosition = currentPosition else { return nil }
            return headersData[currentPosition].policy
        case 2:
            guard let policyId = insuranceData?.policyId else { return nil }
            return policyId
        case 3:
            guard let accountId = insuranceData?.accountId else { return nil }
            return accountId
        default:
            return nil
        }
    }
    
    // MARK: - MenuOptions
    override func menuOptions(withProductConfig productConfig: ProductConfig) {}
    
    func transactionDidSelected(at index: Int) {}
}

extension InsuranceProtectionProfile: LocationsResolver {
    var useCaseProvider: UseCaseProvider {
        return dependencies.useCaseProvider
    }
    
    var useCaseHandler: UseCaseHandler {
        return dependencies.useCaseHandler
    }
    
    var genericErrorHandler: GenericPresenterErrorHandler {
        return errorHandler
    }
}

extension InsuranceProtectionProfile {
    func actionData() -> ProductWebviewParameters? {
        guard let current = currentPosition else { return nil }
        let insuranceWebviewParameters: InsuranceWebviewParameters = InsuranceWebviewParameters(contractId: insuranceProtections[current].contractId, family: insuranceData?.familyId)
        return insuranceWebviewParameters
    }
}
