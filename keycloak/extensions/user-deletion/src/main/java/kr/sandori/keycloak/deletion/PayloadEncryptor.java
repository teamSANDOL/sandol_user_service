package kr.sandori.keycloak.deletion;

import java.security.GeneralSecurityException;
import java.security.SecureRandom;
import java.util.Base64;

import javax.crypto.Cipher;
import javax.crypto.spec.GCMParameterSpec;
import javax.crypto.spec.SecretKeySpec;

// AES-256-GCM으로 탈퇴 정보를 암호화한다.
// GCM은 암호화와 함께 인증 태그를 붙여서, 키가 없으면 내용을 읽을 수도 위조할 수도 없다.
public class PayloadEncryptor {

    static final int KEY_BYTES = 32;
    static final int IV_BYTES = 12;
    static final int TAG_BITS = 128;

    private static final SecureRandom RANDOM = new SecureRandom();

    private final String keyId;
    private final SecretKeySpec key;

    // base64Key: 32바이트 키를 Base64로 적은 값 (.env에 넣을 값)
    public PayloadEncryptor(String keyId, String base64Key) {
        if (keyId == null || keyId.isBlank()) {
            throw new IllegalArgumentException("keyId is required");
        }
        byte[] keyBytes;
        try {
            keyBytes = Base64.getDecoder().decode(base64Key == null ? "" : base64Key.trim());
        } catch (IllegalArgumentException e) {
            throw new IllegalArgumentException("encryption key is not valid Base64", e);
        }
        if (keyBytes.length != KEY_BYTES) {
            throw new IllegalArgumentException(
                    "encryption key must be " + KEY_BYTES + " bytes, but was " + keyBytes.length);
        }
        this.keyId = keyId;
        this.key = new SecretKeySpec(keyBytes, "AES");
    }

    public EncryptedPayload encrypt(byte[] plaintext) {
        // 같은 키로 IV를 다시 쓰면 GCM이 깨지므로 매번 새 난수를 만든다.
        byte[] iv = new byte[IV_BYTES];
        RANDOM.nextBytes(iv);
        try {
            Cipher cipher = Cipher.getInstance("AES/GCM/NoPadding");
            cipher.init(Cipher.ENCRYPT_MODE, key, new GCMParameterSpec(TAG_BITS, iv));
            byte[] ciphertext = cipher.doFinal(plaintext);
            Base64.Encoder base64 = Base64.getEncoder();
            return new EncryptedPayload(keyId, base64.encodeToString(iv), base64.encodeToString(ciphertext));
        } catch (GeneralSecurityException e) {
            throw new IllegalStateException("failed to encrypt deletion payload", e);
        }
    }
}
