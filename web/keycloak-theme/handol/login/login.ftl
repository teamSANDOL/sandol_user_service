<#import "template.ftl" as layout>
<#import "parts.ftl" as parts>
<#assign showIdStep = message?has_content || (login.username!'')?has_content || messagesPerField.existsError('username','password')>
<@layout.registrationLayout displayInfo=false displayMessage=false; section>
    <#if section = "header">
        ${msg("doLogIn")}
    <#elseif section = "form">
        <div class="sandori-auth-container sandori-centered sandori-login" data-step="<#if showIdStep>id<#else>start</#if>">
            <#-- 1단계: 시작화면 (소셜 로그인 + 아이디로 시작하기) -->
            <div class="sandori-view sandori-view-start">
                <div class="sandori-body">
                    <@parts.appIcon/>
                    <h1 class="sandori-title">${msg("loginStartTitle")?no_esc}</h1>

                    <#if realm.identityFederationEnabled && social.providers?? && social.providers?size gt 0>
                        <div class="sandori-social" role="group" aria-label="${msg("socialLoginGroup")}">
                            <#list social.providers as p>
                                <#assign providerClass = p.alias?lower_case>
                                <#if providerClass == "kakao">
                                    <a id="social-${p.alias}" class="sandori-social-btn sandori-social-kakao" href="${p.loginUrl}" aria-label="${msg("socialLoginKakao")}"><img src="${url.resourcesPath}/img/kakao-symbol.svg" alt=""></a>
                                <#elseif providerClass == "google">
                                    <a id="social-${p.alias}" class="sandori-social-btn sandori-social-google" href="${p.loginUrl}" aria-label="${msg("socialLoginGoogle")}"><img src="${url.resourcesPath}/img/google-logo.svg" alt=""></a>
                                <#elseif providerClass == "apple">
                                    <a id="social-${p.alias}" class="sandori-social-btn sandori-social-apple" href="${p.loginUrl}" aria-label="${msg("socialLoginApple")}"><img src="${url.resourcesPath}/img/apple-logo.svg" alt=""></a>
                                <#else>
                                    <a id="social-${p.alias}" class="sandori-social-btn sandori-social-generic" href="${p.loginUrl}" aria-label="${msg("socialLoginGeneric", p.displayName!p.alias)}" title="${p.displayName!p.alias}">${(p.displayName!p.alias)?substring(0, 1)?upper_case}</a>
                                </#if>
                            </#list>
                        </div>
                        <div class="sandori-divider sandori-start-only">${msg("dividerOr")}</div>
                    </#if>

                    <div class="sandori-start-cta sandori-start-only">
                        <button type="button" class="sandori-btn" data-action="show-id">${msg("startWithId")}</button>
                    </div>
                </div>
            </div>

            <#-- 2단계: 아이디로 로그인 -->
            <div class="sandori-view sandori-view-id">
                <div class="sandori-topbar">
                    <button type="button" class="sandori-back" data-action="show-start" aria-label="${msg("backLabel")}"><@parts.backArrow/></button>
                    <div class="sandori-topbar-end"><@parts.localeSwitch/></div>
                </div>
                <div class="sandori-body">
                    <div class="sandori-id-only"><@parts.appIcon/></div>
                    <h1 class="sandori-title sandori-id-only">${msg("loginIdTitle")?no_esc}</h1>

                    <form id="kc-form-login" class="sandori-form" action="${url.loginAction}" method="post">
                        <#if !usernameHidden??>
                            <input
                                tabindex="1"
                                id="username"
                                class="sandori-input"
                                name="username"
                                value="${(login.username!'')}"
                                type="text"
                                autocomplete="username"
                                aria-label="<#if !realm.loginWithEmailAllowed>${msg('username')}<#elseif !realm.registrationEmailAsUsername>${msg('usernameOrEmail')}<#else>${msg('email')}</#if>"
                                placeholder="<#if !realm.loginWithEmailAllowed>${msg('username')}<#elseif !realm.registrationEmailAsUsername>${msg('usernameOrEmail')}<#else>${msg('email')}</#if>"
                                aria-invalid="<#if messagesPerField.existsError('username','password')>true<#else>false</#if>"
                            />
                        </#if>

                        <input
                            tabindex="2"
                            id="password"
                            class="sandori-input"
                            name="password"
                            type="password"
                            autocomplete="current-password"
                            aria-label="${msg('password')}"
                            placeholder="${msg('password')}"
                            aria-invalid="<#if messagesPerField.existsError('username','password')>true<#else>false</#if>"
                        />

                        <#if message?has_content>
                            <div class="sandori-message sandori-message-${message.type}" role="alert">${kcSanitize(message.summary)?no_esc}</div>
                        <#elseif messagesPerField.existsError('username','password')>
                            <span class="sandori-field-error" role="alert">${kcSanitize(messagesPerField.getFirstError('username','password'))?no_esc}</span>
                        </#if>

                        <#if realm.rememberMe && !usernameHidden??>
                            <label class="sandori-check-row sandori-remember-row" for="rememberMe">
                                <input tabindex="3" id="rememberMe" name="rememberMe" type="checkbox"<#if login.rememberMe??> checked</#if>>
                                <span class="sandori-checkmark" aria-hidden="true"></span>
                                <span>${msg("rememberMe")}</span>
                            </label>
                        </#if>

                        <input type="hidden" id="id-hidden-input" name="credentialId"<#if auth.selectedCredential?has_content> value="${auth.selectedCredential}"</#if>/>

                        <button tabindex="4" class="sandori-btn sandori-login-submit" name="login" id="kc-login" type="submit">${msg("loginButton")}</button>
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
        </div>
    </#if>
</@layout.registrationLayout>
