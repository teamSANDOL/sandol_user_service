package kr.sandori.keycloak.deletion;

import static org.junit.jupiter.api.Assertions.assertEquals;

import java.util.List;

import org.junit.jupiter.api.Test;

// 탈퇴를 막았을 때 남기는 한 줄 로그의 형식을 확인한다.
class BlockReasonTest {

    private static final List<DeletionPayload.LinkedIdentity> APPLE_AND_KAKAO = List.of(
            new DeletionPayload.LinkedIdentity("apple", "001234.apple", "r.secret-refresh", "kr.sandori.app"),
            new DeletionPayload.LinkedIdentity("kakao", "987654321", null, null));

    // 202가 아닌 응답이면 상태 코드가 줄 끝에 붙고, 토큰·이메일은 들어가지 않는다.
    @Test
    void formatsRejectedLine() {
        String line = BlockReason.RELAY_REJECTED.logLine("Sandori", "user-1", payload(APPLE_AND_KAKAO), 500);

        assertEquals("[sandol-user-deletion] DELETION_BLOCKED realm=Sandori userId=user-1 eventId=event-1"
                + " reason=RELAY_REJECTED providers=apple,kakao status=500", line);
    }

    // 정보를 모으기 전에 실패하면 "-", 연동이 없으면 "none"이고, 상태 코드가 없으면 status를 붙이지 않는다.
    @Test
    void marksUnknownAndEmptyValues() {
        assertEquals("[sandol-user-deletion] DELETION_BLOCKED realm=Sandori userId=user-1 eventId=-"
                        + " reason=INTERNAL_ERROR providers=-",
                BlockReason.INTERNAL_ERROR.logLine("Sandori", "user-1", null, null));
        assertEquals("[sandol-user-deletion] DELETION_BLOCKED realm=Sandori userId=user-1 eventId=event-1"
                        + " reason=CONFIG_INVALID providers=none",
                BlockReason.CONFIG_INVALID.logLine("Sandori", "user-1", payload(List.of()), null));
    }

    private static DeletionPayload payload(List<DeletionPayload.LinkedIdentity> identities) {
        return new DeletionPayload("event-1", "2026-11-16T00:00:00Z", "Sandori", "user-1", "user@example.com",
                identities);
    }
}
