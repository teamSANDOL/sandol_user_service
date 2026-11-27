<#import "template.ftl" as layout>
<#import "app-frame.ftl" as app>
<@layout.registrationLayout displayInfo=false displayMessage=false; section>
    <#if section = "header">
        ${msg("infoTitle")}
    <#elseif section = "form">
        <@app.frame title=msg("infoTitle") showMessage=false>
            <p class="sandori-action-subtitle"><#if message?has_content>${kcSanitize(message.summary)?no_esc}<#else>${msg("infoDefaultMessage")}</#if></p>
            <#-- 돌아갈 곳이 서버가 준 주소(pageRedirectUri/actionUri)일 때만 버튼을 그린다 -->
            <#if pageRedirectUri?? || actionUri??>
                <div class="sandori-action-stack">
                    <#if pageRedirectUri??>
                        <a class="sandori-btn" href="${pageRedirectUri}">${msg("backToApp")}</a>
                    <#else>
                        <a class="sandori-btn" href="${actionUri}">${msg("continueAction")}</a>
                    </#if>
                </div>
            </#if>
        </@app.frame>
    </#if>
</@layout.registrationLayout>
