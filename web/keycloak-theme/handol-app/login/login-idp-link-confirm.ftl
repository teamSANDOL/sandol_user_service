<#import "template.ftl" as layout>
<#import "app-frame.ftl" as app>
<@layout.registrationLayout displayInfo=false displayMessage=false; section>
    <#if section = "header">
        ${msg("confirmLinkIdpTitle")}
    <#elseif section = "form">
        <@app.frame title=msg("confirmLinkIdpTitle")>
            <form id="kc-register-form" class="sandori-form" action="${url.loginAction}" method="post">
                <button type="submit" class="sandori-btn" name="submitAction" id="linkAccount" value="linkAccount">${msg("confirmLinkIdpContinue", idpDisplayName)}</button>
                <#if !hideReviewButton?has_content>
                    <button type="submit" class="sandori-btn sandori-btn-secondary" name="submitAction" id="updateProfile" value="updateProfile">${msg("confirmLinkIdpReviewProfile")}</button>
                </#if>
            </form>
        </@app.frame>
    </#if>
</@layout.registrationLayout>
