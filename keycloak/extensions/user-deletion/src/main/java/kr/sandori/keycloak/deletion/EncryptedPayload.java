package kr.sandori.keycloak.deletion;

// 암호화된 탈퇴 정보. 이 형태 그대로 JSON으로 만들어 auth-relay에 보낸다.
// kid: 어떤 키로 암호화했는지 (키를 바꿀 때 구분용)
// iv: 암호화할 때마다 새로 만드는 12바이트 난수 (Base64)
// ciphertext: 암호문 + 인증 태그 16바이트 (Base64)
public record EncryptedPayload(String kid, String iv, String ciphertext) {
}
