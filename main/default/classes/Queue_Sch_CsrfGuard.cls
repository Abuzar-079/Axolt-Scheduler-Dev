public with sharing class Queue_Sch_CsrfGuard {
    private static final Integer TOKEN_TTL_MILLIS = 300000;

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

    public static void assertValidToken(String actionName, String token) {
        validateActionName(actionName);
        if (String.isBlank(token)) {
            throw new AuraHandledException('Missing request verification token.');
        }

        List<String> tokenParts = token.split('\\.');
        if (tokenParts.size() != 2) {
            throw new AuraHandledException('Invalid request verification token.');
        }

        String encodedPayload = tokenParts[0];
        String providedSignature = tokenParts[1];
        if (buildSignature(encodedPayload) != providedSignature) {
            throw new AuraHandledException('Request verification failed.');
        }

        String payload = EncodingUtil.base64Decode(encodedPayload).toString();
        List<String> payloadParts = payload.split(':');
        if (payloadParts.size() != 4) {
            throw new AuraHandledException('Invalid request payload.');
        }

        if (payloadParts[0] != UserInfo.getUserId()) {
            throw new AuraHandledException('Request user mismatch.');
        }
        if (payloadParts[1] != actionName) {
            throw new AuraHandledException('Request action mismatch.');
        }

        Long issuedAt = Long.valueOf(payloadParts[2]);
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
