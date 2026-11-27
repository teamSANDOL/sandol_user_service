<#-- 로그인 테마 공통 조각: 언어 전환, 앱 아이콘, 뒤로가기 -->
<#macro localeSwitch>
    <#if realm.internationalizationEnabled && locale?? && locale.supported?? && locale.supported?size gt 1>
        <nav class="sandori-locale-switcher" aria-label="${msg("languageSelector")}">
            <#list locale.supported as l>
                <a class="sandori-locale-option<#if l.languageTag == locale.currentLanguageTag> is-active</#if>" href="${l.url}" lang="${l.languageTag}" hreflang="${l.languageTag}"<#if l.languageTag == locale.currentLanguageTag> aria-current="true"</#if>>${l.languageTag?upper_case}</a>
            </#list>
        </nav>
    </#if>
</#macro>

<#macro appIcon small=false>
    <img class="sandori-app-icon<#if small> is-small</#if>" src="${url.resourcesPath}/img/handol-icon.svg" alt="${msg("serviceLogo")}">
</#macro>

<#macro backArrow>
    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true" focusable="false"><path d="M22 12H3"/><path d="M11 4L3 12l8 8"/></svg>
</#macro>

<#-- 상태/비밀번호 화면 공통 머리: 언어 전환 + 아이콘 -->
<#macro actionTop>
    <div class="sandori-topbar">
        <div class="sandori-topbar-end"><@localeSwitch/></div>
    </div>
</#macro>
