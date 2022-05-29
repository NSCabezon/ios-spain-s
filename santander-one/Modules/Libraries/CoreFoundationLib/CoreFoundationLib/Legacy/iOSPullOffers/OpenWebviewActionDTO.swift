import CoreDomain

public enum OpenWebViewActionParameter: String {
    case token = "$TOKEN"
    case companyId = "$IDEMPRESA"
    case userId = "$USERID"
    case contractId = "$CONTRACT_ID"
    case portfolioId = "$IDCARTERA"
    case stockFundName = "$FONDONOMBREVALOR"
    case family = "$FAMILY_ID"
    case userName = "$USERNAME"
    case stockCode = "$CODIGO_VALOR"
    case identificationNumber = "$CODIGO_EMISION"
    case language = "$LANGUAGE"
    case personCode = "$COD_PERSON"
    case channelFrame = "$CHANNEL_FRAME"
    case typePerson = "$TYPE_PERSON"
    case multiCompany = "$MULTI_EMPRESA"
    case multiCenter = "$MULTI_CENTRO"
    case multiProd = "$MULTI_PRODUCTO"
    case multiNumContract = "$MULTI_NUM_CONTRACT"
    case languageISO = "$IDIOMA_ISO"
    case dialectISO = "$DIALECTO_ISO"
}

public enum OpenWebviewActionEngine: String {
    case uiWebView = "uiwebview"
    case wkWebView = "wkwebview"
    
    public var engine: WebViewConfigurationEngine {
        return WebViewConfigurationEngine(string: self.rawValue)
    }
}

public enum WebviewActionParametersType {
    case query, body
}

public struct OpenWebviewAction: OfferActionRepresentable {
    public let topTitle: String
    public let reloadSessionOnClose: Bool
    public let openUrl: String
    public let closeUrl: String
    public let pdfName: String
    public let method: HTTPMethodType
    public let parameters: [OfferWebViewParameter]
    public let type = "open_webview"
    public let navigations: [OpenWebViewActionNavigations]?
    public let webviewEngineVersion: OpenWebviewActionEngine
    public let isIgnorePdfEnabled: Bool
    public let timerLoadingTips: String
    public let parametersType: WebviewActionParametersType?
    public let isFullScreenEnabled: Bool
    public let headers: [OpenWebViewHeader]?
    
    public func getDeserialized() -> String {
        var output = "<top_title>\(topTitle)</top_title>" +
            "<reload_session_on_close>\(reloadSessionOnClose)</reload_session_on_close>" +
            "<open_url>" +
            "<![CDATA[ \(openUrl) ]]>" +
            "</open_url>" +
            "<close_url>" +
            "<![CDATA[ \(closeUrl) ]]>" +
            "</close_url>" +
            "<pdf_name>\(pdfName)</pdf_name>" +
            "<method>\(method)</method>" +
            "<parameters>"
        
        for parameter in parameters {
            output += "<parameter name=\"\(parameter.key)\">\(parameter.value)</parameter>"
        }
        output += "</parameters>"
        output += "<ios_webview_engine_version>\(webviewEngineVersion.rawValue)</ios_webview_engine_version>"
        output += "<except_download_pdf>\(isIgnorePdfEnabled ? "true": "false")</except_download_pdf>"
        output += "<full_screen_enabled>\(isFullScreenEnabled ? "true": "false")</full_screen_enabled>"
        if let navigations = navigations {
            output += "<navigations>"
            
            for navigation in navigations {
                output += "<navigation>"
                    + "<url>\(navigation.url)</url>"
                    + "<operative>\(navigation.operative)</operative>"
                    
                if let id = navigation.id {
                    output += "<id>\(id)</id>"
                }
                
                output += "</navigation>"
            }
            output += "</navigations>"
        }
        if let headers = headers {
            output += "<headers>"
            for header in headers {
                output += "<header name=\"\(header.key)\">\(header.value)</header>"
            }
            output += "</headers>"
        }
        return output
    }
}

public struct OpenWebViewActionNavigations {
    
    public let url: String
    public let operative: String
    public let id: String?
    
    public init(url: String, operative: String, id: String?) {
        self.url = url
        self.operative = operative
        self.id = id
    }
}

public struct OpenWebViewHeader {
    
    public let key: String
    public let value: String
    
    public init(key: String, value: String) {
        self.key = key
        self.value = value
    }
}

extension OpenWebViewHeader: WebViewMacroCapable { }
