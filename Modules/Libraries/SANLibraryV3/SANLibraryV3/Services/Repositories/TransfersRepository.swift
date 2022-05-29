//
//  TransfersRepository.swift
//  SANServicesLibrary
//
//  Created by José María Jiménez Pérez on 27/7/21.
//

import SANServicesLibrary
import CoreFoundationLib
import SANSpainLibrary
import SANLegacyLibrary
import CoreDomain
import OpenCombine

struct TransfersDataRepository: SpainTransfersRepository {
    let environmentProvider: EnvironmentProvider
    let networkManager: NetworkClientManager
    let storage: Storage
    let requestSyncronizer: RequestSyncronizer
    let configurationRepository: ConfigurationRepository
    let bsanTransferManager: BSANTransfersManager
    let transferListDataSource: TransferListDataSourceProtocol
    
    init(environmentProvider: EnvironmentProvider,
         networkManager: NetworkClientManager,
         storage: Storage,
         requestSyncronizer: RequestSyncronizer,
         configurationRepository: ConfigurationRepository,
         bsanTransferManager: BSANTransfersManager) {
        self.environmentProvider = environmentProvider
        self.networkManager = networkManager
        self.storage = storage
        self.requestSyncronizer = requestSyncronizer
        self.configurationRepository = configurationRepository
        self.bsanTransferManager = bsanTransferManager
        self.transferListDataSource = TransferListDataSource(
            configurationRepository: configurationRepository,
            environmentProvider: environmentProvider,
            networkManager: networkManager,
            storage: storage
        )
    }
    
    // Transfer type
    func transferType(originAccount: AccountRepresentable, selectedCountry: String, selectedCurrerncy: String) throws -> Result<TransfersType, Error> {
        guard let accountDto = originAccount as? AccountDTO else { return .failure(RepositoryError.unknown) }
        let response = try bsanTransferManager.transferType(originAccountDTO: accountDto, selectedCountry: selectedCountry, selectedCurrerncy: selectedCurrerncy)
        let convertedResponse: Result<TransfersType, Error> = try BSANResponseConverter.convert(response: response)
        return convertedResponse
    }
    
    // Validate transfer
    
    func validateGenericTransfer(originAccount: AccountRepresentable, nationalTransferInput: SendMoneyGenericTransferInput) throws -> Result<ValidateAccountTransferRepresentable, Error> {
        guard let accountDto = originAccount as? AccountDTO,
              let ibanRepresentable = nationalTransferInput.ibanRepresentable,
              let amountRepresentable = nationalTransferInput.amountRepresentable
        else { return .failure(RepositoryError.unknown) }
        let input = GenericTransferInputDTO(beneficiary: nationalTransferInput.beneficiary,
                                            isSpanishResident: true,
                                            ibanRepresentable: ibanRepresentable,
                                            saveAsUsual: nationalTransferInput.saveAsUsual,
                                            saveAsUsualAlias: nationalTransferInput.saveAsUsualAlias,
                                            beneficiaryMail: nationalTransferInput.beneficiaryMail,
                                            amountRepresentable: amountRepresentable,
                                            concept: nationalTransferInput.concept,
                                            transferType: self.transferTypeDTOFromString(nationalTransferInput.transferType),
                                            tokenPush: nil)
        let response = try bsanTransferManager.validateGenericTransfer(originAccountDTO: accountDto, nationalTransferInput: input)
        let convertedResponse: Result<ValidateAccountTransferRepresentable, Error> = try BSANResponseConverter.convert(response: response)
        return convertedResponse
    }
    
    func validateDeferredTransfer(originAcount: AccountRepresentable, scheduledTransferInput: SendMoneyScheduledTransferInput) throws -> Result<ValidateScheduledTransferRepresentable, Error> {
        guard let accountDto = originAcount as? AccountDTO,
              let dateNextExecution = scheduledTransferInput.dateNextExecution,
              let iban = scheduledTransferInput.ibanDestinationRepresentable,
              let value = scheduledTransferInput.amountRepresentable?.value,
              let currencyRepresentable = scheduledTransferInput.amountRepresentable?.currencyRepresentable
        else { return .failure(RepositoryError.unknown) }
        let amount = AmountDTO(value: value,
                               currency: CurrencyDTO(currencyName: currencyRepresentable.currencyName,
                                                     currencyType: currencyRepresentable.currencyType))
        let ibanDTO = IBANDTO(countryCode: iban.countryCode, checkDigits: iban.checkDigits, codBban: iban.codBban)
        let input = ScheduledTransferInput(dateStartValidity: nil,
                                           dateEndValidity: nil,
                                           scheduledDayType: nil,
                                           periodicalType: nil,
                                           indicatorResidence: true,
                                           concept: scheduledTransferInput.concept,
                                           dateNextExecution: DateModel(date: dateNextExecution),
                                           currency: scheduledTransferInput.amountRepresentable?.currencyRepresentable?.currencyName,
                                           nameBankIbanBeneficiary: nil,
                                           actuanteCompany: nil,
                                           actuanteCode: nil,
                                           actuanteNumber: nil,
                                           ibanDestination: ibanDTO,
                                           saveAsUsual: nil,
                                           saveAsUsualAlias: nil,
                                           beneficiary: scheduledTransferInput.beneficiary,
                                           transferAmount: amount,
                                           company: nil,
                                           subType: nil)
        let response = try bsanTransferManager.validateDeferredTransfer(originAcount: accountDto, scheduledTransferInput: input)
        let convertedResponse: Result<ValidateScheduledTransferRepresentable, Error> = try BSANResponseConverter.convert(response: response)
        return convertedResponse
    }
    
    func validatePeriodicTransfer(originAcount: AccountRepresentable, scheduledTransferInput: SendMoneyScheduledTransferInput) throws -> Result<ValidateScheduledTransferRepresentable, Error> {
        guard let accountDto = originAcount as? AccountDTO,
              let value = scheduledTransferInput.amountRepresentable?.value,
              let currencyRepresentable = scheduledTransferInput.amountRepresentable?.currencyRepresentable,
              let iban = scheduledTransferInput.ibanDestinationRepresentable,
              let amount = scheduledTransferInput.amountRepresentable
        else { return .failure(RepositoryError.unknown) }
        var dateStartValidity: DateModel?
        let ibanDTO = IBANDTO(countryCode: iban.countryCode, checkDigits: iban.checkDigits, codBban: iban.codBban)
        if let date = scheduledTransferInput.dateStartValidity {
            dateStartValidity = DateModel(date: date)
        }
        var dateEndValidity: DateModel?
        if let date = scheduledTransferInput.dateEndValidity {
            dateEndValidity = DateModel(date: date)
        }
        let input = ScheduledTransferInput(dateStartValidity: dateStartValidity,
                                           dateEndValidity: dateEndValidity,
                                           scheduledDayType: self.scheduledDayDTOFromString(scheduledTransferInput.workingDayIssue),
                                           periodicalType: self.periodicalTypeDTOFromString(scheduledTransferInput.periodicity),
                                           indicatorResidence: true,
                                           concept: scheduledTransferInput.concept,
                                           dateNextExecution: nil,
                                           currency: scheduledTransferInput.amountRepresentable?.currencyRepresentable?.currencyName,
                                           nameBankIbanBeneficiary: nil,
                                           actuanteCompany: nil,
                                           actuanteCode: nil,
                                           actuanteNumber: nil,
                                           ibanDestination: ibanDTO,
                                           saveAsUsual: nil,
                                           saveAsUsualAlias: nil,
                                           beneficiary: scheduledTransferInput.beneficiary,
                                           transferAmount: amount,
                                           company: nil,
                                           subType: nil)
        let response = try bsanTransferManager.validateScheduledTransfer(originAcount: accountDto, scheduledTransferInput: input)
        let convertedResponse: Result<ValidateScheduledTransferRepresentable, Error> = try BSANResponseConverter.convert(response: response)
        return convertedResponse
    }

    func validateNoSEPATransfer(noSepaTransferInput: SendMoneyNoSEPAInput, validationSwift: ValidationSwiftRepresentable?) throws -> Result<ValidationIntNoSepaRepresentable, Error> {
        guard let input = self.getNoSepaTransferInput(noSepaTransferInput: noSepaTransferInput)
        else { return .failure(RepositoryError.unknown) }
        
        let validationSwiftDto = validationSwift as? ValidationSwiftDTO
        let response = try bsanTransferManager.validationIntNoSEPA(noSepaTransferInput: input, validationSwiftDTO: validationSwiftDto)
        let convertedResponse: Result<ValidationIntNoSepaRepresentable, Error> = try BSANResponseConverter.convert(response: response)
        return convertedResponse
    }
    
    func validateSwift(noSepaTransferInput: SendMoneyNoSEPAInput) throws -> Result<ValidationSwiftRepresentable, Error> {
        guard let input = self.getNoSepaTransferInput(noSepaTransferInput: noSepaTransferInput)
        else { return .failure(RepositoryError.unknown) }
        let response = try bsanTransferManager.validateSwift(noSepaTransferInput: input)
        let convertedResponse: Result<ValidationSwiftRepresentable, Error> = try BSANResponseConverter.convert(response: response)
        return convertedResponse
    }

    // Validate transfer OTP
    
    func validateGenericTransferOTP(originAccount: AccountRepresentable, nationalTransferInput: NationalTransferInputRepresentable, signature: SignatureRepresentable) throws -> Result<OTPValidationRepresentable, Error> {
        guard let accountDto = originAccount as? AccountDTO,
              let nationalTransferInputImpl = nationalTransferInput as? NationalTransferInput,
              let signatureDto = signature as? SignatureDTO
        else { return .failure(RepositoryError.unknown) }
        let response = try bsanTransferManager.validateGenericTransferOTP(originAccountDTO: accountDto,
                                                                          nationalTransferInput: nationalTransferInputImpl,
                                                                          signatureDTO: signatureDto)
        var convertedResponse: Result<OTPValidationRepresentable, Error> = try BSANResponseConverter.convert(response: response)
        if var validationDTO = try? response.getResponseData(),
           case .failure(let error) = convertedResponse,
           let error = error as? RepositoryError,
           case .errorWithCode(let error) = error
        {
            let error = error as NSError
            let signature = try self.processSendMoneySignatureResult(error)
            if case .otpUserExcepted = signature {
                validationDTO.otpExcepted = true
                convertedResponse = .success(validationDTO)
            }
        }
        return convertedResponse
    }
    
    func validatePeriodicTransferOTP(signature: SignatureRepresentable, dataToken: String) throws -> Result<OTPValidationRepresentable, Error> {
        guard let signatureDTO = signature as? SignatureDTO
        else { return .failure(RepositoryError.unknown) }
        let response = try bsanTransferManager.validateScheduledTransferOTP(signatureDTO: signatureDTO, dataToken: dataToken)
        var convertedResponse: Result<OTPValidationRepresentable, Error> = try BSANResponseConverter.convert(response: response)
        guard var validationDTO = try? response.getResponseData() else { return convertedResponse }
        if validationDTO.otpExcepted {
            return .success(validationDTO)
        } else if case .failure(let error) = convertedResponse,
                  let error = error as? RepositoryError,
                  case .errorWithCode(let error) = error
        {
            let error = error as NSError
            let signature = try self.processSendMoneySignatureResult(error)
            if case .otpUserExcepted = signature {
                validationDTO.otpExcepted = true
                convertedResponse = .success(validationDTO)
            }
        }
        return convertedResponse
    }
    
    func validateDeferredTransferOTP(signature: SignatureRepresentable, dataToken: String) throws -> Result<OTPValidationRepresentable, Error> {
        guard let signatureDTO = signature as? SignatureDTO
        else { return .failure(RepositoryError.unknown) }
        let response = try bsanTransferManager.validateDeferredTransferOTP(signatureDTO: signatureDTO, dataToken: dataToken)
        var convertedResponse: Result<OTPValidationRepresentable, Error> = try BSANResponseConverter.convert(response: response)
        guard var validationDTO = try? response.getResponseData() else { return convertedResponse }
        if validationDTO.otpExcepted {
            return .success(validationDTO)
        } else if case .failure(let error) = convertedResponse,
                  let error = error as? RepositoryError,
                  case .errorWithCode(let error) = error
        {
            let error = error as NSError
            let signature = try self.processSendMoneySignatureResult(error)
            if case .otpUserExcepted = signature {
                validationDTO.otpExcepted = true
                convertedResponse = .success(validationDTO)
            }
        }
        return convertedResponse
    }
    
    func validateOtpNoSepa(input: SendMoneyNoSEPAInput, validationIntNoSepa: ValidationIntNoSepaRepresentable, signature: SignatureRepresentable) throws -> Result<OTPValidationRepresentable, Error> {
        guard let noSepaTransferInput = self.getNoSepaTransferInput(noSepaTransferInput: input),
              var validationIntNoSepaDTO = validationIntNoSepa as? ValidationIntNoSepaDTO,
              let signatureDTO = signature as? SignatureDTO
        else {
            return .failure(RepositoryError.unknown)
        }
        validationIntNoSepaDTO.signature = signatureDTO
        let response = try bsanTransferManager.validationOTPIntNoSEPA(validationIntNoSepaDTO: validationIntNoSepaDTO, noSepaTransferInput: noSepaTransferInput)
        var convertedResponse: Result<OTPValidationRepresentable, Error> = try BSANResponseConverter.convert(response: response)
        guard var validationDTO = try? response.getResponseData() else { return convertedResponse }
        if validationDTO.otpExcepted {
            return .success(validationDTO)
        } else if case .failure(let error) = convertedResponse,
           let error = error as? RepositoryError,
           case .errorWithCode(let error) = error
        {
            let error = error as NSError
            let signature = try self.processSendMoneySignatureResult(error)
            if case .otpUserExcepted = signature {
                validationDTO.otpExcepted = true
                convertedResponse = .success(validationDTO)
            }
        }
        return convertedResponse
    }
    
    // Confirm transfer
    
    func confirmGenericTransfer(originAccount: AccountRepresentable, nationalTransferInput: SendMoneyGenericTransferInput, otpValidation: OTPValidationRepresentable?, otpCode: String?) throws -> Result<TransferConfirmAccountRepresentable, Error> {
        fatalError("Spain should inject use case to call is spain library the confirmGenericTransfer but with the trusteerInfo param")
    }
    
    func confirmGenericTransfer(originAccount: AccountRepresentable, nationalTransferInput: SendMoneyGenericTransferInput, otpValidation: OTPValidationRepresentable?, otpCode: String?, trusteerInfo: TrusteerInfoRepresentable?) throws -> Result<TransferConfirmAccountRepresentable, Error> {
        guard let originAccountdto = originAccount as? AccountDTO,
              let otpValidationDto = otpValidation as? OTPValidationDTO,
              let ibanRepresentable = nationalTransferInput.ibanRepresentable,
              let amountRepresentable = nationalTransferInput.amountRepresentable
        else { return .failure(RepositoryError.unknown)}
        
        let nationalTransferInputdto = GenericTransferInputDTO(beneficiary: nationalTransferInput.beneficiary,
                                                               isSpanishResident: true,
                                                               ibanRepresentable: ibanRepresentable,
                                                               saveAsUsual: nationalTransferInput.saveAsUsual,
                                                               saveAsUsualAlias: nationalTransferInput.saveAsUsualAlias,
                                                               beneficiaryMail: nationalTransferInput.beneficiaryMail,
                                                               amountRepresentable: amountRepresentable,
                                                               concept: nationalTransferInput.concept,
                                                               transferType: self.transferTypeDTOFromString(nationalTransferInput.transferType),
                                                               tokenPush: nil)
        let trusteerInfoDto = trusteerInfo as? TrusteerInfoDTO
        let response = try bsanTransferManager.confirmGenericTransfer(originAccountDTO: originAccountdto, nationalTransferInput: nationalTransferInputdto, otpValidationDTO: otpValidationDto, otpCode: otpCode, trusteerInfo: trusteerInfoDto)
        let result: Result<TransferConfirmAccountRepresentable, Error> = try BSANResponseConverter.convert(response: response)
        return result
    }
    
    func confirmPeriodicTransfer(originAccount: AccountRepresentable, scheduledTransferInput: SendMoneyScheduledTransferInput, otpValidation: OTPValidationRepresentable, otpCode: String) throws -> Result<Void, Error> {
        guard let accountDto = originAccount as? AccountDTO,
              let scheduledTransferInputImpl = self.getScheduledTransferInput(from: scheduledTransferInput),
              let otpValidationDto = otpValidation as? OTPValidationDTO
        else { return .failure(RepositoryError.unknown) }
        let response = try bsanTransferManager.confirmScheduledTransfer(originAccountDTO: accountDto,
                                                                        scheduledTransferInput: scheduledTransferInputImpl,
                                                                        otpValidationDTO: otpValidationDto,
                                                                        otpCode: otpCode)
        if response.isSuccess() {
            return .success(())
        } else {
            let convertedResponse: Result<Void, Error> = try BSANResponseConverter.convert(response: response)
            return convertedResponse
        }
    }
    
    func confirmDeferredTransfer(originAccount: AccountRepresentable, scheduledTransferInput: SendMoneyScheduledTransferInput, otpValidation: OTPValidationRepresentable, otpCode: String) -> Result<Void, Error> {
        fatalError("Spain should inject use case to call is spain library the confirmDeferredTransfer but with the trusteerInfo param")
    }
    
    func confirmDeferredTransfer(originAccount: AccountRepresentable, scheduledTransferInput: SendMoneyScheduledTransferInput, otpValidation: OTPValidationRepresentable, otpCode: String, trusteerInfo: TrusteerInfoRepresentable?) throws -> Result<Void, Error> {
        guard let accountDto = originAccount as? AccountDTO,
              let scheduledTransferInputImpl = self.getScheduledTransferInput(from: scheduledTransferInput),
              let otpValidationDto = otpValidation as? OTPValidationDTO
        else { return .failure(RepositoryError.unknown)}
        let trusteerInfoDto = trusteerInfo as? TrusteerInfoDTO
        let response = try bsanTransferManager.confirmDeferredTransfer(originAccountDTO: accountDto,
                                                                       scheduledTransferInput: scheduledTransferInputImpl,
                                                                       otpValidationDTO: otpValidationDto,
                                                                       otpCode: otpCode,
                                                                       trusteerInfo: trusteerInfoDto)
        let convertedResponse: Result<Void, Error> = try BSANResponseConverter.convert(response: response)
        return convertedResponse
    }
    
    func confirmSendMoneyNoSepa(input: ConfirmSendMoneyNoSepaInputRepresentable) throws -> Result<ConfirmationNoSepaRepresentable, Error> {
        guard let spInput = input as? SPConfirmSendMoneyNoSepaUseCaseInput,
              let validationIntNoSepaDTO = spInput.validationNoSepa as? ValidationIntNoSepaDTO,
              let validationSwiftDTO = spInput.validationSwift as? ValidationSwiftDTO?,
              let noSepaTransferInput = self.getNoSepaTransferInput(noSepaTransferInput: spInput.noSepaTransferInput),
              let otpValidationDTO = spInput.otpValidation as? OTPValidationDTO,
              let trusteerInfoDTO = spInput.trusteerInfo as? TrusteerInfoDTO
        else { return .failure(RepositoryError.unknown) }
        let response = try bsanTransferManager.confirmationIntNoSEPA(
            validationIntNoSepaDTO: validationIntNoSepaDTO,
            validationSwiftDTO: validationSwiftDTO,
            noSepaTransferInput: noSepaTransferInput,
            otpValidationDTO: otpValidationDTO,
            otpCode: spInput.otpCode,
            countryCode: spInput.countryCode,
            aliasPayee: spInput.aliasPayee,
            isNewPayee: spInput.isNewPayee,
            trusteerInfo: trusteerInfoDTO)
        let convertedResponse: Result<ConfirmationNoSepaRepresentable, Error> = try BSANResponseConverter.convert(response: response)
        return convertedResponse
    }

    // Retrieve transfers
    
    func getTransferDetail(transfer: TransferRepresentable) throws -> Result<TransferRepresentable, Error> {
        guard let transferEmittedDTO = transfer as? TransferEmittedDTO else { return .failure(RepositoryError.unknown) }
        let response = try bsanTransferManager.getEmittedTransferDetail(transferEmittedDTO: transferEmittedDTO)
        let convertedResponse: Result<TransferRepresentable, Error> = try BSANResponseConverter.convert(response: response)
        return convertedResponse
    }
    
    func getNoSepaTransferDetail(transfer: TransferRepresentable) throws -> Result<NoSepaTransferRepresentable, Error> {
        guard let transferEmittedDTO = transfer as? TransferEmittedDTO else { return .failure(RepositoryError.unknown)}
        let response = try bsanTransferManager.loadEmittedNoSepaTransferDetail(transferEmittedDTO: transferEmittedDTO)
        let convertedResponse: Result<NoSepaTransferRepresentable, Error> = try BSANResponseConverter.convert(response: response)
        return convertedResponse
    }
    
    func processSignatureResult(_ response: Any) throws -> SignatureResultEntity {
        guard let bSANResponse = response as? BSANResponse<Any> else {
            return SignatureResultEntity.otherError
        }
        if bSANResponse.isSuccess() {
            return SignatureResultEntity.ok
        } else if try bSANResponse.getErrorCode() == BSANSoapResponse.RESULT_OTP_EXCEPTED_USER {
            return SignatureResultEntity.otpUserExcepted
        } else {
            guard let errorMessage = try bSANResponse.getErrorMessage() else {
                return SignatureResultEntity.otherError
            }
            let uppercaseInsensitiveErrorMessage = errorMessage.uppercased().deleteAccent()
            if uppercaseInsensitiveErrorMessage.contains("REVOCADA")
                || uppercaseInsensitiveErrorMessage.starts(with: "SU CLAVE DE FIRMA HA SIDO REVOCADA")
                || uppercaseInsensitiveErrorMessage.starts(with: "ERROR FIRMA. FIRMA REVOCADA")
                || uppercaseInsensitiveErrorMessage.starts(with: "SIGBRO_00004")
                || uppercaseInsensitiveErrorMessage.contains("50201004")
                || uppercaseInsensitiveErrorMessage.contains("GESOTP_00009003") {
                return SignatureResultEntity.revoked
            } else if uppercaseInsensitiveErrorMessage.contains("INVALIDO")
                        || uppercaseInsensitiveErrorMessage.contains("ERRONEA")
                        || uppercaseInsensitiveErrorMessage.starts(with: "LOS VALORES DE LA FIRMA POR POSICIONES NO SON CORRECTOS")
                        || uppercaseInsensitiveErrorMessage.starts(with: "ERROR FIRMA. DATOS INVALIDOS")
                        || uppercaseInsensitiveErrorMessage.starts(with: "LA CLAVE INTRODUCIDA ES ERRONEA")
                        || uppercaseInsensitiveErrorMessage.starts(with: "LA CLAVE DE FIRMA INTRODUCIDA ES ERRONEA")
                        || uppercaseInsensitiveErrorMessage.starts(with: "FIRMA POR POSICIONES INCORRECTA")
                        || uppercaseInsensitiveErrorMessage.starts(with: "SIGBRO_00003")
                        || uppercaseInsensitiveErrorMessage.contains("50201001")
                        || uppercaseInsensitiveErrorMessage.contains("GESOTP_00009000") {
                return SignatureResultEntity.invalid
            }
        }
        
        return SignatureResultEntity.otherError
    }
    
    func processSendMoneySignatureResult(_ error: Any) throws -> SignatureResultEntity {
        guard let error = error as? NSError else {
            return SignatureResultEntity.otherError
        }
        if error.errorCode == BSANSoapResponse.RESULT_OTP_EXCEPTED_USER {
            return SignatureResultEntity.otpUserExcepted
        } else {
            let uppercaseInsensitiveErrorMessage = error.localizedDescription.uppercased().deleteAccent()
            if uppercaseInsensitiveErrorMessage.contains("REVOCADA")
                || uppercaseInsensitiveErrorMessage.starts(with: "SU CLAVE DE FIRMA HA SIDO REVOCADA")
                || uppercaseInsensitiveErrorMessage.starts(with: "ERROR FIRMA. FIRMA REVOCADA")
                || uppercaseInsensitiveErrorMessage.starts(with: "SIGBRO_00004")
                || uppercaseInsensitiveErrorMessage.contains("50201004")
                || uppercaseInsensitiveErrorMessage.contains("GESOTP_00009003") {
                return SignatureResultEntity.revoked
            } else if uppercaseInsensitiveErrorMessage.contains("INVALIDO")
                        || uppercaseInsensitiveErrorMessage.contains("ERRONEA")
                        || uppercaseInsensitiveErrorMessage.starts(with: "LOS VALORES DE LA FIRMA POR POSICIONES NO SON CORRECTOS")
                        || uppercaseInsensitiveErrorMessage.starts(with: "ERROR FIRMA. DATOS INVALIDOS")
                        || uppercaseInsensitiveErrorMessage.starts(with: "LA CLAVE INTRODUCIDA ES ERRONEA")
                        || uppercaseInsensitiveErrorMessage.starts(with: "LA CLAVE DE FIRMA INTRODUCIDA ES ERRONEA")
                        || uppercaseInsensitiveErrorMessage.starts(with: "FIRMA POR POSICIONES INCORRECTA")
                        || uppercaseInsensitiveErrorMessage.starts(with: "SIGBRO_00003")
                        || uppercaseInsensitiveErrorMessage.contains("50201001")
                        || uppercaseInsensitiveErrorMessage.contains("GESOTP_00009000") {
                return SignatureResultEntity.invalid
            }
            return SignatureResultEntity.otherError
        }
    }
    
    func checkEntityAdhered(genericTransferInput: SendMoneyGenericTransferInput) throws -> Result<Void, Error> {
        guard let ibanRepresentable = genericTransferInput.ibanRepresentable,
              let amountRepresentable = genericTransferInput.amountRepresentable
        else { return .failure(RepositoryError.unknown) }
        let input = GenericTransferInputDTO(beneficiary: genericTransferInput.beneficiary,
                                            isSpanishResident: true,
                                            ibanRepresentable: ibanRepresentable,
                                            saveAsUsual: genericTransferInput.saveAsUsual,
                                            saveAsUsualAlias: genericTransferInput.saveAsUsualAlias,
                                            beneficiaryMail: genericTransferInput.beneficiaryMail,
                                            amountRepresentable: amountRepresentable,
                                            concept: genericTransferInput.concept,
                                            transferType: self.transferTypeDTOFromString(genericTransferInput.transferType),
                                            tokenPush: nil)
        let response = try bsanTransferManager.checkEntityAdhered(genericTransferInput: input)
        let convertedResponse: Result<Void, Error> = try BSANResponseConverter.convert(response: response)
        return convertedResponse
    }
    
    func checkTransferStatus(reference: ReferenceRepresentable) throws -> Result<CheckTransferStatusRepresentable, Error> {
        guard let referenceDTO = reference as? ReferenceDTO else {
            return .failure(RepositoryError.unknown)
        }
        let response = try bsanTransferManager.checkTransferStatus(referenceDTO: referenceDTO)
        let convertedResponse: Result<CheckTransferStatusRepresentable, Error> = try BSANResponseConverter.convert(response: response)
        return convertedResponse
    }
    
    func loadAllUsualTransfers() -> AnyPublisher<[PayeeRepresentable], Error> {
        return Future { promise in
            do {
                let response = try bsanTransferManager.loadAllUsualTransfers()
                let convertedResponse: Result<[PayeeRepresentable], Error> = try BSANResponseConverter.convert(response: response)
                promise(convertedResponse)
            } catch let error {
                promise(.failure(error))
            }
        }
        .eraseToAnyPublisher()
    }
    
    func noSepaPayeeDetail(of alias: String, recipientType: String) -> AnyPublisher<NoSepaPayeeDetailRepresentable, Error> {
        return Future { promise in
            do {
                let response = try bsanTransferManager.noSepaPayeeDetail(of: alias, recipientType: recipientType)
                let convertedResponse: Result<NoSepaPayeeDetailRepresentable, Error> = try BSANResponseConverter.convert(response: response)
                promise(convertedResponse)
            } catch let error {
                promise(.failure(error))
            }
        }
        .eraseToAnyPublisher()
    }
    
    func loadEmittedTransfers(
        account: AccountRepresentable,
        amountFrom: AmountRepresentable?,
        amountTo: AmountRepresentable?,
        dateFilter: DateFilter,
        pagination: PaginationRepresentable?
    ) -> AnyPublisher<TransferListResponse, Error> {
        return Future { promise in
            promise(transferListDataSource.loadEmittedTransfers(
                account: account,
                amountFrom: amountFrom,
                amountTo: amountTo,
                dateFilter: dateFilter,
                pagination: pagination
            ))
        }
        .eraseToAnyPublisher()
    }
    
    func getAccountTransactions(
        forAccount account: AccountRepresentable,
        pagination: PaginationRepresentable?,
        filter: AccountTransferFilterInput
    ) -> AnyPublisher<TransferListResponse, Error> {
        return Future { promise in
            do {
                let response = try bsanTransferManager.getAccountTransactions(
                    forAccount: account,
                    pagination: pagination,
                    filter: filter
                )
                let convertedResponse: Result<AccountTransactionsListDTO, Error> = try BSANResponseConverter.convert(response: response)
                switch convertedResponse {
                case .success(let dto):
                    let pagination = dto.pagination.endList ? nil: pagination
                    promise(.success(TransferListResponse(
                        transactions: dto.transactionDTOs,
                        pagination: pagination
                    )))
                case .failure(let error):
                    promise(.failure(error))
                }
            } catch let error {
                promise(.failure(error))
            }
        }
        .eraseToAnyPublisher()
        
    }
    
    func getNoSepaPayeeDetail(alias: String, recipientType: String) throws -> Result<SPNoSepaPayeeDetailRepresentable, Error> {
        let response = try bsanTransferManager.noSepaPayeeDetail(of: alias, recipientType: recipientType)
        let convertedResponse: Result<SPNoSepaPayeeDetailRepresentable, Error> = try BSANResponseConverter.convert(response: response)
        return convertedResponse
    }
    
    func getNoSepaFees() throws -> Result<Data?, Error> {
        struct NoSepaFeesPdfRequest: NetworkRequest {
            var method: String = "GET"
            var serviceName: String = ""
            var url: String = "https://infoproductos.bancosantander.es/cssa/StaticBS?blobcol=urldata&blobheadername1=content-type&blobheadername2=Content-Disposition&blobheadervalue1=application%2Fpdf&blobheadervalue2=inline%3B+filename%3Dtransferencias_exterior.pdf&blobkey=id&blobtable=MungoBlobs&blobwhere=1320599239338&cachecontrol=immediate&ssbinary=true&maxage=3600"
            
            var headers: [String: String] = [:]
            var body: String = ""
        }
        let response = try self.networkManager.request(NoSepaFeesPdfRequest(), requestInterceptors: [], responseInterceptors: [])
        let data: Result<Data?, Error> = response.map { response in
            response.data
        }
        return data
    }
}

extension TrusteerInfoDTO: TrusteerInfoRepresentable { }

private extension TransfersRepository {
    func transferTypeDTOFromString(_ string: String?) -> TransferTypeDTO {
        switch string {
        case "S": return .NATIONAL_URGENT_TRANSFER
        case "I": return .NATIONAL_INSTANT_TRANSFER
        default: return .USUAL_TRANSFER
        }
    }

    func expensesTypeDTOFromString(_ string: String?) -> ExpensesType? {
        return ExpensesType.parse(string)
    }
    
    func scheduledDayDTOFromString(_ string: String?) -> ScheduledDayDTO? {
        guard let string = string else { return nil }
        return ScheduledDayDTO(rawValue: string)
    }
    
    func periodicalTypeDTOFromString(_ string: String?) -> PeriodicalTypeTransferDTO? {
        guard let string = string else { return nil }
        return PeriodicalTypeTransferDTO(rawValue: string)
    }
    
    func getScheduledTransferInput(from scheduledTransferInput: SendMoneyScheduledTransferInput) -> ScheduledTransferInput? {
        guard let iban = scheduledTransferInput.ibanDestinationRepresentable,
              let amount = scheduledTransferInput.amountRepresentable
        else { return nil }
        var dateStartValidity: DateModel?
        if let date = scheduledTransferInput.dateStartValidity {
            dateStartValidity = DateModel(date: date)
        }
        var dateEndValidity: DateModel?
        if let date = scheduledTransferInput.dateEndValidity {
            dateEndValidity = DateModel(date: date)
        }
        var dateNextExecution: DateModel?
        if let date = scheduledTransferInput.dateNextExecution {
            dateNextExecution = DateModel(date: date)
        }
        let ibanDTO = IBANDTO(countryCode: iban.countryCode, checkDigits: iban.checkDigits, codBban: iban.codBban)
        return ScheduledTransferInput(dateStartValidity: dateStartValidity,
                                      dateEndValidity: dateEndValidity,
                                      scheduledDayType: self.scheduledDayDTOFromString(scheduledTransferInput.workingDayIssue),
                                      periodicalType: self.periodicalTypeDTOFromString(scheduledTransferInput.periodicity),
                                      indicatorResidence: true,
                                      concept: scheduledTransferInput.concept,
                                      dateNextExecution: dateNextExecution,
                                      currency: scheduledTransferInput.amountRepresentable?.currencyRepresentable?.currencyName,
                                      nameBankIbanBeneficiary: scheduledTransferInput.nameBankIbanBeneficiary,
                                      actuanteCompany: scheduledTransferInput.actuanteCompany,
                                      actuanteCode: scheduledTransferInput.actuanteCode,
                                      actuanteNumber: scheduledTransferInput.actuanteNumber,
                                      ibanDestination: ibanDTO,
                                      saveAsUsual: scheduledTransferInput.saveAsUsual,
                                      saveAsUsualAlias: scheduledTransferInput.saveAsUsualAlias,
                                      beneficiary: scheduledTransferInput.beneficiary,
                                      transferAmount: amount,
                                      company: nil,
                                      subType: self.transferTypeDTOFromString(scheduledTransferInput.transferType))
    }
    
    func getNoSepaTransferInput(noSepaTransferInput: SendMoneyNoSEPAInput) -> NoSEPATransferInput? {
        guard let accountDto = noSepaTransferInput.originAccountRepresentable as? AccountDTO,
              let amountValue = noSepaTransferInput.transferAmount.value,
              let currencyRepresentable = noSepaTransferInput.transferAmount.currencyRepresentable,
              let expensesType = self.expensesTypeDTOFromString(noSepaTransferInput.expensiveIndicator)
        else { return nil }
        let amountDto = AmountDTO(value: amountValue,
                                  currency: CurrencyDTO(currencyName: currencyRepresentable.currencyName,
                                                        currencyType: currencyRepresentable.currencyType))
        let internationalAccountDto: InternationalAccountDTO
        if let beneficiaryAccountSwift = noSepaTransferInput.beneficiaryAccountSwift, !beneficiaryAccountSwift.isEmpty {
            internationalAccountDto = InternationalAccountDTO(swift: beneficiaryAccountSwift, account: noSepaTransferInput.beneficiaryAccount)
        } else {
            let bankData = BankDataDTO(name: noSepaTransferInput.beneficiaryAccountBankName,
                                       address: noSepaTransferInput.beneficiaryAccountBankAddress,
                                       location: noSepaTransferInput.beneficiaryAccountBankLocation,
                                       country: noSepaTransferInput.beneficiaryAccountBankCountry)
            internationalAccountDto = InternationalAccountDTO(bankData: bankData, account: noSepaTransferInput.beneficiaryAccount)
        }
        let addressDto = AddressDTO(country: noSepaTransferInput.beneficiaryAccountCountry,
                                    address: noSepaTransferInput.beneficiaryAccountAddress,
                                    locality: noSepaTransferInput.beneficiaryAccountLocality)
        return NoSEPATransferInput(originAccountDTO: accountDto,
                                        beneficiary: noSepaTransferInput.beneficiary,
                                        beneficiaryAccount: internationalAccountDto,
                                        beneficiaryAddress: addressDto,
                                        indicatorResidence: noSepaTransferInput.indicatorResidence,
                                        dateOperation: noSepaTransferInput.dateOperation,
                                        transferAmount: amountDto,
                                        expensiveIndicator: expensesType,
                                        type: self.transferTypeDTOFromString(noSepaTransferInput.type),
                                        countryCode: noSepaTransferInput.countryCode,
                                        concept: noSepaTransferInput.concept ?? "",
                                        beneficiaryEmail: noSepaTransferInput.beneficiaryEmail)
    }
}
