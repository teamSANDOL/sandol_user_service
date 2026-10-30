package kr.sandori.keycloak.deletion;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertThrows;

import java.io.IOException;
import java.net.InetSocketAddress;
import java.net.URI;
import java.nio.charset.StandardCharsets;
import java.time.Duration;
import java.util.Base64;
import java.util.List;
import java.util.Map;
import java.util.concurrent.atomic.AtomicReference;

import javax.crypto.Cipher;
import javax.crypto.spec.GCMParameterSpec;
import javax.crypto.spec.SecretKeySpec;

import org.junit.jupiter.api.AfterEach;
import org.junit.jupiter.api.Test;
import org.keycloak.util.JsonSerialization;

import com.sun.net.httpserver.HttpServer;

// 가짜 auth-relay 서버를 띄워 실제 HTTP로 보내 보고 결과를 확인한다.
class DeletionRelayTest {

    private static final String KEY = Base64.getEncoder().encodeToString(new byte[32]);
    private static final DeletionPayload PAYLOAD = new DeletionPayload(
            "event-1", "2026-10-30T00:00:00Z", "Sandori", "user-1", "user@example.com",
            List.of(new DeletionPayload.LinkedIdentity("apple", "001234.apple", "r.apple-refresh")));

    private HttpServer server;

    @AfterEach
    void stopServer() {
        if (server != null) {
            server.stop(0);
        }
    }

    // 202를 받으면 성공이고, 보낸 내용은 키로 풀면 원래 정보가 나온다.
    @Test
    void sendsEncryptedPayloadAndSucceedsOn202() throws Exception {
        AtomicReference<byte[]> received = new AtomicReference<>();
        URI url = startServer(202, 0, received);

        relay(url, Duration.ofSeconds(2)).send(PAYLOAD);

        Map<?, ?> envelope = JsonSerialization.readValue(received.get(), Map.class);
        assertEquals("v1", envelope.get("kid"));
        Map<?, ?> json = JsonSerialization.readValue(decrypt(envelope), Map.class);
        assertEquals("event-1", json.get("event_id"));
        assertEquals("user-1", json.get("user_id"));
        assertEquals("user@example.com", json.get("email"));
        Map<?, ?> apple = (Map<?, ?>) ((List<?>) json.get("identities")).get(0);
        assertEquals("r.apple-refresh", apple.get("refresh_token"));
    }

    // 202가 아니면 (예: 500) 실패다.
    @Test
    void failsWhenStatusIsNot202() throws Exception {
        URI url = startServer(500, 0, new AtomicReference<>());

        assertThrows(RelayException.class, () -> relay(url, Duration.ofSeconds(2)).send(PAYLOAD));
    }

    // auth-relay가 꺼져 있으면 실패다.
    @Test
    void failsWhenRelayIsDown() throws Exception {
        URI url = startServer(202, 0, new AtomicReference<>());
        server.stop(0);
        server = null;

        assertThrows(RelayException.class, () -> relay(url, Duration.ofSeconds(2)).send(PAYLOAD));
    }

    // 정해진 시간 안에 답이 없으면 실패다.
    @Test
    void failsOnTimeout() throws Exception {
        URI url = startServer(202, 3000, new AtomicReference<>());

        assertThrows(RelayException.class, () -> relay(url, Duration.ofSeconds(1)).send(PAYLOAD));
    }

    private static DeletionRelay relay(URI url, Duration timeout) {
        return new DeletionRelay(url, new PayloadEncryptor("v1", KEY), timeout);
    }

    // 받은 요청 본문을 저장하고, delayMillis만큼 기다린 뒤 status로 답하는 서버를 띄운다.
    private URI startServer(int status, long delayMillis, AtomicReference<byte[]> received) throws IOException {
        server = HttpServer.create(new InetSocketAddress("127.0.0.1", 0), 0);
        server.createContext("/internal/account-deletions", exchange -> {
            received.set(exchange.getRequestBody().readAllBytes());
            try {
                Thread.sleep(delayMillis);
            } catch (InterruptedException e) {
                Thread.currentThread().interrupt();
            }
            exchange.sendResponseHeaders(status, -1);
            exchange.close();
        });
        server.start();
        return URI.create("http://127.0.0.1:" + server.getAddress().getPort() + "/internal/account-deletions");
    }

    // auth-relay가 하는 것과 같은 방식으로 복호화한다.
    private static String decrypt(Map<?, ?> envelope) throws Exception {
        Base64.Decoder base64 = Base64.getDecoder();
        Cipher cipher = Cipher.getInstance("AES/GCM/NoPadding");
        cipher.init(Cipher.DECRYPT_MODE, new SecretKeySpec(base64.decode(KEY), "AES"),
                new GCMParameterSpec(128, base64.decode((String) envelope.get("iv"))));
        return new String(cipher.doFinal(base64.decode((String) envelope.get("ciphertext"))), StandardCharsets.UTF_8);
    }
}
