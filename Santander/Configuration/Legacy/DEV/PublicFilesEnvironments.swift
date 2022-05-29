import CoreFoundationLib

struct PublicFilesEnvironments {
    
    // Entornos XML
    static let xmlEndpointFF: String = "https://microsite.bancosantander.es/filesFF/"
    static let xmlEndpointCiberDev: String = "https://serverftp.ciber-es.com/movilidad/files_dev/"
    static let xmlEndpointRC: String = "https://serverftp.ciber-es.com/movilidad/files_rc/"
    static let xmlEndpointCiberQA: String = "https://serverftp.ciber-es.com/movilidad/files_qa/"
    static let xmlEndpointCiberIsban: String = "https://serverftp.ciber-es.com/movilidad/files/"
    static let xmlEndpointCiberNegocio: String = "https://serverftp.ciber-es.com/movilidad/files_negocio/"
    static let xmlEndpointCiberElab: String = "https://serverftp.ciber-es.com/movilidad/files_elab/"
    static let xmlEndpointPruebas: String = "http://is28925x318767p.scisb.isban.corp/isban/files/"
    static let xmlEndpointPongodes: String = "http://pongodes.bsch:3105/files/"
    
    static let xmlEnvironmentFF = PublicFilesEnvironmentDTO("SAN_FF", xmlEndpointFF, false)
    static let xmlEnvironmentCiberDev = PublicFilesEnvironmentDTO("CIBER_DEV", xmlEndpointCiberDev, false)
    static let xmlEnvironmentRC = PublicFilesEnvironmentDTO("RC", xmlEndpointRC, false)
    static let xmlEnvironmentCiberQA = PublicFilesEnvironmentDTO("CIBER_QA", xmlEndpointCiberQA, false)
    static let xmlEnvironmentCiberIsban = PublicFilesEnvironmentDTO("CIBER_ISBAN", xmlEndpointCiberIsban, false)
    static let xmlEnvironmentCiberNegocio = PublicFilesEnvironmentDTO("CIBER_NEGOCIO", xmlEndpointCiberNegocio, false)
    static let xmlEnvironmentCiberElab = PublicFilesEnvironmentDTO("CIBER_ELAB", xmlEndpointCiberElab, false)
    static let xmlEnvironmentPruebas = PublicFilesEnvironmentDTO("PRUEBAS", xmlEndpointPruebas, false)
    static let xmlEnvironmentPongodes = PublicFilesEnvironmentDTO("PONGODES", xmlEndpointPongodes, false)
    static let xmlEnvironmentLocal = PublicFilesEnvironmentDTO("DEFAULT", "/assets/default/", true)
    static let xmlEnvironmentLocal1 = PublicFilesEnvironmentDTO("LOCAL_1", "/assetsLocal/local_1/", true)
    static let xmlEnvironmentLocal2 = PublicFilesEnvironmentDTO("LOCAL_2", "/assetsLocal/local_2/", true)
}
