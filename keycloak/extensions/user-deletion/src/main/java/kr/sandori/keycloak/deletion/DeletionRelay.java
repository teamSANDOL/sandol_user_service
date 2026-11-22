package kr.sandori.keycloak.deletion;

import java.io.IOException;
import java.net.URI;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.net.http.HttpTimeoutException;
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
        } catch (HttpTimeoutException e) {
            // 정해진 시간 안에 연결하거나 응답받지 못함. IOException의 하위 클래스라서 먼저 잡는다.
            throw new RelayException(BlockReason.RELAY_TIMEOUT, "auth-relay did not respond in time", e);
        } catch (IOException e) {
            // 연결 거부, 주소를 찾지 못함, 연결 끊김 등
            throw new RelayException(BlockReason.RELAY_UNREACHABLE,
                    "request to auth-relay failed: " + e.getClass().getSimpleName(), e);
        } catch (InterruptedException e) {
            Thread.currentThread().interrupt();
            throw new RelayException(BlockReason.INTERNAL_ERROR, "request to auth-relay was interrupted", e);
        }

        if (status != ACCEPTED) {
            throw RelayException.rejected(status);
        }
    }

    // 평문 JSON을 암호화해서 {kid, iv, ciphertext} JSON으로 만든다.
    byte[] toRequestBody(DeletionPayload payload) {
        try {
            byte[] plaintext = JsonSerialization.writeValueAsBytes(payload.toJsonMap());
            return JsonSerialization.writeValueAsBytes(encryptor.encrypt(plaintext));
        } catch (IOException e) {
            throw new RelayException(BlockReason.INTERNAL_ERROR, "failed to serialize deletion payload", e);
        }
    }
}
