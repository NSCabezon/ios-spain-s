import Foundation
import CoreFoundationLib
import SANLegacyLibrary
import Transfer
import PersonalManager

public protocol AdditionalUseCasesProviderProtocol {
    func getAdditionalPublicFilesUseCases() -> [(useCase: UseCase<Void, Void, StringErrorOutput>, isMandatory: Bool)]
}

public class UseCaseProvider {
    let appConfigRepository: AppConfigRepository
    let loadingTipsRepository: LoadingTipsRepository
    let merchantRepository: MerchantRepository
    let countriesRepository: CountriesRepository
    let searchKeywordRepository: SearchKeywordsRepository
    let managerHobbiesRepository: ManagerHobbiesRepository
    let appRepository: AppRepository
    let comingFeaturesRepository: ComingFeaturesRepository
    let frequentEmittersRepository: FrequentEmittersRepository
    let tricksRepository: TricksRepository
    private let downloadsRepository: DownloadsRepository
    let accountDescriptorRepository: AccountDescriptorRepository
    let appInfoRepository: AppInfoRepository
    private let rulesRepository: RulesRepository
    private let offersRepository: OffersRepository
    private let bsanManagersProvider: BSANManagersProvider
    let segmentedUserRepository: SegmentedUserRepository
    let faqsRepository: FaqsRepository
    private let servicesForYouRepository: ServicesForYouRepository
    private let pullOffersRepository: PullOffersRepositoryProtocol
    let pullOffersConfigRepository: PullOffersConfigRepository
    let sepaInfoRepository: SepaInfoRepository
    let publicProductsRepository: PublicProductsRepository
    private let pullOffersEngine: EngineInterface
    let pullOffersInterpreter: PullOffersInterpreter
    let tealiumRepository: TealiumRepository
    private let netInsightRepository: NetInsightRepository
    private let siriAssistant: SiriAssistant
    private let daoSharedAppConfig: DAOSharedAppConfig
    private let documentsRepository: DocumentsRepository
    private let bsanDataProvider: BSANDataProviderProtocol
    private let dependenciesEngine: DependenciesInjector & DependenciesResolver
    private let trusteerRepository: TrusteerRepositoryProtocol
    let bizumDefaultNGOsRepository: BizumDefaultNGOsRepository
    var dependenciesResolver: DependenciesInjector & DependenciesResolver {
        return self.dependenciesEngine
    }

    init(appRepository: AppRepository,
         downloadsRepository: DownloadsRepository,
         appInfoRepository: AppInfoRepository,
         segmentedUserRepository: SegmentedUserRepository,
         faqsRepository: FaqsRepository,
         rulesRepository: RulesRepository,
         offersRepository: OffersRepository,
         servicesForYouRepository: ServicesForYouRepository,
         bsanManagersProvider: BSANManagersProvider,
         appConfigRepository: AppConfigRepository,
         accountDescriptorRepository: AccountDescriptorRepository,
         pullOffersRepository: PullOffersRepositoryProtocol,
         pullOffersConfigRepository: PullOffersConfigRepository,
         sepaInfoRepository: SepaInfoRepository,
         pullOffersEngine: EngineInterface,
         publicProductsRepository: PublicProductsRepository,
         pullOffersInterpreter: PullOffersInterpreter,
         tealiumRepository: TealiumRepository,
         netInsightRepository: NetInsightRepository,
         daoSharedAppConfig: DAOSharedAppConfig,
         siriAssistant: SiriAssistant,
         documentsRepository: DocumentsRepository,
         bsanDataProvider: BSANDataProviderProtocol,
         dependenciesEngine: DependenciesInjector & DependenciesResolver,
         loadingTipsRepository: LoadingTipsRepository,
         countriesRepository: CountriesRepository,
         searchKeywordRepository: SearchKeywordsRepository,
         managerHobbiesRepository: ManagerHobbiesRepository,
         comingFeaturesRepository: ComingFeaturesRepository,
         frequentEmittersRepository: FrequentEmittersRepository,
         tricksRepository: TricksRepository,
         trusteerRepository: TrusteerRepositoryProtocol,
         bizumDefaultNGOsRepository: BizumDefaultNGOsRepository,
         merchantRepository: MerchantRepository) {
        self.appRepository = appRepository
        self.downloadsRepository = downloadsRepository
        self.appInfoRepository = appInfoRepository
        self.segmentedUserRepository = segmentedUserRepository
        self.faqsRepository = faqsRepository
        self.rulesRepository = rulesRepository
        self.offersRepository = offersRepository
        self.servicesForYouRepository = servicesForYouRepository
        self.appConfigRepository = appConfigRepository
        self.bsanManagersProvider = bsanManagersProvider
        self.accountDescriptorRepository = accountDescriptorRepository
        self.pullOffersRepository = pullOffersRepository
        self.pullOffersConfigRepository = pullOffersConfigRepository
        self.publicProductsRepository = publicProductsRepository
        self.sepaInfoRepository = sepaInfoRepository
        self.pullOffersEngine = pullOffersEngine
        self.pullOffersInterpreter = pullOffersInterpreter
        self.tealiumRepository = tealiumRepository
        self.netInsightRepository = netInsightRepository
        self.daoSharedAppConfig = daoSharedAppConfig
        self.siriAssistant = siriAssistant
        self.documentsRepository = documentsRepository
        self.bsanDataProvider = bsanDataProvider
        self.dependenciesEngine = dependenciesEngine
        self.loadingTipsRepository = loadingTipsRepository
        self.countriesRepository = countriesRepository
        self.searchKeywordRepository = searchKeywordRepository
        self.managerHobbiesRepository = managerHobbiesRepository
        self.comingFeaturesRepository = comingFeaturesRepository
        self.frequentEmittersRepository = frequentEmittersRepository
        self.tricksRepository = tricksRepository
        self.trusteerRepository = trusteerRepository
        self.bizumDefaultNGOsRepository = bizumDefaultNGOsRepository
        self.merchantRepository = merchantRepository
    }

    // MARK: Super Use cases //
    func getSessionDataManager(useCaseHandler: UseCaseHandler) -> SessionDataManager {
        return DefaultSessionDataManager(dependenciesResolver: dependenciesEngine)
    }
    
    func getLoadCustomerServiceOptionsSuperUseCase(useCaseHandler: UseCaseHandler, errorHandler: GenericPresenterErrorHandler, isLoggedIn: Bool) -> LoadCustomerServiceOptionsSuperUseCase {
        return LoadCustomerServiceOptionsSuperUseCase(useCaseProvider: self, useCaseHandler: useCaseHandler, errorHandler: errorHandler, isLoggedIn: isLoggedIn, segmentedUserRepository: segmentedUserRepository, bsanManagersProvider: bsanManagersProvider, appConfig: appConfigRepository)
    }
    
    func getLoadEmittedTransfersSuperUseCase(useCaseHandler: UseCaseHandler) -> LoadEmittedTransferListSuperUseCase {
        return LoadEmittedTransferListSuperUseCase(useCaseProvider: self, useCaseHandler: useCaseHandler, appConfigRepository: appConfigRepository)
    }
    
    func getLoadPersonalAreaFrequentOperativesSuperUseCase(useCaseHandler: UseCaseHandler) -> LoadPersonalAreaFrequentOperativesSuperUseCase {
        return LoadPersonalAreaFrequentOperativesSuperUseCase(useCaseProvider: self, useCaseHandler: useCaseHandler)
    }
    
    func getLoadUsualTransfersSuperUseCase(useCaseHandler: UseCaseHandler) -> LoadUsualTransfersSuperUseCase {
        return LoadUsualTransfersSuperUseCase(useCaseProvider: self, useCaseHandler: useCaseHandler)
    }
    
    // MARK: WS Environments  //
    func getGetBSANEnvironmentsUseCase() -> UseCase<Void, GetBSANEnvironmentsUseCaseOkOutput, GetBSANEnvironmentsUseCaseErrorOutput> {
        return GetBSANEnvironmentsUseCase(bsanManagersProvider: bsanManagersProvider)
    }

    func getGetCurrentBSANEnvironmentUseCase() -> UseCase<Void, GetCurrentBSANEnvironmentUseCaseOkOutput, GetCurrentBSANEnvironmentUseCaseErrorOutput> {
        return GetBSANCurrentEnvironmentUseCase(bsanManagersProvider: bsanManagersProvider, appRepository: appRepository)
    }

    func getChangeBSANEnvironmentUseCase(_ input: ChangeBSANEnvironmentUseCaseInput) -> UseCase<ChangeBSANEnvironmentUseCaseInput, Void, ChangeBSANEnvironmentUseCaseErrorOutput> {
        return ChangeBSANEnvironmentUseCase(bsanManagersProvider: bsanManagersProvider, netInsightRepository: netInsightRepository).setRequestValues(requestValues: input)
    }
    
    // MARK: CMC //
    
    func getCMCAndSupportPhoneUseCase() -> UseCase<Void, GetCMCAndSupportPhoneUseCaseOkOutput, StringErrorOutput> {
        return GetCMCAndSupportPhoneUseCase(provider: bsanManagersProvider, appConfigRepository: appConfigRepository)
    }
    
    // MARK: Personal Area
    
    func getPermissionsStatusUseCase(dependencies: PresentationComponent) -> UseCase<Void, GetPermissionsStatusUseCaseOkOutput, StringErrorOutput> {
        return GetPermissionsStatusUseCase(dependencies: dependencies)
    }

    func getPersonalAreaOptionsUseCase() -> UseCase<Void, GetPersonalAreaOptionsUseCaseOkOutput, StringErrorOutput> {
        return GetPersonalAreaOptionsUseCase(managersProvider: bsanManagersProvider)
    }
    
    func getLoadPersonalAreaConfigUseCase() -> UseCase<Void, LoadPersonalAreaConfigUseCaseOkOutput, StringErrorOutput> {
        return LoadPersonalAreaConfigUseCase(appConfigRepository: appConfigRepository)
    }
    
    func registerDevice(input: RegisterDeviceInput) -> UseCase<RegisterDeviceInput, RegisterDeviceOkOutput, RegisterDeviceErrorOutput> {
        return RegisterDeviceUseCase(provider: bsanManagersProvider, appRepository: appRepository, dependenciesResolver: self.dependenciesEngine).setRequestValues(requestValues: input)
    }
    
    func setTouchIdLoginData(input: SetTouchIdLoginDataInput) -> UseCase<SetTouchIdLoginDataInput, Void, SetTouchIdLoginDataErrorOutput> {
        return SetTouchIdLoginDataUseCase(dependenciesResolver: self.dependenciesEngine).setRequestValues(requestValues: input)
    }
    
    func getPersonalAreaFrequentOperativesUseCase() -> UseCase<Void, GetFrequentOperativeOptionUseCaseOkOutput, GetFrequentOperativeOptionUseCaseErrorOutput> {
        return GetFrequentOperativeOptionsUseCase(provider: bsanManagersProvider, appRepository: appRepository)
    }
    
    func savePersonalAreaFrequentOperativesUseCase(input: SaveFrequentOperativeOptionsUseCaseInput) -> UseCase<SaveFrequentOperativeOptionsUseCaseInput, Void, SaveFrequentOperativeOptionUseCaseErrorOutput> {
        return SaveFrequentOperativeOptionsUseCase(provider: bsanManagersProvider, appRepository: appRepository).setRequestValues(requestValues: input)
    }
    
    func getTouchIdLoginData() -> UseCase<Void, GetTouchIdLoginDataOkOutput, GetTouchIdLoginDataErrorOutput> {
        return GetTouchIdLoginDataUseCase(dependenciesResolver: self.dependenciesEngine)
    }
    
    func setWidgetAccess(input: SetWidgetAccessInput) -> UseCase<SetWidgetAccessInput, Void, SetWidgetAccessErrorOutput> {
        return SetWidgetAccessUseCase(dependenciesResolver: self.dependenciesEngine).setRequestValues(requestValues: input)
    }
    
    func getWidgetAccess() -> UseCase<Void, GetWidgetAccessOkOutput, StringErrorOutput> {
        return GetWidgetAccessUseCase(dependenciesResolver: self.dependenciesEngine)
    }
    
    // MARK: PublicFiles Environments  //
    func getGetPublicFilesEnvironmentsUseCase() -> UseCase<Void, GetPublicFilesEnvironmentsUseCaseOkOutput, GetPublicFilesEnvironmentsUseCaseErrorOutput> {
        return GetPublicFilesEnvironmentsUseCase(appRepository: appRepository)
    }

    func getGetCurrentPublicFilesEnvironmentUseCase() -> UseCase<Void, GetCurrentPublicFilesEnvironmentUseCaseOkOutput, GetCurrentPublicFilesEnvironmentUseCaseErrorOutput> {
        return GetCurrentPublicFilesEnvironmentUseCase(appRepository: appRepository)
    }

    func getChangePublicFilesEnvironmentUseCase(_ input: ChangePublicFilesEnvironmentUseCaseInput) -> UseCase<ChangePublicFilesEnvironmentUseCaseInput, Void, ChangePublicFilesEnvironmentUseCaseErrorOutput> {
        return ChangePublicFilesEnvironmentUseCase(
            appRepository: appRepository,
            appConfigRepository: appConfigRepository,
            segmentedUserRepository: segmentedUserRepository,
            accountDescriptorRepository: accountDescriptorRepository).setRequestValues(requestValues: input)
    }
    
    func getLoadSepaInfoUseCase() -> UseCase<Void, Void, StringErrorOutput> {
        return LoadSepaInfoUseCase(dependencies: self.dependenciesResolver, sepaInfoRepository: sepaInfoRepository, appRepository: appRepository)
    }
    
    func getLoadLoadingTipsUseCase() -> UseCase<Void, Void, StringErrorOutput> {
        return LoadLoadingTipsUseCase(dependencies: self.dependenciesResolver, loadingTipsRepository: loadingTipsRepository, appRepository: appRepository)
    }
    
    func getLoadingTipsUseCase() -> GetLoadingTipsUseCase {
        return GetLoadingTipsUseCase(dependenciesResolver: dependenciesEngine)
    }
    
    func getLoadingTipsTimerUseCase() -> GetLoadingTipsTimerUseCase {
        return GetLoadingTipsTimerUseCase(appConfigRepository: appConfigRepository)
    }
    
    func getCheckPersistedUserUseCase() -> UseCase<Void, Void, CheckPersistedUserUseCaseErrorOutput> {
        return CheckPersistedUserUseCase(appRepository: appRepository, bsanManagersProvider: bsanManagersProvider, netInsightRepository: netInsightRepository)
    }

    func getPersistedUserUseCase() -> UseCase<Void, GetPersistedUserUseCaseOkOutput, GetPersistedUserUseCaseErrorOutput> {
        return GetPersistedUserUseCase(appRepository: appRepository)
    }

    func getRemovePersistedUserUseCase() -> UseCase<Void, Void, RemovePersistedUserUseCaseErrorOutput> {
        return RemovePersistedUserUseCase(appRepository: appRepository)
    }
    
    func getIsSameClientUseCase(input: IsSameClientUseCaseInput) -> UseCase<IsSameClientUseCaseInput, Void, StringErrorOutput> {
        return IsSameClientUseCase(provider: bsanManagersProvider).setRequestValues(requestValues: input)
    }
    
    func setLoginMessagesContextUseCase(input: SetLoginMessagesContextUseCaseInput) -> UseCase<SetLoginMessagesContextUseCaseInput, Void, StringErrorOutput> {
        return SetLoginMessagesContextUseCase(appRepository: appRepository).setRequestValues(requestValues: input)
    }
    
    func getLoginMessagesContextUseCase() -> UseCase<Void, GetLoginMessagesContextUseCaseOkOutput, StringErrorOutput> {
        return GetLoginMessagesContextUseCase(appRepository: appRepository, dependenciesResolver: dependenciesResolver)
    }
    
    func getCommercialSegmentUseCase() -> UseCase<Void, GetCommercialSegmentUseCaseOkOutput, StringErrorOutput> {
        return GetCommercialSegmentUseCase(appRepository: appRepository)
    }

    func getPGInterventionTypeUseCase() -> UseCase<Void, GetPGInterventionTypeUseCaseOkOutput, GetPGInterventionTypeUseCaseErrorOutput> {
        return GetPGInterventionTypeUseCase(appRepository: appRepository)
    }

    func setPGInterventionTypeUseCase(input: SetPGInterventionTypeUseCaseInput) -> UseCase<SetPGInterventionTypeUseCaseInput, Void, SetPGInterventionTypeUseCaseErrorOutput> {
        return SetPGInterventionTypeUseCase(appRepository: appRepository).setRequestValues(requestValues: input)
    }
    
    func getUpdatePGUserPrefUseCase(input: UpdatePGUserPrefUseCaseInput) -> UseCase<UpdatePGUserPrefUseCaseInput, Void, StringErrorOutput> {
        return UpdatePGUserPrefUseCase(appRepository: appRepository).setRequestValues(requestValues: input)
    }
    
    func updateUserVisualizationsUseCase(input: UpdateUserVisualizationsUseCaseInput) -> UseCase<UpdateUserVisualizationsUseCaseInput, UpdateUserVisualizationsUseCaseOkOutput, UpdateUserVisualizationsUseCaseErrorOutput> {
        return UpdateUserVisualizationsUseCase().setRequestValues(requestValues: input)
    }

    func getSelectedProductUseCase() -> UseCase<Void, GetSelectedProductUseCaseOkOutput, GetSelectedProductUseCaseErrorOutput> {
        return GetSelectedProductUseCase(appRepository: appRepository)
    }

    func setSelectedProductUseCase(input: SetSelectedProductUseCaseInput) -> UseCase<SetSelectedProductUseCaseInput, Void, SetSelectedProductUseCaseErrorOutput> {
        return SetSelectedProductUseCase(appRepository: appRepository).setRequestValues(requestValues: input)
    }
    
    func getInfoServicesForYouUseCase() -> UseCase<Void, GetInfoServicesForYouUseCaseOkOutput, GetInfoServicesForYouUseCaseErrorOutput> {
        return GetInfoServicesForYouUseCase(servicesForYouRepository: servicesForYouRepository, appRepository: appRepository)
    }

    // ------------- POR REALIZAR ------------- //
    
    func getLoadGlobalPositionV2UseCase() -> UseCase<Void, Void, StringErrorOutput> {
        return LoadGlobalPositionV2UseCase(bsanManagersProvider: bsanManagersProvider, appRepository: appRepository, appConfigRepository: appConfigRepository, accountDescriptorRepository: accountDescriptorRepository)
    }
    
    func setupBlockCardUseCase(input: SetupBlockCardUseCaseInput) -> UseCase<SetupBlockCardUseCaseInput, SetupBlockCardUseCaseOkOutput, SetupBlockCardUseCaseErrorOutput> {
        return SetupBlockCardUseCase(managersProvider: bsanManagersProvider, appConfigRepository: appConfigRepository).setRequestValues(requestValues: input)
    }

    func validateBlockCardUseCase(input: ValidateBlockCardUseCaseInput) -> UseCase<ValidateBlockCardUseCaseInput, ValidateBlockCardUseCaseOkOutput, ValidateBlockCardUseCaseErrorOutput> {
        return ValidateBlockCardUseCase(managersProvider: bsanManagersProvider).setRequestValues(requestValues: input)
    }
    
    func confirmBlockCardUseCase(input: ConfirmBlockCardUseCaseInput) -> UseCase<ConfirmBlockCardUseCaseInput, ConfirmBlockCardUseCaseOkOutput, GenericErrorSignatureErrorOutput> {
        return ConfirmBlockCardUseCase(managersProvider: bsanManagersProvider).setRequestValues(requestValues: input)
    }
    
    func setupChargeDischargeUseCase(input: SetupChargeDischargeCardUseCaseInput) -> UseCase<SetupChargeDischargeCardUseCaseInput, SetupChargeDischargeCardUseCaseOkOutput, SetupChargeDischargeCardUseCaseErrorOutput> {
        return SetupChargeDischargeCardUseCase(managersProvider: bsanManagersProvider, appConfigRepository: appConfigRepository).setRequestValues(requestValues: input)
    }
    
    func preValidateChargeDischargeAmountUseCase(input: PreValidateChargeDischargeAmountUseCaseInput) -> UseCase<PreValidateChargeDischargeAmountUseCaseInput, PreValidateChargeDischargeAmountUseCaseOkOutput, PreValidateChargeDischargeAmountUseCaseErrorOutput> {
        return PreValidateChargeDischargeAmountUseCase(managersProvider: bsanManagersProvider).setRequestValues(requestValues: input)
    }
    
    func validateChargeDischargeUseCase(input: ValidateChargeDischargeUseCaseInput) -> UseCase<ValidateChargeDischargeUseCaseInput, ValidateChargeDischargeUseCaseOkOutput, ValidateChargeDischargeUseCaseErrorOutput> {
        return ValidateChargeDischargeUseCase(managersProvider: bsanManagersProvider).setRequestValues(requestValues: input)
    }
    
    func confirmChargeDischargeUseCase(input: ConfirmChargeDischargeUseCaseInput) -> UseCase<ConfirmChargeDischargeUseCaseInput, ConfirmChargeDischargeUseCaseOkOutput, GenericErrorSignatureErrorOutput> {
        return ConfirmChargeDischargeUseCase(managersProvider: bsanManagersProvider).setRequestValues(requestValues: input)
    }
    
    func confirmOtpChargeDischargeUseCase(input: ConfirmOtpChargeDischargeUseCaseInput) -> UseCase<ConfirmOtpChargeDischargeUseCaseInput, ConfirmOtpChargeDischargeUseCaseOkOutput, GenericErrorOTPErrorOutput> {
        return ConfirmOtpChargeDischargeUseCase(managersProvider: bsanManagersProvider).setRequestValues(requestValues: input)
    }
    
    func setupSignUpCesCardUseCase(input: SetupSignUpCesCardUseCaseInput) -> UseCase<SetupSignUpCesCardUseCaseInput, SetupSignUpCesCardUseCaseOkOutput, SetupSignUpCesCardUseCaseErrorOutput> {
        return SetupSignUpCesCardUseCase(managersProvider: bsanManagersProvider, appConfigRepository: appConfigRepository).setRequestValues(requestValues: input)
    }
    
    func validateSignUpCesCardUseCase(input: ValidateSignUpCesCardUseCaseInput) -> UseCase<ValidateSignUpCesCardUseCaseInput, ValidateSignUpCesCardUseCaseOkOutput, ValidateSignUpCesCardUseCaseErrorOutput> {
        return ValidateSignUpCesCardUseCase(managersProvider: bsanManagersProvider).setRequestValues(requestValues: input)
    }
    
    func confirmSignUpCesCardUseCase(input: ConfirmSignUpCesCardUseCaseInput) -> UseCase<ConfirmSignUpCesCardUseCaseInput, ConfirmSignUpCesCardUseCaseOkOutput, GenericErrorSignatureErrorOutput> {
        return ConfirmSignUpCesCardUseCase(managersProvider: bsanManagersProvider).setRequestValues(requestValues: input)
    }
    
    func confirmOtpSignUpCesCardUseCase(input: ConfirmOtpSignUpCesCardUseCaseInput) -> UseCase<ConfirmOtpSignUpCesCardUseCaseInput, ConfirmOtpSignUpCesCardUseCaseOkOutput, GenericErrorOTPErrorOutput> {
        return ConfirmOtpSignUpCesCardUseCase(managersProvider: bsanManagersProvider).setRequestValues(requestValues: input)
    }
    
    func getGetWithdrawMoneyCardDomainCase() -> UseCase<Void, GetWithdrawMoneyCardDomainCaseOkOutput, GetWithdrawMoneyCardDomainCaseErrorOutput> {
        return GetWithdrawMoneyCardDomainCase(bsanManagersProvider: bsanManagersProvider)
    }
    
    func getGetCreditCardsUseCase() -> UseCase<Void, GetCreditCardsDomainCaseOkOutput, GetCreditCardsDomainCaseErrorOutput> {
        return GetCreditCardsDomainCase(bsanManagersProvider: bsanManagersProvider)
    }
    
    func getCreditCardForPANUseCase(input: GetCreditCardForPANUseCaseInput) -> UseCase<GetCreditCardForPANUseCaseInput, GetCreditCardForPANUseCaseOkOutput, StringErrorOutput> {
        return GetCreditCardForPANUseCase(appConfig: appConfigRepository, bsanManagerProvider: bsanManagersProvider, appRepository: appRepository, accountDescriptorRepository: accountDescriptorRepository, appConfigRepository: appConfigRepository).setRequestValues(requestValues: input)
    }
    
    func setupPINQueryCardUseCase(input: SetupPINQueryCardUseCaseInput) -> UseCase<SetupPINQueryCardUseCaseInput, SetupPINQueryCardUseCaseOkOutput, SetupPINQueryCardUseCaseErrorOutput> {
        return SetupPINQueryCardUseCase(managersProvider: bsanManagersProvider, appConfigRepository: appConfigRepository).setRequestValues(requestValues: input)
    }
    
    func confirmPINQueryCardUseCase(input: ConfirmPINQueryCardUseCaseInput) -> UseCase<ConfirmPINQueryCardUseCaseInput, ConfirmPINQueryCardUseCaseOkOutput, GenericErrorSignatureErrorOutput> {
        return ConfirmPINQueryCardUseCase(managersProvider: bsanManagersProvider).setRequestValues(requestValues: input)
    }
    
    func confirmOtpPINQueryCardUseCase(input: ConfirmOtpPINQueryCardUseCaseInput) -> UseCase<ConfirmOtpPINQueryCardUseCaseInput, ConfirmOtpPINQueryCardUseCaseOkOutput, GenericErrorOTPErrorOutput> {
        return ConfirmOtpPINQueryCardUseCase(managersProvider: bsanManagersProvider).setRequestValues(requestValues: input)
    }

    func getLoadUsualTransfersUseCase() -> UseCase<Void, Void, LoadUsualTransfersUseCaseErrorOutput> {
        return LoadUsualTransfersUseCase(bsanManagersProvider: bsanManagersProvider)
    }
    
    func getFavoritesUseCase() -> UseCase<Void, GetFavoriteTransfersUseCaseOkOutput, GetFavoriteTransfersUseCaseErrorOutput> {
        return GetFavoriteTransfersUseCase(managersProvider: bsanManagersProvider, sepaRepository: sepaInfoRepository)
    }

    func getPGDataUseCase() -> UseCase<Void, GetPGProductsUseCaseOkOutput, GetPGProductsUseCaseErrorOutput> {
        return GetPGProductsUseCase(bsanManagersProvider: bsanManagersProvider, appRepository: appRepository, accountDescriptorRepository: accountDescriptorRepository, appConfigRepository: appConfigRepository)
    }
    
    func getPrivateMenuDataUseCase() -> UseCase<Void, GetPrivateMenuDataUseCaseOkOutput, StringErrorOutput> {
        return GetPrivateMenuDataUseCase(bsanManagersProvider: bsanManagersProvider, appRepository: appRepository, accountDescriptorRepository: accountDescriptorRepository, appConfigRepository: appConfigRepository, servicesForYouRepository: servicesForYouRepository, dependenciesResolver: dependenciesResolver)
    }
    
    func getPGModeChangeUseCase(input: GetPGModeChangeUseCaseInput) -> UseCase<GetPGModeChangeUseCaseInput, GetPGModeChangeUseCaseOkOutput, GetPGModeChangeUseCaseErrorOutput> {
        return GetPGModeChangeUseCase(appRepository: appRepository).setRequestValues(requestValues: input)
    }
    
    func getLogoutDialogUseCase() -> UseCase<Void, LogoutDialogUseCaseOkOutput, StringErrorOutput> {
        return LogoutDialogUseCase(dependenciesResolver: dependenciesResolver)
    }
    
    func getMinimumEasyPayAmountUseCase() -> UseCase<Void, MinimumAmountEasyPayOkOutput, StringErrorOutput> {
        return GetMinimumAmountEasyPayAmountUseCase(bsanManagersProvider: bsanManagersProvider)
    }
    
    func getSetupPublicFilesUseCase() -> UseCase<Void, Void, StringErrorOutput> {
        return SetupPublicFilesUseCase(appConfigRepository: appConfigRepository,
                                       publicProductsRepository: publicProductsRepository,
                                       segmentedUsersRepository: segmentedUserRepository,
                                       faqsRepository: faqsRepository,
                                       rulesRepository: rulesRepository,
                                       offersRepository: offersRepository,
                                       servicesForYouRepository: servicesForYouRepository,
                                       sepaInfoRepository: sepaInfoRepository,
                                       tricksRepository: tricksRepository)
    }
    
    func getLoadAppConfigDomainCase() -> UseCase<Void, Void, LoadAppConfigDomainCaseErrorOutput> {
        return LoadAppConfigDomainCase(dependencies: self.dependenciesResolver, appConfigRepository: appConfigRepository, appRepository: appRepository, daoSharedAppConfig: daoSharedAppConfig)
    }
    
    func getPublicCategoriesUseCase() -> UseCase<Void, GetPublicCategoriesUseCaseOkOutput, StringErrorOutput> {
        return GetPublicCategoriesUseCase(pullOffersRepository: pullOffersConfigRepository, pullOffersInterpreter: pullOffersInterpreter)
    }
    
    func getPublicProductsUseCase() -> UseCase<Void, GetPublicProductsUseCaseOutput, StringErrorOutput> {
        return GetPublicProductsUseCase(dependencies: self.dependenciesResolver, productsRepository: publicProductsRepository, appRepository: appRepository)
    }
    
    //! Get category by identifier
    func getPublicCategoryUseCase(input: GetPublicCategoryUseCaseInput) -> UseCase<GetPublicCategoryUseCaseInput, GetPublicCategoryUseCaseOkOutput, StringErrorOutput> {
        return GetPublicCategoryUseCase(pullOffersRepository: pullOffersConfigRepository, pullOffersInterpreter: pullOffersInterpreter).setRequestValues(requestValues: input)
    }
    
    func getLoadServicesForYouCase() -> UseCase<Void, Void, LoadServicesForYouErrorOutput> {
        return LoadServicesForYouUseCase(dependencies: self.dependenciesResolver, servicesForYouRepository: servicesForYouRepository, appRepository: appRepository)
    }
    
    func getPreSetupCreateUsualTransferUseCase() -> UseCase<Void, PreSetupCreateUsualTransferUseCaseOkOutput, StringErrorOutput> {
        return PreSetupCreateUsualTransferUseCase(sepaRepository: sepaInfoRepository)
    }
    
    func getSetupCreateUsualTransferUseCase(input: SetupCreateUsualTransferUseCaseInput) -> UseCase<SetupCreateUsualTransferUseCaseInput, SetupCreateUsualTransferUseCaseOKOutput, StringErrorOutput> {
        return SetupCreateUsualTransferUseCase(appConfigRepository: appConfigRepository, bsanManagersProvider: bsanManagersProvider).setRequestValues(requestValues: input)
    }
    
    func getUserSegmentsCase() -> UseCase<Void, Void, LoadUserSegmentsErrorOutput> {
        return LoadUserSegmentsUseCase(dependencies: self.dependenciesResolver,segmentedUserRepository: segmentedUserRepository, appRepository: appRepository)
    }
    
    func getFaqsUseCase() -> LoadFaqsUseCase {
        return LoadFaqsUseCase(dependencies: self.dependenciesResolver, faqsRepository: faqsRepository, appRepository: appRepository)
    }
    
    func getLoadPullOfferRules() -> UseCase<Void, Void, LoadPullOffersRulesErrorOutput> {
        return LoadPullOffersRulesUseCase(dependencies: self.dependenciesResolver, rulesRepository: rulesRepository, appRepository: appRepository)
    }
    
    func getLoadPullOfferOffers() -> UseCase<Void, Void, LoadPullOffersOffersErrorOutput> {
        return LoadPullOffersOffersUseCase(dependencies: self.dependenciesResolver, offersRepository: offersRepository, appRepository: appRepository)
    }
    
    func getLoadPullOffersConfigUseCase() -> UseCase<Void, Void, StringErrorOutput> {
        return LoadPullOffersConfigUseCase(dependencies: self.dependenciesResolver, pullOffersConfigRepository: pullOffersConfigRepository, appRepository: appRepository)
    }
    
    func getRemovePullOfferLocationUseCase(input: RemovePullOfferLocationUseCaseInput) -> UseCase<RemovePullOfferLocationUseCaseInput, Void, StringErrorOutput> {
        return RemovePullOfferLocationUseCase(pullOffersInterpreter: pullOffersInterpreter).setRequestValues(requestValues: input)
    }
    
    func getDisableOnSessionPullOfferUseCase(input: DisableOnSessionPullOfferUseCaseInput) -> UseCase<DisableOnSessionPullOfferUseCaseInput, Void, StringErrorOutput> {
        return DisableOnSessionPullOfferUseCase(dependenciesResolver: dependenciesResolver).setRequestValues(requestValues: input)
    }
    
    func getLoadAccountDescriptorDomainCase() -> UseCase<Void, Void, LoadAccountDescriptorDomainCaseErrorOutput> {
        return LoadAccountDescriptorDomainCase(dependencies: dependenciesResolver, accountDescriptorRepository: accountDescriptorRepository, appRepository: appRepository)
    }
 
    func getAccounTransactionsListPdfUseCase(input: AccounTransactionsListPdfUseCaseInput) -> UseCase<AccounTransactionsListPdfUseCaseInput, AccounTransactionsListPdfUseCaseOkOutput, StringErrorOutput> {
        return AccounTransactionsListPdfUseCase(bsanManagersProvider: bsanManagersProvider).setRequestValues(requestValues: input)
    }

    func getAccountDetailUseCase(input: GetAccountDetailUseCaseInput) -> UseCase<GetAccountDetailUseCaseInput, GetAccountDetailUseCaseOKOutput, GetAccountDetailUseCaseErrorOutput> {
        return GetAccountDetailUseCase(managerProvider: bsanManagersProvider, dependenciesResolver: dependenciesResolver).setRequestValues(requestValues: input)
    }

    func getFundTransactionsUseCase(input: GetFundTransactionsUseCaseInput) -> UseCase<GetFundTransactionsUseCaseInput, GetFundTransactionsUseCaseOkOutput, GetFundTransactionsUseCaseErrorOutput> {
        return GetFundTransactionsUseCase(managersProvider: bsanManagersProvider).setRequestValues(requestValues: input)
    }

    func getFundDetailUseCase(input: GetFundDetailUseCaseInput) -> UseCase<GetFundDetailUseCaseInput, GetFundDetailUseCaseOKOutput, GetFundDetailUseCaseErrorOutput> {
        return GetFundDetailUseCase(managersProvider: bsanManagersProvider).setRequestValues(requestValues: input)
    }

    func getPensionTransactionsUseCase(input: GetPensionTransactionsUseCaseInput) -> UseCase<GetPensionTransactionsUseCaseInput, GetPensionTransactionsUseCaseOkOutput, GetPensionTransactionsUseCaseErrorOutput> {
        return GetPensionTransactionsUseCase(managersProvider: bsanManagersProvider).setRequestValues(requestValues: input)
    }

    func getPensionDetailUseCase(input: GetPensionDetailUseCaseInput) -> UseCase<GetPensionDetailUseCaseInput, GetPensionDetailUseCaseOKOutput, GetPensionDetailUseCaseErrorOutput> {
        return GetPensionDetailUseCase(managerProvider: bsanManagersProvider).setRequestValues(requestValues: input)
    }
    
    func setupPensionPeriodicalContributionUseCase(input: SetupPeriodicalContributionUseCaseInput) -> UseCase<SetupPeriodicalContributionUseCaseInput, SetupPeriodicalContributionUseCaseOKOutput, SetupPeriodicalContributionUseCaseErrorOutput> {
        return SetupPeriodicalContributionUseCase(repository: appConfigRepository, managersProvider: bsanManagersProvider).setRequestValues(requestValues: input)
    }
    
    func getPreSetupPensionExtraordinaryContributionUseCase(input: PreSetupPensionExtraordinaryContributionUseCaseInput) -> UseCase<PreSetupPensionExtraordinaryContributionUseCaseInput, PreSetupPensionExtraordinaryContributionUseCaseOkOutput, StringErrorOutput> {
        return PreSetupPensionExtraordinaryContributionUseCase(managersProvider: bsanManagersProvider, appConfigRepository: appConfigRepository, appRepository: appRepository, accountDescriptorRepository: accountDescriptorRepository).setRequestValues(requestValues: input)
    }
    
    func setupPensionExtraordinaryContributionUseCase(input: SetupPensionExtraordinaryContributionUseCaseInput) -> UseCase<SetupPensionExtraordinaryContributionUseCaseInput, SetupPensionExtraordinaryContributionUseCaseOkOutput, StringErrorOutput> {
        return SetupPensionExtraordinaryContributionUseCase(managersProvider: bsanManagersProvider, appConfigRepository: appConfigRepository).setRequestValues(requestValues: input)
    }
    
    func preValidateExtraordinaryContributionUseCase(input: PreValidateExtraordinaryContributionUseCaseInput) -> UseCase<PreValidateExtraordinaryContributionUseCaseInput, PreValidateExtraordinaryContributionUseCaseOkOutput, PreValidateExtraordinaryContributionUseCaseErrorOutput> {
        return PreValidateExtraordinaryContributionUseCase(managersProvider: bsanManagersProvider).setRequestValues(requestValues: input)
    }
    
    func validateExtraordinaryContributionUseCase() -> ValidateExtraordinaryContributionUseCase {
        return ValidateExtraordinaryContributionUseCase(managersProvider: bsanManagersProvider)
    }
    
    func confirmExtraordinaryContributionUseCase(input: ConfirmExtraordinaryContributionUseCaseInput) -> UseCase<ConfirmExtraordinaryContributionUseCaseInput, Void, GenericErrorSignatureErrorOutput> {
        return ConfirmExtraordinaryContributionUseCase(managersProvider: bsanManagersProvider).setRequestValues(requestValues: input)
    }
    
    func getConfirmDirectMoneyUseCase(input: ConfirmDirectMoneyUseCaseInput) -> UseCase<ConfirmDirectMoneyUseCaseInput, Void, GenericErrorSignatureErrorOutput> {
        return ConfirmDirectMoneyUseCase(managersProvider: bsanManagersProvider).setRequestValues(requestValues: input)
    }
    
    func getValidateDirectMoneyUseCase(input: ValidateDirectMoneyUseCaseInput) -> UseCase<ValidateDirectMoneyUseCaseInput, ValidateDirectMoneyUseCaseOkOutput, StringErrorOutput> {
        return ValidateDirectMoneyUseCase(managersProvider: bsanManagersProvider).setRequestValues(requestValues: input)
    }
    
    func getSetupDirectMoneyUseCase(input: SetupDirectMoneyUseCaseInput) -> UseCase<SetupDirectMoneyUseCaseInput, SetupDirectMoneyUseCaseOkOutput, StringErrorOutput> {
        return SetupDirectMoneyUseCase(managersProvider: bsanManagersProvider,
                                       appConfigRepository: appConfigRepository,
                                       dependenciesResolver: dependenciesResolver).setRequestValues(requestValues: input)
    }

    func getImpositionsUseCase(input: GetImpositionsUseCaseInput) -> UseCase<GetImpositionsUseCaseInput, GetImpositionsUseCaseOkOutput, GetImpositionsUseCaseErrorOutput> {
        return GetImpositionsUseCase(managersProvider: bsanManagersProvider).setRequestValues(requestValues: input)
    }

    func getProductConfigUseCase() -> UseCase<Void, GetProductUseCaseOKOutput, GetProductUseCaseErrorOutput> {
        return GetProductUseCase(appConfigRepository: appConfigRepository, accountDescriptorRepository: accountDescriptorRepository, bsanManagersProvider: bsanManagersProvider)
    }
    
    func getFundTransactionDetailUseCase(input: GetFundTransactionDetailUseCaseInput) -> UseCase<GetFundTransactionDetailUseCaseInput, GetFundTransactionDetailUseCaseOkOutput, GetFundTransactionDetailUseCaseErrorOutput> {
        return GetFundTransactionDetailUseCase(managersProvider: bsanManagersProvider).setRequestValues(requestValues: input)
    }
    
    func getOnboardingUseCase(dependencies: PresentationComponent) -> UseCase<Void, GetOnboardingUseCaseOkOutput, StringErrorOutput> {
        return GetOnboardingUseCase(bsanManagersProvider: bsanManagersProvider, appRepository: appRepository, accountDescriptorRepository: accountDescriptorRepository, appConfigRepository: appConfigRepository, dependencies: dependencies)
    }

    func setupChangeLoanLinkedAccount(input: SetupChangeLinkedAccountUseCaseInput) -> UseCase<SetupChangeLinkedAccountUseCaseInput, SetupChangeLinkedAccountUseCaseOkOutput, SetupChangeLinkedAccountUseCaseErrorOutput> {
        return SetupChangeLinkedAccountUseCase(appRepository: appRepository, appConfig: appConfigRepository, accountDescriptorRepository: accountDescriptorRepository, bsanManagerProvider: bsanManagersProvider).setRequestValues(requestValues: input)
    }
    
    func prevalidateChangeLoanLinkedAccount(input: PrevalidateChangeLinkedAccountUseCaseInput) -> UseCase<PrevalidateChangeLinkedAccountUseCaseInput, PrevalidateChangeLinkedAccountUseCaseOkOutput, PrevalidateChangeLinkedAccountUseCaseErrorOutput> {
        return PrevalidateChangeLinkedAccountUseCase(managersProvider: bsanManagersProvider).setRequestValues(requestValues: input)
    }
    
    func setupSignatureUseCase(input: SetupSignatureUseCaseInput) -> UseCase<SetupSignatureUseCaseInput, SetupSignatureUseCaseOkOutput, StringErrorOutput> {
        return SetupSignatureUseCase(managersProvider: bsanManagersProvider, appConfigRepository: appConfigRepository).setRequestValues(requestValues: input)
    }
    
    func getSignatureOperativeConfigurationUseCase() -> UseCase<Void, SignatureOperativeConfigurationUseCaseOkOutput, StringErrorOutput> {
        return SignatureOperativeConfigurationUseCase(managersProvider: bsanManagersProvider, appConfigRepository: appConfigRepository)
    }
    
    func getSignatureActivationStateUseCase() -> UseCase<Void, GetSignatureActivationStateUseCaseOkOutput, StringErrorOutput> {
        return GetSignatureActivationStateUseCase(managersProvider: bsanManagersProvider)
    }
    
    func validateSignatureActivationUseCase(input: ValidateSignatureActivationUseCaseInput) -> UseCase<ValidateSignatureActivationUseCaseInput, ValidateSignatureActivationUseCaseOkOutput, ValidateSignatureActivationUseCaseErrorOutput> {
        return ValidateSignatureActivationUseCase(managersProvider: bsanManagersProvider).setRequestValues(requestValues: input)
    }
    
    func confirmSignatureActivationUseCase(input: ConfirmSignatureActivationUseCaseInput) -> UseCase<ConfirmSignatureActivationUseCaseInput, Void, GenericErrorSignatureErrorOutput> {
        return ConfirmSignatureActivationUseCase(managersProvider: bsanManagersProvider).setRequestValues(requestValues: input)
    }
    
    func confirmSignatureChangeUseCase(input: ConfirmSignatureChangeUseCaseInput) -> UseCase<ConfirmSignatureChangeUseCaseInput, Void, GenericErrorSignatureErrorOutput> {
        return ConfirmSignatureChangeUseCase(managersProvider: bsanManagersProvider).setRequestValues(requestValues: input)
    }
    
    func setupMobileTopUp(input: SetupMobileTopUpUseCaseInput) -> UseCase<SetupMobileTopUpUseCaseInput, SetupMobileTopUpUseCaseOkOutput, SetupMobileTopUpUseCaseErrorOutput> {
        return SetupMobileTopUpUseCase(managersProvider: bsanManagersProvider, appConfigRepository: appConfigRepository).setRequestValues(requestValues: input)
    }
    
    func validateMobileTopUpUseCase(input: ValidateMobileTopUpUseCaseInput) -> UseCase<ValidateMobileTopUpUseCaseInput, ValidateMobileTopUpUseCaseOkOutput, StringErrorOutput> {
        return ValidateMobileTopUpUseCase(managersProvider: bsanManagersProvider).setRequestValues(requestValues: input)
    }
    
    func confirmMobileToUpUseCase(input: ConfirmMobileToUpUseCaseInput) -> UseCase<ConfirmMobileToUpUseCaseInput, ConfirmMobileToUpUseCaseOkOutput, GenericErrorSignatureErrorOutput> {
        return ConfirmMobileToUpUseCase(managersProvider: bsanManagersProvider).setRequestValues(requestValues: input)
    }
    
    func confirmOtpMobileToUpUseCase(input: ConfirmOtpMobileToUpUseCaseInput) -> UseCase<ConfirmOtpMobileToUpUseCaseInput, ConfirmOtpMobileToUpUseCaseOkOutput, GenericErrorOTPErrorOutput> {
        return ConfirmOtpMobileToUpUseCase(managersProvider: bsanManagersProvider).setRequestValues(requestValues: input)
    }
    
    func getSetupCVVQueryCardUseCase() -> UseCase<SetupCVVQueryCardUseCaseInput, SetupCVVQueryCardUseCaseOkOutput, SetupCVVQueryCardUseCaseErrorOutput> {
        return SetupCVVQueryCardUseCase(dependenciesResolver: self.dependenciesResolver, appConfigRepository: appConfigRepository)
    }
    
    func confirmCVVQueryCardUseCase(input: ConfirmCVVQueryCardUseCaseInput) -> UseCase<ConfirmCVVQueryCardUseCaseInput, ConfirmCVVQueryCardUseCaseOkOutput, GenericErrorSignatureErrorOutput> {
        return ConfirmCVVQueryCardUseCase(managersProvider: bsanManagersProvider).setRequestValues(requestValues: input)
    }
    
    func confirmOtpCVVQueryCardUseCase(input: ConfirmOtpCVVQueryCardUseCaseInput) -> UseCase<ConfirmOtpCVVQueryCardUseCaseInput, ConfirmOtpCVVQueryCardUseCaseOkOutput, GenericErrorOTPErrorOutput> {
        return ConfirmOtpCVVQueryCardUseCase(managersProvider: bsanManagersProvider).setRequestValues(requestValues: input)
    }

    func validateLinkedChangeAccount() -> UseCase<Void, ValidateChangeLinkedAccountUseCaseOkOutput, ValidateChangeLinkedAccountUseCaseErrorOutput> {
        return ValidateChangeLinkedAccountUseCase(managersProvider: bsanManagersProvider)
    }

    func confirmChangeLinkedAccount(input: ConfirmChangeLinkedAccountUseCaseInput) -> UseCase<ConfirmChangeLinkedAccountUseCaseInput, ConfirmChangeLinkedAccountUseCaseOkOutput, GenericErrorSignatureErrorOutput> {
        return ConfirmChangeLinkedAccountUseCase(managersProvider: bsanManagersProvider).setRequestValues(requestValues: input)
    }
    
    func preSetupPayLaterCardUseCase(input: PreSetupPayLaterCardUseCaseInput) -> UseCase<PreSetupPayLaterCardUseCaseInput, PreSetupPayLaterCardUseCaseOkOutput, StringErrorOutput> {
        return PreSetupPayLaterCardUseCase(managersProvider: bsanManagersProvider, appConfigRepository: appConfigRepository, appRepository: appRepository, accountDescriptorRepository: accountDescriptorRepository).setRequestValues(requestValues: input)
    }
    
    func setupPayLaterCardUseCase(input: SetupPayLaterCardUseCaseInput) -> UseCase<SetupPayLaterCardUseCaseInput, SetupPayLaterCardUseCaseOkOutput, StringErrorOutput> {
        return SetupPayLaterCardUseCase(managersProvider: bsanManagersProvider, appConfigRepository: appConfigRepository).setRequestValues(requestValues: input)
    }
    
    func prevalidatePayLaterCardUseCase(input: PrevalidatePayLaterCardUseCaseInput) -> UseCase<PrevalidatePayLaterCardUseCaseInput, Void, PrevalidatePayLaterCardUseCaseErrorOutput> {
        return PrevalidatePayLaterCardUseCase(managersProvider: bsanManagersProvider).setRequestValues(requestValues: input)
    }
    
    func validatePayLaterCardUseCase(input: ValidatePayLaterCardUseCaseInput) -> UseCase<ValidatePayLaterCardUseCaseInput, Void, StringErrorOutput> {
        return ValidatePayLaterCardUseCase(managersProvider: bsanManagersProvider).setRequestValues(requestValues: input)
    }
    
    func preSetupCardModifyPaymentFormUseCase(input: PreSetupCardModifyPaymentFormUseCaseInput) -> UseCase<PreSetupCardModifyPaymentFormUseCaseInput, PreSetupCardModifyPaymentFormUseCaseOkOutput, StringErrorOutput> {
        return PreSetupCardModifyPaymentFormUseCase(managersProvider: bsanManagersProvider, appConfigRepository: appConfigRepository, appRepository: appRepository, accountDescriptorRepository: accountDescriptorRepository).setRequestValues(requestValues: input)
    }
    
    func setupCardModifyPaymentFormUseCase(input: SetupCardModifyPaymentFormUseCaseInput) -> UseCase<SetupCardModifyPaymentFormUseCaseInput, SetupCardModifyPaymentFormUseCaseOkOutput, SetupCardModifyPaymentFormUseCaseErrorOutput> {
        return SetupCardModifyPaymentFormUseCase(managersProvider: bsanManagersProvider, appConfigRepository: appConfigRepository).setRequestValues(requestValues: input)
    }
    
    func confirmCardModifyPaymentFormUseCase(input: ConfirmCardModifyPaymentFormUseCaseInput) -> UseCase<ConfirmCardModifyPaymentFormUseCaseInput, Void, ConfirmCardModifyPaymentFormCaseUseErrorOutput> {
        return ConfirmCardModifyPaymentFormUseCase(managersProvider: bsanManagersProvider).setRequestValues(requestValues: input)
    }
    
    func getStocksUseCase(input: GetStocksUseCaseInput) -> UseCase<GetStocksUseCaseInput, GetStocksUseCaseOkOutput, GetStocksUseCaseErrorOutput> & Cancelable {
        let usecase = GetStocksUseCase(managersProvider: bsanManagersProvider)
        _ = usecase.setRequestValues(requestValues: input)
        return usecase
    }
    
    func getRVManagedStocksUseCase() -> UseCase<Void, GetRVManagedStockAccountsUseCaseOkOutput, StringErrorOutput> & Cancelable {
        return GetRVManagedStockAccountsUseCase(managersProvider: bsanManagersProvider)
    }
    
    func getRVNotManagedStocksUseCase() -> UseCase<Void, GetRVNotManagedStockAccountsUseCaseOkOutput, StringErrorOutput> & Cancelable {
        return GetRVNotManagedStockAccountsUseCase(managersProvider: bsanManagersProvider)
    }
    
    func getAllStockAccountsUseCase(input: GetAllStockAccountsUseCaseInput) -> UseCase<GetAllStockAccountsUseCaseInput, GetAllStockAccountsUseCaseOkOutput, StringErrorOutput> & Cancelable {
        let useCase = GetAllStockAccountsUseCase(provider: bsanManagersProvider, appRepository: appRepository, accountDescriptorRepository: accountDescriptorRepository, appConfigRepository: appConfigRepository)
        _ = useCase.setRequestValues(requestValues: input)
        return useCase
    }
    
    func getAllStocksUseCase() -> UseCase<Void, GetAllStocksUseCaseOkOutput, StringErrorOutput> {
        return GetAllStocksUseCase(managersProvider: bsanManagersProvider)
    }
    
    func getChatInbentaDataUseCase() -> UseCase<Void, GetChatInbentaDataUseCaseOkOutput, StringErrorOutput> {
        return GetChatInbentaDataUseCase(bsanManagersProvider: bsanManagersProvider, appConfigRepository: appConfigRepository)
    }

    func getManagerWallDataUseCase(input: GetManagerWallDataUseCaseInput) -> UseCase<GetManagerWallDataUseCaseInput, GetManagerWallDataUseCaseOkOutput, StringErrorOutput> {
        return GetManagerWallDataUseCase(bsanManagersProvider: bsanManagersProvider, appConfigRepository: appConfigRepository).setRequestValues(requestValues: input)
    }

    func getVirtualAssitantDataUseCase() -> UseCase<Void, GetVirtualAssitantDataUseCaseOkOutput, StringErrorOutput> {
        return GetVirtualAssitantDataUseCase(bsanManagersProvider: bsanManagersProvider, appConfigRepository: appConfigRepository)
    }
    
    func getIsMarketplaceEnabledUseCase() -> UseCase<Void, IsMarketplaceEnabledUseCaseOkOutput, StringErrorOutput> {
        return IsMarketplaceEnabledUseCase(appConfigRepository: appConfigRepository)
    }
    
    func getFinancingUseCase() -> UseCase<Void, GetFinancingUseCaseOkOutput, StringErrorOutput> {
        return GetFinancingUseCase(appConfigRepository: appConfigRepository)
    }
    
    func getGetInsurancBillEmittersUseCase() -> UseCase<Void, GetInsuranceBillEmittersOkOutput, StringErrorOutput> {
        return GetInsuranceBillEmittersUseCase(appConfigRepository: appConfigRepository)
    }
    
    func getFinancingCardsDeeplinkUseCase() -> UseCase<Void, GetFinancingCardsDeeplinkUseCaseOkOutput, StringErrorOutput> {
        return GetFinancingCardsDeeplinkUseCase(dependenciesResolver: dependenciesResolver, appConfigRepository: appConfigRepository)
    }
    
    func getMarketplaceUseCase(input: GetMarketplaceWebViewConfigurationInput) -> UseCase<GetMarketplaceWebViewConfigurationInput, GetMarketplaceWebViewConfigurationOkOutput, StringErrorOutput> {
        return GetMarketplaceWebViewConfigurationUseCase(appConfigRepository: appConfigRepository, bsanManagersProvider: bsanManagersProvider).setRequestValues(requestValues: input)
    }
    
    func getSantanderAppsUseCase() -> UseCase<Void, GetSantanderAppsWebViewConfigurationUseCaseOkOutput, StringErrorOutput> {
        return GetSantanderAppsWebViewConfigurationUseCase(appRepository: appRepository, appConfigRepository: appConfigRepository)
    }

    func getStockIbexSanUseCase() -> UseCase<Void, GetStockIbexSanUseCaseOkOutput, StringErrorOutput> {
        return GetStockIbexSanUseCase(managersProvider: bsanManagersProvider)
    }
    
    func getStockQuoteSearchUseCase(input: GetStocksQuoteSearchUseCaseInput) -> UseCase<GetStocksQuoteSearchUseCaseInput, GetStocksQuoteSearchUseCaseOkOutput, StringErrorOutput> {
        return GetStocksQuoteSearchUseCase(managersProvider: bsanManagersProvider).setRequestValues(requestValues: input)
    }

    func getStockQuoteDetailUseCase(input: GetStockQuoteDetailUseCaseInput) -> UseCase<GetStockQuoteDetailUseCaseInput, GetStockQuoteDetailUseCaseOkOutput, GetStockQuoteDetailUseCaseErrorOutput> {
        return GetStockQuoteDetailUseCase(managersProvider: bsanManagersProvider).setRequestValues(requestValues: input)
    }
    
    func getCounterValueDetailUseCase(input: GetCounterValueDetailUseCaseInput) -> UseCase<GetCounterValueDetailUseCaseInput, GetCounterValueDetailUseCaseOkOutput, StringErrorOutput> {
        return GetCounterValueDetailUseCase(managersProvider: bsanManagersProvider).setRequestValues(requestValues: input)
    }
    
    func getOrderListUseCase(input: GetOrderListUseCaseInput) -> UseCase<GetOrderListUseCaseInput, GetOrderListUseCaseOkOutput, GetOrderListUseCaseErrorOutput> {
        return GetOrderListUseCase(managersProvider: bsanManagersProvider).setRequestValues(requestValues: input)
    }
    
    func getOrderListFilteredUseCase(input: GetOrderListUseCaseInput) -> UseCase<GetOrderListUseCaseInput, GetOrderListUseCaseOkOutput, GetOrderListUseCaseErrorOutput> {
        return GetOrderListFilteredUseCase(managersProvider: bsanManagersProvider).setRequestValues(requestValues: input)
    }
    
    func getOrderDetailUseCase(input: GetOrderDetailUseCaseInput) -> UseCase<GetOrderDetailUseCaseInput, GetOrderDetailUseCaseOkOutput, GetOrderDetailUseCaseErrorOutput> {
        return GetOrderDetailUseCase(managersProvider: bsanManagersProvider).setRequestValues(requestValues: input)
    }
    
    func getInsuranceDataUseCase(input: GetInsuranceDataUseCaseInput) -> UseCase<GetInsuranceDataUseCaseInput, GetInsuranceDataUseCaseOkOutput, GetInsuranceDataUseCaseErrorOutput> {
        return GetInsuranceDataUseCase(managersProvider: bsanManagersProvider).setRequestValues(requestValues: input)
    }
    
    func getInsuranceSavingDataUseCase(input: GetInsuranceSavingDataUseCaseInput) -> UseCase<GetInsuranceSavingDataUseCaseInput, GetInsuranceDataUseCaseOkOutput, GetInsuranceDataUseCaseErrorOutput> {
        return GetInsuranceSavingDataUseCase(managersProvider: bsanManagersProvider).setRequestValues(requestValues: input)
    }
    
    func getInsuranceParticipantsUseCase(input: GetInsuranceParticipantsUseCaseInput) -> UseCase<GetInsuranceParticipantsUseCaseInput, GetInsuranceParticipantsUseCaseOkOutput, GetInsuranceParticipantsUseCaseErrorOutput> {
        return GetInsuranceParticipantsUseCase(managersProvider: bsanManagersProvider).setRequestValues(requestValues: input)
    }
    
    func getSavingInsuranceParticipantsUseCase(input: GetSavingInsuranceParticipantsUseCaseInput) -> UseCase<GetSavingInsuranceParticipantsUseCaseInput, GetInsuranceParticipantsUseCaseOkOutput, GetInsuranceParticipantsUseCaseErrorOutput> {
        return GetSavingInsuranceParticipantsUseCase(managersProvider: bsanManagersProvider).setRequestValues(requestValues: input)
    }
    
    func getInsuranceBeneficiariesUseCase(input: GetInsuranceBeneficiariesUseCaseInput) -> UseCase<GetInsuranceBeneficiariesUseCaseInput, GetInsuranceBeneficiariesUseCaseOkOutput, GetInsuranceBeneficiariesUseCaseErrorOutput> {
        return GetInsuranceBeneficiariesUseCase(managersProvider: bsanManagersProvider).setRequestValues(requestValues: input)
    }
    
    func getSavingInsuranceBeneficiariesUseCase(input: GetSavingInsuranceBeneficiariesUseCaseInput) -> UseCase<GetSavingInsuranceBeneficiariesUseCaseInput, GetInsuranceBeneficiariesUseCaseOkOutput, GetInsuranceBeneficiariesUseCaseErrorOutput> {
        return GetSavingInsuranceBeneficiariesUseCase(managersProvider: bsanManagersProvider).setRequestValues(requestValues: input)
    }
    
    func getInsuranceCoveragesUseCase(input: GetInsuranceCoveragesUseCaseInput) -> UseCase<GetInsuranceCoveragesUseCaseInput, GetInsuranceCoveragesUseCaseOkOutput, GetInsuranceCoveragesUseCaseErrorOutput> {
        return GetInsuranceCoveragesUseCase(managersProvider: bsanManagersProvider).setRequestValues(requestValues: input)
    }
    
    func getPortfolioProductListUseCase(input: GetPortfolioProductListUseCaseInput) -> UseCase<GetPortfolioProductListUseCaseInput, GetPortfolioProductListUseCaseOkOutput, GetPortfolioProductListUseCaseErrorOutput> {
        return GetPortfolioProductListUseCase(managersProvider: bsanManagersProvider).setRequestValues(requestValues: input)
    }
    
    func getPortfolioProductTransactionUseCase(input: GetPortfolioProductTransactionsUseCaseInput) -> UseCase<GetPortfolioProductTransactionsUseCaseInput, GetPortfolioProductTransactionsUseCaseOkOutput, GetPortfolioProductTransactionsUseCaseErrorOutput> {
        return GetPortfolioProductTransactionsUseCase(managersProvider: bsanManagersProvider).setRequestValues(requestValues: input)
    }
    
    func getPortfolioProductTransactionDetailUseCase(input: GetPortfolioProductTransactionDetailUseCaseInput) -> UseCase<GetPortfolioProductTransactionDetailUseCaseInput, GetPortfolioProductTransactionDetailUseCaseOkOutput, GetPortfolioProductTransactionDetailUseCaseErrorOutput> {
        return GetPortfolioProductTransactionDetailUseCase(managersProvider: bsanManagersProvider).setRequestValues(requestValues: input)
    }
    
    func getPortfolioProductHolderDetailUseCase(input: GetPortfolioProductHolderDetailUseCaseInput) -> UseCase<GetPortfolioProductHolderDetailUseCaseInput, GetPortfolioProductHolderDetailUseCaseOkOutput, GetPortfolioProductHolderDetailUseCaseErrorOutput> {
        return GetPortfolioProductHolderDetailUseCase(managersProvider: bsanManagersProvider).setRequestValues(requestValues: input)
    }
    
    func getImpositionsTransactionsUseCase(input: GetImpositionsTransactionUseCaseInput) -> UseCase<GetImpositionsTransactionUseCaseInput, GetImpositionsTransactionUseCaseOkOutput, GetImpositionsTransactionUseCaseErrorOutput> {
        return GetImpositionsTransactionUseCase(managersProvider: bsanManagersProvider).setRequestValues(requestValues: input)
    }
    
    func getDetailLiquidationUseCase(input: GetDetailLiquidationUseCaseInput) -> UseCase<GetDetailLiquidationUseCaseInput, GetDetailLiquidationUseCaseOkOutput, GetDetailLiquidationUseCaseErrorOutput> {
        return GetDetailLiquidationUseCase(managersProvider: bsanManagersProvider).setRequestValues(requestValues: input)
    }
    
    func getLiquidationImpositionUseCase(input: LoadImpositionLiquidationsUseCaseInput) -> UseCase<LoadImpositionLiquidationsUseCaseInput, LoadImpositionLiquidationsUseCaseOKOutput, LoadImpositionLiquidationsUseCaseErrorOutput> {
        return LoadImpositionLiquidationsUseCase(managersProvider: bsanManagersProvider).setRequestValues(requestValues: input)
    }
    
    func validateFundSubscriptionAmountUseCase(input: ValidateFundSubscriptionAmountUseCaseInput) -> UseCase<ValidateFundSubscriptionAmountUseCaseInput, ValidateFundSubscriptionAmountUseCaseOkOutput, ValidateFundSubscriptionAmountUseCaseErrorOutput> {
        return ValidateFundSubscriptionAmountUseCase(managersProvider: bsanManagersProvider).setRequestValues(requestValues: input)
    }
    
    func validateFundSubscriptionSharesUseCase(input: ValidateFundSubscriptionSharesUseCaseInput) -> UseCase<ValidateFundSubscriptionSharesUseCaseInput, ValidateFundSubscriptionSharesUseCaseOkOutput, ValidateFundSubscriptionSharesUseCaseErrorOutput> {
        return ValidateFundSubscriptionSharesUseCase(managersProvider: bsanManagersProvider).setRequestValues(requestValues: input)
    }
    
    func confirmFundSubscriptionAmountUseCase(input: ConfirmFundSubscriptionAmountUseCaseInput) -> UseCase<ConfirmFundSubscriptionAmountUseCaseInput, ConfirmFundSubscriptionAmountUseCaseOkOutput, GenericErrorSignatureErrorOutput> {
        return ConfirmFundSubscriptionAmountUseCase(managersProvider: bsanManagersProvider).setRequestValues(requestValues: input)
    }
    
    func confirmFundSubscriptionSharesUseCase(input: ConfirmFundSubscriptionSharesUseCaseInput) -> UseCase<ConfirmFundSubscriptionSharesUseCaseInput, ConfirmFundSubscriptionSharesUseCaseOkOutput, GenericErrorSignatureErrorOutput> {
        return ConfirmFundSubscriptionSharesUseCase(managersProvider: bsanManagersProvider).setRequestValues(requestValues: input)
    }
    
    func validateTotalFundTransferUseCase(input: ValidateTotalFundTransferUseCaseInput) -> UseCase<ValidateTotalFundTransferUseCaseInput, ValidateTotalFundTransferUseCaseOkOutput, ValidateTotalFundTransferUseCaseErrorOutput> {
        return ValidateTotalFundTransferUseCase(managersProvider: bsanManagersProvider).setRequestValues(requestValues: input)
    }
    
    func confirmTotalFundTransferUseCase(input: ConfirmTotalFundTransferUseCaseInput) -> UseCase<ConfirmTotalFundTransferUseCaseInput, ConfirmTotalFundTransferUseCaseOkOutput, GenericErrorSignatureErrorOutput> {
        return ConfirmTotalFundTransferUseCase(managersProvider: bsanManagersProvider).setRequestValues(requestValues: input)
    }
    
    func validatePartialAmountFundTransferUseCase(input: ValidatePartialAmountFundTransferUseCaseInput) -> UseCase<ValidatePartialAmountFundTransferUseCaseInput, ValidatePartialAmountFundTransferUseCaseOkOutput, ValidatePartialAmountFundTransferUseCaseErrorOutput> {
        return ValidatePartialAmountFundTransferUseCase(managersProvider: bsanManagersProvider).setRequestValues(requestValues: input)
    }
    
    func confirmPartialAmountFundTransferUseCase(input: ConfirmPartialAmountFundTransferUseCaseInput) -> UseCase<ConfirmPartialAmountFundTransferUseCaseInput, ConfirmPartialAmountFundTransferUseCaseOkOutput, GenericErrorSignatureErrorOutput> {
        return ConfirmPartialAmountFundTransferUseCase(managersProvider: bsanManagersProvider).setRequestValues(requestValues: input)
    }

    func validatePartialSharesFundTransferUseCase(input: ValidatePartialSharesFundTransferUseCaseInput) -> UseCase<ValidatePartialSharesFundTransferUseCaseInput, ValidatePartialSharesFundTransferUseCaseOkOutput, ValidatePartialSharesFundTransferUseCaseErrorOutput> {
        return ValidatePartialSharesFundTransferUseCase(managersProvider: bsanManagersProvider).setRequestValues(requestValues: input)
    }
    
    func confirmPartialSharesFundTransferUseCase(input: ConfirmPartialSharesFundTransferUseCaseInput) -> UseCase<ConfirmPartialSharesFundTransferUseCaseInput, ConfirmPartialSharesFundTransferUseCaseOkOutput, GenericErrorSignatureErrorOutput> {
        return ConfirmPartialSharesFundTransferUseCase(managersProvider: bsanManagersProvider).setRequestValues(requestValues: input)
    }
    
    func validatePeriodicalContributionUseCase() -> ValidatePeriodicalContributionUseCase {
        return ValidatePeriodicalContributionUseCase(managersProvider: bsanManagersProvider)
    }
    
    func confirmPeriodicalContributionUseCase(input: ConfirmPeriodicalContributionUseCaseInput) -> UseCase<ConfirmPeriodicalContributionUseCaseInput, Void, GenericErrorSignatureErrorOutput> {
        return ConfirmPeriodicalContributionUseCase(managersProvider: bsanManagersProvider).setRequestValues(requestValues: input)
    }
    
    // MARK: Stocks and Orders
    
    func setupStocksTradeUseCase(input: SetupStocksTradeUseCaseInput) -> UseCase<SetupStocksTradeUseCaseInput, SetupStocksTradeUseCaseOkOutput, SetupStocksTradeUseCaseErrorOutput> {
        return SetupStocksTradeUseCase(appConfig: appConfigRepository, bsanManagerProvider: bsanManagersProvider).setRequestValues(requestValues: input)
    }
    
    func preValidateStocksTradeUseCase(input: ValidateStocksTradeUseCaseInput) -> UseCase<ValidateStocksTradeUseCaseInput, PreValidateStocksTradeUseCaseOkOutput, PreValidateStocksTradeUseCaseErrorOutput> {
        return PreValidateStocksTradeUseCase(bsanManagerProvider: bsanManagersProvider).setRequestValues(requestValues: input)
    }
    
    func validateStocksTradeUseCase(input: ValidateStocksTradeUseCaseInput) -> UseCase<ValidateStocksTradeUseCaseInput, ValidateStocksTradeUseCaseOkOutput, ValidateStocksTradeUseCaseErrorOutput> {
        return ValidateStocksTradeUseCase(bsanManagerProvider: bsanManagersProvider).setRequestValues(requestValues: input)
    }
    
    func confirmStocksTradeUseCase(input: ConfirmStocksTradeUseCaseInput) -> UseCase<ConfirmStocksTradeUseCaseInput, Void, GenericErrorSignatureErrorOutput> {
        return ConfirmStocksTradeUseCase(managersProvider: bsanManagersProvider).setRequestValues(requestValues: input)
    }
    
    func confirmCancelOrderUseCase(input: ConfirmCancelOrderUseCaseInput) -> UseCase<ConfirmCancelOrderUseCaseInput, Void, GenericErrorSignatureErrorOutput> {
        return ConfirmCancelOrderUseCase(managersProvider: bsanManagersProvider).setRequestValues(requestValues: input)
    }
    
    func setupCancelOrderUseCase(input: SetupCancelOrderUseCaseInput) -> UseCase<SetupCancelOrderUseCaseInput, SetupCancelOrderUseCaseOKOutput, SetupCancelOrderUseCaseErrorOutput> {
        return SetupCancelOrderUseCase(repository: appConfigRepository, managersProvider: bsanManagersProvider).setRequestValues(requestValues: input)
    }
    
    func setupActivateCardUseCase(input: SetupActivateCardUseCaseInput) -> UseCase<SetupActivateCardUseCaseInput, SetupActivateCardUseCaseOkOutput, SetupActivateCardUseCaseErrorOutput> {
        let useCase = SetupActivateCardUseCase(managersProvider: bsanManagersProvider, appConfigRepository: appConfigRepository).setRequestValues(requestValues: input)
        return useCase
    }
    
    func confirmActivateCardUseCase(input: ConfirmActivateCardUseCaseInput) -> UseCase<ConfirmActivateCardUseCaseInput, ConfirmActivateCardUseCaseOkOutput, GenericErrorSignatureErrorOutput> {
        return ConfirmActivateCardUseCase(managersProvider: bsanManagersProvider).setRequestValues(requestValues: input)
    }
    
    func setupWithdrawMoneyHistoricalUseCase() -> UseCase<Void, SetupWithdrawMoneyHistoricalUseCaseOkOutput, SetupWithdrawMoneyHistoricalUseCaseErrorOutput> {
        return SetupWithdrawMoneyHistoricalUseCase(managersProvider: bsanManagersProvider, appConfigRepository: appConfigRepository)
    }
    
    func confirmWithdrawMoneyHistoricalUseCase(input: ConfirmWithdrawMoneyHistoricalUseCaseInput) -> UseCase<ConfirmWithdrawMoneyHistoricalUseCaseInput, ConfirmWithdrawMoneyHistoricalUseCaseOkOutput, ConfirmWithdrawMoneyHistoricalUseCaseErrorOutput> {
        return ConfirmWithdrawMoneyHistoricalUseCase(managersProvider: bsanManagersProvider).setRequestValues(requestValues: input)
    }
    
    func getDispensationsUseCase(input: GetDispensationsUseCaseInput) -> UseCase<GetDispensationsUseCaseInput, GetDispensationsUseCaseOkOutput, StringErrorOutput> {
        return GetDispensationsUseCase().setRequestValues(requestValues: input)
    }
    
    func getConfirmHistoricalDetailWithdrawMoneyUseCase(input: GetConfirmHistoricalDetailWithdrawMoneyUseCaseInput) -> UseCase<GetConfirmHistoricalDetailWithdrawMoneyUseCaseInput, GetConfirmHistoricalDetailWithdrawMoneyUseCaseOkOutput, StringErrorOutput> {
        return GetConfirmHistoricalDetailWithdrawMoneyUseCase(managersProvider: bsanManagersProvider).setRequestValues(requestValues: input)
    }
    
    func preSetupWithdrawMoneyWithCodeUseCase(input: PreSetupWithdrawMoneyWithCodeUseCaseInput) -> UseCase<PreSetupWithdrawMoneyWithCodeUseCaseInput, PreSetupWithdrawMoneyWithCodeUseCaseOkOutput, StringErrorOutput> {
        return PreSetupWithdrawMoneyWithCodeUseCase(managersProvider: bsanManagersProvider, appConfigRepository: appConfigRepository, appRepository: appRepository, accountDescriptorRepository: accountDescriptorRepository).setRequestValues(requestValues: input)
    }
    
    func setupWithdrawMoneyWithCodeUseCase(input: SetupWithdrawMoneyWithCodeUseCaseInput) -> UseCase<SetupWithdrawMoneyWithCodeUseCaseInput, SetupWithdrawMoneyWithCodeUseCaseOkOutput, StringErrorOutput> {
        return SetupWithdrawMoneyWithCodeUseCase(managersProvider: bsanManagersProvider, appConfigRepository: appConfigRepository).setRequestValues(requestValues: input)
    }
    
    func validateWithdrawMoneyWithCodeUseCase(input: ValidateWithdrawMoneyWithCodeUseCaseInput) -> UseCase<ValidateWithdrawMoneyWithCodeUseCaseInput, ValidateWithdrawMoneyWithCodeUseCaseOkOutput, StringErrorOutput> {
        return ValidateWithdrawMoneyWithCodeUseCase(managersProvider: bsanManagersProvider).setRequestValues(requestValues: input)
    }
    
    func confirmWithdrawMoneyWithCodeUseCase(input: ConfirmWithdrawMoneyWithCodeUseCaseInput) -> UseCase<ConfirmWithdrawMoneyWithCodeUseCaseInput, ConfirmWithdrawMoneyWithCodeUseCaseOkOutput, GenericErrorSignatureErrorOutput> {
        return ConfirmWithdrawMoneyWithCodeUseCase(managersProvider: bsanManagersProvider).setRequestValues(requestValues: input)
    }
    
    func confirmOtpWithdrawMoneyWithCodeUseCase(input: ConfirmOtpWithdrawMoneyWithCodeUseCaseInput) -> UseCase<ConfirmOtpWithdrawMoneyWithCodeUseCaseInput, ConfirmOtpWithdrawMoneyWithCodeUseCaseOkOutput, GenericErrorOTPErrorOutput> {
        return ConfirmOtpWithdrawMoneyWithCodeUseCase(managersProvider: bsanManagersProvider, appConfigRepository: appConfigRepository, trusteerRepository: trusteerRepository).setRequestValues(requestValues: input)
    }
    
    // MARK: Change Alias
    func changeCardAliasNameUseCase(input: ChangeCardAliasNameInputUseCase) -> UseCase<ChangeCardAliasNameInputUseCase, Void, StringErrorOutput> {
        return ChangeCardAliasNameUseCase(dependenciesResolver: dependenciesResolver).setRequestValues(requestValues: input)
    }
    
    func preSetupPayOffCardUseCase(input: PreSetupPayOffCardUseCaseInput) -> UseCase<PreSetupPayOffCardUseCaseInput, PreSetupPayOffCardUseCaseOkOutput, StringErrorOutput> {
        return PreSetupPayOffCardUseCase(resolver: dependenciesResolver).setRequestValues(requestValues: input)
    }
    
    func setupPayOffCardUseCase(input: SetupPayOffCardUseCaseInput) -> UseCase<SetupPayOffCardUseCaseInput, SetupPayOffCardUseCaseOkOutput, StringErrorOutput> {
        return SetupPayOffCardUseCase(managersProvider: bsanManagersProvider, appConfigRepository: appConfigRepository).setRequestValues(requestValues: input)
    }

    func validatePayOffUsecase() -> UseCase<Void, ValidatePayOffUseCaseOkOutput, StringErrorOutput> {
        return ValidatePayOffUsecase(bsanManagersProvider)
    }
    
    func confirmPayOffUseCase(input: ConfirmPayOffUseCaseInput) -> UseCase<ConfirmPayOffUseCaseInput, Void, GenericErrorSignatureErrorOutput> {
        return ConfirmPayOffUseCase(managersProvider: bsanManagersProvider).setRequestValues(requestValues: input)
    }
    
    // MARK: Mifid - STEP 1
    
    func stocksMifid2IndicatorsUseCase(input: StocksMifid2IndicatorsUseCaseInput) -> UseCase<StocksMifid2IndicatorsUseCaseInput, Mifid2IndicatorsUseCaseOkOutput, Mifid2IndicatorsUseCaseErrorOutput> {
        return StocksMifid2IndicatorsUseCase(appConfigRepository: appConfigRepository, managersProvider: bsanManagersProvider).setRequestValues(requestValues: input)
    }
    
    // MARK: Mifid - STEP 2
    
    func pensionsMifidAdvicesUseCase(input: PensionsMifidAdvicesUseCaseInput) -> UseCase<PensionsMifidAdvicesUseCaseInput, (state: MifidAdviceState, data: PensionMifidDTO), MifidAdvicesUseCaseErrorOutput> {
        return PensionsMifidAdvicesUseCase(appConfigRepository: appConfigRepository, managersProvider: bsanManagersProvider).setRequestValues(requestValues: input)
    }
    
    func fundSubscriptionAmountAdvicesUseCase(input: FundSubscriptionAmountAdvicesUseCaseInput) -> UseCase<FundSubscriptionAmountAdvicesUseCaseInput, (state: MifidAdviceState, data: FundSubscriptionDTO), MifidAdvicesUseCaseErrorOutput> {
        return FundSubscriptionAmountAdvicesUseCase(appConfigRepository: appConfigRepository, managersProvider: bsanManagersProvider).setRequestValues(requestValues: input)
    }
    
    func fundSubscriptionSharesAdvicesUseCase(input: FundSubscriptionSharesAdvicesUseCaseInput) -> UseCase<FundSubscriptionSharesAdvicesUseCaseInput, (state: MifidAdviceState, data: FundSubscriptionDTO), MifidAdvicesUseCaseErrorOutput> {
        return FundSubscriptionSharesAdvicesUseCase(appConfigRepository: appConfigRepository, managersProvider: bsanManagersProvider).setRequestValues(requestValues: input)
    }
    
    func fundTransferTotalAdvicesUseCase(input: FundTransferTotalAdvicesUseCaseInput) -> UseCase<FundTransferTotalAdvicesUseCaseInput, (state: MifidAdviceState, data: FundTransferDTO), MifidAdvicesUseCaseErrorOutput> {
        return FundTransferTotalAdvicesUseCase(appConfigRepository: appConfigRepository, managersProvider: bsanManagersProvider).setRequestValues(requestValues: input)
    }
    
    func fundTransferPartialByAmountAdvicesUseCase(input: FundTransferPartialByAmountAdvicesUseCaseInput) -> UseCase<FundTransferPartialByAmountAdvicesUseCaseInput, (state: MifidAdviceState, data: FundTransferDTO), MifidAdvicesUseCaseErrorOutput> {
        return FundTransferPartialByAmountAdvicesUseCase(appConfigRepository: appConfigRepository, managersProvider: bsanManagersProvider).setRequestValues(requestValues: input)
    }
    
    func fundTransferPartialBySharesAdvicesUseCase(input: FundTransferPartialBySharesAdvicesUseCaseInput) -> UseCase<FundTransferPartialBySharesAdvicesUseCaseInput, (state: MifidAdviceState, data: FundTransferDTO), MifidAdvicesUseCaseErrorOutput> {
        return FundTransferPartialBySharesAdvicesUseCase(appConfigRepository: appConfigRepository, managersProvider: bsanManagersProvider).setRequestValues(requestValues: input)
    }
    
    func stocksMifidAdvicesUseCase(input: StocksMifidAdvicesUseCaseInput) -> UseCase<StocksMifidAdvicesUseCaseInput, (state: MifidAdviceState, data: MifidDTO), MifidAdvicesUseCaseErrorOutput> {
        return StocksMifidAdvicesUseCase(appConfigRepository: appConfigRepository, managersProvider: bsanManagersProvider).setRequestValues(requestValues: input)
    }
    
    // MARK: Mifid - STEP 3
    
    func pensionsMifid2IndicatorsUseCase(input: PensionsMifid2IndicatorsUseCaseInput) -> UseCase<PensionsMifid2IndicatorsUseCaseInput, Mifid2IndicatorsUseCaseOkOutput, Mifid2IndicatorsUseCaseErrorOutput> {
        return PensionsMifid2IndicatorsUseCase(appConfigRepository: appConfigRepository, managersProvider: bsanManagersProvider).setRequestValues(requestValues: input)
    }
    
    func fundsMifid2IndicatorsUseCase(input: FundsMifid2IndicatorsUseCaseInput) -> UseCase<FundsMifid2IndicatorsUseCaseInput, Mifid2IndicatorsUseCaseOkOutput, Mifid2IndicatorsUseCaseErrorOutput> {
        return FundsMifid2IndicatorsUseCase(appConfigRepository: appConfigRepository, managersProvider: bsanManagersProvider).setRequestValues(requestValues: input)
    }
    
    func pensionsMifid1UseCase(input: PensionsMifid1UseCaseInput) -> UseCase<PensionsMifid1UseCaseInput, Mifid1UseCaseOkOutput, Mifid1UseCaseErrorOutput> {
        return PensionsMifid1UseCase(appConfigRepository: appConfigRepository, managersProvider: bsanManagersProvider).setRequestValues(requestValues: input)
    }
    
    func fundSubscriptionAmountMifid1UseCase(input: FundSubscriptionAmountMifid1UseCaseInput) -> UseCase<FundSubscriptionAmountMifid1UseCaseInput, Mifid1UseCaseOkOutput, Mifid1UseCaseErrorOutput> {
        return FundSubscriptionAmountMifid1UseCase(appConfigRepository: appConfigRepository, managersProvider: bsanManagersProvider).setRequestValues(requestValues: input)
    }
    
    func fundSubscriptionSharesMifid1UseCase(input: FundSubscriptionSharesMifid1UseCaseInput) -> UseCase<FundSubscriptionSharesMifid1UseCaseInput, Mifid1UseCaseOkOutput, Mifid1UseCaseErrorOutput> {
        return FundSubscriptionSharesMifid1UseCase(appConfigRepository: appConfigRepository, managersProvider: bsanManagersProvider).setRequestValues(requestValues: input)
    }
    
    func fundTransferTotalMifid1UseCase(input: FundTransferTotalMifid1UseCaseInput) -> UseCase<FundTransferTotalMifid1UseCaseInput, Mifid1UseCaseOkOutput, Mifid1UseCaseErrorOutput> {
        return FundTransferTotalMifid1UseCase(appConfigRepository: appConfigRepository, managersProvider: bsanManagersProvider).setRequestValues(requestValues: input)
    }
    
    func fundTransferPartialByAmountMifid1UseCase(input: FundTransferPartialByAmountMifid1UseCaseInput) -> UseCase<FundTransferPartialByAmountMifid1UseCaseInput, Mifid1UseCaseOkOutput, Mifid1UseCaseErrorOutput> {
        return FundTransferPartialByAmountMifid1UseCase(appConfigRepository: appConfigRepository, managersProvider: bsanManagersProvider).setRequestValues(requestValues: input)
    }
    
    func fundTransferPartialBySharesMifid1UseCase(input: FundTransferPartialBySharesMifid1UseCaseInput) -> UseCase<FundTransferPartialBySharesMifid1UseCaseInput, Mifid1UseCaseOkOutput, Mifid1UseCaseErrorOutput> {
        return FundTransferPartialBySharesMifid1UseCase(appConfigRepository: appConfigRepository, managersProvider: bsanManagersProvider).setRequestValues(requestValues: input)
    }
    
    func stocksMifid1UseCase(input: StocksMifid1UseCaseInput) -> UseCase<StocksMifid1UseCaseInput, Mifid1UseCaseOkOutput, Mifid1UseCaseErrorOutput> {
        return StocksMifid1UseCase(appConfigRepository: appConfigRepository, managersProvider: bsanManagersProvider).setRequestValues(requestValues: input)
    }
    
    // MARK: Managers  //

    func getHasAnyManagerUseCase() -> UseCase<Void, HasAnyManagerUseCaseOkOutput, HasAnyManagerUseCaseErrorOutput> {
        return HasAnyManagerUseCase(bsanManagersProvider: bsanManagersProvider)
    }
    
    func getDigitalProfilePercentageUseCase(input: GetDigitalProfilePercentageUseCaseInput) -> UseCase<GetDigitalProfilePercentageUseCaseInput, GetDigitalProfilePercentageUseCaseOkOutput, StringErrorOutput> {        
        return GetDigitalProfilePercentageUseCase(dependenciesResolver: dependenciesEngine).setRequestValues(requestValues: input)

    }

    func getGetPersonalManagersUseCase() -> UseCase<Void, GetPersonalManagersUseCaseOkOutput, GetPersonalManagersUseCaseErrorOutput> {
        return GetPersonalManagersUseCase(bsanManagersProvider: bsanManagersProvider, appConfigRepository: appConfigRepository)
    }

    func getGetOfficeManagersUseCase() -> UseCase<Void, GetOfficeManagersUseCaseOkOutput, GetOfficeManagersUseCaseErrorOutput> {
        return GetOfficeManagersUseCase(bsanManagersProvider: bsanManagersProvider, appConfigRepository: appConfigRepository)
    }
    
    func getLoadPersonalWithManagerUseCase() -> UseCase<Void, LoadPersonalWithManagerUseCaseOkOutput, StringErrorOutput> {
        return LoadPersonalWithManagerUseCase(bsanManagersProvider: bsanManagersProvider, appConfig: appConfigRepository)
    }
    
    func getManagerNotificationsUseCase() -> UseCase<Void, GetManagerNotificationUseCaseOkOutput, StringErrorOutput> {
        return GetManagerNotificationUseCase(dependenciesResolver: dependenciesResolver)
    }
    
    func getInsuranceDetailEnabledUseCase() -> UseCase<Void, GetInsuranceDetailEnabledUseCaseOkOutput, GetInsuranceDetailEnabledUseCaseErrorOutput> {
        return GetInsuranceDetailEnabledUseCase(appConfigRepository: appConfigRepository)
    }
    
    func preSetupFundSubscriptionUseCase(input: PreSetupFundSubscriptionUseCaseInput) -> UseCase<PreSetupFundSubscriptionUseCaseInput, PreSetupFundSubscriptionUseCaseOkOutput, StringErrorOutput> {
        return PreSetupFundSubscriptionUseCase(managersProvider: bsanManagersProvider, appConfigRepository: appConfigRepository, appRepository: appRepository, accountDescriptorRepository: accountDescriptorRepository).setRequestValues(requestValues: input)
    }
    
    func setupFundSubscriptionUseCase(input: SetupFundSubscriptionUseCaseInput) -> UseCase<SetupFundSubscriptionUseCaseInput, SetupFundSubscriptionUseCaseOkOutput, SetupFundSubscriptionUseCaseErrorOutput> {
        return SetupFundSubscriptionUseCase(managersProvider: bsanManagersProvider, appConfigRepository: appConfigRepository).setRequestValues(requestValues: input)
    }
    
    func setupFundTransferUseCase(input: SetupFundTransferUseCaseInput) -> UseCase<SetupFundTransferUseCaseInput, SetupFundTransferUseCaseOkOutput, SetupFundTransferUseCaseErrorOutput> {
        return SetupFundTransferUseCase(managersProvider: bsanManagersProvider, appConfigRepository: appConfigRepository).setRequestValues(requestValues: input)
    }
    
    // MARK: - Delete
    
    func deletePortfoliosProductsUseCase() -> UseCase<Void, Void, DeletePortfoliosProductsUseCaseErrorOutput> {
        return DeletePortfoliosProductsUseCase(managersProvider: bsanManagersProvider)
    }
    
    func deleteStockOrdersUseCase() -> UseCase<Void, Void, DeleteStockOrdersUseCaseErrorOutput> {
        return DeleteStockOrdersUseCase(managersProvider: bsanManagersProvider)
    }
    
    // MARK: - Account PDF
    func getAccountPdfTransactionUseCase(input: GetAccountPdfTransactionUseCaseInput) -> UseCase<GetAccountPdfTransactionUseCaseInput, GetAccountPDFTransactionUseCaseOkOutput, StringErrorOutput> {
        return GetAccountPdfTransactionUseCase(managersProvider: bsanManagersProvider).setRequestValues(requestValues: input)
    }
    
    func isMoneyPlanEnabled() -> UseCase<Void, IsMoneyPlanEnabledOkOutput, StringErrorOutput> {
        return IsMoneyPlanEnabled(appConfigRepository: appConfigRepository)
    }
    
    func getPdfExtractMonthNumberUseCase(input: GetPdfExtractMonthNumberUseCaseInput) -> UseCase<GetPdfExtractMonthNumberUseCaseInput, GetPdfExtractMonthNumberUseCaseOkOutput, StringErrorOutput> {
        return GetPdfExtractMonthNumberUseCase(managersProvider: bsanManagersProvider).setRequestValues(requestValues: input)
    }
    
    func getCardPdf(input: GetCardPdfTransactionUseCaseInput) -> UseCase<GetCardPdfTransactionUseCaseInput, GetCardPdfTransactionUseCaseOkOutput, GetCardPdfTransactionUseCaseErrorOutput> {
        return GetCardPdfTransactionUseCase(dependenciesResolver: self.dependenciesResolver).setRequestValues(requestValues: input)
    }

    func getFileFromNetwork(input: GetFileDataUseCaseInput) -> UseCase<GetFileDataUseCaseInput, GetFileDataUseCaseOkOutput, GetFileDataUseCaseErrorOutput> {
        return GetFileDataUseCase().setRequestValues(requestValues: input)
    }
    
    func getSingleSignOnUseCase() -> UseCase<Void, Void, StringErrorOutput> {
        let managers = dependenciesResolver.resolve(for: BSANManagersProvider.self)
        return SingleSignOnUseCase(managersProvider: bsanManagersProvider, dependenciesResolver: self.self.dependenciesEngine)
    }
    
    func getAppStoreInformationUseCase() -> AppStoreInformationUseCase? {
        return dependenciesResolver.resolve(forOptionalType: AppStoreInformationUseCase.self)
    }
    
    func getSetupLocalTransfersUseCase() -> UseCase<Void, SetupLocalTransfersUseCaseOkOutput, StringErrorOutput> {
        return SetupLocalTransfersUseCase(appConfig: appConfigRepository)
    }
    
    func getValidateLocalTransferUseCase(input: ValidateLocalTransferUseCaseInput) -> UseCase<ValidateLocalTransferUseCaseInput, ValidateLocalTransferUseCaseOkOutput, StringErrorOutput> {
        return ValidateLocalTransferUseCase(managersProvider: bsanManagersProvider, appConfigRepository: appConfigRepository, trusteerRepository: trusteerRepository, dependenciesResolver: self.dependenciesResolver).setRequestValues(requestValues: input)
    }
    
    func getConfirmLocalTransferUseCase(input: ConfirmLocalTransferUseCaseInput) -> UseCase<ConfirmLocalTransferUseCaseInput, ConfirmLocalTransferUseCaseOkOutput, GenericErrorSignatureErrorOutput> {
        return ConfirmLocalTransferUseCase(managersProvider: bsanManagersProvider, appConfigRepository: appConfigRepository, trusteerRepository: trusteerRepository, dependenciesResolver: self.dependenciesResolver).setRequestValues(requestValues: input)
    }
    
    func getPreSetupBillsAndTaxesUseCase(input: PreSetupBillsAndTaxesUseCaseInput) -> UseCase<PreSetupBillsAndTaxesUseCaseInput, PreSetupBillsAndTaxesUseCaseOkOutput, StringErrorOutput> {
        return PreSetupBillsAndTaxesUseCase(managersProvider: bsanManagersProvider, appConfigRepository: appConfigRepository, appRepository: appRepository, accountDescriptorRepository: accountDescriptorRepository, dependenciesResolver: dependenciesResolver).setRequestValues(requestValues: input)
    }
    
    func getSetupBillsAndTaxesUseCase() -> UseCase<Void, SetupBillsAndTaxesUseCaseOkOutput, StringErrorOutput> {
        return SetupBillsAndTaxesUseCase(appConfig: appConfigRepository)
    }
    
    func getPreValidateScannerBillsAndTaxesUseCase(input: PreValidateScannerBillsAndTaxesUseCaseInput) -> UseCase<PreValidateScannerBillsAndTaxesUseCaseInput, PreValidateScannerBillsAndTaxesUseCaseOkOutput, PreValidateScannerBillsAndTaxesUseCaseErrorOutput> {
        return PreValidateScannerBillsAndTaxesUseCase(managersProvider: bsanManagersProvider).setRequestValues(requestValues: input)
    }
    
    func getPreValidateManualBillsAndTaxesUseCase(input: PreValidateManualBillsAndTaxesUseCaseInput) -> UseCase<PreValidateManualBillsAndTaxesUseCaseInput, PreValidateManualBillsAndTaxesUseCaseOkOutput, PreValidateManualBillsAndTaxesUseCaseErrorOutput> {
        return PreValidateManualBillsAndTaxesUseCase(managersProvider: bsanManagersProvider).setRequestValues(requestValues: input)
    }
    
    func getValidateBillsAndTaxesUseCase(input: ValidateBillsAndTaxesUseCaseInput) -> UseCase<ValidateBillsAndTaxesUseCaseInput, ValidateBillsAndTaxesUseCaseOkOutput, StringErrorOutput> {
        return ValidateBillsAndTaxesUseCase(managersProvider: bsanManagersProvider).setRequestValues(requestValues: input)
    }
    
    func confirmBillsAndTaxesUseCase(input: ConfirmBillsAndTaxesUseCaseInput) -> UseCase<ConfirmBillsAndTaxesUseCaseInput, ConfirmBillsAndTaxesUseCaseOkOutput, GenericErrorSignatureErrorOutput> {
        return ConfirmBillsAndTaxesUseCase(managersProvider: bsanManagersProvider).setRequestValues(requestValues: input)
    }
    // MARK: - Avatar
    
    func getPersistedUserAvatarUseCase() -> UseCase<Void, GetPersistedUserAvatarUseCaseOkOutput, StringErrorOutput> {
        return GetPersistedUserAvatarUseCase(bsanManagersProvider: bsanManagersProvider, appRepository: appRepository)
    }
    
    func setPersistedUserAvatarUseCase(input: SetPersistedUserAvatarUseCaseInput) -> UseCase<SetPersistedUserAvatarUseCaseInput, Void, StringErrorOutput> {
        return SetPersistedUserAvatarUseCase(bsanManagersProvider: bsanManagersProvider, appRepository: appRepository).setRequestValues(requestValues: input)
    }
        
    func getBillAndTaxesDetailUseCase(input: GetBillAndTaxesDetailUseCaseInput) -> UseCase<GetBillAndTaxesDetailUseCaseInput, GetBillAndTaxesDetailUseCaseOkOutput, GetBillAndTaxesDetailUseCaseErrorOutput> {
        let usecase = GetBillAndTaxesDetailUseCase(dependenciesResolver: dependenciesResolver)
        _ = usecase.setRequestValues(requestValues: input)
        return usecase
    }
    
    // MARK: - Language
    
    func getLanguagesSelectionUseCase() -> UseCase<Void, GetLanguagesSelectionUseCaseOkOutput, StringErrorOutput> {
        return GetLanguagesSelectionUseCase(dependencies: self.dependenciesResolver)
    }
    
    func setLanguageUseCase(input: SetLanguageUseCaseInput) -> UseCase<SetLanguageUseCaseInput, SetLanguageUseCaseOkOutput, StringErrorOutput> {
        return SetLanguageUseCase(appRepository: appRepository, bsanManagersProvider: bsanManagersProvider).setRequestValues(requestValues: input)
    }
    
    // MARK: - PullOffers
    
    func getLocalPullOffersUseCase() -> UseCase<Void, Void, StringErrorOutput> {
        return LoadLocalPullOffersVarsUseCase(managersProvider: bsanManagersProvider, appConfigRepository: appConfigRepository, appRepository: appRepository, accountDescriptorRepository: accountDescriptorRepository, servicesForYouRepository: servicesForYouRepository, pullOffersEngine: pullOffersEngine, dependenciesResolver: dependenciesEngine)
    }
    
    func getLoadPublicPullOffersVarsUseCase() -> UseCase<Void, Void, StringErrorOutput> {
        return LoadPublicPullOffersVarsUseCase(managersProvider: bsanManagersProvider, appConfigRepository: appConfigRepository, appRepository: appRepository, accountDescriptorRepository: accountDescriptorRepository, servicesForYouRepository: servicesForYouRepository, pullOffersEngine: pullOffersEngine)
    }
    
    func getCardTransactionPullOffersUseCase(input: LoadCardTransactionPullOffersVarsUseCaseInput) -> UseCase<LoadCardTransactionPullOffersVarsUseCaseInput, Void, StringErrorOutput> {
        return LoadCardTransactionPullOffersVarsUseCase(pullOffersEngine: pullOffersEngine).setRequestValues(requestValues: input)
    }
    
    func getAccountTransactionPullOffersUseCase(input: LoadAccountTransactionPullOffersVarsUseCaseInput) -> UseCase<LoadAccountTransactionPullOffersVarsUseCaseInput, Void, StringErrorOutput> {
        return LoadAccountTransactionPullOffersVarsUseCase(pullOffersEngine: pullOffersEngine).setRequestValues(requestValues: input)
    }
    
    func getPullOfferActionUseCase(input: GetPullOfferActionUseCaseInput) -> UseCase<GetPullOfferActionUseCaseInput, GetPullOfferActionUseCaseOkOutput, StringErrorOutput> {
        return GetPullOfferActionUseCase(pullOffersInterpreter: pullOffersInterpreter).setRequestValues(requestValues: input)
    }
    
    func getExpirePullOfferUseCase(input: ExpirePullOfferUseCaseInput) -> UseCase<ExpirePullOfferUseCaseInput, Void, StringErrorOutput> {
        return ExpirePullOfferUseCase(appRepository: appRepository, pullOffersInterpreter: pullOffersInterpreter, bsanManagersProvider: bsanManagersProvider).setRequestValues(requestValues: input)
    }
        
    // MARK: - PullOffers (Tips)
    
    func getTipsUseCase() -> UseCase<Void, GetTipsUseCaseOkOutput, StringErrorOutput> {
        return GetTipsUseCase(appRepository: appRepository, pullOffersInterpreter: pullOffersInterpreter)
    }
    
    func calculateLocationsUseCase(input: CalculateLocationsUseCaseInput) -> UseCase<CalculateLocationsUseCaseInput, Void, StringErrorOutput> {
        return CalculateLocationsUseCase(provider: bsanManagersProvider, pullOffersInterpreter: pullOffersInterpreter, pullOffersConfigRepository: pullOffersConfigRepository, appRepository: appRepository).setRequestValues(requestValues: input)
    }
    
    func getSetupPullOffersUseCase() -> UseCase<Void, Void, StringErrorOutput> {
        return SetupPullOffersUseCase(pullOffersRepository: pullOffersRepository)
    }
    
    func getCandidatesUseCase(input: PullOfferCandidatesUseCaseInput) -> UseCase<PullOfferCandidatesUseCaseInput, PullOfferCandidatesUseCaseOkOutput, PullOfferCandidatesUseCaseErrorOutput> {
        return PullOfferCandidatesUseCase(pullOffersInterpreter: pullOffersInterpreter, appRepository: appRepository, bsanManagersProvider: bsanManagersProvider).setRequestValues(requestValues: input)
    }
    
    func getTutorialCandidatesUseCase(input: PullOfferTutorialCandidatesUseCaseInput) -> UseCase<PullOfferTutorialCandidatesUseCaseInput, PullOfferTutorialCandidatesUseCaseOkOutput, PullOfferTutorialCandidatesUseCaseErrorOutput> {
        return PullOfferTutorialCandidatesUseCase(pullOffersInterpreter: pullOffersInterpreter, appRepository: appRepository, bsanManagersProvider: bsanManagersProvider).setRequestValues(requestValues: input)
    }
    
    func getRobinsonListUseCase() -> UseCase<Void, CheckRobinsonListUseCaseOkOutput, StringErrorOutput> {
        return CheckRobinsonListUseCase(resolver: dependenciesResolver)
    }
    
    func getConvertWebviewActionParametersUseCase(input: ConvertWebviewActionParametersUseCaseInput) -> UseCase<ConvertWebviewActionParametersUseCaseInput, ConvertWebviewActionParametersUseCaseOkOutput, StringErrorOutput> {
        return ConvertWebviewActionParametersUseCase(appRepository: appRepository, provider: bsanManagersProvider, dataProvider: bsanDataProvider, dependencies: self.dependenciesResolver).setRequestValues(requestValues: input)
    }

    // MARK: - Opinator

    func getOpinatorParametersValuesUseCase(requestValues: GetOpinatorParametersValuesUseCaseInput) -> UseCase<GetOpinatorParametersValuesUseCaseInput, GetOpinatorParametersValuesUseCaseOkOutput, StringErrorOutput> {
        return GetOpinatorParametersValuesUseCase(dependenciesResolver: self.dependenciesResolver).setRequestValues(requestValues: requestValues)
    }
    
    func getOpinatorUrlBaseUseCase() -> UseCase<Void, GetOpinatorBaseUrlUseCaseOutput, StringErrorOutput> {
        return GetOpinatorBaseUrlUseCase(dependenciesResolver: self.dependenciesResolver)
    }
    
    // MARK: - Coachmarks
    
    func isCoachmarkSeen(input: GetCoachmarkStatusUseCaseInput) -> UseCase<GetCoachmarkStatusUseCaseInput, GetCoachmarkStatusOkOutput, StringErrorOutput> {
        return GetCoachmarkStatusUseCase(appRepository: appRepository, bsanManagersProvider: bsanManagersProvider).setRequestValues(requestValues: input)
    }
    
    func setCoachmarkSeen(input: SetCoachmarkSeenInput) -> UseCase<SetCoachmarkSeenInput, Void, StringErrorOutput> {
        return SetCoachmarkSeenUseCase(appRepository: appRepository, bsanManagersProvider: bsanManagersProvider).setRequestValues(requestValues: input)
    }
    
    func getManagerCoachmarkData(input: DisplaySideMenuManagerUseCaseInput) -> UseCase<DisplaySideMenuManagerUseCaseInput, DisplaySideMenuManagerOkOutput, StringErrorOutput> {
        return DisplaySideMenuManagerUseCase(appRepository: appRepository, appConfig: appConfigRepository, bsanManagersProvider: bsanManagersProvider).setRequestValues(requestValues: input)
    }

    // MARK: - Download Pdf
    
    func getPdfUseCase(input: GetPdfUseCaseInput) -> UseCase<GetPdfUseCaseInput, GetPdfUseCaseOkOutput, StringErrorOutput> {
        return GetPdfUseCase(bsanProvider: bsanManagersProvider, downloadsRepository: downloadsRepository).setRequestValues(requestValues: input)
    }
    
    //! Get Temporary Pdf in order to assign it a name
    func getTempPdfUseCase(input: GetTempPdfUseCaseInput) -> UseCase<GetTempPdfUseCaseInput, GetTempPdfUseCaseOkOutput, StringErrorOutput> {
        return GetTempPdfUseCase(documentsRepository: documentsRepository).setRequestValues(requestValues: input)
    }
    
     // MARK: - One Pay
    
    func getPredefinedSCAOnePayTransferUseCase() ->  UseCase<Void, PredefinedSCAOnePayTransferUseCaseOkOutput, StringErrorOutput> {
        return PredefinedSCAOnePayTransferUseCase(dependenciesResolver: self.dependenciesResolver)
    }
    
    func getPreSetupOnePayTransferCardUseCase() -> UseCase<PreSetupOnePayTransferCardUseCaseInput, PreSetupOnePayTransferCardUseCaseOkOutput, StringErrorOutput> {
        return PreSetupOnePayTransferCardUseCase(managersProvider: bsanManagersProvider, appConfigRepository: appConfigRepository, appRepository: appRepository, accountDescriptorRepository: accountDescriptorRepository, sepaRepository: sepaInfoRepository, dependenciesResolver: dependenciesResolver)
    }

    func setupOnePayTranferCardUseCase() -> UseCase<Void, SetupOnePayTransferCardUseCaseOkOutput, StringErrorOutput> {
        return SetupOnePayTransferCardUseCase(managersProvider: bsanManagersProvider, appConfigRepository: appConfigRepository, appRepository: appRepository, accountDescriptorRepository: accountDescriptorRepository)
    }
    
    func getEmittedTransfersUseCase(input: GetEmittedTransfersUseCaseInput) -> UseCase<GetEmittedTransfersUseCaseInput, GetEmittedTransfersUseCaseOkOutput, GetEmittedTransfersUseCaseErrorOutput> & Cancelable {
        let usecase = GetEmittedTransfersUseCase(managersProvider: bsanManagersProvider)
        _ = usecase.setRequestValues(requestValues: input)
        return usecase
    }
    
    func getEmittedTransferDetailUseCase(input: GetEmittedTransferDetailUseCaseInput) -> UseCase<GetEmittedTransferDetailUseCaseInput, GetEmittedTransferDetailUseCaseOkOutput, GetEmittedTransferDetailUseCaseErrorOutput> {
        let usecase = GetEmittedTransferDetailUseCase(managersProvider: bsanManagersProvider, sepaRepository: sepaInfoRepository, appConfigRepository: appConfigRepository)
        _ = usecase.setRequestValues(requestValues: input)
        return usecase
    }
    
    func getEmittedNoSepaTransferDetailUseCase(input: GetEmittedNoSepaTransferDetailUseCaseInput) -> UseCase<GetEmittedNoSepaTransferDetailUseCaseInput, GetEmittedNoSepaTransferDetailUseCaseOkOutput, GetEmittedNoSepaTransferDetailUseCaseErrorOutput> {
        let usecase = GetEmittedNoSepaTransferDetailUseCase(managersProvider: bsanManagersProvider, sepaRepository: sepaInfoRepository, appConfigRepository: appConfigRepository)
        _ = usecase.setRequestValues(requestValues: input)
        return usecase
    }
    
    func getScheduledTransferDetailUseCase(input: GetScheduledTransferDetailUseCaseInput) -> UseCase<GetScheduledTransferDetailUseCaseInput, GetScheduledTransferDetailUseCaseOkOutput, GetScheduledTransferDetailUseCaseErrorOutput> {
        let usecase = GetScheduledTransferDetailUseCase(managersProvider: bsanManagersProvider, sepaRepository: sepaInfoRepository, appConfigRepository: appConfigRepository)
        _ = usecase.setRequestValues(requestValues: input)
        return usecase
    }
    
    func getDestinationOnePayTransferUseCase(input: DestinationOnePayTransferUseCaseInput) -> UseCase<DestinationOnePayTransferUseCaseInput, DestinationOnePayTransferUseCaseOkOutput, DestinationOnePayTransferUseCaseErrorOutput> {
        return DestinationOnePayTransferUseCase(managersProvider: bsanManagersProvider, appConfigRepository: appConfigRepository).setRequestValues(requestValues: input)
    }
    
    func getDestinationAccountOnePayTransferUseCase(input: DestinationAccountOnePayTransferUseCaseInput) -> UseCase<DestinationAccountOnePayTransferUseCaseInput, DestinationAccountOnePayTransferUseCaseOkOutput, DestinationAccountOnePayTransferUseCaseErrorOutput> {
        return DestinationAccountOnePayTransferUseCase(managersProvider: bsanManagersProvider, appConfigRepository: appConfigRepository, trusteerRepository: trusteerRepository, dependenciesResolver: dependenciesResolver).setRequestValues(requestValues: input)
    }
    
    func getValidateOnePayTransferUseCase(input: ValidateOnePayTransferUseCaseInput) -> UseCase<ValidateOnePayTransferUseCaseInput, ValidateOnePayTransferUseCaseOkOutput, ValidateTransferUseCaseErrorOutput> {
        return ValidateOnePayTransferUseCase(managersProvider: bsanManagersProvider, appConfigRepository: appConfigRepository, trusteerRepository: trusteerRepository, dependenciesResolver: self.dependenciesResolver).setRequestValues(requestValues: input)
    }
    
    func getValidateOnePaySanKeyTransferUseCase(input: ValidateOnePayTransferUseCaseInput) -> UseCase<ValidateOnePayTransferUseCaseInput, ValidateOnePayTransferUseCaseOkOutput, ValidateTransferUseCaseErrorOutput> {
        return ValidateOnePaySanKeyTransferUseCase(managersProvider: bsanManagersProvider, appConfigRepository: appConfigRepository, trusteerRepository: trusteerRepository, dependenciesResolver: self.dependenciesResolver).setRequestValues(requestValues: input)
    }

    func getSubtypeOnePayTransferUseCase(input: SubtypeOnePayTransferUseCaseInput) -> UseCase<SubtypeOnePayTransferUseCaseInput, SubtypeOnePayTransferUseCaseOkOutput, SubtypeTransferUseCaseErrorOutput> {
        return SubtypeOnePayTransferUseCase(dependenciesResolver: dependenciesResolver).setRequestValues(requestValues: input)
    }
    
    func getSubtypeOnePaySanKeyTransferUseCase(input: SubtypeOnePayTransferUseCaseInput) -> UseCase<SubtypeOnePayTransferUseCaseInput, SubtypeOnePayTransferUseCaseOkOutput, SubtypeTransferUseCaseErrorOutput> {
        return SubtypeOnePaySanKeyTransferUseCase(dependenciesResolver: dependenciesResolver).setRequestValues(requestValues: input)
    }
    
    func getSubTypeTransferCommissions(input: TransferSubTypeCommissionsUseCaseInput) -> UseCase<TransferSubTypeCommissionsUseCaseInput, TransferSubTypeCommissionsUseCaseOkOutput, StringErrorOutput> {
        return TransferSubTypeCommissionsUseCase(dependenciesResolver: dependenciesEngine).setRequestValues(requestValues: input)
    }
    
    func getConfirmOnePayTransferUseCase(input: ConfirmOnePayTransferUseCaseInput) -> UseCase<ConfirmOnePayTransferUseCaseInput, ConfirmOnePayTransferUseCaseOkOutput, GenericErrorSignatureErrorOutput> {
        return ConfirmOnePayTransferUseCase(managersProvider: bsanManagersProvider, appConfigRepository: appConfigRepository, trusteerRepository: trusteerRepository, dependenciesResolver: dependenciesResolver).setRequestValues(requestValues: input)
    }
    
    func getConfirmOnePaySanKeyTransferUseCase(input: ConfirmOnePayTransferUseCaseInput) -> UseCase<ConfirmOnePayTransferUseCaseInput, ConfirmOnePayTransferUseCaseOkOutput, GenericErrorSignatureErrorOutput> {
        return ValidateSanKeyOTPUseCase(managersProvider: bsanManagersProvider, appConfigRepository: appConfigRepository, trusteerRepository: trusteerRepository, dependenciesResolver: dependenciesResolver).setRequestValues(requestValues: input)
    }
    
    func getConfirmOtpOnePayTransferUseCase(input: ConfirmOtpOnePayTransferUseCaseInput) -> UseCase<ConfirmOtpOnePayTransferUseCaseInput, ConfirmOtpOnePayTransferUseCaseOkOutput, GenericErrorOTPErrorOutput> {
        return ConfirmOtpOnePayTransferUseCase(managersProvider: bsanManagersProvider, appConfigRepository: appConfigRepository, trusteerRepository: trusteerRepository, dependenciesResolver: dependenciesResolver).setRequestValues(requestValues: input)
    }
    
    func getConfirmOtpOnePaySanKeyTransferUseCase(input: ConfirmOtpOnePayTransferUseCaseInput) -> UseCase<ConfirmOtpOnePayTransferUseCaseInput, ConfirmOtpOnePayTransferUseCaseOkOutput, GenericErrorOTPErrorOutput> {
        return ConfirmOtpOnePaySanKeyTransferUseCase(
            managersProvider: bsanManagersProvider,
            appConfigRepository: appConfigRepository,
            trusteerRepository: trusteerRepository,
            dependenciesResolver: dependenciesResolver
        ).setRequestValues(requestValues: input)
    }
    
    func getCheckStatusOnePayTransferUseCase(input: CheckStatusOnePayTransferUseCaseInput) -> UseCase<CheckStatusOnePayTransferUseCaseInput, CheckStatusOnePayTransferUseCaseOkOutput, StringErrorOutput> {
        return CheckStatusOnePayTransferUseCase(managersProvider: bsanManagersProvider).setRequestValues(requestValues: input)
    }
    
    func setupUsualTransferUseCase() -> UseCase<Void, SetupUsualTransferUseCaseOkOutput, StringErrorOutput> {
        return SetupUsualTransferUseCase(managersProvider: bsanManagersProvider, appConfigRepository: appConfigRepository, appRepository: appRepository, accountDescriptorRepository: accountDescriptorRepository)
    }
    
    func getModifyPeriodicTransferUseCase(input: ModifyPeriodicTransferUseCaseInput) -> UseCase<ModifyPeriodicTransferUseCaseInput, ModifyPeriodicTransferUseCaseOkOutput, StringErrorOutput> {
        return ModifyPeriodicTransferUseCase(bsanManagersProvider: bsanManagersProvider).setRequestValues(requestValues: input)
    }
    
    func getModifyDeferredTransferUseCase(input: ModifyDeferredTransferUseCaseInput) -> UseCase<ModifyDeferredTransferUseCaseInput, ModifyDeferredTransferUseCaseOkOutput, StringErrorOutput> {
        return ModifyDeferredTransferUseCase(managersProvider: bsanManagersProvider, appConfigRepository: appConfigRepository).setRequestValues(requestValues: input)
    }
    
    func getValidateDeferredTransferUseCase(input: ValidateDeferredTransferUseCaseInput) -> UseCase<ValidateDeferredTransferUseCaseInput, ValidateDeferredTransferUseCaseOkOutput, GenericErrorSignatureErrorOutput> {
        return ValidateDeferredTransferUseCase(managersProvider: bsanManagersProvider).setRequestValues(requestValues: input)
    }
    
    func getConfirmDeferredTransferUseCase(input: ConfirmDeferredTransferUseCaseInput) -> UseCase<ConfirmDeferredTransferUseCaseInput, Void, GenericErrorOTPErrorOutput> {
        return ConfirmDeferredTransferUseCase(appConfigRepository: appConfigRepository,
            managersProvider: bsanManagersProvider,
            trusteerRepository: trusteerRepository).setRequestValues(requestValues: input)
    }
    
    func getGetValidPullOfferUseCase(input: GetValidPullOfferUseCaseInput) -> UseCase<GetValidPullOfferUseCaseInput, GetValidPullOfferUseCaseOkOutput, StringErrorOutput> {
        return GetValidPullOfferUseCase(pullOffersInterpreter: pullOffersInterpreter).setRequestValues(requestValues: input)
    }
    
    func getPreSetupLocalTransfersUseCase() -> UseCase<Void, PreSetupLocalTransfersUseCaseOkOutput, StringErrorOutput> {
        return PreSetupLocalTransfersUseCase(bsanManagerProvider: bsanManagersProvider, appRepository: appRepository, accountDescriptorRepository: accountDescriptorRepository, appConfigRepository: appConfigRepository)
    }
    
    func getPreSetupDirectMoneyUseCase() -> UseCase<Void, PreSetupDirectMoneyUseCaseOkOutput, StringErrorOutput> {
        return PreSetupDirectMoneyUseCase(managersProvider: bsanManagersProvider, appConfigRepository: appConfigRepository, appRepository: appRepository, accountDescriptorRepository: accountDescriptorRepository)
    }

    //TODO: Creado momentaneamente unicamente para filtrar nosepa, se eliminara en un futuro. (NO SEPA)
    func getSepaListUseCase() -> UseCase<Void, GetSepaListUseCaseOkOutput, StringErrorOutput> {
        return GetSepaListUseCase(sepaRepository: sepaInfoRepository)
    }
    
    func getSubtypeUsualTransferUseCase(input: SubtypeUsualTransferUseCaseInput) -> UseCase<SubtypeUsualTransferUseCaseInput, SubtypeUsualTransferUseCaseOkOutput, SubtypeTransferUseCaseErrorOutput> {
        return SubtypeUsualTransferUseCase(dependenciesResolver: dependenciesResolver).setRequestValues(requestValues: input)
    }
    
    func getConfirmUsualTransferUseCase(input: ConfirmUsualTransferUseCaseInput) -> UseCase<ConfirmUsualTransferUseCaseInput, ConfirmUsualTransferUseCaseOkOutput, GenericErrorSignatureErrorOutput> {
        return ConfirmUsualTransferUseCase(managersProvider: bsanManagersProvider).setRequestValues(requestValues: input)
    }
    
    func getValidateUsualTransferUseCaseInput(input: ValidateUsualTransferUseCaseInput) -> UseCase<ValidateUsualTransferUseCaseInput, ValidateUsualTransferUseCaseOkOutput, ValidateTransferUseCaseErrorOutput> {
        return ValidateUsualTransferUseCase(managersProvider: bsanManagersProvider).setRequestValues(requestValues: input)
    }
    
    func getSelectorUsualTransferUseCase(input: SelectorUsualTransferUseCaseInput) -> UseCase<SelectorUsualTransferUseCaseInput, SelectorUsualTransferUseCaseOkOutput, SelectorUsualTransferUseCaseErrorOutput> {
        return SelectorUsualTransferUseCase(managersProvider: bsanManagersProvider).setRequestValues(requestValues: input)
    }
    
    func getPreSetupPINQueryUseCase() -> UseCase<Void, PreSetupPINQueryUseCaseOkOutput, StringErrorOutput> {
        return PreSetupPINQueryUseCase(appConfig: appConfigRepository, bsanManagerProvider: bsanManagersProvider, appRepository: appRepository, accountDescriptorRepository: accountDescriptorRepository, appConfigRepository: appConfigRepository)
    }
    
    func getPreSetupCVVQueryCardUseCase() -> UseCase<Void, PreSetupCVVQueryCardUseCaseOkOutput, StringErrorOutput> {
        return PreSetupCVVQueryCardUseCase(appConfig: appConfigRepository, bsanManagerProvider: bsanManagersProvider, appRepository: appRepository, accountDescriptorRepository: accountDescriptorRepository, appConfigRepository: appConfigRepository)
    }
    
    func getPreSetupSignUpCesCardUseCase() -> UseCase<Void, PreSetupSignUpCesCardUseCaseOkOutput, StringErrorOutput> {
        return PreSetupSignUpCesCardUseCase(appConfig: appConfigRepository, bsanManagerProvider: bsanManagersProvider, appRepository: appRepository, accountDescriptorRepository: accountDescriptorRepository, appConfigRepository: appConfigRepository, bsanManagersProvider: bsanManagersProvider)
    }
    
    func getPreSetupActivateCardUseCase() -> UseCase<Void, PreSetupActivateCardUseCaseOkOutput, StringErrorOutput> {
        return PreSetupActivateCardUseCase(appConfig: appConfigRepository, bsanManagerProvider: bsanManagersProvider, appRepository: appRepository, accountDescriptorRepository: accountDescriptorRepository, appConfigRepository: appConfigRepository)
    }
    
    func getPreSetupChargeDischargeCardUseCase() -> UseCase<Void, PreSetupChargeDischargeCardUseCaseOkOutput, StringErrorOutput> {
        return PreSetupChargeDischargeCardUseCase(bsanManagerProvider: bsanManagersProvider, appRepository: appRepository, accountDescriptorRepository: accountDescriptorRepository, appConfigRepository: appConfigRepository)
    }
    
    func getGetCreditCardsWithPdfUseCase() -> UseCase<Void, GetCreditCardsWithPdfUseCaseOkOutput, StringErrorOutput> {
        return GetCreditCardsWithPdfUseCase(appConfig: appConfigRepository, bsanManagerProvider: bsanManagersProvider, appRepository: appRepository, accountDescriptorRepository: accountDescriptorRepository, appConfigRepository: appConfigRepository)
    }
    
    // MARK: - Cancel transfer
    
    func getSetUpCancelTransferUseCase(input: SetUpCancelTransferUseCaseInput) -> UseCase<SetUpCancelTransferUseCaseInput, SetUpCancelTransferUseCaseOkOutput, StringErrorOutput> {
        return SetUpCancelTransferUseCase(appRepository: appRepository, managersProvider: bsanManagersProvider, appConfigRepository: appConfigRepository).setRequestValues(requestValues: input)
    }
    
    func getConfirmCancelTransferSignUseCase(input: ConfirmCancelTransferSignUseCaseInput) -> UseCase<ConfirmCancelTransferSignUseCaseInput, Void, GenericErrorSignatureErrorOutput> {
        return ConfirmCancelTransferSignUseCase(managersProvider: bsanManagersProvider).setRequestValues(requestValues: input)
    }
    
    // MARK: - Push Notifications
    
    func setupPushNotificationsInboxUseCase() -> UseCase<Void, SetupPushNotificationsInboxUseCaseOkOutput, StringErrorOutput> {
        return SetupPushNotificationsInboxUseCase(appConfigRepository: appConfigRepository, bsanManagersProvider: bsanManagersProvider)
    }
    
    func saveOtpNotificationUseCase(input: SaveOtpNotificationUseCaseInput) -> UseCase<SaveOtpNotificationUseCaseInput, Void, StringErrorOutput> {
        return SaveOtpNotificationUseCase(dependenciesResolver: dependenciesResolver).setRequestValues(requestValues: input)
    }
    
    func getOtpPushNotificationUseCase() -> UseCase<Void, GetOtpPushNotificationUseCaseOkOutput, StringErrorOutput> {
        return GetOtpPushNotificationUseCase(dependenciesResolver: dependenciesResolver)
    }
    
    func removeOtpPushNotificationUseCase() -> UseCase<Void, Void, StringErrorOutput> {
        return RemoveOtpPushNotificationUseCase(dependenciesResolver: dependenciesResolver)
    }
    
    // MARK: - Metrics
    
    func getMetricsTrackUseCase(input: MetricsTrackUseCaseInput) -> UseCase<MetricsTrackUseCaseInput, Void, StringErrorOutput> {
        let localAppConfig = self.dependenciesResolver.resolve(for: LocalAppConfig.self)
        return MetricsTrackUseCase(localAppConfig: localAppConfig, tealiumRepository: tealiumRepository, netInsightRepository: netInsightRepository, languageRepository: appRepository).setRequestValues(requestValues: input)
    }
    
    func getMetricsLogOutUserUseCase() -> UseCase<Void, Void, StringErrorOutput> {
        return MetricsLogOutUserUseCase(tealiumRepository: tealiumRepository, netInsightRepository: netInsightRepository)
    }
    
    func getMetricsUpdateEnviromentUseCase() -> UseCase<Void, Void, StringErrorOutput> {
        return MetricsUpdateEnviromentUseCase(netInsightRepository: netInsightRepository, bsanProvider: bsanManagersProvider)
    }
    
    func getEmmaTrackUseCase(input: EmmaTrackUseCaseInput) -> UseCase<EmmaTrackUseCaseInput, Void, StringErrorOutput> {
        return EmmaTrackUseCase().setRequestValues(requestValues: input)
    }

    // MARK: - Siri
    
    func donateSiriIntentsUseCase() -> UseCase<Void, Void, StringErrorOutput> {
        return DonateSiriIntentsUseCase(siriAssistant: siriAssistant)
    }
    
    func deleteSiriIntentsUseCase() -> UseCase<Void, Void, StringErrorOutput> {
        return DeleteSiriIntentsUseCase(siriAssistant: siriAssistant)
    }
    
    // MARK: - Modify deferred transfer
    
    func getSetupModifyDeferredTransferUseCase(input: SetupModifyDeferredTransferUseCaseInput) -> UseCase<SetupModifyDeferredTransferUseCaseInput, SetupModifyDeferredTransferUseCaseOkOutput, StringErrorOutput> {
        return SetupModifyDeferredTransferUseCase(appConfigRepository: appConfigRepository, sepaRepository: sepaInfoRepository).setRequestValues(requestValues: input)
    }
    
    func getModifyDeferredTransferDestinationUseCase(input: ModifyDeferredTransferDestinationUseCaseInput) -> UseCase<ModifyDeferredTransferDestinationUseCaseInput, ModifyDeferredTransferDestinationUseCaseOkOutput, StringErrorOutput> {
        return ModifyDeferredTransferDestinationUseCase(bsanManagersProvider: bsanManagersProvider, appConfigRepository: appConfigRepository, trusteerRepository: trusteerRepository, dependenciesResolver: self.dependenciesResolver).setRequestValues(requestValues: input)
    }
    
    func getSetupModifyPeriodicTransferUseCase(input: SetupModifyPeriodicTransferUseCaseInput) -> UseCase<SetupModifyPeriodicTransferUseCaseInput, SetupModifyPeriodicTransferUseCaseOkOutput, StringErrorOutput> {
        return SetupModifyPeriodicTransferUseCase(appConfigRepository: appConfigRepository, sepaRepository: sepaInfoRepository).setRequestValues(requestValues: input)
    }
    
    func getModifyPeriodicTransferDestinationUseCase(input: ModifyPeriodicTransferDestinationUseCaseInput) -> UseCase<ModifyPeriodicTransferDestinationUseCaseInput, ModifyPeriodicTransferDestinationUseCaseOkOutput, StringErrorOutput> {
        return ModifyPeriodicTransferDestinationUseCase(bsanManagersProvider: bsanManagersProvider, appConfigRepository: appConfigRepository, trusteerRepository: trusteerRepository, dependenciesResolver: dependenciesResolver).setRequestValues(requestValues: input)
    }
    
    func getValidatePeriodicTransferUseCase(input: ValidatePeriodicTransferUseCaseInput) -> UseCase<ValidatePeriodicTransferUseCaseInput, ValidatePeriodicTransferUseCaseOkOutput, GenericErrorSignatureErrorOutput> {
        return ValidatePeriodicTransferUseCase(bsanManagersProvider: bsanManagersProvider).setRequestValues(requestValues: input)
    }
    
    func getConfirmPeriodicTransferUseCase(input: ConfirmPeriodicTransferUseCaseInput) -> UseCase<ConfirmPeriodicTransferUseCaseInput, Void, GenericErrorOTPErrorOutput> {
        return ConfirmPeriodicTransferUseCase(bsanManagersProvider: bsanManagersProvider).setRequestValues(requestValues: input)
    }
    
    func getConfirmNoSepaTransferUseCase(input: ConfirmNoSepaTransferUseCaseInput) -> UseCase<ConfirmNoSepaTransferUseCaseInput, ConfirmNoSepaTransferUseCaseOkOutput, GenericErrorSignatureErrorOutput> {
        return ConfirmNoSepaTransferUseCase(bsanManagersProvider: bsanManagersProvider).setRequestValues(requestValues: input)
    }
    
    func getDestinationNoSepaTransferUseCase(input: DestinationNoSepaTransferUseCaseInput) -> UseCase<DestinationNoSepaTransferUseCaseInput, DestinationNoSepaTransferUseCaseOkOutput, DestinationNoSepaTransferUseCaseErrorOutput> {
        return DestinationNoSepaTransferUseCase(dependenciesResolver: dependenciesResolver, bsanManager: bsanManagersProvider).setRequestValues(requestValues: input)
    }
    
    func getDestinationDetailNoSepaTransferUseCase(input: DestinationDetailNoSepaTransferUseCaseInput) -> UseCase<DestinationDetailNoSepaTransferUseCaseInput, DestinationDetailNoSepaTransferUseCaseOkOutput, StringErrorOutput> {
        return DestinationDetailNoSepaTransferUseCase(bsanManagersProvider: bsanManagersProvider).setRequestValues(requestValues: input)
    }
    
    func getConfirmOTPInternalScheduledTransferUseCase(input: ConfirmOTPInternalScheduledTransferUseCaseInput) -> UseCase<ConfirmOTPInternalScheduledTransferUseCaseInput, ConfirmOTPInternalScheduledTransferUseCaseOkOutput, GenericErrorOTPErrorOutput> {
        return ConfirmOTPInternalScheduledTransferUseCase(managersProvider: bsanManagersProvider, appConfigRepository: appConfigRepository, trusteerRepository: trusteerRepository, dependenciesResolver: dependenciesResolver).setRequestValues(requestValues: input)
    }
    
    func getValidateNoSepaTransferUseCase(input: ValidateNoSepaTransferUseCaseInput) -> UseCase<ValidateNoSepaTransferUseCaseInput, ValidateNoSepaTransferUseCaseOkOutput, ValidateNoSepaTransferUseCaseErrorOutput> {
        return ValidateNoSepaTransferUseCase(bsanManagersProvider: bsanManagersProvider).setRequestValues(requestValues: input)
    }
    
    func getConfirmNoSepaTransferOTPUseCase(input: ConfirmNoSepaTransferOTPUseCaseInput) -> UseCase<ConfirmNoSepaTransferOTPUseCaseInput, ConfirmNoSepaTransferOTPUseCaseOkOutput, GenericErrorOTPErrorOutput> {
        return ConfirmNoSepaTransferOTPUseCase(appConfigRepository: appConfigRepository, bsanManagersProvider: bsanManagersProvider, trusteerRepository: trusteerRepository).setRequestValues(requestValues: input)
    }
    
    // MARK: - Card limit management
    
    func getValidateCardLimitsUseCase(input: ValidateCardLimitManagementUseCaseInput) -> UseCase<ValidateCardLimitManagementUseCaseInput, Void, ValidateCardLimitManagementUseCaseErrorOutput> {
        return ValidateCardLimitManagementUseCase().setRequestValues(requestValues: input)
    }
    
    func getPreSetupCardLimitManagementUseCase(input: PreSetupCardLimitManagementUseCaseInput) -> UseCase<PreSetupCardLimitManagementUseCaseInput, PreSetupCardLimitManagementUseCaseOkOutput, StringErrorOutput> {
        return PreSetupCardLimitManagementUseCase(bsanManagerProvider: bsanManagersProvider, appRepository: appRepository, accountDescriptorRepository: accountDescriptorRepository, appConfigRepository: appConfigRepository).setRequestValues(requestValues: input)
    }
    
    func getSetupCardLimitManagementUseCase(input: SetupCardLimitManagementUseCaseInput) -> UseCase<SetupCardLimitManagementUseCaseInput, SetupCardLimitManagementUseCaseOkOutput, StringErrorOutput> {
        return SetupCardLimitManagementUseCase(appConfigRepository: appConfigRepository).setRequestValues(requestValues: input)
    }
    
    func getCardLimitManagementValidationUseCase() -> UseCase<Void, CardLimitManagementValidationUseCaseOkOutput, StringErrorOutput> {
        return CardLimitManagementValidationUseCase(bsanManagerProvider: bsanManagersProvider)
    }
    
    func getCardLimitManagementConfirmationUseCase(input: CardLimitManagementConfirmationUseCaseInput) -> UseCase<CardLimitManagementConfirmationUseCaseInput, CardLimitManagementConfirmationUseCaseOkOutput, GenericErrorSignatureErrorOutput> {
        return CardLimitManagementConfirmationUseCase(bsanManagerProvider: bsanManagersProvider).setRequestValues(requestValues: input)
    }
    
    func getCardLimitManagementOTPConfirmationUseCase(input: CardLimitManagementOTPConfirmationUseCaseInput) -> UseCase<CardLimitManagementOTPConfirmationUseCaseInput, Void, GenericErrorOTPErrorOutput> {
        return CardLimitManagementOTPConfirmationUseCase(bsanManagerProvider: bsanManagersProvider).setRequestValues(requestValues: input)
    }
    
    func getGetAccountEasyPayUseCase(input: GetAccountEasyPayUseCaseInput) -> UseCase<GetAccountEasyPayUseCaseInput, GetAccountEasyPayUseCaseOkOutput, GenericUseCaseErrorOutput> {
        return GetAccountEasyPayUseCase(dependenciesResolver: dependenciesResolver).setRequestValues(requestValues: input)
    }
    
    func getAccountEasyPayFundableTypeUseCase(input: AccountEasyPayFundableTypeUseCaseInput) -> UseCase<AccountEasyPayFundableTypeUseCaseInput, AccountEasyPayFundableTypeUseCaseOkOutput, StringErrorOutput> {
        return AccountEasyPayFundableTypeUseCase().setRequestValues(requestValues: input)
    }
    
    func getSetupDuplicateBillUseCase(input: SetupDuplicateBillUseCaseInput) -> UseCase<SetupDuplicateBillUseCaseInput, SetupDuplicateBillUseCaseOKOutput, StringErrorOutput> {
        return SetupDuplicateBillUseCase(repository: appConfigRepository, managersProvider: bsanManagersProvider).setRequestValues(requestValues: input)
    }
    
    func getConfirmDuplicateBillUseCase(input: ConfirmDuplicateBillUseCaseInput) -> UseCase<ConfirmDuplicateBillUseCaseInput, Void, GenericErrorSignatureErrorOutput> {
        return ConfirmDuplicateBillUseCase(dependenciesResolver: dependenciesResolver).setRequestValues(requestValues: input)
    }
    
    func downloadPdfBillUseCase(input: DownloadPdfBillUseCaseInput) -> UseCase<DownloadPdfBillUseCaseInput, DownloadPdfBillUseCaseOkOutput, StringErrorOutput> {
        return DownloadPdfBillUseCase(dependenciesResolver: dependenciesResolver).setRequestValues(requestValues: input)
    }
    
    func getSetupReceiptReturnUseCase(input: SetupReceiptReturnUseCaseInput) -> UseCase<SetupReceiptReturnUseCaseInput, SetupReceiptReturnUseCaseOKOutput, StringErrorOutput> {
        return SetupReceiptReturnUseCase(repository: appConfigRepository, managersProvider: bsanManagersProvider).setRequestValues(requestValues: input)
    }
    
    func getConfirmReceiptReturnUseCase(input: ConfirmReceiptReturnUseCaseInput) -> UseCase<ConfirmReceiptReturnUseCaseInput, Void, GenericErrorSignatureErrorOutput> {
        return ConfirmReceiptReturnUseCase(dependenciesResolver: dependenciesResolver).setRequestValues(requestValues: input)
    }
    
    func setupCancelDirectBillingUseCase(input: SetupCancelDirectBillingUseCaseInput) -> UseCase<SetupCancelDirectBillingUseCaseInput, SetupCancelDirectBillingUseCaseOkOutput, StringErrorOutput> {
        return SetupCancelDirectBillingUseCase(repository: appConfigRepository, managersProvider: bsanManagersProvider).setRequestValues(requestValues: input)
    }
    
    func getCancelDirectBillingValidationUseCase(input: ValidateCancelDirectBillingUseCaseInput) -> UseCase<ValidateCancelDirectBillingUseCaseInput, ValidateCancelDirectBillingUseCaseOkOutput, StringErrorOutput> {
        return ValidateCancelDirectBillingUseCase(dependenciesResolver: dependenciesResolver).setRequestValues(requestValues: input)
    }
    
    func getConfirmCancelDirectBillingUseCase(input: ConfirmCancelDirectBillingUseCaseInput) -> UseCase<ConfirmCancelDirectBillingUseCaseInput, Void, GenericErrorSignatureErrorOutput> {
        return ConfirmCancelDirectBillingUseCase(managersProvider: bsanManagersProvider).setRequestValues(requestValues: input)
    }
    
    func getSetupChangeDirectDebitUseCase(input: SetupChangeDirectDebitUseCaseInput) -> UseCase<SetupChangeDirectDebitUseCaseInput, SetupChangeDirectDebitUseCaseOKOutput, StringErrorOutput> {
        return SetupChangeDirectDebitUseCase(managersProvider: bsanManagersProvider, appConfigRepository: appConfigRepository, appRepository: appRepository, accountDescriptorRepository: accountDescriptorRepository).setRequestValues(requestValues: input)
    }
    
    func getValidateChangeDirectDebitUseCase() -> UseCase<Void, ValidateChangeDirectDebitUseCaseOkOutput, StringErrorOutput> {
        return ValidateChangeDirectDebitUseCase(managersProvider: bsanManagersProvider)
    }
    
    func getConfirmChangeDirectDebitUseCase(input: ConfirmChangeDirectDebitUseCaseInput) -> UseCase<ConfirmChangeDirectDebitUseCaseInput, Void, GenericErrorSignatureErrorOutput> {
        return ConfirmChangeDirectDebitUseCase(managersProvider: bsanManagersProvider).setRequestValues(requestValues: input)
    }
    
    // MARK: - OTP PUSH
    
    func getGetOTPPushDeviceUseCase() -> UseCase<Void, GetOTPPushDeviceUseCaseOkOutput, GetOTPPushDeviceUseCaseErrorOutput> {
        return GetOTPPushDeviceUseCase(bsanManagerProvider: bsanManagersProvider)
    }
    
    func getValidateOTPPushDeviceUseCase(input: ValidateOTPPushDeviceUseCaseInput) -> UseCase<ValidateOTPPushDeviceUseCaseInput, ValidateOTPPushDeviceUseCaseOkOutput, StringErrorOutput> {
        return ValidateOTPPushDeviceUseCase(bsanManagerProvider: bsanManagersProvider).setRequestValues(requestValues: input)
    }
    
    func getGetLocalPushTokenUseCase() -> UseCase<Void, GetLocalPushTokenUseCaseOkOutput, StringErrorOutput> {
        return GetLocalPushTokenUseCase(dependenciesResolver: self.dependenciesResolver)
    }
    
    func getUpdateTokenPushUseCase(input: UpdateTokenPushUseCaseInput) -> UseCase<UpdateTokenPushUseCaseInput, UpdateTokenPushUseCaseOkOutput, GenericUseCaseErrorOutput> {
        return UpdateTokenPushUseCase(bsanManagerProvider: bsanManagersProvider, dependenciesResolver: self.dependenciesEngine).setRequestValues(requestValues: input)
    }
    
    func getSaveTokenPushUseCase(input: SaveTokenPushUseCaseInput) -> UseCase<SaveTokenPushUseCaseInput, Void, StringErrorOutput> {
        return SaveTokenPushUseCase(dependenciesResolver: self.dependenciesEngine).setRequestValues(requestValues: input)
    }
    
    func getRemoveTokenPushUseCase() -> UseCase<Void, Void, StringErrorOutput> {
        return RemoveTokenPushUseCase(dependenciesResolver: self.dependenciesEngine)
    }
    
    func getPreSetupEnableOtpPushUseCase() -> UseCase<Void, Void, StringErrorOutput> {
        return PreSetupEnableOtpPushUseCase(appConfigRepository: appConfigRepository)
    }
    
    func getSetupEnableOtpPushUseCase(input: SetupEnableOtpPushUseCaseInput) -> UseCase<SetupEnableOtpPushUseCaseInput, SetupEnableOtpPushUseCaseOkOutput, StringErrorOutput> {
        return SetupEnableOtpPushUseCase(appConfigRepository: appConfigRepository, bsanManagersProvider: bsanManagersProvider).setRequestValues(requestValues: input)
    }
    
    func getValidateEnableOtpPushUseCase() -> UseCase<Void, ValidateEnableOtpPushUseCaseOkOutput, GenericUseCaseErrorOutput> {
        return ValidateEnableOtpPushUseCase(managersProvider: bsanManagersProvider)
    }
    
    func getConfirmEnableOtpPushUseCase(input: ConfirmEnableOtpPushUseCaseInput) -> UseCase<ConfirmEnableOtpPushUseCaseInput, ConfirmEnableOtpPushUseCaseOkOutput, GenericErrorSignatureErrorOutput> {
        return ConfirmEnableOtpPushUseCase(managersProvider: bsanManagersProvider).setRequestValues(requestValues: input)
    }
    
    func getConfirmOTPEnableOtpPushUseCase(input: ConfirmOTPEnableOtpPushUseCaseInput) -> UseCase<ConfirmOTPEnableOtpPushUseCaseInput, ConfirmOTPEnableOtpPushUseCaseOkOutput, GenericErrorOTPErrorOutput> {
        return ConfirmOTPEnableOtpPushUseCase(dependenciesResolver: self.dependenciesResolver).setRequestValues(requestValues: input)
    }
    
    func getSecureDevicePhoneUseCase() -> UseCase<Void, GetSecureDevicePhoneUseCaseOkOutput, StringErrorOutput> {
        return GetSecureDevicePhoneUseCase(managersProvider: bsanManagersProvider)
    }
            
    func getCheckerChangeDirectDebitUseCase(input: CheckerChangeDirectDebitUseCaseInput) -> UseCase<CheckerChangeDirectDebitUseCaseInput, Void, StringErrorOutput> {
        return CheckerChangeDirectDebitUseCase(managersProvider: bsanManagersProvider, appConfigRepository: appConfigRepository, appRepository: appRepository, accountDescriptorRepository: accountDescriptorRepository).setRequestValues(requestValues: input)
    }
    
    // MARK: - First Installation
    
    func getIsFirstInstallationUseCase() -> UseCase<Void, IsFirstInstallationUseCaseOkOutput, StringErrorOutput> {
        return IsFirstInstallationUseCase(dependenciesResolver: self.dependenciesEngine)
    }
    
    func getSaveFirstInstallationUseCase() -> UseCase<Void, Void, StringErrorOutput> {
        return SaveFirstInstallationUseCase(dependenciesResolver: self.dependenciesEngine)
    }
    
    // MARK: - Change Massive Direct Debits
    
    func getPreSetupChangeMassiveDirectDebitsUseCase() -> UseCase<Void, PreSetupChangeMassiveDirectDebitsUseCaseOkOutput, StringErrorOutput> {
        return PreSetupChangeMassiveDirectDebitsUseCase(appConfigRepository: appConfigRepository, bsanManagerProvider: bsanManagersProvider, appRepository: appRepository, accountDescriptorRepository: accountDescriptorRepository)
    }
    
    func getSetupChangeMassiveDirectDebitsUseCase() -> UseCase<Void, SetupChangeMassiveDirectDebitsUseCaseOKOutput, StringErrorOutput> {
        return SetupChangeMassiveDirectDebitsUseCase(appConfigRepository: appConfigRepository, bsanManagersProvider: bsanManagersProvider)
    }
    
    func getFilterMassiveDirectDebitUseCase(input: FilterMassiveDirectDebitUseCaseInput) -> UseCase<FilterMassiveDirectDebitUseCaseInput, FilterMassiveDirectDebitUseCaseOkOutput, StringErrorOutput> {
        return FilterMassiveDirectDebitUseCase(appConfigRepository: appConfigRepository).setRequestValues(requestValues: input)
    }
    
    func getValidateChangeMassiveDirectDebitsUseCase(input: ValidateChangeMassiveDirectDebitsUseCaseInput) -> UseCase<ValidateChangeMassiveDirectDebitsUseCaseInput, ValidateChangeMassiveDirectDebitsUseCaseOkOutput, StringErrorOutput> {
        return ValidateChangeMassiveDirectDebitsUseCase(bsanManagersProvider: bsanManagersProvider).setRequestValues(requestValues: input)
    }
    
    func getConfirmChangeMassiveDirectDebitsUseCase(input: ConfirmChangeMassiveDirectDebitsUseCaseInput) -> UseCase<ConfirmChangeMassiveDirectDebitsUseCaseInput, Void, GenericErrorSignatureErrorOutput> {
        return ConfirmChangeMassiveDirectDebitsUseCase(bsanManagersProvider: bsanManagersProvider).setRequestValues(requestValues: input)
    }
    
    func getPreSetupUpdateUsualTransferUseCase() -> UseCase<Void, PreSetupUpdateUsualTransferUseCaseOKOutput, StringErrorOutput> {
        return PreSetupUpdateUsualTransferUseCase(sepaRepository: sepaInfoRepository)
    }
    
    func getPreSetupUpdateNoSepaUsualTransferUseCase() -> UseCase<Void, PreSetupUpdateNoSepaUsualTransferUseCaseOkOutput, StringErrorOutput> {
        return PreSetupUpdateNoSepaUsualTransferUseCase(appConfigRepository: appConfigRepository, sepaRepository: sepaInfoRepository)
    }
    
    func getSetupUpdateNoSepaUsualTransferUseCase(input: SetupUpdateNoSepaUsualTransferUseCaseInput) -> UseCase<SetupUpdateNoSepaUsualTransferUseCaseInput, SetupUpdateNoSepaUsualTransferUseCaseOKOutput, StringErrorOutput> {
        return SetupUpdateNoSepaUsualTransferUseCase(appConfigRepository: appConfigRepository, bsanManagersProvider: bsanManagersProvider).setRequestValues(requestValues: input)
    }
    func getSetupUpdateUsualTransferUseCase() -> UseCase<Void, SetupUpdateUsualTransferUseCaseOKOutput, StringErrorOutput> {
        return SetupUpdateUsualTransferUseCase(appConfigRepository: appConfigRepository, bsanManagersProvider: bsanManagersProvider)
    }
    
    func getPreValidateUpdateUsualTransferUseCase(input: PreValidateUpdateUsualTransferUseCaseInput) -> UseCase<PreValidateUpdateUsualTransferUseCaseInput, PreValidateUpdateUsualTransferUseCaseOkOutput, StringErrorOutput> {
        return PreValidateUpdateUsualTransferUseCase(bsanManagersProvider: bsanManagersProvider, appConfigRepository: appConfigRepository, trusteerRepository: trusteerRepository, dependenciesResolver: dependenciesResolver).setRequestValues(requestValues: input)
    }
    
    func getValidateUpdateUsualTransferUseCase(input: ValidateUpdateUsualTransferUseCaseInput) -> UseCase<ValidateUpdateUsualTransferUseCaseInput, ValidateUpdateUsualTransferUseCaseOkOutput, StringErrorOutput> {
        return ValidateUpdateUsualTransferUseCase(managersProvider: bsanManagersProvider).setRequestValues(requestValues: input)
    }
    
    func getValidateUpdateNoSepaUsualTransferUseCase(input: ValidateUpdateNoSepaUsualTransferUseCaseInput) -> UseCase<ValidateUpdateNoSepaUsualTransferUseCaseInput, ValidateUpdateNoSepaUsualTransferUseCaseOkOutput, StringErrorOutput> {
        return ValidateUpdateNoSepaUsualTransferUseCase(managersProvider: bsanManagersProvider).setRequestValues(requestValues: input)
    }
        
    func getValidateOTPUpdateUsualTransferUseCase(input: ValidateOTPUpdateUsualTransferUseCaseInput) -> UseCase<ValidateOTPUpdateUsualTransferUseCaseInput, ValidateOTPUpdateUsualTransferUseCaseOkOutput, GenericErrorSignatureErrorOutput> {
        return ValidateOTPUpdateUsualTransferUseCase(managersProvider: bsanManagersProvider).setRequestValues(requestValues: input)
    }
    
    func getConfirmUpdateUsualTransferUseCase(input: ConfirmUpdateUsualTransferUseCaseInput) -> UseCase<ConfirmUpdateUsualTransferUseCaseInput, Void, GenericErrorOTPErrorOutput> {
        return ConfirmUpdateUsualTransferUseCase(managersProvider: bsanManagersProvider).setRequestValues(requestValues: input)
    }
    
    func getPreValidateCreateUsualTransferUseCase(input: PreValidateCreateUsualTransferUseCaseInput) -> UseCase<PreValidateCreateUsualTransferUseCaseInput, PreValidateCreateUsualTransferUseCaseOkOutput, PreValidateCreateUsualTransferUseCaseErrorOutput> {
        return PreValidateCreateUsualTransferUseCase(bsanManagersProvider: bsanManagersProvider, appConfigRepository: appConfigRepository, trusteerRepository: trusteerRepository, dependenciesResolver: dependenciesResolver).setRequestValues(requestValues: input)
    }
    
    func getValidateCreateUsualTransferUseCase(input: ValidateCreateUsualTransferUseCaseInput) -> UseCase<ValidateCreateUsualTransferUseCaseInput, ValidateCreateUsualTransferUseCaseOkOutput, StringErrorOutput> {
        return ValidateCreateUsualTransferUseCase(managersProvider: bsanManagersProvider).setRequestValues(requestValues: input)
    }
    
    func getValidateOTPCreateUsualTransferUseCase(input: ValidateOTPCreateUsualTransferUseCaseInput) -> UseCase<ValidateOTPCreateUsualTransferUseCaseInput, ValidateOTPCreateUsualTransferUseCaseOkOutput, GenericErrorSignatureErrorOutput> {
        return ValidateOTPCreateUsualTransferUseCase(managersProvider: bsanManagersProvider).setRequestValues(requestValues: input)
    }
    
    func getConfirmCreateUsualTransferUseCase(input: ConfirmCreateUsualTransferUseCaseInput) -> UseCase<ConfirmCreateUsualTransferUseCaseInput, Void, GenericErrorOTPErrorOutput> {
        return ConfirmCreateUsualTransferUseCase(managersProvider: bsanManagersProvider).setRequestValues(requestValues: input)
    }
    
    func getRemoveBillListUseCase() -> UseCase<Void, Void, StringErrorOutput> {
        return RemoveBillListUseCase(managersProvider: bsanManagersProvider)
    }
    
    func getSetupReemittedNoSepaTransferCardUseCase(input: SetupReemittedNoSepaTransferCardUseCaseInput) -> UseCase<SetupReemittedNoSepaTransferCardUseCaseInput, SetupReemittedNoSepaTransferCardUseCaseOkOutput, StringErrorOutput> {
        return SetupReemittedNoSepaTransferCardUseCase(managersProvider: bsanManagersProvider,
                                                       appConfigRepository: appConfigRepository,
                                                       sepaRepository: sepaInfoRepository,
                                                       appRepository: appRepository,
                                                       accountDescriptorRepository:
                                                        accountDescriptorRepository,
                                                       dependenciesResolver: dependenciesResolver).setRequestValues(requestValues: input)
    }
    
    func getDestinationNoSepaReemittedTransferUseCase(input: DestinationNoSepaReemittedTransferUseCaseInput) -> UseCase<DestinationNoSepaReemittedTransferUseCaseInput, DestinationNoSepaReemittedTransferUseCaseOkOutput, DestinationNoSepaReemittedTransferUseCaseErrorOutput> {
        return DestinationNoSepaReemittedTransferUseCase(bsanManagersProvider: bsanManagersProvider).setRequestValues(requestValues: input)
    }
    
//    func getLoadManagersDomainUseCase() -> UseCase<Void, Void, LoadManagersDomainCaseErrorOutput> {
//        return LoadManagersDomainUseCase(bsanManagersProvider: bsanManagersProvider)
//    }
    
    func getAllUsualTransfersOperativesUseCase() -> UseCase<Void, GetAllUsualTransfersUseCaseOkOutput, GetAllUsualTransfersUseCaseErrorOutput> {
        return GetAllUsualTransfersUseCase(bsanManagersProvider: bsanManagersProvider)
    }
    
    func getSepaPayeeDetailUseCase(input: PayeeDetailUseCaseInput) -> UseCase<PayeeDetailUseCaseInput, Void, StringErrorOutput> {
        return PayeeDetailUseCase(managersProvider: bsanManagersProvider).setRequestValues(requestValues: input)
    }
    
    func getNoSepaPayeeDetailUseCase(input: GetNoSepaPayeeDetailUseCaseInput) -> UseCase<GetNoSepaPayeeDetailUseCaseInput, GetNoSepaPayeeDetailUseCaseOkOutput, GetNoSepaPayeeDetailUseCaseErrorOutput> & Cancelable {
        let useCase = GetNoSepaPayeeDetailUseCase(managersProvider: bsanManagersProvider)
        _ = useCase.setRequestValues(requestValues: input)
        return useCase
    }
    
    func getNoSepaPayeeDetailUseCase(input: NoSepaPayeeDetailUseCaseInput) -> UseCase<NoSepaPayeeDetailUseCaseInput, NoSepaPayeeDetailUseCaseOkOutput, NoSepaPayeeDetailUseCaseErrorOutput> {
        let usecase = NoSepaPayeeDetailUseCase(managersProvider: bsanManagersProvider)
        _ = usecase.setRequestValues(requestValues: input)
        return usecase
    }
    
    func getPreValidateCreateNoSepaUsualTransferUseCase(input: PreValidateCreateNoSepaUsualTransferUseCaseInput) -> UseCase<PreValidateCreateNoSepaUsualTransferUseCaseInput, PreValidateCreateNoSepaUsualTransferUseCaseOkOutput, PreValidateCreateNoSepaUsualTransferUseCaseErrorOutput> {
        return PreValidateCreateNoSepaUsualTransferUseCase(bsanManagersProvider: bsanManagersProvider, dependenciesResolver: dependenciesResolver).setRequestValues(requestValues: input)
    }
    
    func getValidateCreateNoSepaUsualTransferInputDetailUseCase(input: ValidateCreateNoSepaUsualTransferInputDetailUseCaseInput) -> UseCase<ValidateCreateNoSepaUsualTransferInputDetailUseCaseInput, ValidateCreateNoSepaUsualTransferInputDetailUseCaseOkOutput, StringErrorOutput> {
        return ValidateCreateNoSepaUsualTransferInputDetailUseCase(bsanManagersProvider: bsanManagersProvider).setRequestValues(requestValues: input)
    }
    
    func getValidateCreateNoSepaUsualTransferUseCase(input: ValidateCreateNoSepaUsualTransferUseCaseInput) -> UseCase<ValidateCreateNoSepaUsualTransferUseCaseInput, ValidateCreateNoSepaUsualTransferUseCaseOkOutput, StringErrorOutput> {
        return ValidateCreateNoSepaUsualTransferUseCase(managersProvider: bsanManagersProvider).setRequestValues(requestValues: input)
    }
    
    func getValidateOTPCreateNoSepaUsualTransferUseCase(input: ValidateOTPCreateNoSepaUsualTransferUseCaseInput) -> UseCase<ValidateOTPCreateNoSepaUsualTransferUseCaseInput, ValidateOTPCreateNoSepaUsualTransferUseCaseOkOutput, GenericErrorSignatureErrorOutput> {
        return ValidateOTPCreateNoSepaUsualTransferUseCase(managersProvider: bsanManagersProvider).setRequestValues(requestValues: input)
    }
    
    func getConfirmCreateNoSepaUsualTransferUseCase(input: ConfirmCreateNoSepaUsualTransferUseCaseInput) -> UseCase<ConfirmCreateNoSepaUsualTransferUseCaseInput, Void, GenericErrorOTPErrorOutput> {
        return ConfirmCreateNoSepaUsualTransferUseCase(managersProvider: bsanManagersProvider).setRequestValues(requestValues: input)
    }
    
    // MARK: - SCA
    
    func getValidateScaUseCase() -> ValidateScaUseCaseProtocol {
        guard let valdateScaUseCaseProtocol = self.dependenciesResolver.resolve(forOptionalType: ValidateScaUseCaseProtocol.self) else {
            return ValidateScaUseCase(managersProvider: bsanManagersProvider)
        }
        return valdateScaUseCaseProtocol
    }
    
    func getConfirmScaUseCase() -> ConfirmScaUseCaseProtocol {
        guard let confirmScaUseCaseProtocol = self.dependenciesResolver.resolve(forOptionalType: ConfirmScaUseCaseProtocol.self) else {
            return ConfirmScaUseCase(managersProvider: bsanManagersProvider)
        }
        return confirmScaUseCaseProtocol
    }
    
    func getScaAccountsStateUseCase(input: GetScaAccountsStateUseCaseInput) -> UseCase<GetScaAccountsStateUseCaseInput, GetScaAccountsStateUseCaseOkOutput, StringErrorOutput> {
        return GetScaAccountsStateUseCase(managersProvider: bsanManagersProvider, appConfigRepository: appConfigRepository).setRequestValues(requestValues: input)
    }
    
    func getValidateOTPUpdateNoSepaUsualTransferUseCase(input: ValidateOTPUpdateNoSepaUsualTransferUseCaseInput) -> UseCase<ValidateOTPUpdateNoSepaUsualTransferUseCaseInput, ValidateOTPUpdateNoSepaUsualTransferUseCaseOkOutput, GenericErrorSignatureErrorOutput> {
        return ValidateOTPUpdateNoSepaUsualTransferUseCase(managersProvider: bsanManagersProvider).setRequestValues(requestValues: input)
    }
    
    func getConfirmUpdateNoSepaUsualTransferUseCase(input: ConfirmUpdateNoSepaUsualTransferUseCaseInput) -> UseCase<ConfirmUpdateNoSepaUsualTransferUseCaseInput, Void, GenericErrorOTPErrorOutput> {
        return ConfirmUpdateNoSepaUsualTransferUseCase(managersProvider: bsanManagersProvider).setRequestValues(requestValues: input)
    }
    
    func getUserPreferencesEntityUseCase() -> UseCase<Void, GetUserPrefEntityUseCaseOkOutput, StringErrorOutput> {
        return GetUserPrefEntityUseCase(bsanManagersProvider: bsanManagersProvider, appRepository: appRepository, accountDescriptorRepository: accountDescriptorRepository, appConfigRepository: appConfigRepository)
    }
    
    func getUpdateOptionsOnboardingUserPrefUseCase(input: UpdateOptionsOnboardingUserPrefUseCaseInput) -> UseCase<UpdateOptionsOnboardingUserPrefUseCaseInput, Void, StringErrorOutput> {
        return UpdateOptionsOnboardingUserPrefUseCase(appRepository: appRepository).setRequestValues(requestValues: input)
    }
    
    func getFirstOnboardingPermissionsUseCase(dependencies: PresentationComponent) -> UseCase<Void, FirstOnboardingPermissionsUseCaseOkOutput, StringErrorOutput> {
        return FirstOnboardingPermissionsUseCase(dependencies: dependencies, dependenciesResolver: self.dependenciesResolver)
    }
    
    // MARK: - Apple Pay
    
    func getSetupAddToApplePayUseCase(input: SetupAddToApplePayUseCaseInput) -> UseCase<SetupAddToApplePayUseCaseInput, SetupAddToApplePayUseCaseOKOutput, StringErrorOutput> {
        return SetupAddToApplePayUseCase(appConfigRepository: appConfigRepository, bsanManagersProvider: bsanManagersProvider).setRequestValues(requestValues: input)
    }

    func getPreSetupAddToApplePayUseCase() -> PreSetupAddToApplePayUseCase {
        return PreSetupAddToApplePayUseCase(provider: bsanManagersProvider, appConfigRepository: appConfigRepository, appRepository: appRepository, accountDescriptorRepository: accountDescriptorRepository)
    }
    
    func getAddToApplePayValidationUseCase(input: AddToApplePayValidationUseCaseInput) -> UseCase<AddToApplePayValidationUseCaseInput, AddToApplePayValidationUseCaseOkOutput, GenericErrorSignatureErrorOutput> {
        return AddToApplePayValidationUseCase(bsanManagersProvider: bsanManagersProvider).setRequestValues(requestValues: input)
    }
    
    // MARK: - TimeLine

    func getGetTimeLineIsEnabledUseCase() -> UseCase<Void, GetTimeLineIsEnabledUseCaseOkOutput, StringErrorOutput> {
        return GetTimeLineIsEnabledUseCase(dependenciesResolver: dependenciesResolver)
    }
    
    // MARK: - BackgroundImages
    
    func getLoadBackgroundImagesUseCase(input: LoadBackgroundImagesUseCaseInput) -> UseCase<LoadBackgroundImagesUseCaseInput, Void, StringErrorOutput> {
        return LoadBackgroundImagesUseCase(dependenciesResolver: self.dependenciesResolver).setRequestValues(requestValues: input)
    }

    // MARK: - Public products
    
    func getSanflixContractInfoUseCase(input: SanflixContractInfoUseCaseInput) -> UseCase<SanflixContractInfoUseCaseInput, SanflixContractInfoUseCaseOkOutput, StringErrorOutput> {
        return SanflixContractInfoUseCase(appConfigRepository: appConfigRepository, bsanManagersProvider: bsanManagersProvider, pullOffersInterpreter: pullOffersInterpreter).setRequestValues(requestValues: input)
    }

    func getSaveFileUseCase(input: SaveFileUseCaseInput) -> UseCase<SaveFileUseCaseInput, SaveFileUseCaseOkOutput, StringErrorOutput> {
        return SaveFileUseCase(documentsRepository: documentsRepository).setRequestValues(requestValues: input)
    }
    
    // MARK: - Trusteer

    func configureTrusteer() -> UseCase<Void, Void, StringErrorOutput> {
        return TrusteerUseCase(appConfigRepository: appConfigRepository, trusteerRepository: trusteerRepository)
    }
    
    func loginTrusteer() -> UseCase<Void, Void, StringErrorOutput> {
        return PinPointTrusteerUseCase(appConfigRepository: appConfigRepository, bsanManagersProvider: bsanManagersProvider, trusteerRepository: trusteerRepository)
    }
    
    // MARK: - Login Date
    
    func getSetLastLoginDateUseCase(input: SetLastLoginDateUseCaseInput) -> UseCase<SetLastLoginDateUseCaseInput, Void, StringErrorOutput> {
        return SetLastLoginDateUseCase(dependenciesResolver: dependenciesResolver).setRequestValues(requestValues: input)
    }

    // MARK: - Analysis Area
    
    func getIsAnalysisAreaEnabledUseCase() -> UseCase<Void, GetIsAnalysisAreaEnabledUseCaseOkOutput, StringErrorOutput> {
        return GetIsAnalysisAreaEnabledUseCase(bsanManagersProvider: bsanManagersProvider, appRepository: appRepository, accountDescriptorRepository: accountDescriptorRepository, appConfigRepository: appConfigRepository)
    }
    
    // MARK: - Menu Texts
    
    func getMenuTextUseCase() -> UseCase<Void, MenuTextUseCaseOutput, StringErrorOutput> {
        return MenuTextUseCase(appConfigRepository: appConfigRepository)
    }
    
    // MARK: - WhatsNeW

    func getIsWhatsNewEnabledUseCase() -> UseCase<Void, IsWhatsNewEnabledUseCaseOkOutput, StringErrorOutput> {
        return IsWhatsNewEnabledUseCase(appConfigRepository: appConfigRepository)
    }
    
    // MARK: - One Plan

    func getHasOneProductsUseCase(input: GetHasOneProductsUseCaseInput) -> UseCase<GetHasOneProductsUseCaseInput, GetHasOneProductsUseCaseOkOutput, StringErrorOutput> {
        return GetHasOneProductsUseCase(dependenciesResolver: dependenciesResolver).setRequestValues(requestValues: input)
    }
    
    // MARK: - AppIcon
    func getChangeAppIconUseCase() -> UseCase<Void, ChangeAppIconUseCaseOkOutput, StringErrorOutput> {
        return ChangeAppIconUseCase(dependenciesResolver: dependenciesResolver, bsanManagersProvider: bsanManagersProvider, appRepository: appRepository, accountDescriptorRepository: accountDescriptorRepository, appConfigRepository: appConfigRepository)
    }
    
    // MARK: - New user pref    
    func updateUserPreferencesUseCase() -> UseCase<UpdateUserPreferencesUseCaseInput, Void, StringErrorOutput> {
        return UpdateUserPreferencesUseCase(dependenciesResolver: dependenciesResolver)
    }
    
    // MARK: - Visible Cards
    func getVisibleCardsUseCase() -> UseCase<Void, GetVisibleCardsUseCaseOkOutPut, StringErrorOutput> {
        return GetVisibleCardsUseCase(dependenciesResolver: dependenciesResolver)
    }
    
    func getAdditionalPublicFilesUseCasesIfPresent() -> [(useCase: UseCase<Void, Void, StringErrorOutput>, isMandatory: Bool)]? {
        let additionalUseCasesProvider = dependenciesEngine.resolve(forOptionalType: AdditionalUseCasesProviderProtocol.self)
        return additionalUseCasesProvider?.getAdditionalPublicFilesUseCases()
    }
    
    // MARK: - CarbonFootprint UseCases
    func getCarbonFootprintTokenIdUseCase() -> UseCase<Void, GetCarbonFootprintIdUseCaseOkOutput, StringErrorOutput> {
        return GetCarbonFootprintIdUseCase(dependenciesResolver: self.dependenciesResolver)
    }
    
    func getCarbonFootprintDataUseCase() -> UseCase<Void, GetCarbonFootprintDataUseCaseOkOutput, StringErrorOutput> {
        return GetCarbonFootprintDataUseCase(dependenciesResolver: self.dependenciesResolver)
    }
    
    func getCarbonFootprintWebViewConfigurationUseCase(tokenId: String,
                                                       tokenData: String) -> UseCase<GetCarbonFootprintWebViewConfigurationInput, GetCarbonFootprintWebViewConfigurationOkOutput, StringErrorOutput> {
        let input = GetCarbonFootprintWebViewConfigurationInput(tokenId: tokenId,
                                                                 tokenData: tokenData)
        return GetCarbonFootprintWebViewConfigurationUseCase(dependenciesResolver: self.dependenciesResolver).setRequestValues(requestValues: input)
    }
}
