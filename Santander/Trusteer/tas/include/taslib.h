#ifndef __taslib_h_included__
#define __taslib_h_included__

#ifdef __cplusplus
#include <string>
#include <map>
extern "C"
{
#endif

#include <time.h>
#include <netinet/in.h>
#include <stdbool.h>

#define ADDITIONAL_DATA_MAX_LENGTH 4096
#define RA_RISK_ASSESSMENT_RECOMMENDATION_MAX_LENGTH 256
#define RA_RISK_ASSESSMENT_RESOLUTION_ID_MAX_LENGTH 64
#define RA_RISK_ASSESSMENT_REASON_MAX_LENGTH 1024

#define TAS_API

////////////////////////////////////////////// General data types //////////////////////////////////////////////

/**
 *\brief Error codes
 */
typedef int TAS_RESULT;

#define TAS_RESULT_SUCCESS                            0 /**< \brief Success */
#define TAS_RESULT_GENERAL_ERROR                     (-1) /**< \brief General Error */
#define TAS_RESULT_INTERNAL_ERROR                    (-2) /**< \brief Internal Error */
#define TAS_RESULT_WRONG_ARGUMENTS                   (-3) /**< \brief Wrong Arguments */
#define TAS_RESULT_DRA_ITEM_NOT_FOUND                (-4) /**< \brief DRA Item Not Found */
#define TAS_RESULT_NO_POLLING                        (-5) /**< \brief Tried to use polling when configured to non-polling */
#define TAS_RESULT_TIMEOUT                           (-6) /**< \brief Timeout */
#define TAS_RESULT_NOT_INITIALIZED                   (-7) /**< \brief A component has not been initialized or configured  */
#define TAS_RESULT_UNAUTHORIZED                      (-8) /**< \brief Unauthorized */
#define TAS_RESULT_ALREADY_INITIALIZED               (-9) /**< \brief Already initialized */
#define TAS_RESULT_ARCH_NOT_SUPPORTED               (-10) /**< \brief Device's architecture is not supported */
#define TAS_RESULT_INTERNAL_EXCEPTION               (-11) /**< \brief Internal exception occurred */
#define TAS_RESULT_INCORRECT_SETUP                  (-12) /**< \brief Could not initialize: requested operating mode's requirements were not fulfilled */
#define TAS_RESULT_INSUFFICIENT_PERMISSIONS         (-13) /**< \brief Could not initialize: required permissions are not granted by the user */
#define TAS_RESULT_MISSING_PERMISSIONS_IN_FOLDER    (-14) /**< \brief Could not initialize: missing permissions in the sdk folder */
#define TAS_RESULT_DISABLED_BY_CONFIGURATION        (-15) /**< \brief Could not initialize: disabled by configuration */
#define TAS_RESULT_NETWORK_ERROR					(-16) /**< \brief Network Error */
#define TAS_RESULT_CONNECTION_INTERNAL_TIMEOUT      (-17) /**< \brief Connection opened but closed because of connection read/write timeout. By default the timeout is 5 seconds. The timeout value can be                                                                set in the configuration file and put under pinpoint_integration.request_timeout_ms*/
#define TAS_RESULT_PINPOINT_CERTIFICATE_PROBLEM     (-18) /**< \brief This error occurs when the certificate or certificate password is wrong or if the license expired*/


#define TAS_EXCEPTION_CALLBACK_KEY                    1 /**< \brief Signal exception callback */
#define TAS_OVERLAY_CALLBACK_KEY                      2 /**< \brief Overlay detection callback (Android only) */
#define TAS_EXTERNAL_NET_CALLBACK_KEY                 3 /**< \brief External network communication callback */

////////////////////////////////////////////// Client management //////////////////////////////////////////////

/**
 * \brief A TAS object handle.
 * \ingroup ObjectAccess
 */
typedef void *TAS_OBJECT;

/**
 * \defgroup TasManagement TAS Client Management
 */

/**
 * \brief Initialization options for the TAS library.
 *
 * \ingroup TasManagement
 */

typedef int TAS_INIT_OPTIONS;

#define TAS_INIT_NO_OPT                         0  /**< \brief No initialization options */
#define TAS_INIT_MANUAL_BG_OPS                  2  /**< \brief Manual background operations. If omitted, use Autonomous mode */
#define TAS_INIT_DELAYED_BG_OPS                 4  /**< \brief When using Autonomous mode only:
                                                               force the background operations to start after the task interval time elapses.
                                                               If omitted, operations will start immediately */
#define TAS_INIT_SUPPRESS_LOGS                  8  /**< \brief When set, info log is suppressed */
#define TAS_INIT_AVOID_UPLOAD_IN_MOBILE_DATA   16  /**< \brief When set, avoid upload files to the server in mobile date (load only via wi-fi) */
#define TAS_INIT_EXTRA_DRA_DATA                32  /**< \brief Extra dra items */
#define TAS_INIT_NO_SERVICE                    64  /**< \brief When using Autonomous mode only:
                                                               When set Android service will not be initiated */

/**
 * \brief Describes a client requesting a session with the TAS API.
 *
 * \ingroup TasManagement
 * \struct TAS_CLIENT_INFO
 */
typedef struct tagTAS_CLIENT_INFO {
    int size;              /**< \brief Size of the structure */

    const char* vendorId;  /**< \brief Pointer to a null-terminated string identifying the client vendor    */
    const char* clientId;  /**< \brief Pointer to a null-terminated string identifying the client product   */
    const char* comment;   /**< \brief Pointer to a null-terminated string specifying a comment to be associated with the session. May be NULL. */
    const char* clientKey; /**< \brief Pointer to a client key block necessary to initialize TAS, obtained from Trusteer. */
} TAS_CLIENT_INFO;

/**
 * \brief Store callback information
 *
 * \ingroup TasManagement
 * \struct TasCallback
 */
typedef struct TasCallback {
	int callbackID;     /**< \brief ID of the callback. Can be one of TAS_..._CALLBACK_KEY values */
	TAS_OBJECT value;   /**< \brief function pointer of the callback */
} TasCallback;

/**
 * \brief Internal exception callback
 *
 * This is a callback for receiving notification whenever and internal exception occurs
 * It allows the app to terminate itself gracefully instead of crashing
 *
 * The callback is called when the code causes an exception signaling when usually causes the
 * app to crash
 *
 * \ingroup TasInitialize
  */
typedef void (*TAS_EXCEPTION_CALLBACK)(
    const char      *message  /**< The exception message */
);

/**
 * \brief Initialize TAS within an application.
 *
 *
 * \return 0 on success; nonzero on failure. See \ref taslib.h for all possible error codes.
 * \ingroup TasManagement
 */
TAS_RESULT TAS_API TasInitialize(
    TAS_CLIENT_INFO *ClientInfo, /**< Information on the client requesting the session. */
    void            *Reserved,   /**< Reserved. Must be NULL. */
    int              InitFlags   /**< Initialization flags -- use TAS_INIT_OPTIONS constants. */
);

/**
 * \brief Initialize TAS within an application giving a callback function for exception handling.
 *
 *
 * \return 0 on success; nonzero on failure. See \ref taslib.h for all possible error codes.
 * \ingroup TasManagement
 */
TAS_RESULT TAS_API TasInitializeWithCallback(
    TAS_CLIENT_INFO *ClientInfo, /**< Information on the client requesting the session. */
    void            *Reserved,   /**< Reserved. Must be NULL. */
    int              InitFlags,  /**< Initialization flags -- use TAS_INIT_OPTIONS constants. */
    TAS_EXCEPTION_CALLBACK ExceptionCallback /**< Exception callback function */
);

/**
 * \brief Initialize TAS within an application giving an array of callbacks.
 *
 * Using this method, TAS can be initialized with multiple callbacks.
 * Currently we support callbacks for:
 * 1) Exception handling - will be called when exception signal occurred
 * 2) Overlay attack detection (used only in android) - will be called when an overlay attack was detected.
 * 	  NOTE: Overlay check will be preformed if 'checkOverlay' API function is called, also without
 * 	  defining the OverlayCallback.
 *
 * \return 0 on success; nonzero on failure. See \ref taslib.h for all possible error codes.
 * \ingroup TasManagement
 */
TAS_RESULT TAS_API TasInitializeWithCallbacks(
    TAS_CLIENT_INFO *ClientInfo, /**< Information on the client requesting the session. */
    void            *Reserved,   /**< Reserved. Must be NULL. */
    int              InitFlags,  /**< Initialization flags -- use TAS_INIT_OPTIONS constants. */
    TasCallback *callbackArray,  /**< Array of callbacks */
    int callbackArraySize        /**< Size of the array of callbacks */
);

/**
* \brief set the user ID.
*
* This function receives the user id string.
*
* The user id is being encrypted by the public key which must be defined in the security manifest.
*
* The function will fail if the relevant section is not configured properly in the security manifest.
 */
TAS_RESULT TAS_API TasSetUserId(
        const char* userId  /**< [in] user ID string. (256 > userID length > 0)*/
);

/**
 * \brief Give TAS a chance to perform background operations.
 *
 * This call notifies TAS it should check and possibly initiate background operations such as
 * Trusteer configuration update and risk score calculation.
 * The call doesn't wait for background operations to complete.
 *
 * \return 0 on success; nonzero on failure. See \ref taslib.h for all possible error codes.
 * \ingroup TasManagement
 */
TAS_RESULT TAS_API TasStartBackgroundOps(void);

/**
 * \brief Check for the status of background operations.
 *
 * This call waits for Timeout milliseconds or until all TAS in-flight background tasks are
 * completed.
 * The return value of this function may indicate a timeout error if there are still background
 * tasks running at timeout.
 *
 * By passing a timeout of 0 and observing the return value a client can use this call to
 * query whether or not there are any active background operations.
 *
 * \return 0 on success; nonzero on failure. See \ref taslib.h for all possible error codes.
 * \ingroup TasManagement
 */
TAS_RESULT TAS_API TasWaitForBackgroundOps(
    int Timeout /**< Timeout in milliseconds to wait for background ops termination */
);

/**
 * \brief Finalize TAS within an application.
 *
 * \return 0 on success; nonzero on failure. See \ref taslib.h for all possible error codes.
 * \ingroup TasManagement
 */
TAS_RESULT TAS_API TasFinalize(void);

////////////////////////////////////////////// Object Access //////////////////////////////////////////////

/**
 * \defgroup ObjectAccess Generic TAS object access functions
 */

/**
 * \brief Get the value of a scalar string property from a TAS object
 *
 * Retrieves the value of a scalar string property from a TAS object, given the property name.
 *
 * Value is retrieved into a caller-provided buffer, with a caller-provided length. In addition
 * the function returns the length of data actually copied to the buffer.
 *
 * The function returns success even if the buffer provided is too small to contain the whole
 * value -- but updates \ref InOutValueLen accordingly.
 *
 * By passing NULL in OutValue, you can retrieve the required length of the buffer.
 *
 * \return 0 on success; nonzero on failure. See \ref taslib.h for all possible error codes.
 * \ingroup ObjectAccess
 */
TAS_RESULT TAS_API TasObGetScalarStringProperty(
    TAS_OBJECT  Object,       /**< Object to fetch property from */
    const char *PropertyName, /**< Name of property to fetch */
    char       *OutValue,     /**< [out] Target buffer, or NULL to fetch length */
    size_t     *InOutValueLen /**< [inout] On entry, length of provided buffer. On exit length of copied value.   */
);

/**
 * \brief Get the count of elements in a collection property from a TAS object
 *
 * Retrieves the count of elements in a collection property from a TAS object, given the property name.
 *
 * \return 0 on success; nonzero on failure. See \ref taslib.h for all possible error codes.
 * \ingroup ObjectAccess
 */
TAS_RESULT TAS_API TasObGetCollectionPropertyCount(
    TAS_OBJECT  Object,       /**< Object to fetch property from */
    const char *PropertyName, /**< Name of property to fetch count of */
    int        *OutCount      /**< Count of elements in property */
);

/**
 * \brief Get the value of an item in a collection property of strings from a TAS object
 *
 * Retrieves the value of a single string item from a collection property of a TAS object,
 * given the property name and the item index within the collection.
 *
 * Value is retrieved into a caller-provided buffer, with a caller-provided length. In addition
 * the function returns the length of data actually copied to the buffer.
 *
 * The function returns success even if the buffer provided is too small to contain the whole
 * value -- but updates \ref InOutValueLen accordingly.
 *
 * By passing NULL in OutValue, you can retrieve the required length of the buffer.
 *
 * \return 0 on success; nonzero on failure. See \ref taslib.h for all possible error codes.
 * \ingroup ObjectAccess
 */
TAS_RESULT TAS_API TasObGetCollectionStringPropertyItem(
    TAS_OBJECT  Object,       /**< Object to fetch property from */
    const char *PropertyName, /**< Name of property to fetch */
    int         Index,        /**< Index (0-based) of item within collection to fetch. */
    char       *OutValue,     /**< [out] Target buffer, or NULL to fetch length */
    size_t     *InOutValueLen /**< [inout] On entry, length of provided buffer. On exit length of copied value.   */
);

/**
 * \brief Get the value of an item in a collection property of objects from a TAS object
 *
 * Retrieves the value of a single object item from a collection property of a TAS object,
 * given the property name and the item index within the collection.
 *
 * \return 0 on success; nonzero on failure. See \ref taslib.h for all possible error codes.
 * \ingroup ObjectAccess
 */
TAS_RESULT TAS_API TasObGetCollectionObjectPropertyItem(
    TAS_OBJECT  Object,       /**< Object to fetch property from */
    const char *PropertyName, /**< Name of property to fetch */
    int Index,                /**< Index (0-based) of item within collection to fetch. */
    TAS_OBJECT *OutValue      /**< [out] Handle to returned object */
);

////////////////////////////////////////////// Device Risk Assessment //////////////////////////////////////////////

/**
 * \defgroup DeviceRiskAssessment Device Risk Assessment
 */

/**
 * \brief Get a risk assessment object.
 *
 * Retrieves a risk assessment object which can then be queried for attributes such as
 * risk items and overall risk score.
 * The returned object should be freed using \ref TasDraReleaseRiskAssessment.
 * \return 0 on success; nonzero on failure. See \ref taslib.h for all possible error codes.
 * \ingroup DeviceRiskAssessment
 */
TAS_RESULT TAS_API TasDraGetRiskAssessment(
    TAS_OBJECT *Object /**< [out] Returned object handle */
);

/**
 * \brief Device risk assessment recalculation options mask.
 *
 * \ingroup DeviceRiskAssessment
 */
typedef int TAS_DRA_CALC_OPTIONS;

#define TAS_DRA_NO_OPT 0 /**< \brief No calculation options */
#define TAS_DRA_FORCE_RECALC 1 /**< \brief Force recalculation of device risk assessment data, regardless of expiration dates */
#define TAS_DRA_FAST_RECALC 2  /**< \brief Only recalculate 'fast' items; this excludes slow malware scanning processes */

/**
 * \brief Force recalculation of risk assessment data.
 *
 * Normally risk score recalculation occurs at the discretion of the TAS background
 * processing facility. This function allows the client application to explicitly request
 * that TAS updates out-of-date risk score items.
 *
 * Either a complete recalculation of all items (whether expired or not), or just
 * expired items can be requested. In addition, a fast recalc option allows the client
 * to specify that only fast-calculating items should be updated.
 *
 * \return 0 on success; nonzero on failure. See \ref taslib.h for all possible error codes.
 *
 * \ingroup DeviceRiskAssessment
 */
TAS_RESULT TAS_API TasDraRecalcRiskAssessment(
    TAS_DRA_CALC_OPTIONS Options /**< Recalculation options. A combination of one or more \ref TAS_DRA_CALC_OPTIONS values */
);

/**
 * \brief Release a risk assessment object.
 *
 * Releases a risk assessment object obtained by \ref TasDraGetRiskAssessment.
 *
 * \return 0 on success; nonzero on failure. See \ref taslib.h for all possible error codes.
 * \ingroup DeviceRiskAssessment
 */
TAS_RESULT TAS_API TasDraReleaseRiskAssessment(
    TAS_OBJECT Object /**< Object handle to release */
);

/**
 * \brief Get count of risk items in assessment object.
 *
 * Retrieves the count of risk items in a risk assessment object. These are the items participating
 * in calculating to overall risk assessment score.
 *
 * \return 0 on success; nonzero on failure. See \ref taslib.h for all possible error codes.
 * \ingroup DeviceRiskAssessment
 */
TAS_RESULT TAS_API TasDraGetRiskItemCount(
    TAS_OBJECT  Object, /**< Risk assessment object to query */
    int        *Result  /**< [out] Count of risk score items */
);

/**
 * \brief Provides information on a risk score item.
 *
 * \ingroup DeviceRiskAssessment
 * \struct TAS_DRA_ITEM_INFO
 */
typedef struct tagTAS_DRA_ITEM_INFO {
    char       ItemName[128];                               /**< Name of item */
    int        ItemValue;                                   /**< Value of risk score item */
    int        ItemValueTag;                                /**< A tag for the item value; this is a symbolic meaning of the value.
                                                                 -1 if the value was based on a continuous scale. **/
    time_t     LastCalculated;                              /**< Last calculation time of risk score item */
    char       AdditionalData[ADDITIONAL_DATA_MAX_LENGTH+1];/**< Additional information regarding the item. */
    TAS_OBJECT ItemObject;                                  /**< A TAS object handle providing additional information on the
                                                                 item; this depends on the specific item type. */
} TAS_DRA_ITEM_INFO;

/**
 * \brief Get individual risk score item information by index.
 *
 * Retrieves a risk score item summary given an index to the risk score item.
 *
 * \return 0 on success; nonzero on failure. See \ref taslib.h for all possible error codes.
 * \ingroup DeviceRiskAssessment
 */
TAS_RESULT TAS_API TasDraGetRiskAssessmentItemByIndex(
    TAS_OBJECT         Object,        /**< Risk assessment object to query */
    int                RiskItemIndex, /**< Index of risk item to return */
    TAS_DRA_ITEM_INFO *RiskItemInfo   /**< [out] Returned risk item info */
);

/**
 * \brief Get individual risk score item information by item name.
 *
 * Retrieves a risk score item summary given the item's name. See the TAS_DRA_ITEM_xxx constants
 * for predefined names.
 *
 * \return 0 on success; nonzero on failure. See \ref taslib.h for all possible error codes.
 * \ingroup DeviceRiskAssessment
 */
TAS_RESULT TAS_API TasDraGetRiskAssessmentItemByName(
    TAS_OBJECT         Object,       /**< Risk assessment object to query */
    const char        *RiskItemName, /**< NULL terminated name of item */
    TAS_DRA_ITEM_INFO *RiskItemInfo  /**< [out] Returned risk item info */
);

/**
 * \brief Get the most recent time when risk assessment was recalculated.
 *
 * Retrieves the latest LastCalculated value for risk score items.
 *
 * \return 0 on success; nonzero on failure. See \ref taslib.h for all possible error codes.
 * \ingroup DeviceRiskAssessment
 */
TAS_RESULT TAS_API TasDraGetLastRiskAssessmentUpdateTime(
    time_t *Time
);

/**
 * \brief Get string representing the Device Risk Assessment
 *
 * \return 0 on success; nonzero on failure. See \ref taslib.h for all possible error codes.
 * \ingroup DeviceRiskAssessment
 */
TAS_RESULT TAS_API TasDraGetDraString(
    TAS_OBJECT  Object,            /**< Risk assessment object to query */
    char       *DraString,         /**< [out] Device Risk Assessment as string */
    size_t      *DraStringLength   /**< [inout] On entry, length of provided buffer. On exit length of copied value.   */
);

////////////////////////////////////////////// Antipharming //////////////////////////////////////////////

/**
 * \defgroup AntiPharming Anti-pharming protection
 */

/**
 * \brief Enable/disable antipharming protection.
 *
 * This call allows to temporarily enable or disable antipharming protection.
 * Calls are reference counted, so multiple calls to enable should be coupled with the same amount of calls to disable.
 * By default antipharming protection is turned on after Tas initialization.
 *
 * Antipharming can't be enabled if not configured in the manifest.
 *
 * Antipharming may not be available on all platforms.
 *
 * \return 0 on success; nonzero on failure. See \ref taslib.h for all possible error codes.
 * \ingroup AntiPharming
*/
TAS_RESULT TAS_API TasApharmEnable(
    int Enable /**< Enable (nonzero)/disable (zero) antipharming */
);

/**
 * \brief Returns non-zero if anti-pharming is active, and zero otherwise.
 *
 * \return non-zero if anti-pharming is active, and zero otherwise.
 * \ingroup AntiPharming
*/
int TAS_API TasApharmIsEnabled(void);


/**
 * \brief Custom antipharming policy callback
 *
 * This is a callback for implementing a custom antipharming policy by the client. When configured through the
 * security manifest, TAS will invoke this callback to consult about the validate of name resolutions.
 *
 * The callback may be called in two contexts; one is before resolution starts, to determine if a host is at all covered by the policy,
 * and a second time to evaluate resolution result and decide if it should be fixed.
 *
 * When called before resolution starts, the \ref ResolvedAddress array is NULL. The callback should then return true to indicate the host
 * is protected, false otherwise. When called after resolution happens, the callback should return true to indicate that the resolved address
 * is valid, or false otherwise.
 *
 * \return  Policy result. See above.
 * \ingroup AntiPharming
  */
typedef bool (*TAS_ANTIPHARMING_POLICY_CALLBACK)(
    const char      *HostName,             /**< Resolved host name */
    struct sockaddr *ResolvedAddress,      /**< If invoked pre-resolve, NULL. If invoked post-resolve, array of resolution result addresses to evaluate */
    size_t           ResolvedAddressCount, /**< Count of elements in ResolvedAddress */
    void            *Context,              /**< The Context used when registering the callback using \ref TasApharmRegisterPolicyCallback */
    void           **FixHint               /**< Reserved. Must be NULL. */
);

/**
 * \brief event registration callback
 *
 * This is a callback for implementing a custom additional policy for handling events.
 * Registering an event callback will cause the callback to be activated when an event will occure.
 *
 * \return  true -  if event callback was registered
 * \ingroup AntiPharming
  */
typedef bool (*TAS_EVENT_REGISTRATION_CALLBACK)(
    const char *EventName /** <name of event object that has arrived. */
);


/**
 * \brief Register a custom policy callback.
 *
 * This call registers a custom antipharming policy callback. The callback is registered with a specific name
 * that identifies it when referred from the manifest.
 *
 * \return 0 on success; nonzero on failure. See \ref taslib.h for all possible error codes.
 * \ingroup AntiPharming
*/
TAS_RESULT TAS_API TasApharmRegisterPolicyCallback(
    const char                      *CallbackName, /**< Name of callback to register */
    TAS_ANTIPHARMING_POLICY_CALLBACK Callback,     /**< Pointer to registered callback function */
    void                            *Context       /**< A user-defined context pointer to be passed as-is to the callback. Can be NULL. */
);

/**
 * \brief Register a custom event receiver callback.
 *
 * This call registers a custom event receiver callback.
 * Only one callback can be defined,
 * registering another callback will override the previous registered callback
 *
 * \return 0 on success; nonzero on failure. See \ref taslib.h for all possible error codes.
 * \ingroup AntiPharming
*/
TAS_RESULT TAS_API TasRegisterEventReceiverCallback(
    TAS_EVENT_REGISTRATION_CALLBACK Callback, /**< Pointer to registered callback function */
    void                           *Context   /**< A user-defined context pointer to be passed as-is to the callback. Can be NULL. */
);

/**
 * \brief Validate an SSL certificate chain for a host.
 *
 * This function checks an SSL certificate chain for a specified host, and returns a flag indicating whether
 * the SSL certificate chain is valid for the specified host.
 * SSL validation is subject to policy (including blacklist, whitelist) defined by the TAS configuration and manifest.
 *
 * \return 0 on success; nonzero on failure. See \ref taslib.h for all possible error codes.
 * \ingroup AntiPharming
*/
TAS_RESULT TAS_API TasApharmValidateSslCert(
    const char *SerializedCertChain,     /**< Serialized certificate chain (see developer's guide) */
    size_t      SerializedCertChainSize, /**< Size of serialized certificate chain */
    const char *Host,                    /**< Connected host for which certificate is provided */
    int        *Result                   /**< [out] SSL validation result; 0 for valid. Nonzero for invalid. */
);

////////////////////////////////////////////// Info Query //////////////////////////////////////////////

/**
 * \defgroup TasInfo Information query
 */

/**
 * \brief Provides information on TAS library current version
 *
 * \ingroup TasInfo
 * \struct TAS_VERSION_INFO
 */
typedef struct tagTAS_VERSION_INFO {
    int    Major;           /**< Library version major component */
    int    Minor;           /**< Library version minor component */
    int    Patch;           /**< Library patch number */
    int    Build;           /**< Library build number */
    int    ApiLevel;        /**< Library API level */
    int    ConfVer;         /**< Library configuration number */
    time_t ConfLastUpdated; /**< Last time library configuration has been updated (in days) */
} TAS_VERSION_INFO;

/**
 * \brief Get current library version
 *
 * \return 0 on success; nonzero on failure. See \ref taslib.h for all possible error codes.
 * \ingroup TasInfo
 */
TAS_RESULT TAS_API TasGetCurrentVersion(
    TAS_VERSION_INFO *VersionInfo /**< [out] Returned version info */
);

/**
 * \brief Gets the device key
 *
 * Retrieves a NULL terminated device key string.
 *
 * If the given buffer to accommodate the device key is too small an error it returned.
 *
 * By passing NULL in \ref DeviceKey, you can retrieve the total required length of the buffer.
 *
 * \return 0 on success; nonzero on failure. See \ref taslib.h for all possible error codes.
 * \ingroup TasInfo
 */
TAS_RESULT TAS_API TasGetDeviceKey(
    char   *DeviceKey,  /**< [out] Target buffer, or NULL to fetch length. If not NULL, on success will contain the NULL-terminated device key. */
    size_t *InOutKeyLen /**< [inout] On entry, length of provided buffer. On exit length of copied value.   */
);

/**
 * \brief Logger callback function type
 *
 * \ingroup TasInfo
 */
typedef void(*TAS_LOGGER_CALLBACK)(int Severity, const char *Authority, const char *Location, const char *Message, void *Context);

/**
 * \brief Set Logger callback function
 *
 * \return 0 on success; nonzero on failure. See \ref taslib.h for all possible error codes.
 * \ingroup TasInfo
 */
TAS_RESULT TAS_API TasSetLoggerCallback(
    TAS_LOGGER_CALLBACK LoggerCallback, /**< Callback function */
    void               *Context         /**< Context for callback function */
);


////////////////////////////////////////////// TAS Testing Profile //////////////////////////////////////////////
/**
 * \defgroup TasTestingProfile TAS testing profile
 */

/**
 * \brief Get value saved in taz provisioning profile by key
 *
 *  By passing NULL in \ref val, you can retrieve the total required length of the buffer.
 *
 * \return 0 on success; nonzero on failure. See \ref taslib.h for all possible error codes.
 *
 * \ingroup TasTestingProfile
 */
TAS_RESULT TAS_API TasGetProfileValueByKey(
		const char  *key,              /**< key is limited to 256 characters */
	    char        *val,              /**< [out] Value for supplied key */
	    size_t      *DraStringLength   /**< [inout] On entry, length of provided buffer. On exit length of copied value.   */
);

/**
 * \brief Load tas provisioning profile
 *
 * Loads a profile that contains several keys and values
 * If the profile is no longer valid it will be removed from system, and 'val' won't contain any data
 *
 * \return 0 on success; nonzero on failure. See \ref taslib.h for all possible error codes.
 * \ingroup TasTestingProfile
 */
TAS_RESULT TAS_API TasLoadProfile(
     const char *profile  /**< Code which represents a profile */
);

/**
 * \brief Checks if the provisioning profile installed on the device is still valid
 *
 * \return 0 on success; nonzero on failure. See \ref taslib.h for all possible error codes.
 * \ingroup TasTestingProfile
 */
TAS_RESULT TAS_API TasIsValidProfile(
    int *is_valid /**< [out] 1 if a valid profile exists. 0 otherwise */
);

/**
 * \brief UnLoads tas provisioning profile if exists
 *
 * Removes TAS profile if exists on the device
 *
 * \ingroup TasTestingProfile
 */
TAS_RESULT TAS_API TasUnloadProfile(void);

/***************** TEMPORARY ADDITIONS START *********************/
TAS_RESULT TasTempCheckForUpdates(void);
TAS_RESULT TasTempDeleteConfiguration(void);
/***************** TEMPORARY ADDITIONS END *********************/

/**
 * \brief Set the PUID
 *
 * \return 0 on success; nonzero on failure. See \ref taslib.h for all possible error codes.
 *
 * \ingroup TasManagement
 */
TAS_RESULT TAS_API TasSetPUID(
        const char* puid                        /**< [in] permanent user ID string */
);

////////////////////////////////////////////// TAS Pinpoint ATO //////////////////////////////////////////////
/**
 * \defgroup PinpointATO pinpoint ATO
 *
 * \deprecated PinpointATO functions are deprecated. RiskAssessment functions should be used if it is licensed
 */

/**
 * \brief Creates new pinpoint ATO session object.
 *
 * Sets the bank session id.
 * Must call TasAtoDestroySession in order to release that object.
 *
 * \return 0 on success; nonzero on failure. See \ref taslib.h for all possible error codes.
 *
 * \ingroup PinpointATO
 */
TAS_RESULT TAS_API TasAtoCreateSession(
		TAS_OBJECT* obj, 			/**< [out] pointer to the new allocated session object */
		const char* bank_session_id	/**< [in] session ID string */
);

/**
 * \brief set the user ID for a given session.
 *
 * \return 0 on success; nonzero on failure. See \ref taslib.h for all possible error codes.
 *
 * \ingroup PinpointATO
 *
 */
TAS_RESULT TAS_API TasAtoSetUserId(
		TAS_OBJECT obj,  	/**< [in] the session object */
		const char* userId 	/**< [in] user ID string */
);

/**
 * \brief add new key/value pair to the session's map.
 *
 * \return 0 on success; nonzero on failure. See \ref taslib.h for all possible error codes.
 *
 * \ingroup PinpointATO
 */
TAS_RESULT TAS_API TasAtoSetAuxiliary(
		TAS_OBJECT obj, 	/**< [in] the session object */
		const char* key, 	/**< [in] key string to add */
		const char* value	/**< [in] value string to add */
);

/**
 * \brief remove a record of a given key from the session's map.
 *
 * \return 0 on success; nonzero on failure. See \ref taslib.h for all possible error codes.
 *
 * \ingroup PinpointATO
 */
TAS_RESULT TAS_API TasAtoRemoveAuxiliary(
		TAS_OBJECT obj, /**< [in] the session object */
		const char* key	/**< [in] key string to remove */
);

/**
 * \brief generates the session's snapshot payload.
 *
 * this method should be called from non UI thread since it might take some time.
 * first call with blob=NULL (second parameter) will return the blob size as the length value (fourth parameter).
 * second call will return the full blob content.
 *
 * \return 0 on success; nonzero on failure. See \ref taslib.h for all possible error codes.
 *
 * \ingroup PinpointATO
 */
TAS_RESULT TAS_API TasAtoGetCommunicationPayload(
		TAS_OBJECT obj, 	/**< [in] the session object */
		char* blob, 		/**< [inout] pointer to the blob array, or NULL in order to get the blob size */
		size_t* InOutBlobLength	/**< [inout] On entry, length of provided buffer. On exit length of the return blob data. */
);

/**
 * \brief Destroy previously created session
 *
 * \return 0 on success; nonzero on failure. See \ref taslib.h for all possible error codes.
 *
 * \ingroup PinpointATO
 */
TAS_RESULT TAS_API TasAtoDestroySession(
		TAS_OBJECT obj	/**< [in] the session object */
);

////////////////////////////////////////////// TAS RiskAssessment ATO //////////////////////////////////////////////
/**
 * \defgroup RiskAssessment Risk Assessment
 */

/**
 * \brief TAS activity data handle.
 *
 * \ingroup RiskAssessment
 */
typedef void *TAS_RA_ACTIVITY_DATA;

/**
* \brief Pinpoint risk assessment response structure
* \ingroup RiskAssessment
*/
typedef struct tagTAS_RA_RISK_ASSESSMENT {
	char recommendation[RA_RISK_ASSESSMENT_RECOMMENDATION_MAX_LENGTH+1];/**< The Pinpoint recommendation for the requested activity */
	int  reason_id;                                                     /**< The reason ID for the recommendation */
	char reason[RA_RISK_ASSESSMENT_REASON_MAX_LENGTH+1];                /**< The reason string for the recommendation */
	int  risk_score;                                                    /**< The risk score */
    char resolution_id[RA_RISK_ASSESSMENT_RESOLUTION_ID_MAX_LENGTH+1];  /**< The resolution ID for the recommendation */
} TAS_RA_RISK_ASSESSMENT;

/**
* \brief Create and start Pinpoint risk assessment session and set it with the bank session ID
*
* Sets the bank session ID and fills the session_obj pointer with the session object
* You must call TasRaDestroySession to release the session object before creating a new one
*
* \return 0 on success; nonzero on failure. See \ref taslib.h for all possible error codes.
*
* \ingroup RiskAssessment
*/
TAS_RESULT TAS_API TasRaCreateSession(
    TAS_OBJECT* session_obj,                /**< [out] pointer to the new allocated session object */
    const char* bank_session_id             /**< [in] session ID string */
);

/**
* \brief Destroy previously created Pinpoint risk assessment session and release its resources
*
* \return 0 on success; nonzero on failure. See \ref taslib.h for all possible error codes.
*
* \ingroup RiskAssessment
*/
TAS_RESULT TAS_API TasRaDestroySession(
        TAS_OBJECT obj	/**< [in] the session object created in TasRaCreateSession*/
);

/**
* \brief Create activity data object which can be filled with keys and values with \ref TasRaActivityAddData
*
* Must call TasRaDestroyActivityData to release that object
*
* \return 0 on success; nonzero on failure. See \ref taslib.h for all possible error codes.
*
* \ingroup RiskAssessment
*/
TAS_RESULT TAS_API TasRaCreateActivityData (
    TAS_RA_ACTIVITY_DATA *activity_data        /**< [out] pointer to the new allocated activity data object */
);

/**
* \brief Add key-value pairs to the activity data object
*
* If the key already exists, its value is overwritten with the new data
*
* \return 0 on success; nonzero on failure. See \ref taslib.h for all possible error codes.
*
* \ingroup RiskAssessment
*/
TAS_RESULT TAS_API TasRaActivityAddData (
    TAS_RA_ACTIVITY_DATA activity_data,      /**< [in] activity data object */
    const char* key,                        /**< [in] key string to add */
    const char* value                       /**< [in] value string to add */
);

/**
* \brief Release activity data object and its resources
*
* \return 0 on success; nonzero on failure. See \ref taslib.h for all possible error codes.
*
* \ingroup RiskAssessment
*/
TAS_RESULT TAS_API TasRaDestroyActivityData (
    TAS_RA_ACTIVITY_DATA activity_data         /**< [in] previously allocated activity data object */
);

/**
* \brief Notify Pinpoint risk assessment servers with the user activity
*
* Wait for session data to be collected and update servers with user activity and related data passed in activity data object
*
* \return 0 on success; nonzero on failure. See \ref taslib.h for all possible error codes.
*
* \ingroup RiskAssessment
*/
TAS_RESULT TAS_API TasRaNotifyUserActivity (
    TAS_OBJECT session_obj,                 /**< [in] the session object created in TasRaCreateSession */
    const char* user_activity,              /**< [in] one of the predefined user activities */
    TAS_RA_ACTIVITY_DATA activity_data,     /**< [in] additional activity data (optional) */
    int timeout                             /**< [in] timeout in milliseconds to wait for the function to return */
);

/**
* \brief Notify Pinpoint risk assessment servers with the user activity and get the risk assessment
*
* Wait for session data to be collected and update servers with user activity and related data passed in activity data object
*
* Upon success return, the risk_assessment structure is filled with the server's response
*
* \return 0 on success; nonzero on failure. See \ref taslib.h for all possible error codes.
*
* \ingroup RiskAssessment
*/
TAS_RESULT TAS_API TasRaGetRiskAssessment (
    TAS_OBJECT session_obj,                 /**< [in] the session object created in TasRaCreateSession*/
    const char* user_activity,              /**< [in] one of the predefined user activities */
    TAS_RA_ACTIVITY_DATA activity_data,     /**< [in] additional activity data (optional) */
    TAS_RA_RISK_ASSESSMENT *risk_assessment,/**< [out] returned risk assessment structure */
	int timeout                             /**< [in] timeout in milliseconds to wait for the function to return */
);


////////////////////////////////////////////// Behaviourmetrics //////////////////////////////////////////////
/**
 * \defgroup Behaviourmetrics  Behaviourmetrics
 */


/**
 * \brief Behavioral score response structure
 * \ingroup Behaviourmetrics
 */
typedef struct tagTAS_BEHAVE_SCORE {
    int  behavioralScore;                                 /**< The  Behavioral Score */
    int  confidenceScore;                                 /**< The Confidence Score */
    char additionalInfo[ADDITIONAL_DATA_MAX_LENGTH + 1];   /**< Additional information string */
} TAS_BEHAVE_SCORE;

/**
 * \brief Notify behaviourmetrics servers with the last behaviourmetrics data, if exists and get the score assessment
 *
 * PUID is required as a prior condition
 *
 * Upon success return the Behavioral Score and confidence
 *
 * \return 0 on success; nonzero on failure. See \ref taslib.h for all possible error codes.
 *
 * \ingroup Behaviourmetrics
 */
TAS_RESULT TAS_API TasBehaveGetScore (
        TAS_BEHAVE_SCORE *behave_score,           /**< [out] behave score data */
		int timeout                               /**< [in] timeout for the function to finish */
);


#ifdef __cplusplus
////////////////////////////////////////////// External Network Communication //////////////////////////////////////////////

/**
 * \defgroup ExternalNet External network communication
 */

/**
 * \brief External network communication callback function input structure
 * \ingroup ExternalNet
 */
typedef struct tagTAS_EXTERNAL_NET_CALLBACK_INPUTS {
/**
 * \brief External network communication callback function http version options
 * \ingroup ExternalNet
 */
typedef enum {
    VER_1_0 = 0, /**<http version 1.0 */
    VER_1_1 = 1 /**<http version 1.1 */
} HTTP_VERSION;

private:
    std::string url; /**< The url for sending requests and events */
    std::string method; /**< The method in upper case, e.g.: "GET","POST","PUT","HEAD" */
    std::string body; /**< The body of the request in case of "PUT" or "POST", or empty string for no body */
    std::map<std::string,std::string> headers; /**< Map of request headers, or empty map for no headers */
    int connectionTimeout; /**< Timeout for the http connection setup */
    int requestTimeout; /**< Timeout for the http request */
    bool useAutoRedirect; /**< True if need to redirect requests automatically, otherwise False */
    HTTP_VERSION httpVersion; /**< The http version, one of the options from the HTTP_VERSION enum */
    bool useClientCertificate; /**< True if need to add client certificate to the request, otherwise False*/
    
public:
    tagTAS_EXTERNAL_NET_CALLBACK_INPUTS(std::string url_, std::string method_, std::string body_, std::map<std::string,std::string> headers_, int connectionTimeout_, int requestTimeout_, bool useAutoRedirect_, HTTP_VERSION httpVersion_, bool useClientCertificate_){
        url = url_;
        method = method_;
        body = body_;
        headers = headers_;
        connectionTimeout = connectionTimeout_;
        requestTimeout = requestTimeout_;
        useAutoRedirect = useAutoRedirect_;
        httpVersion = httpVersion_;
        useClientCertificate = useClientCertificate_;
    }

    tagTAS_EXTERNAL_NET_CALLBACK_INPUTS(std::string url_, std::string method_, std::string body_, std::map<std::string,std::string> headers_, int connectionTimeout_, int requestTimeout_, bool useAutoRedirect_, int httpVersion_, bool useClientCertificate_){
        url = url_;
        method = method_;
        body = body_;
        headers = headers_;
        connectionTimeout = connectionTimeout_;
        requestTimeout = requestTimeout_;
        useAutoRedirect = useAutoRedirect_;
        httpVersion = HTTP_VERSION(httpVersion_);
        useClientCertificate = useClientCertificate_;
    }

    const std::string getUrl() const {return url;}
    const std::string getMethod() const {return method;}
    const std::string getBody() const {return body;}
    const std::map<std::string,std::string> getHeaders() const {return headers;}
    const int getConnectionTimeout() const {return connectionTimeout;}
    const int getRequestTimeout() const {return requestTimeout;}
    const bool getUseAutoRedirect() const {return useAutoRedirect;}
    const HTTP_VERSION getHttpVersion() const {return httpVersion;}
    const int getHttpVersionNum() const {return httpVersion;}
    const bool getUseClientCertificate() const {return useClientCertificate;}

} TAS_EXTERNAL_NET_CALLBACK_INPUTS;

/**
 * \brief External network communication callback function output structure
 * \ingroup ExternalNet
 */

typedef struct tagTAS_EXTERNAL_NET_CALLBACK_OUTPUTS {

/**
 * \brief External network communication callback function internal error code options
 * \ingroup ExternalNet
 */
typedef enum {
    ERR_NONE = 0, /**<no errors */
    TIMEOUT = 1, /**<timeout exception/timeout response */
    GENERAL_ERR = 2 /**<other error/exception */
} INTERNAL_ERROR_CODE;

private:
    std::string body; /**< The readable input stream of the response, or empty for no body */
    std::string errorBody; /**< The readable error stream the server returns if the connection failed, or empty for no errors from the server  */
    std::map<std::string,std::string> headers; /**< Map of response readable headers, or empty map for no headers.
                                                If a key has more than one value, put one value as a concatenated string that contains all the values separated by "," (without "," at the end)  */
    int httpCode; /**< The http code of the response */
    INTERNAL_ERROR_CODE internalErrorCode; /**< Any internal error/exception during the http connection, one of the options from the INTERNAL_ERROR_CODE enum */
    std::string internalErrorStr; /**< Your informative string with the internal error description if occurred, or empty for no errors */
    
public:
    std::string getBody() {return body;}
    std::string getErrorBody() {return errorBody;}
    std::map<std::string,std::string> getHeaders() {return headers;}
    int getHttpCode() {return httpCode;}
    INTERNAL_ERROR_CODE getInternalErrorCode() {return internalErrorCode;}
    int getInternalErrorCodeNum() {return internalErrorCode;}
    std::string getInternalErrorStr() {return internalErrorStr;}
    void setBody(std::string body_) {body = body_;}
    void setErrorBody(std::string errorBody_) {errorBody = errorBody_;}
    void setHeader(std::string key, std::string value) {headers.insert({key,value});}
    void setHeaders(std::map<std::string,std::string> headers_) {headers = headers_;}
    void setHttpCode(int httpCode_) {httpCode = httpCode_;}
    void setInternalErrorCode(INTERNAL_ERROR_CODE internalErrorCode_) {internalErrorCode = internalErrorCode_;}
    void setInternalErrorStr(std::string internalErrorStr_) {internalErrorStr = internalErrorStr_;}
    INTERNAL_ERROR_CODE convertIntToInternalErrorCode(int num) {
        switch(num) {
            case 0:
                return ERR_NONE;
            case 1:
                return TIMEOUT;
            case 2:
                return GENERAL_ERR;
            default:
                return GENERAL_ERR;
        }
    }
    
} TAS_EXTERNAL_NET_CALLBACK_OUTPUTS;


/**
 * \brief External network communication callback function
 *
 * This is a callback for sending http requests and receiving http responses.
 * It allows the app to control the communication from and into the sdk.
 *
 * The callback is called when the code sends requests or events.
 *
 * \ingroup ExternalNet
 */
typedef void (*TAS_EXTERNAL_NET_CALLBACK)(
    const TAS_EXTERNAL_NET_CALLBACK_INPUTS& inputs, /**< The input structure with all the inputs */
    TAS_EXTERNAL_NET_CALLBACK_OUTPUTS& outputs /**< Allocated empty output structure to fill in all the outputs --> Don't allocate a new one */
);

}
#endif

#endif /* __taslib_h_included__ */
