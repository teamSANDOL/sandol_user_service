package kr.sandori.keycloak.deletion;

import java.io.IOException;
import java.net.URI;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.time.Duration;

import org.keycloak.util.JsonSerialization;

// 탈퇴 정보를 JSON → 암호화 → auth-relay로 POST 한다.
// auth-relay가 202(영구 저장 완료)를 돌려줄 때만 성공으로 본다.
public class DeletionRelay {

    static final int ACCEPTED = 202;

    private final URI relayUrl;
    private final Duration timeout;
    private final PayloadEncryptor encryptor;
    private final HttpClient http;

    public DeletionRelay(URI relayUrl, PayloadEncryptor encryptor, Duration timeout) {
        this.relayUrl = relayUrl;
        this.timeout = timeout;
        this.encryptor = encryptor;
        this.http = HttpClient.newBuilder()
                .version(HttpClient.Version.HTTP_1_1)
                .connectTimeout(timeout)
                .build();
    }

    // 실패하면 RelayException을 던진다.
    public void send(DeletionPayload payload) {
        HttpRequest request = HttpRequest.newBuilder(relayUrl)
                .timeout(timeout)
                .header("Content-Type", "application/json")
                .POST(HttpRequest.BodyPublishers.ofByteArray(toRequestBody(payload)))
                .build();

        int status;
        try {
            status = http.send(request, HttpResponse.BodyHandlers.discarding()).statusCode();
        } catch (IOException e) {
            // 연결 실패, 시간 초과 등
            throw new RelayException("request to auth-relay failed: " + e.getClass().getSimpleName(), e);
        } catch (InterruptedException e) {
            Thread.currentThread().interrupt();
            throw new RelayException("request to auth-relay was interrupted", e);
        }

        if (status != ACCEPTED) {
            throw new RelayException("auth-relay responded with status " + status);
        }
    }

    // 평문 JSON을 암호화해서 {kid, iv, ciphertext} JSON으로 만든다.
    byte[] toRequestBody(DeletionPayload payload) {
        try {
            byte[] plaintext = JsonSerialization.writeValueAsBytes(payload.toJsonMap());
            return JsonSerialization.writeValueAsBytes(encryptor.encrypt(plaintext));
        } catch (IOException e) {
            throw new RelayException("failed to serialize deletion payload", e);
        }
    }
}
