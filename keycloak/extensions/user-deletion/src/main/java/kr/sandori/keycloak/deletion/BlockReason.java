package kr.sandori.keycloak.deletion;

import java.util.List;
import java.util.stream.Collectors;

// 탈퇴를 막은 사유. 이름이 그대로 로그의 reason= 값이 된다.
public enum BlockReason {
    // auth-relay에 연결하지 못함 (꺼짐, 주소를 찾지 못함, 연결 끊김)
    RELAY_UNREACHABLE,
    // 정해진 시간 안에 auth-relay의 응답이 없음
    RELAY_TIMEOUT,
    // auth-relay가 202가 아닌 상태 코드로 응답함
    RELAY_REJECTED,
    // SANDOL_DELETION_* 설정값 오류 (상세 내용은 Keycloak 시작 로그)
    CONFIG_INVALID,
    // 위에 해당하지 않는 예상하지 못한 오류
    INTERNAL_ERROR;

    // 이 사유로 탈퇴를 막았을 때 남기는 DELETION_BLOCKED 한 줄 로그. 토큰·이메일은 넣지 않는다.
    // payload가 null이면 정보를 모으기 전에 실패한 것이라 eventId와 providers를 "-"로 적는다.
    // Keycloak 클래스를 쓰지 않으므로 Keycloak 없이 테스트할 수 있다.
    String logLine(String realm, String userId, DeletionPayload payload, Integer status) {
        StringBuilder line = new StringBuilder("[sandol-user-deletion] DELETION_BLOCKED")
                .append(" realm=").append(realm)
                .append(" userId=").append(userId)
                .append(" eventId=").append(payload == null ? "-" : payload.eventId())
                .append(" reason=").append(name())
                .append(" providers=").append(payload == null ? "-" : providers(payload.identities()));
        if (status != null) {
            line.append(" status=").append(status);
        }
        return line.toString();
    }

    // 연동된 IdP 이름을 쉼표로 잇는다. 연동이 없으면 none.
    private static String providers(List<DeletionPayload.LinkedIdentity> identities) {
        if (identities.isEmpty()) {
            return "none";
        }
        return identities.stream()
                .map(DeletionPayload.LinkedIdentity::provider)
                .collect(Collectors.joining(","));
    }
}
