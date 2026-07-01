<#import "template.ftl" as layout>
<@layout.registrationLayout displayInfo=false displayMessage=false; section>
    <#if section = "header">
        ${msg("emailVerifyTitle")}
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

            <div class="sandori-status-icon sandori-status-info">i</div>

            <header class="sandori-header">
                <h1 class="sandori-action-title">${msg("emailVerifyTitle")}</h1>
                <p class="sandori-action-subtitle">${msg("emailVerifyInstruction1", user.email)}</p>
            </header>

            <#if message?has_content>
                <div class="sandori-message sandori-message-${message.type}" role="alert">
                    <span>${kcSanitize(message.summary)?no_esc}</span>
                </div>
            </#if>

            <div class="sandori-info-card">
                ${msg("emailVerifyInfo")}
            </div>

            <form id="kc-verify-email-form" class="sandori-form" action="${url.loginAction}" method="post">
                <button class="sandori-btn sandori-btn-login" type="submit">${msg("resendVerifyEmail")}</button>
            </form>

            <footer>
                <div class="sandori-footer-link-block">
                    <a href="${url.loginUrl}">${msg("backToLogin")}</a>
                </div>
            </footer>
        </div>
    </#if>
</@layout.registrationLayout>
