<#import "template.ftl" as layout>
<@layout.registrationLayout displayInfo=false displayMessage=false; section>
    <#if section = "header">
        ${msg("infoTitle")}
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

            <div class="sandori-status-icon sandori-status-success">✓</div>

            <header class="sandori-header">
                <h1 class="sandori-action-title">${msg("infoTitle")}</h1>
                <p class="sandori-action-subtitle"><#if message?has_content>${kcSanitize(message.summary)?no_esc}<#else>${msg("infoDefaultMessage")}</#if></p>
            </header>

            <div class="sandori-action-stack">
                <#if pageRedirectUri??>
                    <a class="sandori-btn sandori-btn-login" href="${pageRedirectUri}">${msg("continueAction")}</a>
                <#elseif actionUri??>
                    <a class="sandori-btn sandori-btn-login" href="${actionUri}">${msg("continueAction")}</a>
                <#elseif client?? && client.baseUrl?has_content>
                    <a class="sandori-btn sandori-btn-login" href="${client.baseUrl}">${msg("backToService")}</a>
                <#else>
                    <a class="sandori-btn sandori-btn-login" href="${url.loginUrl}">${msg("backToLogin")}</a>
                </#if>
            </div>
        </div>
    </#if>
</@layout.registrationLayout>
