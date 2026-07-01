<#import "template.ftl" as layout>
<@layout.registrationLayout displayInfo=false displayMessage=false; section>
    <#if section = "header">
        ${msg("emailForgotTitle")}
    <#elseif section = "form">
        <div class="sandori-auth-container sandori-centered">
            <#if realm.internationalizationEnabled && locale?? && locale.supported?? && locale.supported?size gt 1>
                <nav class="sandori-locale-switcher" aria-label="${msg("languageSelector")}">
                    <#list locale.supported as l>
                        <a class="sandori-locale-option<#if l.languageTag == locale.currentLanguageTag> is-active</#if>" href="${l.url}" lang="${l.languageTag}" hreflang="${l.languageTag}">
                            ${l.languageTag?upper_case}
                        </a>
                    </#list>
                </nav>
            </#if>

            <div class="sandori-logo-container sandori-logo-small">
                <img src="${url.resourcesPath}/img/logo1.png" alt="${msg("serviceLogo")}">
            </div>

            <header class="sandori-header">
                <h1 class="sandori-action-title">${msg("resetPasswordTitle")}</h1>
                <p class="sandori-action-subtitle">${msg("resetPasswordSubtitle")}</p>
            </header>

            <#if message?has_content>
                <div class="sandori-message sandori-message-${message.type}" role="alert">
                    <span>${kcSanitize(message.summary)?no_esc}</span>
                </div>
            </#if>

            <form id="kc-reset-password-form" class="sandori-form" action="${url.loginAction}" method="post">
                <div class="sandori-input-group">
                    <label for="username">${msg("usernameOrEmail")}</label>
                    <input tabindex="1" id="username" class="sandori-input" name="username" value="${(auth.attemptedUsername!'')}" type="text" autofocus autocomplete="username" aria-invalid="<#if messagesPerField.existsError('username')>true</#if>">
                    <#if messagesPerField.existsError('username')>
                        <span class="sandori-field-error" role="alert">${kcSanitize(messagesPerField.get('username'))?no_esc}</span>
                    <#else>
                        <span class="sandori-input-message">${msg("resetPasswordHint")}</span>
                    </#if>
                </div>
                <button tabindex="2" class="sandori-btn sandori-btn-login" type="submit">${msg("resetPasswordSubmit")}</button>
            </form>

            <footer>
                <div class="sandori-footer-link-block">
                    <a href="${url.loginUrl}">${msg("backToLogin")}</a>
                </div>
            </footer>
        </div>
    </#if>
</@layout.registrationLayout>
