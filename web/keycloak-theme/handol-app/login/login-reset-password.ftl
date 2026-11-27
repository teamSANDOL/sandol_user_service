<#import "template.ftl" as layout>
<#import "app-frame.ftl" as app>
<@layout.registrationLayout displayInfo=false displayMessage=false; section>
    <#if section = "header">
        ${msg("resetPasswordTitle")}
    <#elseif section = "form">
        <@app.frame title=msg("resetPasswordTitle") subtitle=msg("resetPasswordSubtitle") backUrl=url.loginUrl showMessage=!messagesPerField.existsError('username')>
            <form id="kc-reset-password-form" class="sandori-form" action="${url.loginAction}" method="post" novalidate>
                <label class="sandori-sr-only" for="username">${msg("email")}</label>
                <input tabindex="1" id="username" class="sandori-input" name="username" value="${(auth.attemptedUsername!'')}" type="text"
                    autocomplete="email" inputmode="email" autocapitalize="none" spellcheck="false" placeholder="${msg("emailPlaceholder")}"
                    aria-invalid="<#if messagesPerField.existsError('username')>true<#else>false</#if>">
                <#if messagesPerField.existsError('username')>
                    <span class="sandori-field-error" role="alert">${kcSanitize(messagesPerField.get('username'))?no_esc}</span>
                </#if>
                <button tabindex="2" class="sandori-btn" type="submit">${msg("resetPasswordSubmit")}</button>
            </form>
            <div class="sandori-footer-link-block"><a href="${url.loginUrl}">${msg("backToLogin")}</a></div>
        </@app.frame>
    </#if>
</@layout.registrationLayout>
