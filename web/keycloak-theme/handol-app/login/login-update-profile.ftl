<#import "template.ftl" as layout>
<#import "app-frame.ftl" as app>
<#import "register-fields.ftl" as fields>
<@layout.registrationLayout displayInfo=false displayMessage=false; section>
    <#if section = "header">
        ${msg("profileTitle")}
    <#elseif section = "form">
        <@app.frame title=msg("profileTitle") subtitle=msg("profileSubtitle")>
            <form id="kc-update-profile-form" class="sandori-form" action="${url.loginAction}" method="post" novalidate>
                <@fields.attributeFields step='all'/>
                <button class="sandori-btn" type="submit">${msg("saveButton")}</button>
                <#if isAppInitiatedAction??>
                    <button class="sandori-btn sandori-btn-secondary" type="submit" name="cancel-aia" value="true" formnovalidate>${msg("doLater")}</button>
                </#if>
            </form>
        </@app.frame>
    </#if>
</@layout.registrationLayout>
