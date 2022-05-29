import Fuzi
import CoreDomain

public struct UserDataDTO: Codable {
    public var company: String?
    public var clientPersonType: String?
    public var clientPersonCode: String?
    public var channelFrame: String?
    public var contract: ContractDTO?
    
    public var controlOperativoCliente: String {
        return "\(clientPersonType ?? "")\(clientPersonCode ?? "")"
    }
    
    public var datosUsuarioWithEmpresa: String {
        return "<empresa>\(company ?? "")</empresa>" +
            "<cliente>" +
            "   <TIPO_DE_PERSONA>\(clientPersonType ?? "")</TIPO_DE_PERSONA>" +
            "   <CODIGO_DE_PERSONA>\(clientPersonCode ?? "")</CODIGO_DE_PERSONA>" +
            "</cliente>" +
            "<canalMarco>\(channelFrame ?? "")</canalMarco>" +
            "<contratoMulticanal>" +
            "   <CENTRO>" +
            "   <EMPRESA>\(contract?.bankCode ?? "")</EMPRESA>" +
            "   <CENTRO>\(contract?.branchCode ?? "")</CENTRO>" +
            "   </CENTRO>" +
            "   <PRODUCTO>\(contract?.product ?? "")</PRODUCTO>" +
            "   <NUMERO_DE_CONTRATO>\(contract?.contractNumber ?? "")</NUMERO_DE_CONTRATO>" +
        "</contratoMulticanal>"
    }
    
    public var datosUsuario: String {
        return "<cliente>" +
            "   <TIPO_DE_PERSONA>\(clientPersonType ?? "")</TIPO_DE_PERSONA>" +
            "   <CODIGO_DE_PERSONA>\(clientPersonCode ?? "")</CODIGO_DE_PERSONA>" +
            "</cliente>" +
            "<canalMarco>\(channelFrame ?? "")</canalMarco>" +
            "<contratoMulticanal>" +
            "   <CENTRO>" +
            "       <EMPRESA>\(contract?.bankCode ?? "")</EMPRESA>" +
            "       <CENTRO>\(contract?.branchCode ?? "")</CENTRO>" +
            "   </CENTRO>" +
            "   <PRODUCTO>\(contract?.product ?? "")</PRODUCTO>" +
            "   <NUMERO_DE_CONTRATO>\(contract?.contractNumber ?? "")</NUMERO_DE_CONTRATO>" +
        "</contratoMulticanal>"
    }
    
    public var datosUsuarioWithContract: String {
        return "<cliente>" +
            "   <TIPO_DE_PERSONA>\(clientPersonType ?? "")</TIPO_DE_PERSONA>" +
            "   <CODIGO_DE_PERSONA>\(clientPersonCode ?? "")</CODIGO_DE_PERSONA>" +
            "</cliente>" +
            "<canalMarco>\(channelFrame ?? "")</canalMarco>" +
            "<contrato>" +
            "   <CENTRO>" +
            "       <EMPRESA>\(contract?.bankCode ?? "")</EMPRESA>" +
            "       <CENTRO>\(contract?.branchCode ?? "")</CENTRO>" +
            "   </CENTRO>" +
            "   <PRODUCTO>\(contract?.product ?? "")</PRODUCTO>" +
            "   <NUMERO_DE_CONTRATO>\(contract?.contractNumber ?? "")</NUMERO_DE_CONTRATO>" +
            "</contrato>"
    }
    
    public var clientAndChannelXml: String {
        return "<cliente>" +
            "   <TIPO_DE_PERSONA>\(clientPersonType ?? "")</TIPO_DE_PERSONA>" +
            "   <CODIGO_DE_PERSONA>\(clientPersonCode ?? "")</CODIGO_DE_PERSONA>" +
            "</cliente>" +
        "<canalMarco>\(channelFrame ?? "")</canalMarco>"
    }
    
    public var getClientChannelCmcXml: String {
        return "<cliente>" +
            "   <TIPO_DE_PERSONA>\(clientPersonType ?? "")</TIPO_DE_PERSONA>" +
            "   <CODIGO_DE_PERSONA>\(clientPersonCode ?? "")</CODIGO_DE_PERSONA>" +
            "</cliente>" +
            "<canalMarco>\(channelFrame ?? "")</canalMarco>" +
            "<centroCMC>" +
            "   <EMPRESA>\(contract?.bankCode ?? "")</EMPRESA>" +
            "   <CENTRO>\(contract?.branchCode ?? "")</CENTRO>" +
            "</centroCMC>"
    }
    
    public func getDatosUsuarioMifid(cmc: ContractDTO?) -> String {
        return
                "<cliente>" +
                "   <TIPO_DE_PERSONA>\(clientPersonType ?? "")</TIPO_DE_PERSONA>" +
                "   <CODIGO_DE_PERSONA>\(clientPersonCode ?? "")</CODIGO_DE_PERSONA>" +
                "</cliente>" +
                "<canal>\(channelFrame ?? "")</canal>" +
                "<contrato>" +
                "   <CENTRO>" +
                "       <EMPRESA>\(cmc?.bankCode ?? "")</EMPRESA>" +
                "       <CENTRO>\(cmc?.branchCode ?? "")</CENTRO>" +
                "   </CENTRO>" +
                "   <PRODUCTO>\(cmc?.product ?? "")</PRODUCTO>" +
                "   <NUMERO_DE_CONTRATO>\(cmc?.contractNumber ?? "")</NUMERO_DE_CONTRATO>" +
                "</contrato>"
    }
    
    public func getUserDataWithChannel() -> String {
        return
            "<cliente>" +
                "   <TIPO_DE_PERSONA>\(clientPersonType ?? "")</TIPO_DE_PERSONA>" +
                "   <CODIGO_DE_PERSONA>\(clientPersonCode ?? "")</CODIGO_DE_PERSONA>" +
                "</cliente>" +
                "<canal>\(channelFrame ?? "")</canal>" +
                "<contratoMulticanal>" +
                "   <CENTRO>" +
                "       <EMPRESA>\(contract?.bankCode ?? "")</EMPRESA>" +
                "       <CENTRO>\(contract?.branchCode ?? "")</CENTRO>" +
                "   </CENTRO>" +
                "   <PRODUCTO>\(contract?.product ?? "")</PRODUCTO>" +
                "   <NUMERO_DE_CONTRATO>\(contract?.contractNumber ?? "")</NUMERO_DE_CONTRATO>" +
                "</contratoMulticanal>"
    }
    
    public func getUserDataWithMultiChannelAndCompany() -> String {
        return
            "<cliente>" +
                "   <TIPO_DE_PERSONA>\(clientPersonType ?? "")</TIPO_DE_PERSONA>" +
                "   <CODIGO_DE_PERSONA>\(clientPersonCode ?? "")</CODIGO_DE_PERSONA>" +
                "</cliente>" +
                "<canal>\(channelFrame ?? "")</canal>" +
                "<empresa>\(contract?.bankCode ?? "")</empresa>" +
                "<contratoMulticanal>" +
                "   <CENTRO>" +
                "       <EMPRESA>\(contract?.bankCode ?? "")</EMPRESA>" +
                "       <CENTRO>\(contract?.branchCode ?? "")</CENTRO>" +
                "   </CENTRO>" +
                "   <PRODUCTO>\(contract?.product ?? "")</PRODUCTO>" +
                "   <NUMERO_DE_CONTRATO>\(contract?.contractNumber ?? "")</NUMERO_DE_CONTRATO>" +
        "</contratoMulticanal>"
    }
    
    public var getUserDataWithChannelAndCompany: String {
        return  "<cliente>" +
                "   <TIPO_DE_PERSONA>\(clientPersonType ?? "")</TIPO_DE_PERSONA>" +
                "   <CODIGO_DE_PERSONA>\(clientPersonCode ?? "")</CODIGO_DE_PERSONA>" +
                "</cliente>" +
                "<canal>\(channelFrame ?? "")</canal>" +
                "<empresa>\(company ?? "")</empresa>" +
                "<contrato>" +
                "   <CENTRO>" +
                "       <EMPRESA>\(contract?.bankCode ?? "")</EMPRESA>" +
                "       <CENTRO>\(contract?.branchCode ?? "")</CENTRO>" +
                "   </CENTRO>" +
                "   <PRODUCTO>\(contract?.product ?? "")</PRODUCTO>" +
                "   <NUMERO_DE_CONTRATO>\(contract?.contractNumber ?? "")</NUMERO_DE_CONTRATO>" +
                "</contrato>"
    }
    
    public var getUserDataWithChannelAndCompanyAndMultiContract: String {
        return
            "<cliente>" +
            "   <TIPO_DE_PERSONA>\(clientPersonType ?? "")</TIPO_DE_PERSONA>" +
            "   <CODIGO_DE_PERSONA>\(clientPersonCode ?? "")</CODIGO_DE_PERSONA>" +
            "</cliente>" +
            "<canal>\(channelFrame ?? "")</canal>" +
            "<empresa>\(company ?? "")</empresa>" +
            "<contratoMulticanal>" +
            "   <CENTRO>" +
            "       <EMPRESA>\(contract?.bankCode ?? "")</EMPRESA>" +
            "       <CENTRO>\(contract?.branchCode ?? "")</CENTRO>" +
            "   </CENTRO>" +
            "   <PRODUCTO>\(contract?.product ?? "")</PRODUCTO>" +
            "   <NUMERO_DE_CONTRATO>\(contract?.contractNumber ?? "")</NUMERO_DE_CONTRATO>" +
        "</contratoMulticanal>"
    }
    
    public var getUserDataWithMarcoChannelAndMultiContract: String {
        return
            "<cliente>" +
                "   <TIPO_DE_PERSONA>\(clientPersonType ?? "")</TIPO_DE_PERSONA>" +
                "   <CODIGO_DE_PERSONA>\(clientPersonCode ?? "")</CODIGO_DE_PERSONA>" +
                "</cliente>" +
                "<canalMarco>\(channelFrame ?? "")</canalMarco>" +
                "<contratoMulticanal>" +
                "   <CENTRO>" +
                "       <EMPRESA>\(contract?.bankCode ?? "")</EMPRESA>" +
                "       <CENTRO>\(contract?.branchCode ?? "")</CENTRO>" +
                "   </CENTRO>" +
                "   <PRODUCTO>\(contract?.product ?? "")</PRODUCTO>" +
                "   <NUMERO_DE_CONTRATO>\(contract?.contractNumber ?? "")</NUMERO_DE_CONTRATO>" +
        "</contratoMulticanal>"
    }
    
    public func getMultiContract() -> String {
        return   "<contratoMulticanal>" +
                "   <CENTRO>" +
                "       <EMPRESA>\(contract?.bankCode ?? "")</EMPRESA>" +
                "       <CENTRO>\(contract?.branchCode ?? "")</CENTRO>" +
                "   </CENTRO>" +
                "   <PRODUCTO>\(contract?.product ?? "")</PRODUCTO>" +
                "   <NUMERO_DE_CONTRATO>\(contract?.contractNumber ?? "")</NUMERO_DE_CONTRATO>" +
                "</contratoMulticanal>"
    }
    
    public func getClientChannelWithCompany() -> String {
        return "<cliente>" +
               "   <TIPO_DE_PERSONA>\(clientPersonType ?? "")</TIPO_DE_PERSONA>" +
               "   <CODIGO_DE_PERSONA>\(clientPersonCode ?? "")</CODIGO_DE_PERSONA>" +
               "</cliente>" +
               "<canal>\(channelFrame ?? "")</canal>" +
               "<empresa>\(company ?? "")</empresa>"
    }
    
    public var getDataUserWithContractCmc: String {
        return "<empresa>\(company ?? "")</empresa>" +
            "<canal>\(channelFrame ?? "")</canal>" +
            "<cmc>" +
            "   <CENTRO>" +
            "   <EMPRESA>\(contract?.bankCode ?? "")</EMPRESA>" +
            "   <CENTRO>\(contract?.branchCode ?? "")</CENTRO>" +
            "   </CENTRO>" +
            "   <PRODUCTO>\(contract?.product ?? "")</PRODUCTO>" +
            "   <NUMERO_DE_CONTRATO>\(contract?.contractNumber ?? "")</NUMERO_DE_CONTRATO>" +
        "</cmc>"
    }
    
    public var getCMC: String {
        let bankCode: String = self.contract?.bankCode ?? ""
        let branchCode: String = self.contract?.branchCode ?? ""
        let product: String = self.contract?.product ?? ""
        let contractNumber: String = self.contract?.contractNumber ?? ""
        return bankCode + branchCode + product + contractNumber
    }
    
    public init() {}
}

extension UserDataDTO: UserDataRepresentable {
    public var contractRepresentable: ContractRepresentable? {
        return self.contract
    }
}
