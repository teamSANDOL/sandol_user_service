package kr.sandori.keycloak.deletion;

// auth-relay 전송 실패. 이 예외가 나면 탈퇴를 막는다.
public class RelayException extends RuntimeException {

    private final BlockReason reason;
    // RELAY_REJECTED일 때 auth-relay가 돌려준 HTTP 상태 코드. 그 외에는 null.
    private final Integer status;

    public RelayException(BlockReason reason, String message, Throwable cause) {
        this(reason, message, cause, null);
    }

    private RelayException(BlockReason reason, String message, Throwable cause, Integer status) {
        super(message, cause);
        this.reason = reason;
        this.status = status;
    }

    // auth-relay가 202가 아닌 상태 코드로 응답했을 때
    public static RelayException rejected(int status) {
        return new RelayException(BlockReason.RELAY_REJECTED,
                "auth-relay responded with status " + status, null, status);
    }

    public BlockReason reason() {
        return reason;
    }

    public Integer status() {
        return status;
    }
}
