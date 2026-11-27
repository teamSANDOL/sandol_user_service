<#import "template.ftl" as layout>
<#import "parts.ftl" as parts>
<@layout.registrationLayout displayInfo=false displayMessage=false; section>
    <#if section = "header">
        ${msg("pageExpiredTitle")}
    <#elseif section = "form">
        <div class="sandori-auth-container sandori-centered">
            <@parts.actionTop/>
            <div class="sandori-body">
                <@parts.appIcon small=true/>
                <div class="sandori-status-icon sandori-status-warning" aria-hidden="true">!</div>
                <h1 class="sandori-action-title">${msg("pageExpiredTitle")}</h1>
                <p class="sandori-action-subtitle">${msg("pageExpiredMessage")}</p>

                <div class="sandori-action-stack">
                    <a class="sandori-btn" href="${url.loginRestartFlowUrl}">${msg("restartLogin")}</a>
                    <a class="sandori-text-link" href="${url.loginUrl}">${msg("goToLogin")}</a>
                </div>
            </div>
        </div>
    </#if>
</@layout.registrationLayout>
