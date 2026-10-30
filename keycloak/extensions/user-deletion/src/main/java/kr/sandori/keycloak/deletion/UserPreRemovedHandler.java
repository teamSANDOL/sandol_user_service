package kr.sandori.keycloak.deletion;

import java.util.List;
import java.util.Set;
import java.util.function.Function;

import org.jboss.logging.Logger;
import org.keycloak.models.UserModel;
import org.keycloak.services.ErrorResponseException;

import jakarta.ws.rs.core.Response;

// 사용자가 삭제되기 직전에 호출된다.
// 정보를 모아 암호화해서 auth-relay로 보내고, 보내지 못하면 탈퇴를 막는다.
public class UserPreRemovedHandler {

    private static final Logger LOG = Logger.getLogger(UserPreRemovedHandler.class);

    private final DeletionPayloadCollector collector = new DeletionPayloadCollector();
    private final Set<String> realms;
    // null이면 전송 기능이 꺼진 상태 (SANDOL_DELETION_RELAY_URL 미설정)
    private final DeletionRelay relay;
    // null이 아니면 설정이 잘못된 상태. 이때는 탈퇴를 막는다.
    private final String configError;

    UserPreRemovedHandler(Set<String> realms, DeletionRelay relay, String configError) {
        this.realms = realms;
        this.relay = relay;
        this.configError = configError;
    }

    // Keycloak이 시작할 때 한 번 호출되어 환경변수로 Handler를 만든다.
    public static UserPreRemovedHandler fromEnvironment(Function<String, String> env) {
        Set<String> realms = RelaySettings.realmsFrom(env);
        try {
            RelaySettings settings = RelaySettings.fromEnv(env);
            if (!settings.enabled()) {
                LOG.warnf("[sandol-user-deletion] %s is not set. Deletions in %s will NOT be sent to auth-relay.",
                        RelaySettings.ENV_RELAY_URL, realms);
                return new UserPreRemovedHandler(realms, null, null);
            }
            DeletionRelay relay = new DeletionRelay(settings.relayUrl(),
                    new PayloadEncryptor(settings.keyId(), settings.key()), settings.timeout());
            LOG.infof("[sandol-user-deletion] relay enabled: url=%s, keyId=%s, timeout=%s, realms=%s",
                    settings.relayUrl(), settings.keyId(), settings.timeout(), realms);
            return new UserPreRemovedHandler(realms, relay, null);
        } catch (IllegalArgumentException e) {
            LOG.errorf("[sandol-user-deletion] invalid configuration: %s. Deletions in %s will be blocked until it is fixed.",
                    e.getMessage(), realms);
            return new UserPreRemovedHandler(realms, null, e.getMessage());
        }
    }

    public void handle(UserModel.UserPreRemovedEvent event) {
        // 대상 realm이 아니면 (예: master의 관리자 계정) 아무것도 하지 않는다.
        if (!realms.contains(event.getRealm().getName())) {
            return;
        }

        DeletionPayload payload = collector.collect(event);
        LOG.infof("[sandol-user-deletion] collected: realm=%s, userId=%s, hasEmail=%s, identities=%s",
                payload.realm(), payload.userId(), payload.email() != null, describe(payload.identities()));

        // Apple 연동인데 토큰이 없으면 Store tokens 설정을 확인하라고 경고한다.
        boolean appleWithoutToken = payload.identities().stream()
                .anyMatch(i -> DeletionPayloadCollector.APPLE.equals(i.provider()) && i.refreshToken() == null);
        if (appleWithoutToken) {
            LOG.warnf("[sandol-user-deletion] Apple refresh token not found for userId=%s. "
                    + "Check that 'Store tokens' is enabled on the Apple identity provider.", payload.userId());
        }

        if (configError != null) {
            LOG.errorf("[sandol-user-deletion] deletion blocked: userId=%s, reason=invalid configuration (%s)",
                    payload.userId(), configError);
            throw unavailable();
        }
        if (relay == null) {
            LOG.warnf("[sandol-user-deletion] relay disabled: userId=%s deleted without notifying auth-relay",
                    payload.userId());
            return;
        }

        try {
            relay.send(payload);
        } catch (RuntimeException e) {
            LOG.errorf(e, "[sandol-user-deletion] deletion blocked: userId=%s, eventId=%s, reason=%s",
                    payload.userId(), payload.eventId(), e.getMessage());
            throw unavailable();
        }
        LOG.infof("[sandol-user-deletion] sent to auth-relay: userId=%s, eventId=%s",
                payload.userId(), payload.eventId());
    }

    // 탈퇴를 막을 때 던지는 예외. 트랜잭션이 롤백되어 사용자가 삭제되지 않는다.
    private static ErrorResponseException unavailable() {
        return new ErrorResponseException("account_deletion_unavailable",
                "Account deletion is temporarily unavailable. Please try again later.",
                Response.Status.SERVICE_UNAVAILABLE);
    }

    // 로그에는 토큰 값을 남기지 않고 "있음/없음"만 남긴다.
    private static String describe(List<DeletionPayload.LinkedIdentity> identities) {
        return identities.stream()
                .map(i -> DeletionPayloadCollector.APPLE.equals(i.provider())
                        ? i.provider() + "(refreshToken=" + (i.refreshToken() != null ? "yes" : "no") + ")"
                        : i.provider())
                .toList()
                .toString();
    }
}
