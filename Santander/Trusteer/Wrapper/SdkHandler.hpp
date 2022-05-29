//
//  SdkHandler.hpp
//  tas_example_app
//
//  Copyright © 2018 com.ibm. All rights reserved.
//

#ifndef SdkHandler_hpp
#define SdkHandler_hpp

#import <Foundation/Foundation.h>
#include "taslib.h"

@interface SdkHandler : NSObject

+ (SdkHandler*)         singleton;

-(TAS_RESULT)           initialize;
-(TAS_RESULT)           finalize;
-(TAS_VERSION_INFO)     getVersionInfo;
-(TAS_RESULT)           setPUID:(NSString*)puid;
-(TAS_RESULT)           createSession : (TAS_OBJECT *) objectRef : (NSString*) bankSessionId;
-(TAS_RESULT)           destroySession : (TAS_OBJECT) tasObject;
-(TAS_RESULT)           createActivityData : (TAS_RA_ACTIVITY_DATA *) activityDataRef;
-(TAS_RESULT)           activityAddData : (TAS_RA_ACTIVITY_DATA) activityData : (NSString*) key : (NSString*) value;
-(TAS_RESULT)           destroyActivityData : (TAS_RA_ACTIVITY_DATA) activityData;
-(TAS_RESULT)           notifyUserActivity : (TAS_OBJECT) sessionObj : (NSString*) userActivity : (TAS_RA_ACTIVITY_DATA) activityData : (int) timeout;
-(TAS_RESULT)           getRiskAssessment : (TAS_OBJECT) sessionObj : (NSString*) userActivity : (TAS_RA_ACTIVITY_DATA) activityData : (TAS_RA_RISK_ASSESSMENT *)riskAssessment : (int) timeout;

-(NSString*)            getRiskReason :(TAS_RA_RISK_ASSESSMENT) risk;
-(NSString*)            getRiskRecommendation :(TAS_RA_RISK_ASSESSMENT)risk;
-(NSString*)            getRiskResolutionId :(TAS_RA_RISK_ASSESSMENT)risk;

-(NSString*)            getCurrentVersion;
-(NSString*)            getConfVer;
-(NSString*)            getMessageForResult:(TAS_RESULT) tasResult;

-(TAS_RESULT)           recalcRiskAssessment;
-(NSMutableArray *)     getRiskItems;
-(void)                 getMalwareAppNames: (TAS_DRA_ITEM_INFO)tasDraItemInfo : (NSMutableArray*)risks;

-(TAS_RESULT)           behaveGetScore: (TAS_BEHAVE_SCORE) behaveScore;

@end

#endif /* SdkHandler_hpp */
