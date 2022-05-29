struct TrackerPagePrivate {
    
    struct Generic {
        enum Action: String {
            case error = "error"
            case help = "ayudanos_a_mejorar"
            case sms = "sms"
            case mail = "email"
            case share = "compartir"
            case swipe
            case search = "buscar"
            case ok = "ok"
            case seeOffer = "oferta_visualizacion"
            case inOffer = "oferta_accion"
            case pdf = "ver_pdf"
            case get_location = "obtener_localizacion"
        }
    }

    struct CustomerService {
        let page = "atencion_logado"
        let emmaToken: String
        
        init(customerServiceEventID: String) {
            self.emmaToken = customerServiceEventID
        }
    }

    struct YourExpenses {
        let page = "tus_gastos"
        enum Action: String {
            case moneyPlan = "acceso_money_plan"
        }
    }
    
    struct Menu {
        let page = "/private_sidebar"
    }

    struct GlobalPosition {
        let page = "/global_position"
        let emmaToken: String
        
        init(globalPositionEventID: String) {
            self.emmaToken = globalPositionEventID
        }
        enum Action: String {
            case accountsOpen = "unfold_account"
            case accountsClose = "fold_account"
            case cardsOpen = "unfold_card"
            case cardsClose = "fold_card"
            case stocksOpen = "unfold_share"
            case stocksClose = "fold_share"
            case fundsOpen = "unfold_fund"
            case fundsClose = "fold_fund"
            case depositsOpen = "unfold_deposit"
            case depositsClose = "fold_deposit"
            case plansOpen = "unfold_pension_plan"
            case plansClose = "fold_pension_plan"
            case loansOpen = "unfold_loan"
            case loansClose = "fold_loan"
            case insurancesSavingsOpen = "unfold_saving_insurance"
            case insurancesSavingsClose = "fold_saving_insurance"
            case insurancesOpen = "unfold_insurance"
            case insurancesClose = "fold_insurance"
            case secureDevice = "alert_different_secure_device"
        }
    }

    // MARK: - Accounts

    struct Accounts {
        let page = "/account"
        let emmaToken: String
        
        init(accountsEventID: String) {
            self.emmaToken = accountsEventID
        }
        enum Action: String {
            case copy = "copy_iban"
            case transfers = "click_transfer"
            case progress = "evolución_gasto"
            case receipt = "click_bill_tax"
            case detail = "detalle_cuenta"
        }
    }

    struct AccountDetail {
        let page = "/account/detail"
        enum Action: String {
            case copy = "copiar_IBAN"
        }
    }

    struct AccountTransactionDetail {
        let page = "/account/transaction_detail"
        enum Action: String {
            case transfer = "click_transfer_switch"
            case expenseDeposit = "gastos_e_ingresos"
            case pdf = "open_pdf"
            case easyPay = "click_easy_pay"
            case easyPayError = "easy_pay_error"
        }
    }

    struct AccountsSearch {
        let page = "cuentas_buscador"
        enum Action: String {
            case pdf = "ver_pdf"
        }
    }

    // MARK: - Cards

    struct Cards {
        let page = "tarjetas"
        let emmaToken: String
        
        init(cardsEventID: String) {
            self.emmaToken = cardsEventID
        }
        
        enum Action: String {
            case tooltip = "tooltip"
            case copyPan = "copiar_pan"
        }
    }
    
    struct CardsApplePay {
        let page = "tarjetas_pagar"
    }

    struct CardDetail {
        let page = "/card/detail"
        enum Action: String {
            case copy = "copy_pan"
            case modifyAlias = "change_alias"
        }
    }
    
    struct CardTransactionDetail {
        let page = "/card/transaction/detail"
        enum Action: String {
            case fraud = "report_fraud"
        }
    }

    struct CardsSearch {
        let page = "tarjetas_buscador"
        enum Action: String {
            case textSearch = "termino_busqueda"
        }
    }
    
    struct PayOffAmount {
        let page = "/card/deposit_in_card/amount"
    }
    
    struct PayOffConfirmation {
        let page = "/card/deposit_in_card/confirm"
    }
    
    struct PayOffSummary {
        let page = "/card/deposit_in_card/thankyou"
    }
    
    struct PayOffSignature {
        let page = "/card/deposit_in_card/signature"
    }
    
    struct CashWithdrawlCode {
        let page = "sacar_dinero_con_codigo"
    }
    
    struct CashWithdrawlCodeSignature {
        let page = "sacar_dinero_con_codigo_firma"
    }
    
    struct CashWithdrawlCodeOtp {
        let page = "sacar_dinero_con_codigo_otp"
    }
    
    struct CashWithdrawlCodeSummary {
        let page = "sacar_dinero_con_codigo_resumen"
    }
    
    struct DirectMoneyAmount {
        let page = "tarjetas_dinero_directo_importe"
    }
    
    struct DirectMoneyConfirmation {
        let page = "tarjetas_dinero_directo_confirmacion"
    }
    
    struct HistoricCashWithdrawlCodeSignature {
        let page = "sacar_dinero_con_codigo_historico_firma"
    }
    
    struct HistoricCashWithdrawlCode {
        let page = "sacar_dinero_con_codigo_historico"
    }
    
    struct HistoricCashWithdrawlCodeDetail {
        let page = "sacar_dinero_con_codigo_historico_detalle"
        
    }
    
    struct ActivateCardSignature {
        let page = "/card/activate/signature"
        enum Action: String {
            case error = "error_{step1_step2}"
        }
    }
    
    struct ActivateCardSummary {
        let page = "/card/activate/thankyou"
    }
    
    struct DirectMoneySignature {
        let page = "/card/instant_cash/signature"
        enum Action: String {
            case error = "error_{step1_step2}"
        }
    }
    
    struct DirectMoneySummary {
        let page = "/card/instant_cash/thankyou"
    }
    
    struct PayLater {
        let page = "tarjetas_pago_luego_importe"
    }
    
    struct PayLaterConfirmation {
        let page = "tarjetas_pago_luego_confirmacion"
    }
    
    struct PayLaterSummary {
        let page = "tarjetas_pago_luego_resumen"
    }
    
    struct EasyPay {
        let page = "tarjetas_pago_facil_cuotas"
    }
    
    struct EasyPayConfirmation {
        let page = "tarjetas_pago_facil_confirmacion"
    }
    
    struct EasyPaySummary {
        let page = "tarjetas_pago facil_resumen"
    }
    
    struct ChargeDischargeAccountSelection {
        let page = "tarjetas_carga_descarga_cuenta_a_operar"
    }
    
    struct CardChargeSignature {
        let page = "tarjetas_carga_firma"
        enum Action: String {
            case error
        }
    }
    
    struct CardDischargeSignature {
        let page = "tarjetas_descarga_firma"
        enum Action: String {
            case error
        }
    }
    
    struct CardChargeOtp {
        let page = "tarjetas_carga_otp"
    }
    
    struct CardDischargeOtp {
        let page = "tarjetas_descarga_otp"
    }
    
    struct CardChargeSummary {
        let page = "tarjetas_carga_resumen"
    }
    
    struct CardDischargeSummary {
        let page = "tarjetas_descarga_resumen"
    }
    
    struct EasyPayEmptyMovementsList {
        let page = "tarjetas_pago facil_no_tienes_compras_para_financiar"
    }
    
    struct EasyPayMovementsList {
        let page = "tarjetas_pago facil_listado_conjunto_movimientos"
    }
    
    // MARK: - Cards charge
    
    struct CardsChargeConfirmation {
        let page = "tarjetas_carga_confirmacion"
        
    }
    
    struct CardsChargeDischargeAmount {
        let page = "tarjetas_carga_descarga_importe"
    }
    
    // MARK: - Cards discharge
    
    struct CardsDischargeConfirmation {
        let page = "tarjetas_descarga_confirmacion"
    }
    
    struct MobilCharge {
        let page = "recarga_movil_datos"
    }
    
    struct MobileRechargeConfirmation {
        let page = "recarga_movil_confirmacion"
    }
    
    struct MobileRechargeSignature {
        let page = "recarga_movil_firma"
    }
    
    struct MobileRechargeOtp {
        let page = "recarga_movil_otp"
    }
    
    struct MobileRechargeSummary {
        let page = "recarga_movil_resumen"
    }
    
    struct SignUpCes {
        let page = "alta_ces_telefono"
    }
    
    struct SignUpCesSignature {
        let page = "alta_ces_firma"
    }
    
    struct SignUpCesOtp {
        let page = "alta_ces_otp"
    }
    
    struct SignUpCesSummary {
        let page = "alta_ces_resumen"
    }

    // MARK: - PIN Query
    
    struct CardsPINQuerySignature {
        let page = "/card/view_pan/signature"
    }
    
    struct CardsPINQueryOtp {
        let page = "/card/view_pan/otp_signature"
    }
    
    struct CardsPINQuerySummary {
        let page = "/card/view_pan/thankyou"
    }
    
    // MARK: - CVV Query
    
    struct CardsCVVQuerySignature {
        let page = "/card/view_cvv/signature"
    }
    
    struct CardsCVVQueryOtp {
        let page = "/card/view_cvv/otp_signature"
    }
    
    struct CardsCVVQuerySummary {
        let page = "/card/view_cvv/thankyou"
    }
    
    // MARK: - Block card
    
    struct BlockCard {
        let page = "/card/block/reason"
    }
    
    struct BlockCardSignature {
        let page = "/card/block/signature"
    }
    
    struct BlockCardSummary {
        let page = "/card/block/thankyou"
    }
    
    // MARK: - Stocks

    struct Stocks {
        let page = "valores"
    }

    struct StocksSearch {
        let page = "buscar_valores"
    }

    struct StocksDetailValue {
        let page = "valores_detalle_valor"
    }

    struct StocksBuyTypeOrder {
        let page = "compra_de_valores_tipo_de_orden"
    }

    struct StocksBuyNumberTitles {
        let page = "compra_de_valores_numero_de_titulos"
    }

    struct StocksBuyLimitedLimite {
        let page = "compra_de_valores_limitada_limite"
    }

    struct StocksBuyValueValidity {
        let page = "compra_de_valores_plazo_de_validez"
    }

    struct StocksBuyConfirmation {
        let page = "compra_de_valores_confirmacion"
    }

    struct StocksBuyMifid {
        let page = "compra_de_valores_mifid"
    }

    struct StocksBuySign {
        let page = "compra_de_valores_firma"
        enum Action: String {
            case error
        }
    }

    struct StocksBuySummary {
        let page = "compra_de_valores_resumen"
        enum Action: String {
            case help = "ayudanos_a_mejorar"
            case sms = "sms"
            case email = "email"
            case share = "compartir"
        }
    }

    struct StocksSellTypeOrder {
        let page = "venta_de_valores_tipo_de_orden"
    }

    struct StocksSellNumberTitles {
        let page = "venta_de_valores_numero_de_titulos"
    }

    struct StocksSellLimitedLinmite {
        let page = "venta_de_valores_limitada_limite"
    }

    struct StocksSellValueValidity {
        let page = "venta_de_valores_plazo_de_validez"
    }

    struct StocksSellConfirmation {
        let page = "venta_de_valores_confirmacion"
    }

    struct StocksSellMidif {
        let page = "venta_de_valores_mifid"
    }

    struct StocksSellSign {
        let page = "venta_de_valores_firmar"
        enum Action: String {
            case error
        }
    }

    struct StocksSellSummary {
        let page = "venta_de_valores_resumen"
        enum Action: String {
            case help = "ayudanos_a_mejorar"
            case sms = "sms"
            case email = "email"
            case share = "compartir"
        }
    }

    // MARK: - Funds

    struct Funds {
        let page = "/fund"
    }

    struct FundsSearch {
        let page = "/fund/search"
    }

    struct FundsDetail {
        let page = "/fund/detail"
    }

    struct FundsDetailTransaction {
        let page = "/fund/transaction/detail"
        enum Action: String {
            case sms = "send_sms"
            case email = "send_email"
            case share = "share_information"
        }
    }
    
    struct FundSubscription {
        let page = "/fund/suscription"
    }
    
    struct FundSubscriptionMifid {
        let page = "fondos_suscripcion_mifid"
    }
    
    struct FundSubscriptionConfirmation {
        let page = "fondos_suscripcion_confirmacion"
    }
    
    struct FundSubscriptionSignature {
        let page = "fondos_suscripcion_firma"
    }
    
    struct FundSubscriptionSummary {
        let page = "fondos_suscripcion_resumen"
    }
    
    struct FundTransfer {
        let page = "fondos_traspaso_seleccion destino"
    }
    
    struct FundTransferType {
        let page = "fondos_traspaso_tipo_traspaso"
    }
    
    struct FundTransferConfirmation {
        let page = "fondos_traspaso_confirmacion"
    }
    
    struct FundTransferSignature {
        let page = "fondos_traspaso_firma"
    }
    
    struct FundTransferSummary {
        let page = "fondos_traspaso_resumen"
    }

    // MARK: - Insurance

    struct InsuranceSaving {
        let page = "seguros_ahorro"
    }

    struct Insurance {
        let page = "seguros"
    }

    // MARK: - Loans

    struct Loans {
        let page = "/loan"
        enum Action: String {
            case copy = "copy_contract"
        }
    }

    struct LoansSearch {
        let page = "/loan/loans_search"
    }

    struct LoansDetail {
        let page = "/loan/detail"
        enum Action: String {
            case copyAccount = "copy_associated_account"
            case copyContract = "copy_contract"
        }
    }

    struct LoandsDetailTransfer {
        let page = "/loan/detail/transaction"
        enum Action: String {
            case sms = "send_sms"
            case email = "send_email"
            case share = "share_information"
        }
    }
    
    struct LoanChangeAssotiatedAccount {
        let page = "prestamos_cambio_cuenta_asociada_seleccion_cuenta"
    }
    
    struct LoanChangeAssotiatedAccountConfirmation {
        let page = "prestamos_cambio_cuenta_asociada_confirmacion"
    }
    
    struct LoanChangeAssotiatedAccountSignature {
        let page = "prestamos_cambio_cuenta_asociada_firma"
    }
    
    struct LoanChangeAssotiatedAccountSummary {
        let page = "prestamos_cambio_cuenta_asociada_resumen"
    }

    // MARK: - Pension

    struct Pension {
        let page = "planes"
    }

    struct PensionsSearch {
        let page = "planes_buscador"
    }

    struct PensionDetail {
        let page = "planes_detalle"
        enum Action: String {
            case copyContract = "copiar_contrato"
        }
    }
    
    struct PensionExtraordinaryContribution {
        let page = "planes_aportacion_extraordinaria_importe"
    }
    
    struct PensionExtraordinaryContributionConfirmation {
        let page = "planes_aportacion_extraordinaria_confirmacion"
    }
    
    struct PensionExtraordinaryContributionSignature {
        let page = "planes_aportacion_extraordinaria_firma"
    }
    
    struct PensionExtraordinaryContributionSummary {
        let page = "planes_aportacion_extraordinaria_resumen"
    }
    
    struct PensionExtraordinaryContributionMifid {
        let page = "planes_aportacion_extraordinaria_mifid"
    }
    
    struct PensionPeriodicalContribution {
        let page = "planes_aportacion_periodica_importe"
    }
    
    struct PensionPeriodicalContributionConfirmation {
        let page = "planes_aportacion_periodica_confirmacion"
    }
    
    struct PensionPeriodicalContributionSignature {
        let page = "planes_aportacion_periodica_firma"
    }
    
    struct PensionPeriodicalContributionSummary {
        let page = "planes_aportacion_periodica_resumen"
    }

    // MARK: - Deposit

    struct Deposit {
        let page = "/deposit"
        enum Action: String {
            case copy = "copy_contract"
        }
    }

    struct DepositsImpositionsSearch {
        let page = "depositos_imposiciones_buscador"
    }

    struct DepositLiquidationSearch {
        let page = "depositos_liquidaciones_buscador"
    }

    struct DepositDetail {
        let page = "/deposit/detail"
        enum Action: String {
            case copy = "copy_contract"
        }
    }

    struct DepositImpositions {
        let page = "depositos_imposiciones"
    }

    struct DepositLiquidation {
        let page = "depositos_liquidaciones"
    }

    struct DepositImpositionDetail {
        let page = "depositos_detalle_imposicion"
    }

    struct DepositImpositionsTrasnferDetail {
        let page = "depositos_imposiciones_detalle_movimiento"
        enum Action: String {
            case sms = "sms"
            case email = "email"
            case share = "compartir"
        }
    }

    struct DepositLiquidationDetail {
        let page = "depositos_detalle_liquidacion"
        enum Action: String {
            case sms = "sms"
            case email = "email"
            case share = "compartir"
        }
    }

    // MARK: - Orders

    struct Orders {
        let page = "ordenes"
    }

    struct OrdersSearch {
        let page = "ordenes_buscador"
    }

    struct OrderDetail {
        let page = "detalle_de_orden"
        enum Action: String {
            case moreInfo = "mas_informacion"
        }
    }

    // MARK: - Tips

    struct Tips {
        let page = "consejos"
        enum Action: String {
            case selectAdvice = "seleccionar_consejo"
        }
    }

    // MARK: - Help improve

    struct HelpImprove {
        let page = "/private_menu/help_us_improve"
    }

    // MARK: - Contract

    struct Contract {
        let page = "contratar"
        enum Action: String {
            case selectProduct = "seleccionar_producto"
        }
    }

    struct ContractOffersForYou {
        let page = "contratar_ofertas_para_ti"
        enum Action: String {
            case selectCategory = "seleccionar_categoria"
            case selectOffer = "seleccionar_oferta"
        }
    }

    // MARK: - Personal area

    struct PersonalArea {
        let page = "/personal_area"
        let emmaToken: String
        
        init(personalAreaEventID: String) {
            self.emmaToken = personalAreaEventID
        }
        enum Action: String {
            case touchOn = "unlock_touchid"
            case touchOff = "lock_touchid"
            case widgetOn = "unlock_widget"
            case widgetOff = "lock_widget"
            case recovery = "recovery_debt"
        }
    }

    struct PersonalAreaUpdateAccessKey {
        let page = "area_personal_cambiar_clave_acceso_clave_actual"
        enum Action: String {
            case seePass = "ver_clave"
        }
    }

    struct PersonalAreaUpdateAccessKeyNewKey {
        let page = "area_personal_cambiar_clave_de_acceso_nueva_clave"
        enum Action: String {
            case seePass = "ver_clave"
            case error
            case ok
        }
    }

    struct PersonalAreaUpdateMultichannelSign {
        let page = "area_personal_seguridad_cambiar_firma_multicanal"
        enum Action: String {
            case error
        }
    }

    struct PersonalAreaUpdateSignMultichannelSign {
        let page = "area_personal_seguridad_cambiar_firma_multicanal_firma"
        enum Action: String {
            case ok
        }
    }

    struct PersonalAreaActivateMultichannelSign {
        let page = "area_personal_seguridad_activar_firma_multicanal"
        enum Action: String {
            case error
        }
    }

    struct PersonalAreaActivateSignMultichannelSign {
        let page = "area_personal_seguridad_activar_firma_multicanal_firma"
        enum Action: String {
            case ok
        }
    }

    struct PersonalAreaOptionsVisualizationPg {
        let page = "area_personal_opciones_visualizacion_pg"
        enum Action: String {
            case activateYourMoney = "tu_dinero_activar"
            case deactivateYourMoney = "tu_dinero_desactivar"
            case activatePersonalExpenses = "gastos_personales_activar"
            case deactivatePersonalExpenses = "gastos_personales_desactivar"
            case activateAccounts = "cuentas_activar"
            case deactivateAccounts = "cuentas_desactivar"
            case moveAccounts = "cuentas_mover"
            case activateCards = "tarjetas_activar"
            case deactivateCards = "tarjetas_desactivar"
            case movecards = "tarjetas_mover"
            case activateStocks = "valores_activar"
            case deactivateStocks = "valores_desactivar"
            case moveStocks = "valores_mover"
            case activateLoans = "prestamos_activar"
            case deactivateLoans = "prestamos_desactivar"
            case moveLoans = "prestamos_mover"
            case activateDeposits = "depositos_activar"
            case deactivateDeposits = "depositos_desactivar"
            case moveDeposits = "depositos_mover"
            case activatePensions = "planes_activar"
            case deactivatePensions = "planes_desactivar"
            case movePensions = "planes_mover"
            case activateFunds = "fondos_activar"
            case deactivateFunds = "fondos_desactivar"
            case moveFunds = "fondos_mover"
            case activateInsurances = "seguros_activar"
            case deactivateInsurances = "seguros_desactivar"
            case moveInsurances = "seguros_mover"
            case activateInsuranceSaving = "seguros_de_ahorro_activar"
            case deactivateInsuranceSaving = "seguros_de_ahorro_desactivar"
            case moveInsuranceSaving = "seguros_de_ahorro_mover"
        }
    }
    
    struct PersonalAreaSecurity {
        let page = "area_personal_seguridad"
        enum Action: String {
            case error
        }
    }
    
    struct GenericManager {
        let emmaToken: String
        
        init(managerEventID: String) {
            self.emmaToken = managerEventID
        }
    }

    struct YourManagerWithoutManager {
        let page = "tu_gestor_sin_gestores"
        enum Action: String {
            case sign = "date_de_alta"
        }
    }

    struct YourManagerOffice {
        let page = "tu_gestor_oficina"
        enum Action: String {
            case call = "llamar"
            case email = "email"
            case sign = "date_de_alta"
        }
    }

    struct YourPersonalManager {
        let page = "tu_gestor_personal"
        enum Action: String {
            case call = "llamar"
            case email = "email"
            case chat = "chat"
            case value = "valora_tu_gestor"
            case sign = "date_de_alta"
        }
    }
    
    // MARK: -
    
    struct SelectExtractMonth {
        let page = "/statement_month_selection"
        enum Action: String {
            case seePdf = "view_pdf"
        }
    }
    
    // MARK: - Bill and Taxes
    struct BillAndTaxes {
        let page = "recibos_e_impuestos"
        let emmaToken: String
        
        init(billAndTaxesEventID: String) {
            self.emmaToken = billAndTaxesEventID
        }
        
        enum Action: String {
            case tooltip
        }
    }
    
    struct BillAndTaxesSearch {
        let page = "recibos_e_impuestos_buscador"
    }
    
    struct BillAndTaxesTransactionDetail {
        let page = "recibos_e_impuestos_detalle_movimiento"
    }
    
    struct BillAndTaxesTransactionDetailPdf {
        let page = "recibos_e_impuestos_detalle_movimiento_pdf"
    }
    
    struct BillAndTaxesPayOriginAccountSelection {
        let page = "recibos_e_impuestos_pagar_cuenta_pago"
    }
    
    struct BillAndTaxesPayBill {
        let page = "recibos_e_impuestos_pagar_recibo"
    }
    
    struct BillAndTaxesPayBillScanner {
        let page = "recibos_e_impuestos_pagar_recibo_escaneo_recibo"
        enum Action: String {
            case manualMode = "introduccion_manual"
        }
    }
    
    struct BillAndTaxesPayBillManualData {
        let page = "recibos_e_impuestos_pagar_recibo_introducir_manual"
    }
    
    struct BillAndTaxesPayBillSignature {
        let page = "recibos_e_impuestos_pagar_recibo_firma"
    }
    
    struct BillAndTaxesPayBillConfirm {
        let page = "recibos_e_impuestos_pagar_recibo_confirmar"
    }
    
    struct BillAndTaxesPayBillSummary {
        let page = "recibos_e_impuestos_pagar_recibo_resumen"
    }
    
    struct BillAndTaxesPayTax {
        let page = "recibos_e_impuestos_pagar_impuesto"
    }
    
    struct BillAndTaxesPayTaxScanner {
        let page = "recibos_e_impuestos_pagar_impuesto_escaneo_impuesto"
        enum Action: String {
            case manualMode = "introduccion_manual"
        }
    }
    
    struct BillAndTaxesPayTaxManualData {
        let page = "recibos_e_impuestos_pagar_impuesto_introducir_manual"
    }
    
    struct BillAndTaxesPayTaxSignature {
        let page = "recibos_e_impuestos_pagar_impuesto_firma"
    }
    
    struct BillAndTaxesPayTaxConfirm {
        let page = "recibos_e_impuestos_pagar_impuesto_confirmar"
    }
    
    struct BillAndTaxesPayTaxSummary {
        let page = "recibos_e_impuestos_pagar_impuesto_resumen"
    }
    
    struct BillAndTaxesFaq {
        let page = "faq_pago_recibos"
    }
    
    struct ChangeMassiveDirectDebitsOriginAccount {
        let page = "recibos_e_impuestos_cambio_masivo_domiciliaciones_cuenta_origen"
    }
    
    struct ChangeMassiveDirectDebitsDestinationAccount {
        let page = "recibos_e_impuestos_cambio_masivo_domiciliaciones_cuenta_destino"
    }
    
    struct ChangeMassiveDirectDebitsConfirmation {
        let page = "recibos_e_impuestos_cambio_masivo_domiciliaciones_confirmar"
    }
    
    struct ChangeMassiveDirectDebitsSignature {
        let page = "recibos_e_impuestos_cambio_masivo_domiciliaciones_firma"
    }
    
    struct ChangeMassiveDirectDebitsSummary {
        let page = "recibos_e_impuestos_cambio_masivo_domiciliaciones_resumen"
    }
    
    struct CancelDirectBillingConfirmation {
        let page = "recibos_e_impuestos_anular_domiciliacion_confirmar"
    }
    
    struct CancelDirectBillingSignature {
        let page = "recibos_e_impuestos_anular_domiciliacion_firma"
    }
    
    struct CancelDirectBillingsSummary {
        let page = "recibos_e_impuestos_anular_domiciliacion_resumen"
    }
    
    struct ReceiptReturnSignature {
        let page = "recibos_e_impuestos_devolver_recibo_firma"
    }
    
    struct ReceiptReturnSummary {
        let page = "recibos_e_impuestos_devolver_recibo_resumen"
    }
    
    struct ChangeDirectDebitOriginAccount {
        let page = "recibos_e_impuestos_domiciliar_otra_cuenta_selector_cuenta"
    }
    
    struct ChangeDirectDebitConfirmation {
        let page = "recibos_e_impuestos_domiciliar_otra_cuenta_confirmar"
    }
    
    struct ChangeDirectDebitSignature {
        let page = "recibos_e_impuestos_domiciliar_otra_cuenta_firma"
    }
    
    struct ChangeDirectDebitSummary {
        let page = "recibos_e_impuestos_domiciliar_otra_cuenta_resumen"
    }
    
    struct DuplicateBillSignature {
        let page = "recibos_e_impuestos_duplicar_recibo_firma"
    }
    
    struct DuplicateBillSummary {
        let page = "recibos_e_impuestos_duplicar_recibo_resumen"
    }
    
    // MARK: - Transfers Home
    
    struct TransfersHome {        
        let emmaToken: String
        
        init(transfersEventID: String) {
            self.emmaToken = transfersEventID
        }
    }
    
    struct FavouriteTransfersHome {
        let page = "transferencias_home_favoritos"
        enum Action: String {
            case create = "alta_favorito"
        }
    }
    
    struct EmittedTransfersHome {
        let page = "transferencias_home_emitidas"
    }
    
    struct ScheduledTransfersHome {
        let page = "transferencias_home_programadas"
        enum Action: String {
            case startScheduled = "nueva_programada"
        }
    }
    
    // MARK: - Internal Transfer
    
    struct InternalTransferOriginAccountSelection {
        let page = "transferencias_traspasos_seleccion_cuenta_origen"
    }
    
    struct InternalTransferDestinationAccountSelection {
        let page = "transferencias_traspasos_seleccion_cuenta_destino"
    }
    
    struct InternalTransferAmountEntry {
        let page = "transferencias_traspasos_importe_y_concepto"
    }
    
    struct InternalTransferConfirmation {
        let page = "transferencias_traspasos_confirmacion"
    }
    
    struct InternalTransferSignature {
        let page = "transferencias_traspasos_firma"
    }
    
    struct InternalTransferSummary {
        let page = "transferencias_traspasos_resumen"
    }
    
    // MARK: - Transfer
    
    struct TransferFaqs {
        let page = "faq_transferencias"
    }
    
    struct TransferOriginAccountSelection {
        let page = "transferencias_envios_selección_cuenta_origen"
    }
    
    struct TransferAmountEntry {
        let page = "transferencias_envios_selector_inicial"
    }
    
    struct TransferCountrySelector {
        let page = "transferencias_envios_buscador_pais"
    }
    
    // MARK: - National Transfer
    
    struct NationalTransferDestinationAccount {
        let page = "transferencias_envio_nacional_destino"
        enum Action: String {
            case isFavourite = "marcar_como_favorito"
        }
    }
    
    struct NationalTransferSubTypeSelector {
        let page = "transferencias_envio_nacional_seleccion_tipo_envio"
    }
    
    struct NationalTransferConfirmation {
        let page = "transferencias_envio_nacional_confirmacion"
    }
    
    struct NationalTransferSignature {
        let page = "transferencias_envio_nacional_firma"
    }
    
    struct NationalTransferOTP {
        let page = "transferencias_envio_nacional_otp"
    }
    
    struct NationalTransferSummary {
        let page = "transferencias_envio_nacional_resumen"
        
        enum Action: String {
            case easyPay = "easy_pay"
            case easyPayError = "easy_pay_error"
            case helpToImprove = "ayudanos_a_mejorar"
            case share = "compartir"
        }
    }
    
    struct NationalTransferImmediateSummaryKO {
        let page = "transferencias_envio_nacional_inmediato_resumen_ko"
    }
    
    struct NationalTransferImmediateSummaryPending {
        let page = "transferencias_envio_nacional_inmediato_resumen_pendiente"
    }
    
    // MARK: - International Transfer
    
    struct InternationalTransferDestinationAccount {
        let page = "transferencias_envio_internacional_sepa_destino"
        enum Action: String {
            case isFavourite = "marcar_como_favorito"
        }
    }
    
    struct InternationalTransferConfirmation {
        let page = "transferencias_envio_internacional_sepa_confirmacion"
    }
    
    struct InternationalTransferSignature {
        let page = "transferencias_envio_internacional_sepa_firma"
    }
    
    struct InternationalTransferOTP {
        let page = "transferencias_envio_internacional_sepa_otp"
    }
    
    struct InternationalTransferSummary {
        let page = "transferencias_envio_internacional_sepa_resumen"
    }
    
    // MARK: - Usual Transfer
    
    struct UsualTransferOriginAccountSelection {
        let page = "transferencias_envio_favorito_seleccion_cuenta_origen"
    }
    
    struct UsualTransferAmountEntry {
        let page = "transferencias_envio_favorito_importe_y_concepto"
    }
    
    struct UsualTransferSubTypeSelector {
        let page = "transferencias_envio_favorito_seleccion_tipo_envio"
    }
    
    struct UsualTransferConfirmation {
        let page = "transferencias_envio_favorito_confirmacion"
    }
    
    struct UsualTransferSignature {
        let page = "transferencias_envio_favorito_firma"
    }
    
    struct UsualTransferSummary {
        let page = "transferencias_envio_favorito_resumen"
    }
    
    struct UsualTransferImmediateSummaryKO {
        let page = "transferencias_envio_favorito_inmediato_resumen_ko"
    }
    
    struct UsualTransferImmediateSummaryPending {
        let page = "transferencias_envio_favorito_inmediato_resumen_pendiente"
    }
    
    struct NoSepaUsualTransfer {
        let accountSelectionPage: String = "transferencias_envio_favorito_no_sepa_seleccion_cuenta_origen"
        let amountPage: String = "transferencias_envio_favorito_no_sepa_importe_y_concepto"
        let confirmationPage: String = "transferencias_envio_favorito_no_sepa_confirmacion"
        let signaturePage: String = "transferencias_envio_favorito_no_sepa_firma"
        let summaryPage: String = "transferencias_envio_favorito_no_sepa_resumen"
    }
    
    // MARK: - Emitted Transfer
    
    struct EmittedTransferDetail {
        let page = "transferencias_detalle_emitida"
    }
    
    // MARK: - Scheduled Transfer
    
    struct ScheduledTransferDetail {
        let page = "transferencias_programadas_detalle"
    }
    
    // MARK: - Reemitted Transfer
    
    struct ReemittedTransferOriginAccountSelection {
        let page = "transferencias_reemision_seleccion_cuenta_origen"
    }
    
    struct ReemittedTransferAmountEntry {
        let page = "transferencias_reemision_importe_y_concepto"
    }
    
    struct ReemittedTransferSubTypeSelector {
        let page = "transferencias_reemision_seleccion_tipo_envio"
    }
    
    struct ReemittedTransferConfirmation {
        let page = "transferencias_reemision_confirmacion"
    }
    
    struct ReemittedTransferSignature {
        let page = "transferencias_reemision_firma"
    }
    
    struct ReemittedTransferOTP {
        let page = "transferencias_reemision_otp"
    }
    
    struct ReemittedTransferSummary {
        let page = "transferencias_reemision_resumen"
    }
    
    struct ReemittedTransferImmediateSummaryKO {
        let page = "transferencias_reemision_inmediata_resumen_ko"
    }
    
    struct ReemittedTransferImmediateSummaryPending {
        let page = "transferencias_reemision_inmediata_resumen_pendiente"
    }
    
    struct NoSepaReemittedTransfer {
        let accountSelectionPage: String = "transferencias_reemision_no_sepa_seleccion_cuenta_origen"
        let amountPage: String = "transferencias_reemision_no_sepa_importe_y_concepto"
        let confirmationPage: String = "transferencias_reemision_no_sepa_confirmacion"
        let signaturePage: String = "transferencias_reemision_no_sepa_firma"
        let otpPage: String = "transferencias_reemision_no_sepa_otp"
        let summaryPage: String = "transferencias_reemision_no_sepa_resumen"
    }
    
    // MARK: - Cancel Scheduled Transfer
    
    struct CancelScheduledTransferConfirmation {
        let page = "transferencias_programadas_baja_confirmacion"
    }
    
    struct CancelScheduledTransferSignature {
        let page = "transferencias_programadas_baja_firma"
    }
    
    struct CancelScheduledTransferSummary {
        let page = "transferencias_programadas_baja_resumen"
    }
    
    // MARK: - Modify Scheduled Transfer
    
    struct ModifyScheduledTransfer {
        let page = "transferencias_programadas_modificacion_editar_datos"
    }
    
    struct ModifyScheduledTransferConfirmation {
        let page = "transferencias_programadas_modificacion_confirmacion"
    }
    
    struct ModifyScheduledTransferSignature {
        let page = "transferencias_programadas_modificacion_firma"
    }
    
    struct ModifyScheduledTransferOTP {
        let page = "transferencias_programadas_modificacion_otp"
    }
    
    struct ModifyScheduledTransferSummary {
        let page = "transferencias_programadas_modificacion_resumen"
    }
    
    // MARK: - Received Transfer
    
    struct ReceivedTransfersDetailPage {
        public let page = "envio_dinero_recibida"
        
        public enum Action: String {
            case pdf = "pdf"
            case share = "compartir"
        }
        public init() {}
    }
    
    // MARK: - Insurance Receipt Emitters
    
    struct InsuranceEmittersPage {
        public let page = "/bill_tax/return_bill/insurance_information"
        
        public enum Action: String {
            case end = "understood"
        }
        public init() {}
    }
    
    // MARK: - Notifications
    
    struct Salesforce {
        let page = "buzon_notificaciones_salesforce"
        
        enum Action: String {
            case delete = "borrar"
            case selectAll = "seleccionar_todo"
            case confirmDelete = "confirmar_borrar"
            case cancel = "cancelar"
        }
    }

    struct OnlineMessages {
        let page = "buzon_notificaciones_correspondencia_online"
    }
    
    struct Inbox {
        //TODO: replace for real Name ask for it
        let page = "buzon"
    }
    
    struct Twinpush {
        let page = "buzon_notificaciones_twinpush"
        
        enum Action: String {
            case delete = "borrar"
            case selectAll = "seleccionar_todo"
            case confirmDelete = "confirmar_borrar"
            case cancel = "cancelar"
        }
    }
    
    struct NotificationDetail {
        let page = "notificaciones_detalle_notificacion"
        enum Action: String {
            case delete = "borrar"
        }
    }
    
    // MARK: Sessions Control
    struct LogoutConfirm {
        let page = "/logout"
        enum Action: String {
            case ok = "logout"
        }
    }
    
    struct TokenOut {
        let page = "/session_expired"
    }
    
    // MARK: Personal Area Direct Access Configuration
    struct PersonalAreaDirectAccesConfiguration {
        let page = "area_personal_configuracion_accesos_rapidos"
        
        enum Action: String {
            case activateDeeplink = "deeplink_activar"
            case deactivateDeeplink = "deeplink_desactivar"
            case moveDeeplink = "deeplink_mover"
        }
    }
    
    // MARK: Landing Push
    struct LandingPushCardMovement {
        let page = "landing_push_movimiento_tarjeta"
        enum Action: String {
            case deeplink
        }
    }
    
    struct LandingPushBill {
        let page: String = "landing_push_recibo_cargado"
        enum Action: String {
            case deeplink
        }
    }
    
    struct LandingPushAccountTransaction {
        let page: String = "landing_push_movimiento_cuenta"
        enum Action: String {
            case deeplink
        }
    }
    
    struct LandingPushEmittedTransfer {
        let page: String = "landing_push_transferencia_emitida"
        enum Action: String {
            case deeplink
        }
    }
    
    struct LandingPushOverdraft {
        let page: String = "landing_push_descubierto"
        enum Action: String {
            case deeplink
        }
    }
    
    struct LandingPushLowerBalance {
        let page: String = "landing_push_saldo_inferior"
        enum Action: String {
            case deeplink
        }
    }
    
    // MARK: Card limits
    struct ModiftCardLimits {
        let page = "modificar_limites_tarjeta"
    }
    
    struct ModifyCardLimitsConfirmation {
        let page = "modificar_limites_tarjeta_confirmacion"
    }
    
    struct ModifyCardLimitsSignature {
        let page = "modificar_limites_tarjeta_firma"
    }
    
    struct ModifyCardLimitsOTP {
        let page = "modificar_limites_tarjeta_otp"
    }
    
    struct ModifyCardLimitsSummary {
        let page = "modificar_limites_tarjeta_resumen"
    }
    
    // MARK: Change Pay Method
    struct CreditCardChangePayMethod {
        let page = "/card/credit/change_payment_method"
    }
    
    struct CreditCardChangePayMethodDeferred {
        let page = "/card/credit/change_payment_method/deferred"
    }
    
    struct CreditCardChangePayMethodFixedFee {
        let page = "/card/credit/change_payment_method/fixed_instalment"
    }
    
    struct CreditCardChangePayMethodConfirmation {
        let page = "/card/credit/change_payment_method/confirm"
        
        enum Action: String {
            case error = "error_{step1_step2}"
        }
    }
    
    struct CreditCardChangePayMethodSummary {
        let page = "/card/credit/change_payment_method/thankyou"
    }
    
    // MARK: No sepa transfers
    struct NoSepaTransferDestiny {
        let page = "transferencias_envio_internacional_no_sepa_destino"
        
        enum Action: String {
            case favourite = "marcar_como_favorito"
        }
    }
    
    struct NoSepaTransferConfirmation {
        let page = "transferencias_envio_internacional_no_sepa_confirmacion"
    }
    
    struct NoSepaTransferSignature {
        let page = "transferencias_envio_internacional_no_sepa_firma"
    }

    struct NoSepaTransferOTP {
        let page = "transferencias_envio_internacional_no_sepa_otp"
    }
    
    struct NoSepaTransferSummary {
        let page = "transferencias_envio_internacional_no_sepa_resumen"
    }

    struct NoSepaTransferFxPayDialog {
        let page = "transferencias_envio_internacional_no_sepa_one_pay_fx"
        
        enum Action: String {
            case standard = "transferencia_estandar"
            case fxPay = "onepay_fx"
        }
    }
    
    struct OnePayHome {
        let page: String = "transferencias_home"
    }
    
    struct Donation {
          let page: String = "transferencias_home"
    }
    
    struct Manager {
        let page: String = "tu_gestor"
    }
    
    // MARK: OTP Push
    struct OtpPushUpdateToken {
        let page = "otp_push_actualizar_token"
    }
    
    struct OtpPush {
        let page = "otp_push"
    }
    
    struct OtpPushAlert {
        let page = "otp_push_alert"
        enum Action: String {
            case update = "actualizar"
            case cancel = "cancelar"
        }
    }
    
    struct OtpPushOperativeAlias {
        let page = "area_personal_seguridad_otp_push_alias"
        enum Action: String {
            case save = "guardar"
        }
    }
    
    struct OtpPushOperativeSignature {
        let page = "area_personal_seguridad_otp_push_firma"
        enum Action: String {
            case error
        }
    }
    
    struct OtpPushOperativeOTP {
        let page = "area_personal_seguridad_otp_push_otp"
    }
    
    struct OtpPushOperativeSummary {
        let page = "area_personal_seguridad_otp_push_resumen"
        enum Action: String {
            case goToPG = "posicion_global"
            case helpToImprove = "ayudanos_a_mejorar"
        }
    }
    
    struct OtpPushRegister {
        let page = "otp_push_registrar"
    }
    
    // MARK: Create usual transfer
    
    struct CreateUsualTransferCountrySelector {
        let page: String = "transferencias_alta_favorito"
    }
    
    struct CreateUsualTransferAccount {
        let page: String = "transferencias_alta_favorito_destino"
    }
    
    struct CreateSepaUsualTransferConfirmation {
        let page: String = "transferencias_alta_favorito_sepa_confirmacion"
    }
    
    struct CreateSepaUsualTransferSignature {
        let page: String = "transferencias_alta_favorito_sepa_firma"
    }
    
    struct CreateSepaUsualTransferOtp {
        let page: String = "transferencias_alta_favorito_sepa_otp"
    }
    
    struct CreateSepaUsualTransferSummary {
        let page: String = "transferencias_alta_favorito_sepa_resumen"
    }
    
    struct CreateNoSepaUsualTransferInputData {
        let page: String = "transferencias_alta_favorito_no_sepa_datos"
    }
    
    struct CreateNoSepaUsualTransferConfirmation {
        let page: String = "transferencias_alta_favorito_no_sepa_confirmacion"
    }
    
    struct CreateNoSepaUsualTransferSignature {
        let page: String = "transferencias_alta_favorito_no_sepa_firma"
    }
    
    struct CreateNoSepaUsualTransferOtp {
        let page: String = "transferencias_alta_favorito_no_sepa_otp"
    }
    
    struct CreateNoSepaUsualTransferSummary {
        let page: String = "transferencias_alta_favorito_no_sepa_resumen"
    }
    
    struct SecurityArea {
        let page = "security_area"
    }
    
    // MARK: Update usual transfer
    
    struct UsualTransferDetail {
        let page: String = "transferencias_detalle_favorito"
        enum Action: String {
            case update = "modificar_favorito"
            case remove = "baja_favorito"
        }
    }
    
    struct UpdateUsualTransfer {
        let countrySelector: String = "transferencias_modificar_favorito"
        let sepaAccountSelector: String = "transferencias_modificar_favorito_sepa_destino"
        let sepaConfirmation: String = "transferencias_modificar_favorito_sepa_confirmacion"
        let sepaSignature: String = "transferencias_modificar_favorito_sepa_firma"
        let sepaOtp: String = "transferencias_modificar_favorito_sepa_otp"
        let sepaSummary: String = "transferencias_modificar_favorito_sepa_resumen"
        let noSepaAccountSelector: String = "transferencias_modificar_favorito_no_sepa_destino"
        let noSepaExtraInput: String = "transferencias_modificar_favorito_no_sepa_datos"
        let noSepaConfirmation: String = "transferencias_modificar_favorito_no_sepa_confirmacion"
        let noSepaSignature: String = "transferencias_modificar_favorito_no_sepa_firma"
        let noSepaOtp: String = "transferencias_modificar_favorito_no_sepa_otp"
        let noSepaSummary: String = "transferencias_modificar_favorito_no_sepa_resumen"
    }
    
    struct LocationPermissions {
        let page: String = "/personal_area/location_permission"
        enum Action: String {
            case ok = "aceptar"
            case cancel = "cancelar"
        }
    }
    
    struct NationalTransferConfirmationPage {
        public let page = "national_transfer_confirmation"
        public init() {}
    }
}
