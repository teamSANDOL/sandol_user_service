package kr.sandori.keycloak.deletion;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertFalse;
import static org.junit.jupiter.api.Assertions.assertNull;
import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.junit.jupiter.api.Assertions.assertTrue;

import java.net.URI;
import java.time.Duration;
import java.util.HashMap;
import java.util.Map;
import java.util.Set;

import org.junit.jupiter.api.Test;

// 환경변수를 읽어 설정을 만드는 규칙을 확인한다.
class RelaySettingsTest {

    private static final String KEY = "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";

    // URL이 없으면 전송 기능이 꺼지고, realm은 Sandori만 처리한다.
    @Test
    void disabledWhenRelayUrlIsMissing() {
        RelaySettings settings = RelaySettings.fromEnv(env(Map.of()));

        assertFalse(settings.enabled());
        assertEquals(Set.of("Sandori"), settings.realms());
    }

    // 값을 주지 않은 항목은 기본값(kid v1, 5초)을 쓴다.
    @Test
    void usesDefaultsForOptionalValues() {
        RelaySettings settings = RelaySettings.fromEnv(env(Map.of(
                RelaySettings.ENV_RELAY_URL, "http://auth-relay-app:5600/internal/account-deletions",
                RelaySettings.ENV_KEY, KEY)));

        assertTrue(settings.enabled());
        assertEquals(URI.create("http://auth-relay-app:5600/internal/account-deletions"), settings.relayUrl());
        assertEquals("v1", settings.keyId());
        assertEquals(Duration.ofSeconds(5), settings.timeout());
    }

    // 모든 값을 직접 지정할 수 있고, realm은 쉼표로 여러 개 줄 수 있다.
    @Test
    void readsAllValues() {
        RelaySettings settings = RelaySettings.fromEnv(env(Map.of(
                RelaySettings.ENV_REALMS, " Sandori, test ,,",
                RelaySettings.ENV_RELAY_URL, "https://relay.example.com/x",
                RelaySettings.ENV_KEY_ID, "v2",
                RelaySettings.ENV_KEY, KEY,
                RelaySettings.ENV_TIMEOUT_SECONDS, "3")));

        assertEquals(Set.of("Sandori", "test"), settings.realms());
        assertEquals("v2", settings.keyId());
        assertEquals(Duration.ofSeconds(3), settings.timeout());
    }

    // 잘못된 값은 처음부터 거부한다.
    @Test
    void rejectsInvalidValues() {
        assertThrows(IllegalArgumentException.class, () -> RelaySettings.fromEnv(env(Map.of(
                RelaySettings.ENV_RELAY_URL, "ftp://relay.example.com", RelaySettings.ENV_KEY, KEY))));
        assertThrows(IllegalArgumentException.class, () -> RelaySettings.fromEnv(env(Map.of(
                RelaySettings.ENV_RELAY_URL, "http://relay.example.com"))));
        assertThrows(IllegalArgumentException.class, () -> RelaySettings.fromEnv(env(Map.of(
                RelaySettings.ENV_RELAY_URL, "http://relay.example.com", RelaySettings.ENV_KEY, KEY,
                RelaySettings.ENV_TIMEOUT_SECONDS, "five"))));
        assertThrows(IllegalArgumentException.class, () -> RelaySettings.fromEnv(env(Map.of(
                RelaySettings.ENV_RELAY_URL, "http://relay.example.com", RelaySettings.ENV_KEY, KEY,
                RelaySettings.ENV_TIMEOUT_SECONDS, "0"))));
    }

    // 설정을 문자열로 찍어도 키는 나오지 않는다.
    @Test
    void toStringHidesKey() {
        RelaySettings settings = RelaySettings.fromEnv(env(Map.of(
                RelaySettings.ENV_RELAY_URL, "http://relay.example.com", RelaySettings.ENV_KEY, KEY)));

        assertFalse(settings.toString().contains(KEY));
    }

    // 꺼진 상태에서는 키와 시간 제한도 비어 있다.
    @Test
    void disabledSettingsHaveNoSecrets() {
        RelaySettings settings = RelaySettings.fromEnv(env(Map.of(RelaySettings.ENV_KEY, KEY)));

        assertNull(settings.key());
        assertNull(settings.timeout());
    }

    private static java.util.function.Function<String, String> env(Map<String, String> values) {
        return new HashMap<>(values)::get;
    }
}
