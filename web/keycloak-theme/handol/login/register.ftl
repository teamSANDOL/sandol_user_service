<#import "template.ftl" as layout>
<#import "parts.ftl" as parts>
<#assign step1Error = messagesPerField.existsError('username','password','password-confirm','email','fullname')>
<#assign step2Error = messagesPerField.existsError('nickname','birthdate','gender','termsAccepted')>
<#-- 비밀번호는 서버가 다시 채워 주지 않으므로, 비밀번호 칸이 있으면 오류 재표시 때 항상 1단계로 연다 -->
<#assign startStep = (!step1Error && step2Error && !passwordRequired??)?then(2, 1)>
<@layout.registrationLayout displayInfo=false displayMessage=false; section>
    <#if section = "header">
        ${msg("registerTitle")}
    <#elseif section = "form">
        <div class="sandori-auth-container sandori-register" data-step="${startStep}">
            <div class="sandori-topbar">
                <a class="sandori-back" href="${url.loginUrl}" data-action="reg-back" aria-label="${msg("backToLogin")}"><@parts.backArrow/></a>
                <div class="sandori-topbar-end">
                    <span class="sandori-step" data-template="${msg("registerStep", "{0}")}"></span>
                    <@parts.localeSwitch/>
                </div>
            </div>

            <header class="sandori-register-head">
                <h1 class="sandori-title">${msg("registerTitle")}</h1>
                <p class="sandori-subtitle sandori-reg-subtitle-1">${msg("registerSubtitle")}</p>
                <p class="sandori-subtitle sandori-reg-subtitle-2">${msg("registerSubtitleStep2")}</p>
            </header>

            <#if message?has_content && !messagesPerField.existsError('username','password','password-confirm','email','fullname','nickname','birthdate','gender','termsAccepted')>
                <div class="sandori-message sandori-message-${message.type}" role="alert">${kcSanitize(message.summary)?no_esc}</div>
            </#if>

            <main>
                <form id="kc-register-form" class="sandori-form sandori-register-form" action="${url.registrationAction}" method="post">
                    <input type="hidden" id="locale" name="locale" value="${(locale.currentLanguageTag!'ko')}">

                    <div class="sandori-reg-step" data-reg-step="1">
                        <div class="sandori-input-group">
                            <label for="username">${msg("username")} <span class="sandori-required" aria-hidden="true">*</span></label>
                            <input tabindex="1" id="username" class="sandori-input" name="username" value="${(register.formData.username!'')}" type="text" autocomplete="username" required placeholder="${msg("usernamePlaceholder")}" aria-invalid="<#if messagesPerField.existsError('username')>true<#else>false</#if>">
                            <#if messagesPerField.existsError('username')>
                                <span class="sandori-field-error" role="alert">${kcSanitize(messagesPerField.get('username'))?no_esc}</span>
                            </#if>
                        </div>
                        <#if passwordRequired??>
                            <div class="sandori-input-group">
                                <label for="password">${msg("password")} <span class="sandori-required" aria-hidden="true">*</span></label>
                                <input tabindex="2" id="password" class="sandori-input" name="password" type="password" autocomplete="new-password" required aria-invalid="<#if messagesPerField.existsError('password','password-confirm')>true<#else>false</#if>">
                                <#if messagesPerField.existsError('password')>
                                    <span class="sandori-field-error" role="alert">${kcSanitize(messagesPerField.get('password'))?no_esc}</span>
                                <#elseif step2Error && !step1Error>
                                    <span class="sandori-input-message">${msg("passwordReenterHint")}</span>
                                <#else>
                                    <span class="sandori-input-message">${msg("passwordPolicyHint")}</span>
                                </#if>
                            </div>
                            <div class="sandori-input-group">
                                <label for="password-confirm">${msg("passwordConfirm")} <span class="sandori-required" aria-hidden="true">*</span></label>
                                <input tabindex="3" id="password-confirm" class="sandori-input" name="password-confirm" type="password" autocomplete="new-password" required placeholder="${msg("passwordConfirmPlaceholder")}" aria-invalid="<#if messagesPerField.existsError('password-confirm')>true<#else>false</#if>">
                                <#if messagesPerField.existsError('password-confirm')>
                                    <span class="sandori-field-error" role="alert">${kcSanitize(messagesPerField.get('password-confirm'))?no_esc}</span>
                                <#else>
                                    <span class="sandori-input-message">${msg("passwordConfirmHint")}</span>
                                </#if>
                            </div>
                        </#if>
                        <div class="sandori-input-group">
                            <label for="email">${msg("email")} <span class="sandori-required" aria-hidden="true">*</span></label>
                            <input tabindex="4" id="email" class="sandori-input" name="email" value="${(register.formData.email!'')}" type="email" autocomplete="email" required placeholder="${msg("emailPlaceholder")}" aria-invalid="<#if messagesPerField.existsError('email')>true<#else>false</#if>">
                            <#if messagesPerField.existsError('email')>
                                <span class="sandori-field-error" role="alert">${kcSanitize(messagesPerField.get('email'))?no_esc}</span>
                            </#if>
                        </div>
                        <div class="sandori-input-group">
                            <label for="fullname">${msg("fullname")} <span class="sandori-required" aria-hidden="true">*</span></label>
                            <input tabindex="5" id="fullname" class="sandori-input" name="fullname" value="${(register.formData.fullname!'')}" type="text" autocomplete="name" required placeholder="${msg("fullnamePlaceholder")}" aria-invalid="<#if messagesPerField.existsError('fullname')>true<#else>false</#if>">
                            <#if messagesPerField.existsError('fullname')>
                                <span class="sandori-field-error" role="alert">${kcSanitize(messagesPerField.get('fullname'))?no_esc}</span>
                            </#if>
                        </div>

                        <#if recaptchaRequired??>
                            <div class="g-recaptcha" data-size="compact" data-sitekey="${recaptchaSiteKey}"></div>
                        </#if>
                    </div>

                    <div class="sandori-reg-step" data-reg-step="2">
                        <div class="sandori-input-group">
                            <label for="nickname">${msg("nickname")} <span class="sandori-optional">${msg("optional")}</span></label>
                            <input tabindex="6" id="nickname" class="sandori-input" name="nickname" value="${(register.formData.nickname!'')}" type="text" autocomplete="nickname" placeholder="${msg("nicknamePlaceholder")}" aria-invalid="<#if messagesPerField.existsError('nickname')>true<#else>false</#if>">
                            <#if messagesPerField.existsError('nickname')>
                                <span class="sandori-field-error" role="alert">${kcSanitize(messagesPerField.get('nickname'))?no_esc}</span>
                            </#if>
                        </div>
                        <div class="sandori-input-group">
                            <label for="birthdate">${msg("birthdate")} <span class="sandori-optional">${msg("optional")}</span></label>
                            <input tabindex="7" id="birthdate" class="sandori-input" name="birthdate" value="${(register.formData.birthdate!'')}" type="date" aria-invalid="<#if messagesPerField.existsError('birthdate')>true<#else>false</#if>">
                            <#if messagesPerField.existsError('birthdate')>
                                <span class="sandori-field-error" role="alert">${kcSanitize(messagesPerField.get('birthdate'))?no_esc}</span>
                            </#if>
                        </div>
                        <div class="sandori-input-group">
                            <label for="gender">${msg("gender")} <span class="sandori-optional">${msg("optional")}</span></label>
                            <select tabindex="8" id="gender" class="sandori-input sandori-select" name="gender" aria-invalid="<#if messagesPerField.existsError('gender')>true<#else>false</#if>">
                                <option value="" <#if !(register.formData.gender??) || register.formData.gender == "">selected</#if>>${msg("genderNone")}</option>
                                <option value="남성" <#if (register.formData.gender!'') == "남성">selected</#if>>${msg("genderMale")}</option>
                                <option value="여성" <#if (register.formData.gender!'') == "여성">selected</#if>>${msg("genderFemale")}</option>
                            </select>
                            <#if messagesPerField.existsError('gender')>
                                <span class="sandori-field-error" role="alert">${kcSanitize(messagesPerField.get('gender'))?no_esc}</span>
                            </#if>
                        </div>

                        <section class="sandori-terms-section">
                            <h2>${msg("termsTitle")}</h2>
                            <div id="kc-registration-terms-text" class="sandori-terms-text">
                                ${msg("termsText")?no_esc}
                            </div>
                            <label class="sandori-check-row" for="termsAccepted">
                                <input tabindex="9" id="termsAccepted" name="termsAccepted" value="true" type="checkbox" required aria-invalid="<#if messagesPerField.existsError('termsAccepted')>true<#else>false</#if>">
                                <span class="sandori-checkmark" aria-hidden="true"></span>
                                <span>${msg("termsAccepted")} <span class="sandori-required" aria-hidden="true">*</span></span>
                            </label>
                            <#if messagesPerField.existsError('termsAccepted')>
                                <span class="sandori-field-error" role="alert">${kcSanitize(messagesPerField.get('termsAccepted'))?no_esc}</span>
                            </#if>
                        </section>
                    </div>

                    <button type="button" class="sandori-btn sandori-reg-next" data-action="reg-next">${msg("registerNext")}</button>
                    <button tabindex="10" class="sandori-btn sandori-reg-submit" type="submit">${msg("signUpButton")}</button>
                </form>
            </main>

            <section class="sandori-reg-about">
                <strong>${msg("aboutTitle")}</strong>
                <p>${msg("aboutText")?no_esc}</p>
            </section>

            <footer>
                <div class="sandori-footer-link-block">
                    <span>${msg("alreadyAccount")}</span><a href="${url.loginUrl}">${msg("backToLogin")}</a>
                </div>
            </footer>
        </div>
    </#if>
</@layout.registrationLayout>
