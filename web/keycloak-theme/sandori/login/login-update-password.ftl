<#import "template.ftl" as layout>
<@layout.registrationLayout displayInfo=false displayMessage=false; section>
    <#if section = "header">
        ${msg("updatePasswordTitle")}
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
                <h1 class="sandori-action-title">${msg("updatePasswordTitle")}</h1>
                <p class="sandori-action-subtitle">${msg("updatePasswordSubtitle")}</p>
            </header>

            <#if message?has_content>
                <div class="sandori-message sandori-message-${message.type}" role="alert">
                    <span>${kcSanitize(message.summary)?no_esc}</span>
                </div>
            </#if>

            <form id="kc-passwd-update-form" class="sandori-form" action="${url.loginAction}" method="post">
                <div class="sandori-input-group">
                    <label for="password-new">${msg("newPassword")}</label>
                    <input tabindex="1" id="password-new" class="sandori-input" name="password-new" type="password" autocomplete="new-password" autofocus aria-invalid="<#if messagesPerField.existsError('password','password-confirm')>true</#if>">
                    <#if messagesPerField.existsError('password')>
                        <span class="sandori-field-error" role="alert">${kcSanitize(messagesPerField.get('password'))?no_esc}</span>
                    <#else>
                        <span class="sandori-input-message">${msg("passwordPolicyHint")}</span>
                    </#if>
                </div>

                <div class="sandori-input-group">
                    <label for="password-confirm">${msg("newPasswordConfirm")}</label>
                    <input tabindex="2" id="password-confirm" class="sandori-input" name="password-confirm" type="password" autocomplete="new-password" aria-invalid="<#if messagesPerField.existsError('password-confirm')>true</#if>">
                    <#if messagesPerField.existsError('password-confirm')>
                        <span class="sandori-field-error" role="alert">${kcSanitize(messagesPerField.get('password-confirm'))?no_esc}</span>
                    <#else>
                        <span class="sandori-input-message">${msg("passwordConfirmHint")}</span>
                    </#if>
                </div>

                <#if isAppInitiatedAction??>
                    <label class="sandori-check-row" for="logout-sessions">
                        <input tabindex="3" id="logout-sessions" name="logout-sessions" type="checkbox" checked>
                        <span class="sandori-checkmark" aria-hidden="true"></span>
                        <span class="sandori-check-label">${msg("logoutOtherSessions")}</span>
                    </label>
                </#if>

                <button tabindex="4" class="sandori-btn sandori-btn-login" type="submit">${msg("updatePasswordSubmit")}</button>
                <#if isAppInitiatedAction??>
                    <button tabindex="5" class="sandori-btn sandori-btn-secondary" type="submit" name="cancel-aia" value="true">${msg("doLater")}</button>
                </#if>
            </form>
        </div>
    </#if>
</@layout.registrationLayout>
