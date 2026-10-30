package kr.sandori.keycloak.deletion;

import java.util.List;

import org.jboss.logging.Logger;
import org.keycloak.models.UserModel;

// 사용자가 삭제되기 직전에 호출된다.
// 지금은 정보를 모아 로그로 남기고, 이후 단계에서 암호화·전송을 추가한다.
public class UserPreRemovedHandler {

    private static final Logger LOG = Logger.getLogger(UserPreRemovedHandler.class);

    private final DeletionPayloadCollector collector = new DeletionPayloadCollector();

    public void handle(UserModel.UserPreRemovedEvent event) {
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