//
//  SdkWrapper.cpp
//  tas_example_app
//
//  Copyright © 2018 com.ibm. All rights reserved.
//

#include "SdkHandler.hpp"

// TODO: First fill the Vendor ID, Client ID, and Client Key provided to you by IBM in a license file
static TAS_CLIENT_INFO default_client_info = { sizeof(TAS_CLIENT_INFO),
 "santanderes.com",
 "santanderes.bankingapp",
 "santanderes_particulares_pre", "YMAQAABNFUWS2LKCIVDUSTRAKBKUETCJIMQEWRKZFUWS2LJNBJGUSSKCJFVECTSCM5VXC2DLNFDTS5ZQIJAVCRKGIFAU6Q2BKE4ECTKJJFBEGZ2LINAVCRKBO5NHA6LKPFZSW3LFIZVTAVCSIF3VIZCMBJDWURBRM5FDI33FKRIE2VTKO5KE4Y2OOVJUCUKTOEVUQ2SPGRFEMTKQPB3GG3CPGVRU6SDUGNJGGRCJJUYWKR3QHFIVASTLIMVXO6DMBJKGYMSFNFSFM3SHGNXUIZLZNR2FMTTDNBZU643TM52WYOCIOZEVURKXLJJEW4KDHBDUGODJPBJVQU2EPIZWG42VHFTXUUT2MZSFUWCLBJUHEWKSHA4TAY3KF54S652MLBTHMSLBPBHDAY3RKUYXA3LYJ43TQWJXI5LVUS3BKNQWQ5LBLBXWG6DMPFJEYL22JIVTSWDYOV3WU4KMBJDVCUKZMJIHQ2CPMMZUG3SJF5HWGYTVIRWXGVKIOFVWMK3YINTGW4TMIU4U4UKXJZHWCWSNPJCWS3LCLBBE6WTLMEVWYYSMONYU243ZBJAWK3L2IR3GQYSKGF5CWVLVMRYEC32FJ4ZW4MKKPAZHMZZTORVXIT2YKV5DKV3WMRIG62CUHA4UYQ2TNJJWQS3HNE2HC6TMOMYDE6RWBJLFCSKEIFIUCQQKFUWS2LJNIVHEIICQKVBEYSKDEBFUKWJNFUWS2LIKAMAAAAAAAAAAAAAAAAABCAAAABZGG2LOM5PXGYLOORQW4ZDFOJSXH5IBAAAACAAAAAAQAAAAKRK2GAA4AAAAA2DUORYHGORPF42TIMBZGAXG4LTUOJ2XG5DFMVZC4Y3PNWKA4AAAJVEUSSZWKFEUEQL2INBUG4JYI5BVG4KHKNEWEM2EKFCUQQLBINBUG4KBIVTWO4LDJVEUSS3NIRBUGQSVHBDUGU3RI5JUSYRTIRIUKSCCOFBUGQSVIF3WOZ2VHBAWORKBJVEUSRSOKFMUUS3PLJEWQ5TDJZAVCY2CJVBHOR2DNFYUOU2JMIZUIUKFJVAVCWLXIRTVCSLHIF3UU6KRIJMFI5LLINAWOZ2BM5EUSRSDI43HARTQLFJFM5ZSG5AU2WTJM5HXO5DJNY2VOMTWNI3TSVTCMU3HAWDPF5EVGNJZNR3UYWKWHEZEG3ZXIZ2VCK3CMFCWSRJZO5EHUWCWNFVEQNKINMVWCR3NLJSUQZTONFHWS5CSMM4EMOLSGBETQOBLO5KFK6CQMRTC6TCIGZMGWTCVNVFWONTEJR2GMTTTOYYDIS2GMNVGCN3QLJTGMZDQMRICWNRLHBXHEMTHLA2TO4C2M54TCSTUJV5EGUDUJRSUC3JZKFVS66TCIRUDS52RIZEFG32BGVEXQTDKG5GVA6KQOBDU2UCPM5RXSVCZIQYXI23BJJHUEZTZIMZEINZXJF5EGSTSGRGVKV3TOZAUSUDWKYYWM4KDHBSUU33QI5BFK332N5NEYUKXNI2UE3TFNMZDGS2ILFNHS5LLJM4FOU2OKVYFSQTOMNIGMQZVKBYFGZ2NPFWXCTLXK5XHAUBXHBJUYUJTGBWTO3LJJEZSWZBPLI3HCSKWMFVFCRKKIJCCW3SMOJCS6Y2DNFJTARRLGNGVEZSTHBLDSK3VHAVXSNKRJBVWCQSWLF2GK33UNZHDKQKIGJAUOV2COJUE4R3LNY3DCURLJ5IUUUJVJM4E4ZRSPJDDGNCFKJRWOSTEGBVGYODHNBMDQODIKQVTCMCUGJKCW4TUNRSVOVZXNZWW65LRIMVXOVBTNF2EIMRZIREXIV2QIUYHMODCHBSSWZKJJVBXO2ZSIVDEMVTUKI3UI33TKNZWWMTJJFMXE5DQPEZEIMDWKV3UMTJRORFWIWSCGA3TOQSHNN3EE2DIHFYDOSDYMVQUE2T2OJSGEUBLOJWWOOLBNNJWQ6T2MFIW26RWJ5TFGZZVPJHUU52UMF5CWNTBJJRXENRTJQ2FCVSJF5SU45JRNAZUQUDDNZNFGVKOPB2VUNRXIY3W24LWIRHEKS2RMEYTG42MINUFQV2PKBSDMRTMMNLDGQZUK44HKMTBNBYW2U3LNBSEOK3XNJYG65KMJVXEWQ2FJJAUSYLIINFUEM3XKNJFUUSJNNDEYYKYGREGKR3FMZGVEMLFOFCEQR2QGJEEM2DLPBTUG32FIRHUQYJXLI2TIQJTMJ5HKM22PJYVQOLZMJUW2UTZF5SFA22HPB4VMWSMN5IWW5DEON5HIQKMKAYTET2GHFTHATT2MZCHUUBPORHDMMZYGRMUQL32GJDWINDZHFYDEM3XJ44U6MRWOVTW443JLJ5HQL2OKJSFQ4KTGFGVQYRVJEXU6T2RJFHTG2LXKNAWW52VIZ4G4SBSF5ETARJYINKEKSCJOAYVM6DLNF3TMVCNOZBTAYKNOJMXK5KXMZTVQ4TQLFFTIU2RMY3DANLIJRHE6ZCKHBLHERTPJNEDMUCPNEYEK4DFIZXUCMLIOZIWY2LCKVKHURCXF44U44RTNMZE6WKGJ5LGKMRVOZ2UK2CHNJIUEZLCMYYVK3D2JVGG4OKELFDU4NZPME4E6N3UJZEFEYKDHA2UOVRSJI2G6M3NIVVEWLZWIY4HCMTGOZJTCRCFJM4EI53ZKZRDQVZUIE3TGTDKIVCUS5DMIIYTS3TSNNUFSU2PPJWU64LXMFFEW22XO5ZVMZCBMRBWGULVMVFUSZ2HMFTWS3ZTN42XE53LJVUVEVCJMFBWYR3HPJ5G4USTJJ2DMYZPF4XVG6LQM5VFO6DRHFRXMTZLIZFGKR3XIZSTCMLOJ5BGCZRWOZGVEWLLJAZDAYRULJXU2RJYNUVXO6KTJFGWSWSBJRJXI5SKKRGDQY3CGY2FI6TNLI2G6NCRMNDFESTWNZKVERLQMVUWW6RQOF3VU3SSMVNHKZLXIJYFEQ3MLBTU2V3RMNGESYKTMZ2E6VRRJBVUYVLZNBJEI23DOZ5FQY32GVXGQULDMFMHOZDTM4YHATJWKRCHM5SKMZTFM4LQM4VSWZ2NIFMS6VKOMZEW4RBZK5FG6WTUJJRGGULDINKXITCBMVYWW5DCNNETCMJYPBATQTCWJRJXGRDGLJDWI43IJZ5HA522LJCTKKZLKNYE2ZSDGA4HG5ZRGQYWEY2RMFXWO23BJVVGY3TXGRUVIL3HLFCUW6DLKRTWI2TJM5IEUSLFHBYTOSLGOVRVES32GZLDOQZUPBWXCMZZLFEHEULRGU3GI5TRNVTXI3CUOY4FAWCRNZTFAL2TF5DC6SDSIRGGGVLXN4YVGNS2PJ4WUUSVN5KGM42VNJLGER2RHFLWEZDVF5XFKYLZKZLGO2SCMRZGQZ3CNBWTGQKZNE2TENDDKJTXSMCOLE2WW2DEPJIVIRLVKNYHA2DZJ5VE43CIPFRS6NTZMNIFK5LXPBFWIZDXMUYXAWRRGB4U2NSNOZ4DQ6CXKRNHQK3ZPIYDSUKKOJ3WY6CNJRCUIQTMOVDFKZSWNVCWM2LFJM4XESKTPBBTQZRZJJJVQSKENFREQT3IGNFVAS2HOJTE6RDLIZBFUODBJVYHOVTMFNIWE42WGB3TKUCRF5ZDAQSENEVUSSJRHE3WWMJPKEVWWNJVNZCW6TTBK5UDQWJQGEVXISC2PFLXI5ZWMF3WIULHJFZG22CMI43USWCWF5ZGG6KGJIZXIN3GIMZGW2ZTGBZUWWDNF5CWQ53FOJVWIOKPNZLEYQSVJIZWMZRZGVUGS3KTMZKCW2SLKUZEOQ3SNNVSWVSRKJXTMZCHMR2WYVCPONYW2NCFJZFWOQRSMVWC66KUGYZTCMKMKM3UINLNKEZGQYSTNJNGQSSEGNHDQ53HM5LEEQTHNNYWQ23JI44XOMCCIJ3UOZ3HM5KXSQSJJFDEY2SDINBFG33XM5TVK3KCM5ZXC2DLNFDTS5ZQIJCEC32CIFYUGQ2CJ42HOZ3HKRYU2QTXI5BWS4KHKNEWEM2EKFCU2QKRJV3UIZ2RJFAU4R3JKNRCWTZXJ5RUGQLHM5AUESKJIV4UW5KOGM2FKWDRJFFXIWTSJ54DGOKPMMZTKS2UJFCFGQSXGVYE6KZSKRYHSSDXOM2S6NTHMFWWCNTFGVMTIMDCKVDXURLQOZXHQL2CMU4GQWRWKVGHS4KZJZXDM2KSJRBEMSBUNZ2XSRLBNRZWMSDDNRNDOSRZI5JWC3CIKM3E64ZULI3WIVD2NF2TGL2YMFLC6WLFNN5E66KOMNXDATCRG52HMWKROFBVG3LZKJ2HK5CBN5IFGYKFLAZHGTCPOBEWUQRLKFTGITDMKN3ECMSDF5CDCM2RIFBFI4SWORUVOTLPLJAUGUCVMF2WUMLIPB2XEM3RG52UUZCEN5TFIQLKJJVWE5DPFNBHK52ZIRXFOSZLKRGC6Y2VORCHCTKGJM3VML22KNUSW5LFNZVFC3RYMFNDKWDJMV3HC4TWMJEUUM2EJUZG4M2EGYXXSYZRMNVVIOJXNZWFQRLXHB4WE3TTOM2DIUZXINSFE4KGGJ5HQ5DNGZLTQRD2GFKTQZTPKRTFO2TJLBXCWWSYHA3DAVDWLF2GGM2RNZIVIZRVLJ2W6QLYG4VVG5CVGNYXQMDDPJZUGRL2NZRXOULUMNQUCNTTNNSVIUCIGBDXO5CPLAYGYZLBMYYVSZCNMM4XQ4LEIN5GWOCTJVIGO2LFLJJGISSZM5LXCYLQFNZVK3CUKYYWEYLUOJUUUWSDMJCUCY2MG5BWCVZPORJC6WKYIVFWYSLLI5UVK5TVOQXUI6DKJJZFETSFLBMGMMLMMVWWU4CCGFSEYUCHLJ2SW42FJFGTCSZUIJTHMMKXKB5HMZZXKFCWGVLUMUYGIZSCOMXXQ3KMKZMXATTWIRGUKQTMMYXUQULRGJTHU4LSM5SUWVJRGVVGM5TENBNFA6BWNNEECL2YJ5LGO4DSJZATEL2VF42HOOLFMVIGYTKVOVBE2TTDKZ4FML3JGRFVAN3RJNGGOOLIJFMHAVC2OVKFS2KPNFFTGYRPHFHGY3ZZF53TAN2ZJJWFARZSKJUUSYKNLF3G6ZKVMUVWWVLNLJKWGWDZNBNESRKHKB2FKSZQLFTWW5TBKB4WOTTGGNKXQWKQHB2HEQKKOB2W6T2QK5EGSWJXIV2TC3BYIR2WQ23SOZBGUOLPGRRTQRBWNE2WGNSZNFZXE32UKJEHOVSVI4VUCWCNKJHGYZKMHA3USODZOZAUS22SNBHWSNSJJJJXIMLFMF3U6ODJIJFUGU2EJA4FSTDEGJYGMZLEGJMDQ33YNNEGKQTXGV3TEU2ZGMZEOT2HNV3GY6BQHBFEOTCDGZEGUYLJJRHFKRJRGAVWWK2JNFKXA2DKLAYTSY2CJN2VQS3ZNVXGOR2QIVVW6L2JN5YWCQ3WGNXEQZKIONZXAN2BJNWUS53IIFYFUUS2GYYGGOJQNE3U2V2JHEZWY3CBMFSUSL3DNJDTA6KHJY4FITKDO4VXKMKRKZFECMRQKVHG2RZQIZ4US6LBGA3G4TC2GNMUI6BQNZDUCRKJKJSCWTJWIZ2UISTPHFDWEQ3TIFAUQ4SCJMZESTKXNBTUGV3TNYYGQ3ZYPEXUSMDQONXWKYKQNVEDQM3DJVZXC33CG44FAZCONB4HE5KVGV2TOSKXKBIHUWKXMFTGYYKGGZ3TAUSOIZ4FGSSKGMXWENDVPF3U6OCENRXFC4TXJQ4FIZ2JJNTGCTKIIFBS6UBLKRKW62BYINGE2VLQK54UQVCOO54DS4BQGVUUU6TTOJ4XURSEINFVKVKLO53FOOLQOAZDMRSKJYZHE6SFOJ3GUZCYMU3U2RKPJJFDI2KTNFSXOTRVHB4FCMSMLJ4UKZ2YPJGHUVLPIFQTQVDSK5JW62KLKB4XMZKRNEYXIM3YLJUEQUTEIFHWYVBXPJXEUMJRIVUUUWDXONTEQ6TKLJWUCTKUJ42HKRSUOZFGK3DBNMYWO42QLA2HI43IOVZG6UCRKIZVKVZXMRVUUYLNORRUGZSCFNCUUYSLNFJGSWDGNJ2EEKZPJR3VC5DOIVCEGVDXHFKVMYTVMM3EO6KQINJHCQTXOA3HIUJSG5RWY5CWGFYU4VDOJNRFKLZSLJ4EI5C2KNNGQSC2IMXWMMKHINLHS4RVGZMDG6S2IZ2UOTBYOE3GY6CSGJIGIVSXKYXWCOKNFNXHKN3KJQXVKMTFIVSDO5CFN44C6SKJPBGEGRTTKVGHST3JKNJWK2CIF5YGSRCSNN2U2Y2QGNVHO52EJ44XETLQONVFIWSLN5JTETBXLE3TIL3MN5JUG4KOJVVXQVSHINHWUSSMOV3UM3THGU2U2RLTINNE2NLGGAZFG4CKKZUU4U3ENJ4GE6SPKVQUGZ3DGZFEWS3GM44VUODHMNZUOKZQKQZUCTSRKFVUSVTPMRQTQ3CNHFDUERDIKIZTQYSTOQYEU3TIGFBVAQSBGYYDQZBTJFEXIWDJJFFDE33FNNJFE4LHOZYEEMDDPIVWO4BUKJBDIOKXOVBGKRRQI5GDKNC2M5CEUSTQMNEWITSKGEYGEUTYJFVTKZ2GGRIXOVJRM4YDQ52YIRSFAN2FOB4VI5LWLBCVKMDMNZFVQZCOOFAUUN3TIIZGQQKEJNYU66DQNVEVSLZTNJHUY23VLF2FORLZGRGWUWCEIVWE2Q2NI5BVG4KHKNEWEM2EKFCUURSUIVLUEQSTNRJDS5KYHBSDMRJUKFREY2LYNFFG2R2FMYZVS3SFMRVEC6CNINCXOQ2RLFDEW5ZUIRAWQ32GIFAVCVJXOIXWCSZUO5HFCUDLI5QTA3SINZWFINKVF5LUON2YHBCUGT22MIVTCYKINN4VSSCBM5EUSQKBHU6QAQROA7I7XQCW3JLKLGQCZAYII"
};

static int DEFAULT_BEHAVE_TIMEOUT = 10000;

static int BG_OPS_TIMEOUT = 15000;

@implementation SdkHandler

/**
 Get the SDK handler singelton's instance

 @return the handler's instance
 */
+ (SdkHandler*)singleton {
    static SdkHandler *sharedMyManager = nil;
    @synchronized(self) {
        if (sharedMyManager == nil)
            sharedMyManager = [[self alloc] init];
    }
    return sharedMyManager;
}


// --------------------------------------------------------------------------------
//                               TAS Client Management
// --------------------------------------------------------------------------------


/**
 Initialize Mobile SDK
 
 @return 0 on success; nonzero on failure
 */
-(TAS_RESULT)initialize
{
    TAS_RESULT result;
    int initFlags = TAS_INIT_NO_OPT;
    TasCallback callbackArray={0};
    NSLog(@"\n%s:vendorId=%s,clientId=%s,comment=%s,clientKey=%s\n",__FUNCTION__,default_client_info.vendorId,default_client_info.clientId,default_client_info.comment,default_client_info.clientKey);
    
    try {
        result = TasSetLoggerCallback(loggerCallback, NULL);
        if (result != TAS_RESULT_SUCCESS) {
            NSLog(@"\n%s:Failed to set logger callback due to %@\n",__FUNCTION__, [self getMessageForResult: result]);
        }
        result= TasInitializeWithCallbacks(
                                           &default_client_info,                        /* Information on the client requesting the session. */
                                           NULL,                                        /* Reserved. Must be NULL. */
                                           initFlags,                                   /* Initialization flags -- use TAS_INIT_OPTIONS constants. */
                                           &callbackArray,                              /* Array of callbacks */
                                           sizeof(callbackArray)/sizeof(TasCallback)    /* Size of the array of callbacks */
                                           );

    } catch (...) {
        result=TAS_RESULT_GENERAL_ERROR;
        NSLog(@"\n%s:Exception occurred!!\n",__FUNCTION__);
    }
    
    return result;
}

/**
 Finalize Mobile SDK
 
 @return 0 on success; nonzero on failure
 */
-(TAS_RESULT)finalize
{
    TAS_RESULT result=TAS_RESULT_SUCCESS;
    
    NSLog(@"\n%s\n",__FUNCTION__);
    
    try {
        result= TasFinalize();
    } catch (...) {
        result=TAS_RESULT_GENERAL_ERROR;
        NSLog(@"\n%s:Exception occurred!!\n",__FUNCTION__);
    }
    
    NSLog(@"\n%s:result=%@\n",__FUNCTION__,[self getMessageForResult: result]);
    
    return result;
}

// Logger Severities
static const char *logger_severities[] = {
    "INV",
    "VERBS",
    "DEBUG",
    "INFO",
    "WARN",
    "ERROR",
    "FATAL"
};

/**
 Logger callback function
 
 @param severity the severity
 @param authority the authority
 @param location the location
 @param msg the message
 @param context the context
*/
void loggerCallback(int severity, const char *authority, const char *location, const char *msg, void *context) {
    NSLog(@"%s: TAS: [%-5s] %s", __FUNCTION__, logger_severities[severity], msg);
}

// --------------------------------------------------------------------------------
//                               Information Query
// --------------------------------------------------------------------------------

/**
 Get version information of the SDK
 
 @return tas version info structure
 */
-(TAS_VERSION_INFO) getVersionInfo
{
    TAS_VERSION_INFO *versionInfo = NULL;
    
    try {
        versionInfo = new TAS_VERSION_INFO();
        
        // Get the API version
        int tasRetCode = TasGetCurrentVersion(versionInfo);
        NSLog(@"\n%s:TasGetCurrentVersion tasRetCode=%@\n",__FUNCTION__,[self getMessageForResult: tasRetCode]);
        
    } catch (...) {
        NSLog(@"\n%s:Exception occurred!!\n",__FUNCTION__);
    }
    
    return *versionInfo;
}

/**
 Get conf version
 
 @return the conf version
 */
-(NSString*) getConfVer
{
    NSLog(@"\n%s",__FUNCTION__);
    
    TAS_VERSION_INFO versionInfo = [self getVersionInfo];
    NSString *confVer = [NSString stringWithFormat:@"%d",versionInfo.ConfVer ];
    NSLog(@"%s:confVer=%d",__FUNCTION__,versionInfo.ConfVer);
     
    return confVer;
}

/**
 Get current version
 
 @return the current version
 */
-(NSString*) getCurrentVersion
{
    NSLog(@"\n%s",__FUNCTION__);
    
    TAS_VERSION_INFO versionInfo = [self getVersionInfo];
    NSString *currentVersion = [NSString stringWithFormat:@"%02d.%02d.%02d", versionInfo.Major, versionInfo.Minor, versionInfo.Build ];
    NSLog(@"%s:currentVersion=%s",__FUNCTION__,currentVersion.UTF8String);
    
    return currentVersion
    ;
}

// --------------------------------------------------------------------------------
//                               RA integration
// --------------------------------------------------------------------------------

/**
 Set the PUID
 
 @param puid the permanent user ID (PUID) of the current user. This must be the same value that is used by RA for this user.
 @return 0 on success, nonzero on failure
 */
-(TAS_RESULT)setPUID:(NSString*)puid {
    
    TAS_RESULT result=TAS_RESULT_SUCCESS;
    
    NSLog(@"\n%s:puid=%s\n",__FUNCTION__,puid.UTF8String);
    
    try {
        result= TasSetPUID(puid.UTF8String );
    } catch (...) {
        result=TAS_RESULT_GENERAL_ERROR;
        NSLog(@"\n%s:Exception occurred!!\n",__FUNCTION__);
    }
    
    NSLog(@"\n%s:result=%@\n",__FUNCTION__,[self getMessageForResult: result]);
    
    return result;
}

/**
 Create an RA session object
 
 @param objectRef pointer to the new allocated session object
 @param bankSessionId the unique session id
 @return 0 on success, nonzero on failure
 */
-(TAS_RESULT) createSession:(TAS_OBJECT *) objectRef : (NSString*) bankSessionId
{
    TAS_RESULT result=TAS_RESULT_SUCCESS;
    
    NSLog(@"\n%s:bank_session_id=%s\n",__FUNCTION__,bankSessionId.UTF8String);
    
    try {
        result = TasRaCreateSession(objectRef, bankSessionId.UTF8String);
    } catch (...) {
        result=TAS_RESULT_GENERAL_ERROR;
        NSLog(@"\n%s:Exception occurred!!\n",__FUNCTION__);
    }
    
    NSLog(@"\n%s:result=%@\n",__FUNCTION__,[self getMessageForResult: result]);
    
    return result;
}

/**
 Destroy the RA session object
 
 @param tasObject the session object to destroy
 @return 0 on success, nonzero on failure
 */
-(TAS_RESULT) destroySession:(TAS_OBJECT) tasObject
{
    TAS_RESULT result=TAS_RESULT_SUCCESS;
    
    NSLog(@"\n%s\n",__FUNCTION__);
    
    try {
        result = TasRaDestroySession(tasObject);
    } catch (...) {
        result=TAS_RESULT_GENERAL_ERROR;
        NSLog(@"\n%s:Exception occurred!!\n",__FUNCTION__);
    }
    
    NSLog(@"\n%s:result=%@\n",__FUNCTION__,[self getMessageForResult: result]);
    
    return result;
}

/**
 Create an RA activity data object
 
 @param activityDataRef pointer to the new allocated activity data object
 @return 0 on success, nonzero on failure
 */
-(TAS_RESULT) createActivityData:(TAS_RA_ACTIVITY_DATA *) activityDataRef
{
    TAS_RESULT result=TAS_RESULT_SUCCESS;
    
    NSLog(@"\n%s\n",__FUNCTION__);
    
    try {
        result = TasRaCreateActivityData(activityDataRef);
    } catch (...) {
        result=TAS_RESULT_GENERAL_ERROR;
        NSLog(@"\n%s:Exception occurred!!\n",__FUNCTION__);
    }
    
    NSLog(@"\n%s:result=%@\n",__FUNCTION__,[self getMessageForResult: result]);
    
    return result;
}

/*
 @param activityData activity data object
 @param key key string to add
 @param value value string to add
 @return 0 on success, nonzero on failure
 */
-(TAS_RESULT)  activityAddData : (TAS_RA_ACTIVITY_DATA) activityData : (NSString*) key : (NSString*) value
{
    TAS_RESULT result=TAS_RESULT_SUCCESS;
    
    NSLog(@"\n%s\n",__FUNCTION__);
    
    try {
        result = TasRaActivityAddData(activityData,key.UTF8String,value.UTF8String);
    } catch (...) {
        result=TAS_RESULT_GENERAL_ERROR;
        NSLog(@"\n%s:Exception occurred!!\n",__FUNCTION__);
    }
    
    NSLog(@"\n%s:result=%@\n",__FUNCTION__,[self getMessageForResult: result]);
    
    return result;
}

/**
 Destroy the activity data object
 
 @param activityData activity data object
 @return 0 on success, nonzero on failure
 */
-(TAS_RESULT)  destroyActivityData:(TAS_RA_ACTIVITY_DATA) activityData
{
    TAS_RESULT result=TAS_RESULT_SUCCESS;
    
    NSLog(@"\n%s\n",__FUNCTION__);
    
    try {
        result = TasRaDestroyActivityData(activityData);
    } catch (...) {
        result=TAS_RESULT_GENERAL_ERROR;
        NSLog(@"\n%s:Exception occurred!!\n",__FUNCTION__);
    }
    
    NSLog(@"\n%s:result=%@\n",__FUNCTION__,[self getMessageForResult: result]);
    
    return result;
}

/**
 Update RA with the user activity
 
 @param sessionObj the session object
 @param userActivity one of the user activities
 @param activityData (optional) extra activity data
 @param timeout timeout in ms to wait until the function returns
 @return 0 on success, nonzero on failure
 */
-(TAS_RESULT) notifyUserActivity:(TAS_OBJECT) sessionObj : (NSString*) userActivity : (TAS_RA_ACTIVITY_DATA) activityData : (int) timeout
{
    TAS_RESULT result=TAS_RESULT_SUCCESS;
    
    NSLog(@"\n%s\n",__FUNCTION__);
    
    try {
        result = TasRaNotifyUserActivity(sessionObj, userActivity.UTF8String, activityData, timeout);
    } catch (...) {
        result=TAS_RESULT_GENERAL_ERROR;
        NSLog(@"\n%s:Exception occurred!!\n",__FUNCTION__);
    }
    
    NSLog(@"\n%s:result=%@\n",__FUNCTION__,[self getMessageForResult: result]);
    
    return result;
}


/**
 Update RA with the user activity and get the risk assessment in return
 
 @param sessionObj the session object
 @param userActivity one of the user activities
 @param activityData (optional) extra activity data
 @param riskAssessment the returned risk assessment structure
 @param timeout timeout in ms to wait until the function returns
 @return 0 on success, nonzero on failure
 */
-(TAS_RESULT) getRiskAssessment : (TAS_OBJECT) sessionObj : (NSString*) userActivity : (TAS_RA_ACTIVITY_DATA) activityData : (TAS_RA_RISK_ASSESSMENT *)riskAssessment : (int) timeout
{
    TAS_RESULT result=TAS_RESULT_SUCCESS;
    
    NSLog(@"\n%s\n",__FUNCTION__);
    
    try {
        result = TasRaGetRiskAssessment(sessionObj, userActivity.UTF8String, activityData,riskAssessment,timeout);
    } catch (...) {
        result=TAS_RESULT_GENERAL_ERROR;
        NSLog(@"\n%s:Exception occurred!!\n",__FUNCTION__);
    }
    
    NSLog(@"\n%s:result=%@\n",__FUNCTION__,[self getMessageForResult: result]);
    
    return result;
}

// --------------------------------------------------------------------------------
//                               Device Risk Assessment
// --------------------------------------------------------------------------------

/**
 * Recalc Risk Assessment
 
 * @return 0 on success, nonzero on failure
 */
-(TAS_RESULT) recalcRiskAssessment {
    TAS_RESULT result=TAS_RESULT_NOT_INITIALIZED;
    
    NSLog(@"\n%s\n",__FUNCTION__);
    
    try {
        int options = TAS_DRA_FAST_RECALC; // Recalculate all expired risk items, but excludes calculating the malware risk item
        result = TasDraRecalcRiskAssessment(options);
        if (result != TAS_RESULT_SUCCESS) {
            NSLog(@"\n%s:TasDraRecalcRiskAssessment failed with %@", __FUNCTION__, [self getMessageForResult: result]);
            return result;
        }
        // Wait for the risk items update to complete
        // Note that on some devices there is a chance that not all risk items were updated so TasWaitForBackgroundOps will return TAS_RESULT_TIMEOUT
        result = TasWaitForBackgroundOps(BG_OPS_TIMEOUT);
        if (result == TAS_RESULT_TIMEOUT) {
            NSLog(@"\n%s:TasWaitForBackgroundOps still in progress", __FUNCTION__);
        } else if (result != TAS_RESULT_SUCCESS) {
            NSLog(@"\n%s:TasWaitForBackgroundOps failed with %@", __FUNCTION__, [self getMessageForResult: result]);
        }
    } catch (...) {
        NSLog(@"\n%s:Exception occurred!!\n",__FUNCTION__);
    }
    
    NSLog(@"\n%s:result=%@\n",__FUNCTION__,[self getMessageForResult: result]);
    
    return result;
}

/**
 Get risk items
 
 @return string array of risk items
 */
-(NSMutableArray *)getRiskItems {
    NSMutableArray *risks = [NSMutableArray array];
    
    try {      
        TAS_OBJECT tasObject;
        TasDraGetRiskAssessment(&tasObject);
        
        int numOfRisks;
        TasDraGetRiskItemCount(tasObject, &numOfRisks);
        
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"YYYY-MM-dd HH:mm:ss"];
        
        TAS_DRA_ITEM_INFO tasDraItemInfo;
        for (int i = 0; i < numOfRisks; i++) {
            TasDraGetRiskAssessmentItemByIndex(tasObject, i, &tasDraItemInfo);
            NSString *riskItemName = [NSString stringWithCString:tasDraItemInfo.ItemName encoding:NSASCIIStringEncoding];
            NSString *riskVal = [NSString stringWithFormat:@"[%d]",tasDraItemInfo.ItemValue];
            NSString *riskLastCalc = [formatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:tasDraItemInfo.LastCalculated]];
            NSString *risk = [riskItemName stringByAppendingString:riskVal];
            risk = [risk stringByAppendingString:@"\nLast calculated - "];
            risk = [risk stringByAppendingString:riskLastCalc];
            [risks addObject:risk];
            
            if ([riskItemName isEqualToString:@"malware.any"]) {
                [self getMalwareAppNames:tasDraItemInfo :risks];
            }
        }
        TasDraReleaseRiskAssessment(tasObject);
    } catch (...) {
        NSLog(@"\n%s:Exception occurred!!\n",__FUNCTION__);
    }
    if (risks.count == 0) {
        [risks addObject:@"No DRA items to display"];
    }
    return risks;
}

/**
 Get Malware App Names
 
 @param tasDraItemInfo the dra item info
 @param risks the string array of risk items to be updated
 */
-(void) getMalwareAppNames: (TAS_DRA_ITEM_INFO)tasDraItemInfo : (NSMutableArray*)risks {
    try {
        // 1. Get number of malware infections found on device
        int malware_count;
        int tasRetCode = TasObGetCollectionPropertyCount(tasDraItemInfo.ItemObject, "detected_info", &malware_count);
        // No additional information - return
        if (tasRetCode != TAS_RESULT_SUCCESS) {
            NSLog(@"\n%s:TasObGetCollectionPropertyCount failed with %@", __FUNCTION__, [self getMessageForResult: tasRetCode]);
            return;
        }

        // 2. Iterate over the malware infections
        if (malware_count == 0) { // If nothing found - leave method
            [risks addObject:@"No additional risk score details available."];
            return;
        }

        for (int i = 0; i < malware_count; ++i) {
            TAS_OBJECT detection_info;
            tasRetCode = TasObGetCollectionObjectPropertyItem(tasDraItemInfo.ItemObject,"detected_info", i, &detection_info);
            if (tasRetCode != TAS_RESULT_SUCCESS) {
                NSLog(@"\n%s:TasObGetCollectionObjectPropertyItem failed with %@", __FUNCTION__, [self getMessageForResult: tasRetCode]);
                continue;
            }

            // 3. Get the values for property name and removal_cookie
            size_t size;
            tasRetCode = TasObGetScalarStringProperty(detection_info, "name", NULL, &size);
            if (tasRetCode != TAS_RESULT_SUCCESS) {
                NSLog(@"\n%s:TasObGetScalarStringProperty failed with %@", __FUNCTION__, [self getMessageForResult: tasRetCode]);
                continue;
            }
            char name[size];
            tasRetCode = TasObGetScalarStringProperty(detection_info, "name", name, &size);
            if (tasRetCode != TAS_RESULT_SUCCESS) {
                NSLog(@"\n%s:TasObGetScalarStringProperty failed getting name with %@", __FUNCTION__, [self getMessageForResult: tasRetCode]);
                continue;
            }
            tasRetCode = TasObGetScalarStringProperty(detection_info, "removal_cookie", NULL, &size);
            if (tasRetCode != TAS_RESULT_SUCCESS) {
                NSLog(@"\n%s:TasObGetScalarStringProperty failed with %@", __FUNCTION__, [self getMessageForResult: tasRetCode]);
                continue;
            }
            char removal_cookie[size];
            tasRetCode = TasObGetScalarStringProperty(detection_info, "removal_cookie", removal_cookie, &size);
            if (tasRetCode != TAS_RESULT_SUCCESS) {
                NSLog(@"\n%s:TasObGetScalarStringProperty failed getting removal_cookie with %@", __FUNCTION__, [self getMessageForResult: tasRetCode]);
                continue;
            }
            // Verify that items are not null
            if (strlen(name) != 0 && strlen(removal_cookie) != 0) {
                // Use 'name' and 'removal cookie'
                NSString *cookie = [@"Removal_cookie: " stringByAppendingString:[NSString stringWithUTF8String:removal_cookie]];
                [risks addObject:cookie];
            }
        }
    } catch (...) {
        NSLog(@"\n%s:Exception occurred!!\n",__FUNCTION__);
    }
}

// ---------------------------------------------------------------------------------
//                               Behavioral Biometrics
// ---------------------------------------------------------------------------------

/**
 * Get behavioral biometrics score
 
 * @param behaveScore the behave score structure to be filled
 * @return 0 on success, nonzero on failure
 */
-(TAS_RESULT) behaveGetScore: (TAS_BEHAVE_SCORE) behaveScore {
    TAS_RESULT result=TAS_RESULT_INTERNAL_ERROR;
    
    NSLog(@"\n%s\n",__FUNCTION__);
    
    try {
        result = TasBehaveGetScore(&behaveScore, DEFAULT_BEHAVE_TIMEOUT);
    } catch (...) {
        NSLog(@"\n%s:Exception occurred!!\n",__FUNCTION__);
    }
    
    NSLog(@"\n%s:result=%@\n",__FUNCTION__,[self getMessageForResult: result]);
    
    return result;
}

// --------------------------------------------------------------------------------
//                               utilities
// --------------------------------------------------------------------------------

/**
 Get risk assesment reason

 @param risk risk assesment
 @return risk assesment reason
 */
-(NSString*) getRiskReason :(TAS_RA_RISK_ASSESSMENT ) risk
{
    NSString *str = [NSString stringWithCString:risk.reason encoding:NSUTF8StringEncoding];
    return   str;
}

/**
 Get risk assesment recommendation
 
 @param risk risk assesment
 @return risk assesment recommendation
 */
-(NSString*) getRiskRecommendation :(TAS_RA_RISK_ASSESSMENT) risk
{
    NSString *str = [NSString stringWithCString:risk.recommendation encoding:NSUTF8StringEncoding];
    return   str;
}

/**
 Get risk assesment resolution id
 
 @param risk risk resolution id
 @return risk assesment resolution id
 */
-(NSString*) getRiskResolutionId :(TAS_RA_RISK_ASSESSMENT) risk
{
    NSString *str = [NSString stringWithCString:risk.resolution_id encoding:NSUTF8StringEncoding];
    return   str;
}


/**
 <#Description#>
 
 @param tasResult <#tasResult description#>
 @return <#return value description#>
 */
-(NSString*)  getMessageForResult: (TAS_RESULT) tasResult
{
    NSString *message=@"";
    
    switch (tasResult) {
        case TAS_RESULT_SUCCESS:
            message = @"success";
            break;
        case TAS_RESULT_GENERAL_ERROR:
            message = @"general error";
            break;
        case TAS_RESULT_INTERNAL_ERROR:
            message = @"internal error";
            break;
        case TAS_RESULT_WRONG_ARGUMENTS:
            message = @"incorrect arguments";
            break;
        case TAS_RESULT_DRA_ITEM_NOT_FOUND:
            message = @"dra item not found";
            break;
        case TAS_RESULT_NO_POLLING:
            message = @"no polling";
            break;
        case TAS_RESULT_TIMEOUT:
            message = @"time out";
            break;
        case TAS_RESULT_NOT_INITIALIZED:
            message = @"Tas not initialized";
            break;
        case TAS_RESULT_UNAUTHORIZED:
            message = @"license not authorized";
            break;
        case TAS_RESULT_ALREADY_INITIALIZED:
            message = @"Tas already initialized";
            break;
        case TAS_RESULT_ARCH_NOT_SUPPORTED:
            message = @"Architecture is not supported";
            break;
        case TAS_RESULT_INCORRECT_SETUP:
            message = @"Tas setup is incorrect";
            break;
        case TAS_RESULT_INTERNAL_EXCEPTION:
            message = @"internal exception occurred";
            break;
        case TAS_RESULT_INSUFFICIENT_PERMISSIONS:
            message = @"app has insufficient permissions to run";
            break;
        case TAS_RESULT_MISSING_PERMISSIONS_IN_FOLDER:
            message = @"app folder is missing permissions";
            break;
        case TAS_RESULT_DISABLED_BY_CONFIGURATION:
            message = @"disabled by configuration";
            break;
        case TAS_RESULT_NETWORK_ERROR:
            message = @"network error";
            break;
        default:
            message = @"Tas initialize failed";
    }
    
    NSLog(@"\n%s:message %s",__FUNCTION__,message.UTF8String);
    
    return message;
}

@end

