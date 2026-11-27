<#-- 한돌이 앱 테마 공통 틀: 상단바(뒤로/언어) + 아이콘 + 제목/부제 + 메시지 -->
<#import "parts.ftl" as parts>
<#macro frame title subtitle="" backUrl="" showMessage=true>
    <div class="sandori-auth-container sandori-centered">
        <div class="sandori-topbar">
            <#if backUrl?has_content><a class="sandori-back" href="${backUrl}" aria-label="${msg("backToLogin")}"><@parts.backArrow/></a></#if>
            <div class="sandori-topbar-end"><@parts.localeSwitch/></div>
        </div>
        <div class="sandori-body">
            <@parts.appIcon small=true/>
            <h1 class="sandori-action-title">${title}</h1>
            <#if subtitle?has_content><p class="sandori-action-subtitle">${subtitle?no_esc}</p></#if>
            <#if showMessage && message?has_content>
                <div class="sandori-message sandori-message-${message.type}" role="alert">${kcSanitize(message.summary)?no_esc}</div>
            </#if>
            <#nested>
        </div>
    </div>
</#macro>
