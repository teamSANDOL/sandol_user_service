<#import "template.ftl" as layout>
<#import "parts.ftl" as parts>
<#import "register-fields.ftl" as fields>
<#-- profile.attributes 에서 단계 분할과 오류 단계를 계산한다. 2단계에 둘 속성이 없으면 한 화면으로 보인다. -->
<#assign step1Error = messagesPerField.existsError('password', 'password-confirm')>
<#assign step2Error = messagesPerField.existsError('termsAccepted')>
<#assign hasStep2Attributes = false>
<#list profile.attributes as attribute>
    <#if attribute.name != 'locale'>
        <#if fields.step1Names?seq_contains(attribute.name)>
            <#if messagesPerField.existsError(attribute.name)><#assign step1Error = true></#if>
        <#else>
            <#assign hasStep2Attributes = true>
            <#if messagesPerField.existsError(attribute.name)><#assign step2Error = true></#if>
        </#if>
    </#if>
</#list>
<#-- 비밀번호는 서버가 다시 채워 주지 않으므로, 비밀번호 칸이 있으면 오류 재표시 때 항상 1단계로 연다 -->
<#if !hasStep2Attributes>
    <#assign startStep = 'single'>
<#elseif !step1Error && step2Error && !passwordRequired??>
    <#assign startStep = '2'>
<#else>
    <#assign startStep = '1'>
</#if>
<#assign reenterPassword = hasStep2Attributes && !step1Error && step2Error && passwordRequired??>
<@layout.registrationLayout displayInfo=false displayMessage=false; section>
    <#if section = "header">
        ${msg("registerTitle")}
    <#elseif section = "form">
        <div class="sandori-auth-container sandori-register" data-step="${startStep}">
            <div class="sandori-topbar">
                <a class="sandori-back" href="${url.loginUrl}" data-action="reg-back" aria-label="${msg("backToLogin")}"><@parts.backArrow/></a>
                <div class="sandori-topbar-end">
                    <#if hasStep2Attributes><span class="sandori-step" aria-live="polite" data-template="${msg("registerStep", "{0}")}"></span></#if>
                    <@parts.localeSwitch/>
                </div>
            </div>

            <header class="sandori-register-head">
                <h1 class="sandori-title">${msg("registerTitle")}</h1>
                <p class="sandori-subtitle sandori-reg-subtitle-1">${msg("registerSubtitle")}</p>
                <#if hasStep2Attributes><p class="sandori-subtitle sandori-reg-subtitle-2">${msg("registerSubtitleStep2")}</p></#if>
            </header>

            <#if message?has_content && !step1Error && !step2Error>
                <div class="sandori-message sandori-message-${message.type}" role="alert">${kcSanitize(message.summary)?no_esc}</div>
            </#if>

            <main>
                <form id="kc-register-form" class="sandori-form sandori-register-form" action="${url.registrationAction}" method="post">
                    <#if hasStep2Attributes>
                        <div class="sandori-reg-step" data-reg-step="1">
                            <@fields.attributeFields step='1' reenter=reenterPassword/>
                        </div>
                        <div class="sandori-reg-step" data-reg-step="2">
                            <@fields.attributeFields step='2'/>
                            <@terms/>
                            <@captcha/>
                        </div>
                        <button type="button" class="sandori-btn sandori-reg-next" data-action="reg-next">${msg("registerNext")}</button>
                    <#else>
                        <div class="sandori-reg-step" data-reg-step="1">
                            <@fields.attributeFields step='all'/>
                            <@terms/>
                            <@captcha/>
                        </div>
                    </#if>
                    <button class="sandori-btn sandori-reg-submit" type="submit">${msg("signUpButton")}</button>
                </form>
            </main>

            <footer>
                <div class="sandori-footer-link-block">
                    <span>${msg("alreadyAccount")}</span><a href="${url.loginUrl}">${msg("backToLogin")}</a>
                </div>
            </footer>

            <#list profile.html5DataAnnotations?keys as key>
                <script type="module" src="${url.resourcesPath}/js/${key}.js"></script>
            </#list>
        </div>
    </#if>
</@layout.registrationLayout>

<#macro terms>
    <section class="sandori-terms-section">
        <h2>${msg("termsTitle")}</h2>
        <div id="kc-registration-terms-text" class="sandori-terms-text">
            ${msg("termsText")?no_esc}
        </div>
        <label class="sandori-check-row" for="termsAccepted">
            <input id="termsAccepted" name="termsAccepted" value="true" type="checkbox" required aria-invalid="<#if messagesPerField.existsError('termsAccepted')>true<#else>false</#if>">
            <span class="sandori-checkmark" aria-hidden="true"></span>
            <span>${msg("termsAccepted")} <span class="sandori-required" aria-hidden="true">*</span></span>
        </label>
        <#if messagesPerField.existsError('termsAccepted')>
            <span class="sandori-field-error" role="alert">${kcSanitize(messagesPerField.get('termsAccepted'))?no_esc}</span>
        </#if>
    </section>
</#macro>

<#macro captcha>
    <#if recaptchaRequired??>
        <div class="g-recaptcha" data-size="compact" data-sitekey="${recaptchaSiteKey}"></div>
    </#if>
</#macro>
