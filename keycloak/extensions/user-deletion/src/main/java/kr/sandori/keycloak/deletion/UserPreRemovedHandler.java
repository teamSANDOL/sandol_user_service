package kr.sandori.keycloak.deletion;

import org.jboss.logging.Logger;
import org.keycloak.models.UserModel;


//사용자가 삭제되기 직전에 호출됨.
//지금은 로그만 남기고, 이후 단계에서 정보 수집·암호화·전송을 추가함.

public class UserPreRemovedHandler {

    private static final Logger LOG = Logger.getLogger(UserPreRemovedHandler.class);

    public void handle(UserModel.UserPreRemovedEvent event) {
        LOG.infof("[sandol-user-deletion] user pre-remove detected: realm=%s, userId=%s",
                event.getRealm().getName(), event.getUser().getId());
    }
}