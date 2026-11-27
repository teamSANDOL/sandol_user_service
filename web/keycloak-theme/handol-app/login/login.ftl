<#import "template.ftl" as layout>
<#import "parts.ftl" as parts>
<#assign fieldError = messagesPerField.existsError('username','password')>
<@layout.registrationLayout displayInfo=false displayMessage=false; section>
    <#if section = "header">
        ${msg("doLogIn")}
    <#elseif section = "form">
        <div class="sandori-auth-container sandori-login">
            <#-- 뒤로 화살표 없음: 앱 브라우저 탭에서 닫을 수 없어 갇히므로 그리지 않는다 -->
            <div class="sandori-topbar">
                <div class="sandori-topbar-end"><@parts.localeSwitch/></div>
            </div>
            <div class="sandori-body sandori-login-body">
                <@parts.appIcon/>
                <h1 class="sandori-title">${msg("loginIdTitle")?no_esc}</h1>

                <form id="kc-form-login" class="sandori-form" action="${url.loginAction}" method="post" novalidate>
                    <#if !usernameHidden??>
                        <label class="sandori-sr-only" for="username"><#if !realm.loginWithEmailAllowed>${msg('username')}<#elseif !realm.registrationEmailAsUsername>${msg('usernameOrEmail')}<#else>${msg('email')}</#if></label>
                        <input tabindex="1" id="username" class="sandori-input" name="username" value="${(login.username!'')}" type="text"
                            autocomplete="username" autocapitalize="none" spellcheck="false"
                            placeholder="<#if !realm.loginWithEmailAllowed>${msg('username')}<#elseif !realm.registrationEmailAsUsername>${msg('usernameOrEmail')}<#else>${msg('email')}</#if>"
                            aria-invalid="<#if fieldError>true<#else>false</#if>"<#if fieldError> aria-describedby="login-error"</#if>>
                    </#if>
                    <label class="sandori-sr-only" for="password">${msg('password')}</label>
                    <input tabindex="2" id="password" class="sandori-input" name="password" type="password"
                        autocomplete="current-password" placeholder="${msg('password')}"
                        aria-invalid="<#if fieldError>true<#else>false</#if>"<#if fieldError> aria-describedby="login-error"</#if>>

                    <#if fieldError>
                        <span id="login-error" class="sandori-field-error" role="alert">${kcSanitize(messagesPerField.getFirstError('username','password'))?no_esc}</span>
                    <#elseif message?has_content>
                        <div class="sandori-message sandori-message-${message.type}" role="alert">${kcSanitize(message.summary)?no_esc}</div>
                    </#if>

                    <#-- rememberMe 체크박스는 의도적으로 그리지 않는다(realm 설정은 그대로) -->
                    <input type="hidden" id="id-hidden-input" name="credentialId"<#if auth.selectedCredential?has_content> value="${auth.selectedCredential}"</#if>/>

                    <button tabindex="3" class="sandori-btn sandori-login-submit" name="login" id="kc-login" type="submit">${msg("loginButton")}</button>
                </form>

                <#if realm.password && realm.registrationAllowed && !registrationDisabled??>
                    <div class="sandori-signup-section">
                        <span>${msg("noAccount")}</span><a href="${url.registrationUrl}">${msg("signUpLink")}</a>
                    </div>
                </#if>
                <#if realm.resetPasswordAllowed>
                    <div class="sandori-find-account-section">
                        <a href="${url.loginResetCredentialsUrl}">${msg("findAccountLink")}</a>
                    </div>
                </#if>
            </div>
        </div>
    </#if>
</@layout.registrationLayout>
