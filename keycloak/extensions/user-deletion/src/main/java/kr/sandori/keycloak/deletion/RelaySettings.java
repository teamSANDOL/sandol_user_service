package kr.sandori.keycloak.deletion;

import java.net.URI;
import java.time.Duration;
import java.util.Arrays;
import java.util.Set;
import java.util.function.Function;
import java.util.stream.Collectors;

// 환경변수에서 읽은 auth-relay 전송 설정.
// relayUrl이 null이면 전송 기능이 꺼진 상태다.
public record RelaySettings(Set<String> realms, URI relayUrl, String keyId, String key, Duration timeout) {

    static final String ENV_REALMS = "SANDOL_DELETION_REALMS";
    static final String ENV_RELAY_URL = "SANDOL_DELETION_RELAY_URL";
    static final String ENV_KEY_ID = "SANDOL_DELETION_KEY_ID";
    static final String ENV_KEY = "SANDOL_DELETION_KEY";
    static final String ENV_TIMEOUT_SECONDS = "SANDOL_DELETION_TIMEOUT_SECONDS";

    static final String DEFAULT_REALMS = "Sandori";
    static final String DEFAULT_KEY_ID = "v1";
    static final String DEFAULT_TIMEOUT_SECONDS = "5";

    public boolean enabled() {
        return relayUrl != null;
    }

    // 처리할 realm 목록 (쉼표로 구분). 값이 없으면 Sandori만 처리한다.
    static Set<String> realmsFrom(Function<String, String> env) {
        return Arrays.stream(valueOrDefault(env.apply(ENV_REALMS), DEFAULT_REALMS).split(","))
                .map(String::trim)
                .filter(name -> !name.isEmpty())
                .collect(Collectors.toUnmodifiableSet());
    }

    // 설정값이 잘못되어 있으면 IllegalArgumentException을 던진다.
    static RelaySettings fromEnv(Function<String, String> env) {
        Set<String> realms = realmsFrom(env);
        String url = env.apply(ENV_RELAY_URL);
        if (url == null || url.isBlank()) {
            return new RelaySettings(realms, null, null, null, null);
        }

        URI relayUrl;
        try {
            relayUrl = URI.create(url.trim());
        } catch (IllegalArgumentException e) {
            throw new IllegalArgumentException(ENV_RELAY_URL + " is not a valid URL", e);
        }
        boolean http = "http".equals(relayUrl.getScheme()) || "https".equals(relayUrl.getScheme());
        if (!http || relayUrl.getHost() == null) {
            throw new IllegalArgumentException(ENV_RELAY_URL + " must be an http:// or https:// URL");
        }

        String key = env.apply(ENV_KEY);
        if (key == null || key.isBlank()) {
            throw new IllegalArgumentException(ENV_KEY + " is required when " + ENV_RELAY_URL + " is set");
        }

        int seconds;
        try {
            seconds = Integer.parseInt(valueOrDefault(env.apply(ENV_TIMEOUT_SECONDS), DEFAULT_TIMEOUT_SECONDS));
        } catch (NumberFormatException e) {
            throw new IllegalArgumentException(ENV_TIMEOUT_SECONDS + " must be a whole number", e);
        }
        if (seconds <= 0) {
            throw new IllegalArgumentException(ENV_TIMEOUT_SECONDS + " must be greater than 0");
        }

        String keyId = valueOrDefault(env.apply(ENV_KEY_ID), DEFAULT_KEY_ID);
        return new RelaySettings(realms, relayUrl, keyId, key.trim(), Duration.ofSeconds(seconds));
    }

    // 실수로 로그에 찍혀도 키가 드러나지 않게 한다.
    @Override
    public String toString() {
        return "RelaySettings[realms=" + realms + ", relayUrl=" + relayUrl + ", keyId=" + keyId
                + ", timeout=" + timeout + "]";
    }

    private static String valueOrDefault(String value, String defaultValue) {
        return value == null || value.isBlank() ? defaultValue : value.trim();
    }
}
