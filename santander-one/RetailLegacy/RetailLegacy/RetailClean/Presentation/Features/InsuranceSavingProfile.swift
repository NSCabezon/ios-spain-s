import CoreFoundationLib
import UIKit
import CoreDomain

class InsuranceSavingProfile: BaseProductHomeProfile<InsuranceSaving, Void, GetInsuranceSavingDataUseCaseInput, GetInsuranceDataUseCaseOkOutput, GetInsuranceDataUseCaseErrorOutput, InsuranceData>, ProductProfile {
   
   var menuOptionSelected: PrivateMenuOptions? {
       return .myProducts
   }
   
    var locations: [PullOfferLocation] {
        return PullOffersLocationsFactory().insuranceHome
    }
    
    private lazy var options = [ProductOption]()
    var insuranceData: InsuranceData?
    var insuranceDataCompletionHandler: (([DateProvider]) -> Void)?
    var insuranceDateProviderList = [DateProvider]()
    // Necessary in order to get the external reference
    var insuranceSavings = [InsuranceSaving]()
    
    override func convertToProductHeader(element: InsuranceSaving, position: Int) -> CarouselItem {
        let shouldDisplayBalance = productConfig?.isSavingInsuranceBalanceEnabled ?? false
        let data = ProductHeader(title: element.getAlias(),
                                 subtitle: element.getDetailUI(),
                                 amount: shouldDisplayBalance ? element.getAmount() : nil,
                                 pendingText: dependencies.stringLoader.getString("insurances_label_totalAmountAccumulated"),
                                 isPending: shouldDisplayBalance,
                                 isCopyButtonAvailable: true,
                                 copyTag: 1,
                                 isBigSeparator: needsExtraBottomSpace,
                                 shareDelegate: self)
        insuranceSavings.append(element)
        return CarouselGenericCell(data: data)
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
        return dependencies.stringLoader.getString("toolbar_title_insuranceSaving")
    }
        
    override var transactionHeaderTitle: LocalizedStylableText? {
        return LocalizedStylableText(text: "", styles: nil)
    }
    
    override var isHeaderCellHidden: Bool {
        return true
    }
    
    var isFilterIconVisible: Bool {
        return false
    }
    
    override var hasDefaultRows: Bool {
        return false
    }

    // MARK: - TrackerScreenProtocol

    var screenId: String? {
        return TrackerPagePrivate.InsuranceSaving().page
    }

    // MARK: -

    private var presenterOffers: [PullOfferLocation: Offer] = [:]
        
    override func extractProductList(globalPosition: GlobalPositionWrapper) -> [InsuranceSaving] {
        return globalPosition.insuranceSavings.get(ordered: true, visibles: true)
    }
    
    override func requestTransactions(fromBeginning isFromBeginning: Bool, completion: @escaping ([DateProvider]) -> Void) {
        guard let currentPosition = currentPosition else {
            return
        }
        
        transactionsCompletionHandler = completion
        guard let uc: UseCase<GetInsuranceSavingDataUseCaseInput, GetInsuranceDataUseCaseOkOutput, GetInsuranceDataUseCaseErrorOutput> = useCaseForTransactions() else {
            return
        }
        
        UseCaseWrapper(with: uc, useCaseHandler: dependencies.useCaseHandler, errorHandler: errorHandler, onSuccess: { [weak self] (result) in
            
            guard let strongSelf = self else { return }
            guard strongSelf.currentPosition == currentPosition else {
                return
            }
            let generalData = strongSelf.transactionsFrom(response: result)
            strongSelf.receivedGeneralData(generalData: generalData)
            
        }, onGenericErrorType: { [weak self] (_) in
            guard let strongSelf = self else { return }
            guard strongSelf.currentPosition == currentPosition else {
                return
            }
            strongSelf.receivedGeneralData(generalData: nil)
        })
    }
    
    func requestInsuranceData(completion: @escaping ([DateProvider]) -> Void) {
        insuranceDataCompletionHandler = completion
        insuranceDateProviderList.removeAll()
        requestParticipants()
    }

    func startSecondaryRequest() {
        insuranceDateProviderList.removeAll()
        requestParticipants()
    }
    
    private func requestParticipants() {
        guard let currentPosition = currentPosition else {
            return
        }
        guard let uc: UseCase<GetSavingInsuranceParticipantsUseCaseInput, GetInsuranceParticipantsUseCaseOkOutput, GetInsuranceParticipantsUseCaseErrorOutput> = useCaseForParticipants() else {
            return
        }
        
        UseCaseWrapper(with: uc, useCaseHandler: dependencies.useCaseHandler, errorHandler: errorHandler, onSuccess: { [weak self] (result) in
            
            guard let strongSelf = self else { return }
            guard strongSelf.currentPosition == currentPosition else {
                return
            }
            let participants = result.participantList
            strongSelf.receivedParticipants(participants: participants)
        }, onGenericErrorType: { [weak self] (_) in
            guard let strongSelf = self else { return }
            guard strongSelf.currentPosition == currentPosition else {
                return
            }
            strongSelf.requestBeneficiaries()
        })
    }
    
    private func requestBeneficiaries() {
        guard let currentPosition = currentPosition else {
            return
        }
        guard let uc: UseCase<GetSavingInsuranceBeneficiariesUseCaseInput, GetInsuranceBeneficiariesUseCaseOkOutput, GetInsuranceBeneficiariesUseCaseErrorOutput> = useCaseForBeneficiaries() else {
            return
        }
        
        UseCaseWrapper(with: uc, useCaseHandler: dependencies.useCaseHandler, errorHandler: errorHandler, onSuccess: { [weak self] (result) in
            
            guard let strongSelf = self else { return }
            guard strongSelf.currentPosition == currentPosition else {
                return
            }
            let beneficiaries = result.beneficiaryList
            strongSelf.receivedBeneficiaries(beneficiaries: beneficiaries)
        }, onGenericErrorType: { [weak self] (_) in
            guard let strongSelf = self else { return }
            guard strongSelf.currentPosition == currentPosition else {
                return
            }
            strongSelf.delegate?.addExtraRequestResponse(using: [])
        })
    }
    
    func useCaseForTransactions<Input, Response, Error: StringErrorOutput>() -> UseCase<Input, Response, Error>? {
        let insurance = productList[currentPosition!]
        let input = GetInsuranceSavingDataUseCaseInput(insurance: insurance)
        return dependencies.useCaseProvider.getInsuranceSavingDataUseCase(input: input) as? UseCase<Input, Response, Error>
    }
    
    func useCaseForParticipants<Input, Response, Error: StringErrorOutput>() -> UseCase<Input, Response, Error>? {
        guard let insuranceData = insuranceData else { return nil }
        let insurance = productList[currentPosition!]
        let input = GetSavingInsuranceParticipantsUseCaseInput(insurance: insurance, insuranceData: insuranceData)
        return dependencies.useCaseProvider.getSavingInsuranceParticipantsUseCase(input: input) as? UseCase<Input, Response, Error>
    }
    
    func useCaseForBeneficiaries<Input, Response, Error: StringErrorOutput>() -> UseCase<Input, Response, Error>? {
        guard let insuranceData = insuranceData else { return nil }
        let insurance = productList[currentPosition!]
        let input = GetSavingInsuranceBeneficiariesUseCaseInput(insurance: insurance, insuranceData: insuranceData)
        return dependencies.useCaseProvider.getSavingInsuranceBeneficiariesUseCase(input: input) as? UseCase<Input, Response, Error>
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
        
        if let element = getGeneralData(from: generalData) {
            transactionsCompletionHandler?(element)
        }
        
        setOffer()
    }
    
    func setOffer() {
        if !options.isEmpty { options.removeAll() }
        guard let familyId = insuranceData?.familyId else { return }
        if familyId == InsuranceFamily.z1Family.rawValue || familyId == InsuranceFamily.ppaFamily.rawValue {
            self.getCandidateOffers { [weak self] candidates in
                self?.presenterOffers = candidates
                guard let strongSelf = self else { return }
                if candidates[PullOfferLocation.SV_INSURANCE_CONTRIBUTION] != nil {
                    strongSelf.options.append(InsuranceOptionsHandler.extraAportation(strongSelf.dependencies, with: "insurancesOption_buttom_extraContribution"))
                    
                }
                if candidates[PullOfferLocation.SV_INSURANCE_CHANGE_PLAN] != nil {
                    strongSelf.options.append(InsuranceOptionsHandler.activatePlan(strongSelf.dependencies, with: "insurancesOptions_buttom_changeRemittancePlan"))
                }
                if candidates[PullOfferLocation.SV_INSURANCE_ACTIVATE_PLAN] != nil {
                    strongSelf.options.append(InsuranceOptionsHandler.aportationPlanChange(strongSelf.dependencies, with: "insurancesOption_buttom_activateRemittancePlan"))
                }
                strongSelf.completionOptions?(strongSelf.options)
            }
        }
    }
    
    func optionDidSelected(at index: Int) {
        guard let insuranceOption = ProductsOptions.InsuranceSavingOptions(rawValue: index) else { return }
        switch insuranceOption {
        case .extraAportation:
            guard let offer = presenterOffers[.SV_INSURANCE_CONTRIBUTION], let action = offer.action else {
                return
            }
            delegate?.executePullOfferAction(action: action, offerId: offer.id, location: .SV_INSURANCE_CONTRIBUTION)
        case .aportationPlanChange:
            guard let offer = presenterOffers[.SV_INSURANCE_ACTIVATE_PLAN], let action = offer.action else {
                return
            }
            delegate?.executePullOfferAction(action: action, offerId: offer.id, location: .SV_INSURANCE_ACTIVATE_PLAN)
        case .activatePlan:
            guard let offer = presenterOffers[.SV_INSURANCE_CHANGE_PLAN], let action = offer.action else {
                return
            }
            delegate?.executePullOfferAction(action: action, offerId: offer.id, location: .SV_INSURANCE_CHANGE_PLAN)
        }
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
    
    func getGeneralData(from transaction: InsuranceData) -> [DateProvider]? {
        guard let currentPosition = currentPosition else { return nil }
        let familyId = transaction.familyId
        switch familyId {
        case InsuranceFamily.z1Family.rawValue:
            return ASInsuranceDataBuilder(dependencies: dependencies, shareDelegate: self).getDataForASInsurance(transaction, insuranceSaving: insuranceSavings[currentPosition])
        case InsuranceFamily.ulFamily.rawValue:
            return ULInsuranceDataBuilder(dependencies: dependencies, shareDelegate: self).getDataForULInsurance(transaction, insuranceSaving: insuranceSavings[currentPosition])
        case InsuranceFamily.reFamily.rawValue:
            return REInsuranceDataBuilder(dependencies: dependencies, shareDelegate: self).getDataForREInsurance(transaction, insuranceSaving: insuranceSavings[currentPosition])
        default: 
            return DefaultSavingInsuranceDataBuilder(dependencies: dependencies, shareDelegate: self).getDataForDefaultInsurance(transaction, insuranceSaving: insuranceSavings[currentPosition])
        }
    }
    
    func getParticipantsData(from participants: InsuranceParticipantList) -> [DateProvider]? {
        guard !participants.list.isEmpty else { return nil }
        guard let insuranceData = insuranceData else { return nil }
        let familyId = insuranceData.familyId
        switch familyId {
        case InsuranceFamily.z1Family.rawValue:
            return ASInsuranceDataBuilder(dependencies: dependencies, shareDelegate: self).getParticipantsDataForASInsurance(participants)
        case InsuranceFamily.ulFamily.rawValue:
            return ULInsuranceDataBuilder(dependencies: dependencies, shareDelegate: self).getParticipantsDataForULInsurance(participants)
        case InsuranceFamily.reFamily.rawValue:
            return REInsuranceDataBuilder(dependencies: dependencies, shareDelegate: self).getParticipantsDataForREInsurance(participants)
        default:
            return DefaultSavingInsuranceDataBuilder(dependencies: dependencies, shareDelegate: self).getParticipantsDataForDefaultInsurance(participants)
        }
    }
    
    func getBeneficiariesData(from beneficiaries: InsuranceBeneficiaryList) -> [DateProvider]? {
        guard !beneficiaries.list.isEmpty else { return nil }
        guard let insuranceData = insuranceData else { return nil }
        let familyId = insuranceData.familyId
        switch familyId {
        case InsuranceFamily.z1Family.rawValue:
            return ASInsuranceDataBuilder(dependencies: dependencies, shareDelegate: self).getBeneficiariesDataForASInsurance(beneficiaries)
        case InsuranceFamily.reFamily.rawValue:
            return REInsuranceDataBuilder(dependencies: dependencies, shareDelegate: self).getBeneficiariesDataForREInsurance(beneficiaries)
        default:
            return DefaultSavingInsuranceDataBuilder(dependencies: dependencies, shareDelegate: self).getBeneficiariesDataForDefaultInsurance(beneficiaries)
        }
    }
    
    override func infoToShareWithCode(_ code: Int?) -> String? {
        guard let copyTag = code else { return nil }
        switch copyTag {
        case 1, 2:
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
    override func menuOptions(withProductConfig productConfig: ProductConfig) { }
    
    func transactionDidSelected(at index: Int) {}
}

extension InsuranceSavingProfile: LocationsResolver {
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

extension InsuranceSavingProfile {
    func actionData() -> ProductWebviewParameters? {
        guard let current = currentPosition else {
            return nil
        }
        let insuranceWebviewParameters: InsuranceWebviewParameters = InsuranceWebviewParameters(contractId: insuranceSavings[current].contractId, family: insuranceData?.familyId)
        return insuranceWebviewParameters
    }
}
