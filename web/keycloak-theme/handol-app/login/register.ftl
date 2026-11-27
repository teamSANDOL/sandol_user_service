<#import "template.ftl" as layout>
<#import "parts.ftl" as parts>
<#import "register-fields.ftl" as fields>
<#-- 오류 단계 계산: 서버 오류가 있는 단계로 열어 준다. 2단계에 둘 속성이 없으면 한 화면으로 보인다. -->
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
<#-- 비밀번호는 서버가 다시 채워 주지 않으므로 비밀번호 칸이 있으면 오류 재표시 때 항상 1단계로 연다 -->
<#if !hasStep2Attributes>
    <#assign startStep = 'single'>
<#elseif !step1Error && step2Error && !passwordRequired??>
    <#assign startStep = '2'>
<#else>
    <#assign startStep = '1'>
</#if>
<#assign reenterPassword = hasStep2Attributes && !step1Error && step2Error && passwordRequired??>
<#assign termsPrev = ((register.formData['termsAccepted'])!'') == 'true'>
<@layout.registrationLayout displayInfo=false displayMessage=false; section>
    <#if section = "header">
        ${msg("registerTitle")}
    <#elseif section = "form">
        <div class="sandori-auth-container sandori-register" data-step="${startStep}"
            data-msg-password="${msg("passwordRuleError")}" data-msg-confirm="${msg("passwordMismatch")}" data-msg-email="${msg("emailFormatError")}">
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

            <noscript>
                <div class="sandori-message sandori-message-warning" role="alert">${msg("noscriptRegister")}</div>
                <style>.sandori-register-form, .sandori-reg-about { display: none !important; }</style>
            </noscript>

            <main>
                <form id="kc-register-form" class="sandori-form sandori-register-form" action="${url.registrationAction}" method="post">
                    <#if hasStep2Attributes>
                        <div class="sandori-reg-step" data-reg-step="1">
                            <@fields.attributeFields step='1' reenter=reenterPassword/>
                            <section class="sandori-reg-about">
                            <strong>${msg("aboutTitle")}</strong>
                            <p>${msg("aboutText")?no_esc}</p>
                            </section>
                        </div>
                        <div class="sandori-reg-step" data-reg-step="2">
                            <@fields.attributeFields step='2'/>
                            <@consents/>
                            <@captcha/>
                        </div>
                        <button type="button" class="sandori-btn sandori-reg-next" data-action="reg-next">${msg("registerNext")}</button>
                    <#else>
                        <div class="sandori-reg-step" data-reg-step="1">
                            <@fields.attributeFields step='all'/>
                            <@consents/>
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

            <#-- 개인정보 수집·이용 바텀시트 -->
            <dialog id="sheet-privacy" class="sandori-sheet" aria-labelledby="sheet-privacy-title">
                <div class="sandori-sheet-head"><h2 id="sheet-privacy-title">${msg("privacyRequired")}</h2><button type="button" class="sandori-sheet-close" data-sheet-close aria-label="${msg("closeLabel")}">&times;</button></div>
                <div class="sandori-sheet-body">
                    <table class="sandori-table">
                        <thead><tr><th scope="col">${msg("tableKind")}</th><th scope="col">${msg("tableItems")}</th><th scope="col">${msg("tablePurpose")}</th><th scope="col">${msg("tablePeriod")}</th></tr></thead>
                        <tbody>
                            <tr><th scope="row">${msg("kindRequired")}</th><td>${msg("privReqItems")}</td><td>${msg("privReqPurpose")}</td><td>${msg("privPeriod")}</td></tr>
                            <tr><th scope="row">${msg("kindOptional")}</th><td>${msg("privOptItems")}</td><td>${msg("privOptPurpose")}</td><td>${msg("privPeriod")}</td></tr>
                        </tbody>
                    </table>
                    <p class="sandori-sheet-note">${msg("privNote")}</p>
                    <a class="sandori-sheet-link" href="${properties.privacyPolicyUrl}" target="_blank" rel="noopener noreferrer">${msg("privacyPolicyLink")}</a>
                </div>
            </dialog>


            <#list profile.html5DataAnnotations?keys as key>
                <script type="module" src="${url.resourcesPath}/js/${key}.js"></script>
            </#list>
        </div>
    </#if>
</@layout.registrationLayout>

<#macro consents>
    <section class="sandori-consents" aria-labelledby="consents-title">
        <h2 id="consents-title" class="sandori-sr-only">${msg("termsTitle")}</h2>
        <label class="sandori-check-row sandori-consent-all" for="consent-all">
            <input id="consent-all" type="checkbox" data-consent-all>
            <span class="sandori-checkmark" aria-hidden="true"></span>
            <span>${msg("consentAll")}</span>
        </label>
        <div class="sandori-consent-item">
            <label class="sandori-check-row" for="consent-terms">
                <input id="consent-terms" type="checkbox" name="termsAccepted" value="true" required data-consent<#if termsPrev> checked</#if>>
                <span class="sandori-checkmark" aria-hidden="true"></span>
                <span>${msg("termsRequired")}</span>
            </label>
            <a class="sandori-info-btn" href="${properties.termsUrl}" target="_blank" rel="noopener noreferrer" aria-label="${msg("termsViewLabel")}"><svg viewBox="0 0 20 20" fill="none" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" aria-hidden="true" focusable="false"><circle cx="10" cy="10" r="8"/><path d="M10 9v4.5"/><circle cx="10" cy="6.2" r=".6" fill="currentColor"/></svg></a>
        </div>
        <div class="sandori-consent-item">
            <label class="sandori-check-row" for="consent-privacy">
                <input id="consent-privacy" type="checkbox" required data-consent<#if termsPrev> checked</#if>>
                <span class="sandori-checkmark" aria-hidden="true"></span>
                <span>${msg("privacyRequired")}</span>
            </label>
            <button type="button" class="sandori-info-btn" data-sheet-open="sheet-privacy" aria-label="${msg("privacyViewLabel")}"><svg viewBox="0 0 20 20" fill="none" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" aria-hidden="true" focusable="false"><circle cx="10" cy="10" r="8"/><path d="M10 9v4.5"/><circle cx="10" cy="6.2" r=".6" fill="currentColor"/></svg></button>
        </div>
        <div class="sandori-consent-item">
            <label class="sandori-check-row" for="consent-overseas">
                <input id="consent-overseas" type="checkbox" required data-consent<#if termsPrev> checked</#if>>
                <span class="sandori-checkmark" aria-hidden="true"></span>
                <span>${msg("overseasRequired")}</span>
            </label>
            <a class="sandori-info-btn" href="${properties.overseasTransferUrl}" target="_blank" rel="noopener noreferrer" aria-label="${msg("overseasViewLabel")}"><svg viewBox="0 0 20 20" fill="none" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" aria-hidden="true" focusable="false"><circle cx="10" cy="10" r="8"/><path d="M10 9v4.5"/><circle cx="10" cy="6.2" r=".6" fill="currentColor"/></svg></a>
        </div>
        <#-- 서버에는 termsAccepted 하나만 간다(이용약관 체크박스가 name 을 가짐). 필수 3개를 모두 required 로 두어 HTML 만으로도 3개 모두 체크해야 제출된다. JS 는 전체 동의·버튼 활성만 돕는다. -->
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
