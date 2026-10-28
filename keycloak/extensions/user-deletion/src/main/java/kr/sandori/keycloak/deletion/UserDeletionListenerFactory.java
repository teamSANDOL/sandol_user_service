package kr.sandori.keycloak.deletion;

import org.keycloak.Config;
import org.keycloak.events.Event;
import org.keycloak.events.EventListenerProvider;
import org.keycloak.events.EventListenerProviderFactory;
import org.keycloak.events.admin.AdminEvent;
import org.keycloak.models.KeycloakSession;
import org.keycloak.models.KeycloakSessionFactory;
import org.keycloak.models.UserModel;

//Keycloak이 시작될 때 불러가는 진입점.
//postInit()에서 "사용자 삭제 직전" 이벤트를 구독.
public class UserDeletionListenerFactory implements EventListenerProviderFactory {

    public static final String ID = "sandol-user-deletion";

    // 로그인 이벤트 등은 쓰지 않으므로 아무것도 하지 않는 리스너를 돌려준다.
    private static final EventListenerProvider NOOP = new EventListenerProvider() {
        @Override
        public void onEvent(Event event) {
        }

        @Override
        public void onEvent(AdminEvent event, boolean includeRepresentation) {
        }

        @Override
        public void close() {
        }
    };

    private final UserPreRemovedHandler handler = new UserPreRemovedHandler();

    @Override
    public EventListenerProvider create(KeycloakSession session) {
        return NOOP;
    }

    @Override
    public void init(Config.Scope config) {
    }

    @Override
    public void postInit(KeycloakSessionFactory factory) {
        factory.register(event -> {
            if (event instanceof UserModel.UserPreRemovedEvent removed) {
                handler.handle(removed);
            }
        });
    }

    @Override
    public void close() {
    }

    @Override
    public String getId() {
        return ID;
    }
}
