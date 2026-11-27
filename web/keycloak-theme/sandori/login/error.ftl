<#import "template.ftl" as layout>
<#import "parts.ftl" as parts>
<@layout.registrationLayout displayInfo=false displayMessage=false; section>
    <#if section = "header">
        ${msg("errorTitle")}
    <#elseif section = "form">
        <div class="sandori-auth-container sandori-centered">
            <@parts.actionTop/>
            <div class="sandori-body">
                <@parts.appIcon small=true/>
                <div class="sandori-status-icon sandori-status-error" aria-hidden="true">!</div>
                <h1 class="sandori-action-title">${msg("errorHeading")}</h1>
                <p class="sandori-action-subtitle"><#if message?has_content>${kcSanitize(message.summary)?no_esc}<#else>${msg("errorDefaultMessage")}</#if></p>

                <div class="sandori-action-stack">
                    <#if client?? && client.baseUrl?has_content>
                        <a class="sandori-btn" href="${client.baseUrl}">${msg("backToService")}</a>
                    </#if>
                    <#if !skipLink??>
                        <#if client?? && client.clientId?? && client.clientId == "sandol-meal-web">
                            <a class="sandori-text-link" href="/meal-web/auth/login">${msg("retryLogin")}</a>
                        <#elseif client?? && client.baseUrl?has_content>
                            <a class="sandori-text-link" href="${client.baseUrl}">${msg("retryLogin")}</a>
                        <#else>
                            <a class="sandori-text-link" href="${url.loginUrl}">${msg("retryLogin")}</a>
                        </#if>
                    </#if>
                </div>
            </div>
        </div>
    </#if>
</@layout.registrationLayout>
