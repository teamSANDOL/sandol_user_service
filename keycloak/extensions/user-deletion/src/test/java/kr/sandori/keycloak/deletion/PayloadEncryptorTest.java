package kr.sandori.keycloak.deletion;

import static org.junit.jupiter.api.Assertions.assertArrayEquals;
import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertNotEquals;
import static org.junit.jupiter.api.Assertions.assertThrows;

import java.nio.charset.StandardCharsets;
import java.security.GeneralSecurityException;
import java.util.Arrays;
import java.util.Base64;

import javax.crypto.AEADBadTagException;
import javax.crypto.Cipher;
import javax.crypto.spec.GCMParameterSpec;
import javax.crypto.spec.SecretKeySpec;

import org.junit.jupiter.api.Test;

// PayloadEncryptor가 auth-relay에서 풀 수 있는 형태로 암호화하는지 확인한다.
class PayloadEncryptorTest {

    // 테스트용 키 (32바이트를 Base64로). 실제 키가 아니다.
    private static final String KEY = Base64.getEncoder().encodeToString(new byte[32]);
    private static final String OTHER_KEY = Base64.getEncoder().encodeToString(filled(32, (byte) 1));
    private static final byte[] PLAINTEXT = "{\"user_id\":\"u-1\"}".getBytes(StandardCharsets.UTF_8);

    // 암호화한 것을 같은 키로 풀면 원래 내용이 나온다.
    @Test
    void encryptedPayloadDecryptsToOriginal() throws Exception {
        EncryptedPayload encrypted = new PayloadEncryptor("v1", KEY).encrypt(PLAINTEXT);

        assertEquals("v1", encrypted.kid());
        assertEquals(12, Base64.getDecoder().decode(encrypted.iv()).length);
        assertArrayEquals(PLAINTEXT, decrypt(KEY, encrypted));
    }

    // 같은 내용을 두 번 암호화해도 IV와 암호문이 매번 다르다.
    @Test
    void usesNewIvEveryTime() {
        PayloadEncryptor encryptor = new PayloadEncryptor("v1", KEY);
        EncryptedPayload first = encryptor.encrypt(PLAINTEXT);
        EncryptedPayload second = encryptor.encrypt(PLAINTEXT);

        assertNotEquals(first.iv(), second.iv());
        assertNotEquals(first.ciphertext(), second.ciphertext());
    }

    // 암호문이 한 글자라도 바뀌면 풀 때 실패한다 (위조 감지).
    @Test
    void tamperedCiphertextIsRejected() {
        EncryptedPayload encrypted = new PayloadEncryptor("v1", KEY).encrypt(PLAINTEXT);
        byte[] bytes = Base64.getDecoder().decode(encrypted.ciphertext());
        bytes[0] ^= 1;
        EncryptedPayload tampered = new EncryptedPayload(
                encrypted.kid(), encrypted.iv(), Base64.getEncoder().encodeToString(bytes));

        assertThrows(AEADBadTagException.class, () -> decrypt(KEY, tampered));
    }

    // 다른 키로는 풀 수 없다.
    @Test
    void wrongKeyIsRejected() {
        EncryptedPayload encrypted = new PayloadEncryptor("v1", KEY).encrypt(PLAINTEXT);

        assertThrows(AEADBadTagException.class, () -> decrypt(OTHER_KEY, encrypted));
    }

    // 키 길이가 32바이트가 아니거나 Base64가 아니면 처음부터 거부한다.
    @Test
    void invalidKeyIsRejected() {
        String shortKey = Base64.getEncoder().encodeToString(new byte[16]);

        assertThrows(IllegalArgumentException.class, () -> new PayloadEncryptor("v1", shortKey));
        assertThrows(IllegalArgumentException.class, () -> new PayloadEncryptor("v1", "not base64!"));
        assertThrows(IllegalArgumentException.class, () -> new PayloadEncryptor("v1", null));
        assertThrows(IllegalArgumentException.class, () -> new PayloadEncryptor("", KEY));
    }

    // auth-relay가 하는 것과 같은 방식으로 복호화한다.
    private static byte[] decrypt(String base64Key, EncryptedPayload encrypted) throws GeneralSecurityException {
        Base64.Decoder base64 = Base64.getDecoder();
        Cipher cipher = Cipher.getInstance("AES/GCM/NoPadding");
        cipher.init(Cipher.DECRYPT_MODE,
                new SecretKeySpec(base64.decode(base64Key), "AES"),
                new GCMParameterSpec(128, base64.decode(encrypted.iv())));
        return cipher.doFinal(base64.decode(encrypted.ciphertext()));
    }

    private static byte[] filled(int size, byte value) {
        byte[] bytes = new byte[size];
        Arrays.fill(bytes, value);
        return bytes;
    }
}
