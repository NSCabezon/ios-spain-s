public class XMLHelper{
    public class func getContractXML(parentKey: String, company: String?, branch: String?, product: String?, contractNumber: String?) -> String{
        return "<\(parentKey)>"
            + "     <CENTRO>"
            + "         <EMPRESA>\(company ?? "")</EMPRESA>"
            + "         <CENTRO>\(branch ?? "")</CENTRO>"
            + "     </CENTRO>"
            + "     <PRODUCTO>\(product ?? "")</PRODUCTO>"
            + "     <NUMERO_DE_CONTRATO>\(contractNumber ?? "")</NUMERO_DE_CONTRATO>"
            + "</\(parentKey)>"
    }
    
    public class func getAmountXML(parentKey: String, importe: String?, divisa: String?) -> String{
        return "<\(parentKey)>"
            + "     <IMPORTE>\(importe ?? "")</IMPORTE>"
            + "     <DIVISA>\(divisa ?? "")</DIVISA>"
            + "</\(parentKey)>"
    }
    
    public class func getProductTypeAndSubtypeXML(parentKey: String, company: String?, productType: String?, productSubType: String?) -> String{
        return "<\(parentKey)>"
            + "     <TIPO_DE_PRODUCTO>"
            + "         <EMPRESA>\(company ?? "")</EMPRESA>"
            + "         <TIPO_DE_PRODUCTO>\(productType ?? "")</TIPO_DE_PRODUCTO>"
            + "     </TIPO_DE_PRODUCTO>"
            + "     <SUBTIPO_DE_PRODUCTO>\(productSubType ?? "")</SUBTIPO_DE_PRODUCTO>"
            + "</\(parentKey)>"
    }
    
    public class func getFundOperationsTypeXML(parentKey: String, fundOperationsType: FundOperationsType) -> String{
        
        var fundOperationsTypeString = ""
        if fundOperationsType == FundOperationsType.typeAmount{
            fundOperationsTypeString = "I"
        }
        else if fundOperationsType == FundOperationsType.typeShares{
            fundOperationsTypeString = "P"
        }
        
        return "<\(parentKey)>\(fundOperationsTypeString)</\(parentKey)>"
    }
    
    public class func getHeaderData(language: String?, dialect: String?, linkedCompany: String?) -> String{
        return  "<datosCabecera>" +
                "   <idioma>" +
                "       <IDIOMA_ISO>\(language ?? "")</IDIOMA_ISO>" +
                "       <DIALECTO_ISO>\(dialect ?? "")</DIALECTO_ISO>" +
                "   </idioma>" +
                "   <empresaAsociada>\(linkedCompany ?? "")</empresaAsociada>" +
                "</datosCabecera>"
    }
}
