package kr.sandori.keycloak.deletion;

// auth-relay 전송 실패. 이 예외가 나면 탈퇴를 막는다.
public class RelayException extends RuntimeException {

    public RelayException(String message) {
        super(message);
    }

    public RelayException(String message, Throwable cause) {
        super(message, cause);
    }
}
