/**
 * @description Issues and validates short-lived request verification tokens for queue scheduling mutations.
 */
public with sharing class Queue_Sch_CsrfGuard {
    private static final Integer TOKEN_TTL_MILLIS = 300000;

    /**
     * @description Issues a signed token for the requested Apex mutation action.
     * @param actionName Fully qualified action name the token authorizes.
     * @return Signed request verification token.
     */
    @AuraEnabled(cacheable=true)
    public static String issueToken(String actionName) {
        validateActionName(actionName);
        Long issuedAt = DateTime.now().getTime();
        String nonce = EncodingUtil.convertToHex(Crypto.generateAesKey(128));
        String encodedPayload = EncodingUtil.base64Encode(
            Blob.valueOf(
                String.join(
                    new List<String>{
                        UserInfo.getUserId(),
                        actionName,
                        String.valueOf(issuedAt),
                        nonce
                    },
                    ':'
                )
            )
        );
        String signature = buildSignature(encodedPayload);
        return encodedPayload + '.' + signature;
    }

    /**
     * @description Validates a signed request verification token for a mutation action.
     * @param actionName Fully qualified action name expected in the token payload.
     * @param token Signed request verification token from the client.
     */
    public static void assertValidToken(String actionName, String token) {
        validateActionName(actionName);
        List<String> tokenParts = parseTokenParts(token);
        String encodedPayload = tokenParts[0];
        String providedSignature = tokenParts[1];

        assertValidSignature(encodedPayload, providedSignature);
        List<String> payloadParts = parsePayloadParts(encodedPayload);
        assertPayloadContext(actionName, payloadParts);
        assertTokenAgeValid(payloadParts[2]);
    }

    private static List<String> parseTokenParts(String token) {
        if (String.isBlank(token)) {
            throw new AuraHandledException('Missing request verification token.');
        }
        List<String> tokenParts = token.split('\\.');
        if (tokenParts.size() != 2) {
            throw new AuraHandledException('Invalid request verification token.');
        }
        return tokenParts;
    }

    private static void assertValidSignature(String encodedPayload, String providedSignature) {
        if (buildSignature(encodedPayload) != providedSignature) {
            throw new AuraHandledException('Request verification failed.');
        }
    }

    private static List<String> parsePayloadParts(String encodedPayload) {
        String payload = EncodingUtil.base64Decode(encodedPayload).toString();
        List<String> payloadParts = payload.split(':');
        if (payloadParts.size() != 4) {
            throw new AuraHandledException('Invalid request payload.');
        }
        return payloadParts;
    }

    private static void assertPayloadContext(String actionName, List<String> payloadParts) {
        if (payloadParts[0] != UserInfo.getUserId()) {
            throw new AuraHandledException('Request user mismatch.');
        }
        if (payloadParts[1] != actionName) {
            throw new AuraHandledException('Request action mismatch.');
        }
    }

    private static void assertTokenAgeValid(String issuedAtValue) {
        Long issuedAt = Long.valueOf(issuedAtValue);
        Long tokenAge = DateTime.now().getTime() - issuedAt;
        if (tokenAge < 0 || tokenAge > TOKEN_TTL_MILLIS) {
            throw new AuraHandledException('Request verification token expired.');
        }
    }

    private static void validateActionName(String actionName) {
        if (String.isBlank(actionName)) {
            throw new AuraHandledException('Action name is required.');
        }
    }

    private static String buildSignature(String encodedPayload) {
        return EncodingUtil.convertToHex(
            Crypto.generateMac(
                'HmacSHA256',
                Blob.valueOf(encodedPayload),
                Blob.valueOf(getRequestSecret())
            )
        );
    }

    private static String getRequestSecret() {
        String sessionId = UserInfo.getSessionId();
        if (String.isBlank(sessionId)) {
            if (Test.isRunningTest()) {
                return 'QUEUE_SCH_TEST_SESSION_SECRET';
            }
            throw new AuraHandledException('Unable to validate the request context.');
        }
        return sessionId;
    }
}
