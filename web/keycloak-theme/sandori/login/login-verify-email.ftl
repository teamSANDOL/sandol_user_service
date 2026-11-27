<#import "template.ftl" as layout>
<#import "parts.ftl" as parts>
<@layout.registrationLayout displayInfo=false displayMessage=false; section>
    <#if section = "header">
        ${msg("emailVerifyTitle")}
    <#elseif section = "form">
        <div class="sandori-auth-container sandori-centered">
            <@parts.actionTop/>
            <div class="sandori-body">
                <@parts.appIcon small=true/>
                <div class="sandori-status-icon sandori-status-info" aria-hidden="true">i</div>
                <h1 class="sandori-action-title">${msg("emailVerifyTitle")}</h1>
                <p class="sandori-action-subtitle">${msg("emailVerifyInstruction1", user.email)}</p>
                <#if message?has_content>
                    <div class="sandori-message sandori-message-${message.type}" role="alert">${kcSanitize(message.summary)?no_esc}</div>
                </#if>

                <div class="sandori-info-card">${msg("emailVerifyInfo")}</div>

                <form id="kc-verify-email-form" class="sandori-form" action="${url.loginAction}" method="post">
                    <button class="sandori-btn" type="submit">${msg("resendVerifyEmail")}</button>
                </form>

                <div class="sandori-footer-link-block">
                    <a href="${url.loginUrl}">${msg("backToLogin")}</a>
                </div>
            </div>
        </div>
    </#if>
</@layout.registrationLayout>
