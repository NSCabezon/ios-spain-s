import Foundation
import SanLibraryV3

public enum LOGIN_USER: String {
    case SIGNATURE_LOGIN = "30093767S"; //RODRIGO LUIS
    case MOBILE_RECHARGE_LOGIN = "87070155K";
    case DEPOSITS_LOGIN = "00511995S";  //PARA DEPOSITS_LOGIN Y CARDS_LOGIN_EASYPAY
    case STOCKS_BUY = "00282196D";
    case STOCKS_PAGINATION_LOGIN = "00010244D";
    case ACCOUNTS_LOGIN = "41853185Q";  //ANGEL DARIO
    case eva = "22224444G";
    case sabin = "11907980Y";
    case LOANS_LOGIN = "02816068V";     //CARLOS IGNACIO
    case PORTFOLIOS_LOGIN = "50438581H";
    case FUNDS_LOGIN = "38412689K";
    case PENSIONS_LOGIN = "31411817G";
    case INSURANCES_LOGIN = "30638818N";
    case DEPOSITS_PAGINATION_LOGIN = "00010267D";
    case PB_USER = "15838866p";         //LUIS JOSE ANTON
    case CAMPAIGNS_USER = "53441297S"
    case iñaki = "31171180Q"
    case EASY_PAY = "32273582M"
    case RICHARD = "77340126G"
    case mixedUser = "14957860V"        //MARIA DE LA PIMPOLLO
    case superSpeedCardServiceUser = "11907980y"    //MARIA DE LA PIMPOLLO
    case superSpeedCardServiceUser2 = "10739838B"   //EXCEPTUADO OTP
    case superSpeedCardServiceUser3 = "26124L"   //EXCEPTUADO OTP
    case impositionsUser = "71445650Z"
    case erradi = "00062830V";
    case NO_SEPA_NO_EXCEPTUADO_NEW_TRANSFER = "14221344F"
    case NO_SEPA_EXCEPTUADO_NEW_TRANSFER = "03566238L"
    case BILLS_LOGIN = "25405810X"
    case USUAL_TRANSFER = "62830V"
    case PENDING_SOLICITUDE = "98337179N"
    case WITHHOLDING_LIST = "00063891C"
    case SCA = "94925045C" // F - 128242644 , F - 128236325 , N - 94925045C , N - 46548067T
    case FEATURE_BILL = "00054118E"
    case TIMELINE = "15949588P"
    case ONE_PLAN = "13641204L"
    case LAST_LOGON = "15050476N"
    case BIZUM = "00065130V"
    case BIZUM_CONTACTS = "85700022K"
    case BIZUM_HISTORIC = "12835999K"
    case SETTLEMENT_CARDS = "00060446W"
    case CARD_MAP_TRANSACTIONS = "50833213Q"
    case AVIOS = "04587309M"
    case raul = "00016546D"
    case NEW_FEES = "72367457G"
    case SUBSCRIPTIONS_CARDS = "55115408W"
    case SUBSCRIPTIONS_M4M = "61563767N"

    var isPb: Bool {
        switch self {
        case .sabin,
             .PORTFOLIOS_LOGIN:
            return true
        case .SETTLEMENT_CARDS,
             .SCA,
             .ACCOUNTS_LOGIN,
             .INSURANCES_LOGIN,
             .CAMPAIGNS_USER,
             .erradi,
             .eva,
             .iñaki,
             .DEPOSITS_LOGIN,
             .PENDING_SOLICITUDE,
             .ONE_PLAN,
             .AVIOS,
             .raul,
             .superSpeedCardServiceUser2:
            return false
        default:
            return false
        }
    }
}

public enum TestUtils: String {
    case CARD_BLOCK_TEXT = "Mi tarjeta esta deteriorada"
    
    case STOCK_QUOTES_SEARCH = "SANTANDER";
    
    static func fillSignature(input: inout SignatureDTO?){
        if input == nil{
            input = SignatureDTO(length: 4, positions: [1, 2, 3, 4])
        }
        
        if let lenght = input!.length,
            let positions = input!.positions{
            if lenght > 0{
                input!.values = [String]()
                for _ in 0 ... positions.count-1{
                    input!.values!.append("2")
                }
            }
        }
    }
    
    static func fillSignature(input: inout SignatureWithTokenDTO?){
        if input == nil{
            input = SignatureWithTokenDTO(signatureDTO: SignatureDTO(length: 4, positions: [1, 2, 3, 4]), token: "patata")
        }
        
        if var signature = input?.signatureDTO {
            if let lenght = signature.length,
                let positions = signature.positions{
                if lenght > 0{
                    signature.values = [String]()
                    for _ in 0 ... positions.count-1{
                        signature.values?.append("2")
                    }
                    input?.signatureDTO = signature
                }
            }
        }
    }
    
    static func getStockLimitedOperationInputData() -> StockLimitedOperationInput{
        return StockLimitedOperationInput(maxExchange: FieldsUtils.amountDTO, tradesShare: "50", limitedDate: Date())
    }
    
    static func getStockTypeOrderOperationInputData(type: String) -> StockTypeOrderOperationInput{
        return StockTypeOrderOperationInput(stockTradingType: type, tradesShare: "50", limitedDate: Date())
    }
    
    static func getNationalTransferInputData() -> GenericTransferInputDTO{
        return GenericTransferInputDTO(beneficiary: "Carlos",
                                       isSpanishResident: true,
                                       ibandto: IBANDTO(countryCode: "ES", checkDigits: "91", codBban: "21001010541472583691"),
                                       saveAsUsual: true,
                                       saveAsUsualAlias: "Carlos",
                                       beneficiaryMail: "carlos.perez@ciberexperis.es",
                                       amountDTO: FieldsUtils.amountDTO,
                                       concept: "Transferencia nacional",
                                       transferType: TransferTypeDTO.NATIONAL_TRANSFER)
    }
    
    static func getInstantTransferInputData() -> GenericTransferInputDTO{
        return GenericTransferInputDTO(beneficiary: "Carlos",
                                       isSpanishResident: true,
                                       ibandto: IBANDTO(countryCode: "ES", checkDigits: "91", codBban: "21001010541472583691"),
                                       saveAsUsual: true,
                                       saveAsUsualAlias: "Carlos",
                                       beneficiaryMail: "carlos.perez@ciberexperis.es",
                                       amountDTO: FieldsUtils.amountDTO,
                                       concept: "Transferencia inmediata",
                                       transferType: TransferTypeDTO.NATIONAL_INSTANT_TRANSFER)
    }
    
    static func getAccountTransferInputData() -> AccountTransferInput{
        return AccountTransferInput(amountDTO: FieldsUtils.amountDTO, concept: "Transferencia entre cuentas")
    }
    
    static func getUsualTransferInputData() -> UsualTransferInput{
        return UsualTransferInput(amountDTO: FieldsUtils.amountDTO, concept: "Transferencia entre cuentas", beneficiaryMail: "carlos.perez@ciberexperis.es", transferType: TransferTypeDTO.USUAL_TRANSFER)
    }
    
    static func getModifyScheduledTransferInputData() -> ModifyScheduledTransferInput{
        
        let dateFrom = Calendar.current.date(byAdding: .month, value: +2, to: Date())
        let dateTo = Calendar.current.date(byAdding: .month, value: +1, to: Date())
        
        return ModifyScheduledTransferInput(beneficiaryIBAN: IBANDTO(countryCode: "ES", checkDigits: "17", codBban: "20852066623456789011"),
                                            nextExecutionDate: DateModel(date: dateFrom ?? Date()),
                                            amount: FieldsUtils.amountDTO,
                                            concept: "test",
                                            beneficiary: "Roberto Gomez",
                                            transferOperationType: TransferOperationType.NATIONAL_SEPA,
                                            startDateValidity:DateModel(date: dateFrom ?? Date()),
                                            endDateValidity:DateModel(date: dateTo ?? Date()),
                                            periodicalType: PeriodicalTypeTransferDTO.semiannual,
                                            scheduledDayType: ScheduledDayDTO.previous_day)
    }
    
    static func getNoSEPATransferInput(originAccount: AccountDTO) -> NoSEPATransferInput {
        let dateFrom = Calendar.current.date(byAdding: .month, value: 0, to: Date())
        
        return NoSEPATransferInput(originAccountDTO: originAccount,
                                   beneficiary: "Ruben Arranz",
                                   beneficiaryAccount: InternationalAccountDTO(swift: "ROYCCAT2XXX", account: "400808595")/*InternationalAccountDTO(bankData: BankDataDTO(name: "JP MORGAN CHASE BANK, N.A.", address: nil, location: nil, country: nil), account: "400808595")*/,
            beneficiaryAddress: AddressDTO(country: "Brasil", address: "Avda Winston Smith, 33", locality: "Chicago"),
            indicatorResidence: false,
            dateOperation: DateModel(date: dateFrom ?? Date()),
            transferAmount: FieldsUtils.amountTransferDTO,
            expensiveIndicator: ExpensesType.shared,
            type: TransferTypeDTO.INTERNATIONAL_NO_SEPA_TRANSFER,
            countryCode: "US",
            concept: "",
            beneficiaryEmail: nil
        )
    }
    
    static func getValidationSwiftDTO() -> ValidationSwiftDTO {
        let dateFrom = Calendar.current.date(byAdding: .month, value: 0, to: Date())
        
        return ValidationSwiftDTO(settlementAmountPayer: FieldsUtils.amountTransferDTO,
                                  chargeAmount: FieldsUtils.amountTransferDTO,
                                  accountType: "C",
                                  modifyDate: dateFrom ?? Date(),
                                  beneficiaryBic: "ROYCCAT2XXX",
                                  swiftIndicator: false)
    }
    
}


