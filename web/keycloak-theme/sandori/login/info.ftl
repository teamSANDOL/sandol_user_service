<#import "template.ftl" as layout>
<#import "parts.ftl" as parts>
<@layout.registrationLayout displayInfo=false displayMessage=false; section>
    <#if section = "header">
        ${msg("infoTitle")}
    <#elseif section = "form">
        <div class="sandori-auth-container sandori-centered">
            <@parts.actionTop/>
            <div class="sandori-body">
                <@parts.appIcon small=true/>
                <div class="sandori-status-icon sandori-status-success" aria-hidden="true">✓</div>
                <h1 class="sandori-action-title">${msg("infoTitle")}</h1>
                <p class="sandori-action-subtitle"><#if message?has_content>${kcSanitize(message.summary)?no_esc}<#else>${msg("infoDefaultMessage")}</#if></p>

                <div class="sandori-action-stack">
                    <#if pageRedirectUri??>
                        <a class="sandori-btn" href="${pageRedirectUri}">${msg("continueAction")}</a>
                    <#elseif actionUri??>
                        <a class="sandori-btn" href="${actionUri}">${msg("continueAction")}</a>
                    <#elseif client?? && client.baseUrl?has_content>
                        <a class="sandori-btn" href="${client.baseUrl}">${msg("backToService")}</a>
                    <#else>
                        <a class="sandori-btn" href="${url.loginUrl}">${msg("backToLogin")}</a>
                    </#if>
                </div>
            </div>
        </div>
    </#if>
</@layout.registrationLayout>
