<#import "template.ftl" as layout>
<#import "app-frame.ftl" as app>
<@layout.registrationLayout displayInfo=false displayMessage=false; section>
    <#if section = "header">
        ${msg("logoutConfirmHeader")}
    <#elseif section = "form">
        <@app.frame title=msg("logoutConfirmHeader")>
            <form class="sandori-form" action="${url.logoutConfirmAction}" method="post">
                <input type="hidden" name="session_code" value="${logoutConfirm.code}">
                <button class="sandori-btn" name="confirmLogout" id="kc-logout" type="submit">${msg("doLogout")}</button>
            </form>
            <#if !logoutConfirm.skipLink && (client.baseUrl)?has_content>
                <div class="sandori-footer-link-block"><a href="${client.baseUrl}">${msg("backToApplication")}</a></div>
            </#if>
        </@app.frame>
    </#if>
</@layout.registrationLayout>
