<#import "template.ftl" as layout>
<#import "app-frame.ftl" as app>
<@layout.registrationLayout displayInfo=false displayMessage=false; section>
    <#if section = "header">
        ${msg("termsPageTitle")}
    <#elseif section = "form">
        <@app.frame title=msg("termsPageTitle")>
            <div id="kc-terms-text" class="sandori-info-card">${kcSanitize(msg("termsText"))?no_esc}</div>
            <form class="sandori-form sandori-terms-form" action="${url.loginAction}" method="post">
                <button class="sandori-btn" name="accept" id="kc-accept" type="submit">${msg("termsAcceptButton")}</button>
                <button class="sandori-btn sandori-btn-secondary" name="cancel" id="kc-decline" type="submit">${msg("doDecline")}</button>
            </form>
        </@app.frame>
    </#if>
</@layout.registrationLayout>
