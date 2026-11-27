<#import "template.ftl" as layout>
<#import "parts.ftl" as parts>
<@layout.registrationLayout displayInfo=false displayMessage=false; section>
    <#if section = "header">
        ${msg("emailForgotTitle")}
    <#elseif section = "form">
        <div class="sandori-auth-container sandori-centered">
            <@parts.actionTop/>
            <div class="sandori-body">
                <@parts.appIcon small=true/>
                <h1 class="sandori-action-title">${msg("resetPasswordTitle")}</h1>
                <p class="sandori-action-subtitle">${msg("resetPasswordSubtitle")}</p>
                <#if message?has_content>
                    <div class="sandori-message sandori-message-${message.type}" role="alert">${kcSanitize(message.summary)?no_esc}</div>
                </#if>

                <form id="kc-reset-password-form" class="sandori-form" action="${url.loginAction}" method="post">
                    <div class="sandori-input-group">
                        <label for="username">${msg("usernameOrEmail")}</label>
                        <input tabindex="1" id="username" class="sandori-input" name="username" value="${(auth.attemptedUsername!'')}" type="text" autofocus autocomplete="username" aria-invalid="<#if messagesPerField.existsError('username')>true<#else>false</#if>">
                        <#if messagesPerField.existsError('username')>
                            <span class="sandori-field-error" role="alert">${kcSanitize(messagesPerField.get('username'))?no_esc}</span>
                        <#else>
                            <span class="sandori-input-message">${msg("resetPasswordHint")}</span>
                        </#if>
                    </div>
                    <button tabindex="2" class="sandori-btn" type="submit">${msg("resetPasswordSubmit")}</button>
                </form>

                <div class="sandori-footer-link-block">
                    <a href="${url.loginUrl}">${msg("backToLogin")}</a>
                </div>
            </div>
        </div>
    </#if>
</@layout.registrationLayout>
