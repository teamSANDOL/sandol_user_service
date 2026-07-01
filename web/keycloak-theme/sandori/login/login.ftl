<#import "template.ftl" as layout>
<@layout.registrationLayout displayInfo=false displayMessage=false; section>
    <#if section = "header">
        ${msg("doLogIn")}
    <#elseif section = "form">
        <div class="sandori-auth-container sandori-centered">
            <#if realm.internationalizationEnabled && locale?? && locale.supported?? && locale.supported?size gt 1>
                <nav class="sandori-locale-switcher" aria-label="언어 선택">
                    <#list locale.supported as l>
                        <a class="sandori-locale-option<#if l.languageTag == locale.currentLanguageTag> is-active</#if>" href="${l.url}" lang="${l.languageTag}" hreflang="${l.languageTag}">
                            ${l.languageTag?upper_case}
                        </a>
                    </#list>
                </nav>
            </#if>

            <div class="sandori-logo-container">
                <img src="${url.resourcesPath}/img/logo1.png" alt="${msg("serviceLogo")}">
            </div>

            <header class="sandori-header">
                <h1 class="sandori-login-title">${msg("loginTitleLine1")}<br>${msg("loginTitleLine2")}</h1>
            </header>

            <#if message?has_content>
                <div class="sandori-message sandori-message-${message.type}" role="alert">
                    <span>${kcSanitize(message.summary)?no_esc}</span>
                </div>
            </#if>

            <main>
                <#if realm.identityFederationEnabled && social.providers?? && social.providers?size gt 0>
                    <section class="sandori-social-login" aria-label="소셜 로그인">
                        <#list social.providers as p>
                            <#assign providerClass = p.alias?lower_case>
                            <a id="social-${p.alias}" class="sandori-btn sandori-btn-${providerClass}" href="${p.loginUrl}">
                                <#if p.alias?lower_case == "kakao">${msg("socialLoginKakao")}
                                <#elseif p.alias?lower_case == "google">${msg("socialLoginGoogle")}
                                <#elseif p.alias?lower_case == "apple">${msg("socialLoginApple")}
                                <#else>${msg("socialLoginGeneric", p.displayName!p.alias)}</#if>
                            </a>
                        </#list>
                    </section>
                    <div class="sandori-divider">${msg("dividerOr")}</div>
                </#if>

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
                            placeholder="<#if !realm.loginWithEmailAllowed>${msg('username')}<#elseif !realm.registrationEmailAsUsername>${msg('usernameOrEmail')}<#else>${msg('email')}</#if>"
                            aria-invalid="<#if messagesPerField.existsError('username','password')>true</#if>"
                        />
                    </#if>

                    <input
                        tabindex="2"
                        id="password"
                        class="sandori-input"
                        name="password"
                        type="password"
                        autocomplete="current-password"
                        placeholder="${msg('password')}"
                        aria-invalid="<#if messagesPerField.existsError('username','password')>true</#if>"
                    />

                    <#if messagesPerField.existsError('username','password')>
                        <span class="sandori-field-error" role="alert">
                            ${kcSanitize(messagesPerField.getFirstError('username','password'))?no_esc}
                        </span>
                    </#if>

                    <#if realm.rememberMe && !usernameHidden??>
                        <label class="sandori-checkbox-item sandori-remember-row" for="rememberMe">
                            <#if login.rememberMe??>
                                <input tabindex="3" id="rememberMe" name="rememberMe" type="checkbox" checked>
                            <#else>
                                <input tabindex="3" id="rememberMe" name="rememberMe" type="checkbox">
                            </#if>
                            <span>${msg("rememberMe")}</span>
                        </label>
                    </#if>

                    <button tabindex="4" class="sandori-btn sandori-btn-login" name="login" id="kc-login" type="submit">${msg("loginButton")}</button>
                </form>
            </main>

            <footer>
                <#if realm.password && realm.registrationAllowed && !registrationDisabled??>
                    <div class="sandori-signup-section">
                        <span>${msg("noAccount")}</span>
                        <a href="${url.registrationUrl}">${msg("signUpLink")}</a>
                    </div>
                </#if>
                <#if realm.resetPasswordAllowed>
                    <div class="sandori-find-account-section">
                        <a href="${url.loginResetCredentialsUrl}">${msg("findAccountLink")}</a>
                    </div>
                </#if>
            </footer>
        </div>
    </#if>
</@layout.registrationLayout>
