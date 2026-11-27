<#import "template.ftl" as layout>
<@layout.registrationLayout displayInfo=false displayMessage=false; section>
    <#if section = "header">
        ${msg("registerTitle")}
    <#elseif section = "form">
        <div class="sandori-auth-container">
            <#if realm.internationalizationEnabled && locale?? && locale.supported?? && locale.supported?size gt 1>
                <nav class="sandori-locale-switcher" aria-label="${msg("languageSelector")}">
                    <#list locale.supported as l>
                        <a class="sandori-locale-option<#if l.languageTag == locale.currentLanguageTag> is-active</#if>" href="${l.url}" lang="${l.languageTag}" hreflang="${l.languageTag}">
                            ${l.languageTag?upper_case}
                        </a>
                    </#list>
                </nav>
            </#if>

            <header class="sandori-header">
                <h1 class="sandori-register-title">${msg("registerTitle")}</h1>
                <p class="sandori-register-subtitle">${msg("registerSubtitle")}</p>
            </header>

            <#if message?has_content>
                <div class="sandori-message sandori-message-${message.type}" role="alert">
                    <span>${kcSanitize(message.summary)?no_esc}</span>
                </div>
            </#if>

            <main>
                <form id="kc-register-form" class="sandori-form sandori-register-form" action="${url.registrationAction}" method="post">
                    <input type="hidden" id="locale" name="locale" value="${(locale.currentLanguageTag!'ko')}">

                    <div class="sandori-input-group">
                        <label for="username">${msg("username")} <span class="sandori-required" aria-hidden="true">*</span></label>
                        <input tabindex="1" id="username" class="sandori-input" name="username" value="${(register.formData.username!'')}" type="text" autocomplete="username" required aria-invalid="<#if messagesPerField.existsError('username')>true</#if>">
                        <#if messagesPerField.existsError('username')>
                            <span class="sandori-field-error" role="alert">${kcSanitize(messagesPerField.get('username'))?no_esc}</span>
                        </#if>
                    </div>

                    <#if passwordRequired??>
                        <div class="sandori-input-group">
                            <label for="password">${msg("password")} <span class="sandori-required" aria-hidden="true">*</span></label>
                            <input tabindex="2" id="password" class="sandori-input" name="password" type="password" autocomplete="new-password" required aria-invalid="<#if messagesPerField.existsError('password','password-confirm')>true</#if>">
                            <#if messagesPerField.existsError('password')>
                                <span class="sandori-field-error" role="alert">${kcSanitize(messagesPerField.get('password'))?no_esc}</span>
                            <#else>
                                <span class="sandori-input-message">${msg("passwordPolicyHint")}</span>
                            </#if>
                        </div>

                        <div class="sandori-input-group">
                            <label for="password-confirm">${msg("passwordConfirm")} <span class="sandori-required" aria-hidden="true">*</span></label>
                            <input tabindex="3" id="password-confirm" class="sandori-input" name="password-confirm" type="password" autocomplete="new-password" required aria-invalid="<#if messagesPerField.existsError('password-confirm')>true</#if>">
                            <#if messagesPerField.existsError('password-confirm')>
                                <span class="sandori-field-error" role="alert">${kcSanitize(messagesPerField.get('password-confirm'))?no_esc}</span>
                            <#else>
                                <span class="sandori-input-message">${msg("passwordConfirmHint")}</span>
                            </#if>
                        </div>
                    </#if>

                    <div class="sandori-input-group">
                        <label for="email">${msg("email")} <span class="sandori-required" aria-hidden="true">*</span></label>
                        <input tabindex="4" id="email" class="sandori-input" name="email" value="${(register.formData.email!'')}" type="email" autocomplete="email" required aria-invalid="<#if messagesPerField.existsError('email')>true</#if>">
                        <#if messagesPerField.existsError('email')>
                            <span class="sandori-field-error" role="alert">${kcSanitize(messagesPerField.get('email'))?no_esc}</span>
                        </#if>
                    </div>

                    <div class="sandori-input-group">
                        <label for="fullname">${msg("fullname")} <span class="sandori-required" aria-hidden="true">*</span></label>
                        <input tabindex="5" id="fullname" class="sandori-input" name="fullname" value="${(register.formData.fullname!'')}" type="text" autocomplete="name" required aria-invalid="<#if messagesPerField.existsError('fullname')>true</#if>">
                        <#if messagesPerField.existsError('fullname')>
                            <span class="sandori-field-error" role="alert">${kcSanitize(messagesPerField.get('fullname'))?no_esc}</span>
                        </#if>
                    </div>

                    <div class="sandori-input-group">
                        <label for="nickname">${msg("nickname")} <span class="sandori-optional">${msg("optional")}</span></label>
                        <input tabindex="6" id="nickname" class="sandori-input" name="nickname" value="${(register.formData.nickname!'')}" type="text" autocomplete="nickname" aria-invalid="<#if messagesPerField.existsError('nickname')>true</#if>">
                        <#if messagesPerField.existsError('nickname')>
                            <span class="sandori-field-error" role="alert">${kcSanitize(messagesPerField.get('nickname'))?no_esc}</span>
                        </#if>
                    </div>

                    <div class="sandori-input-group">
                        <label for="birthdate">${msg("birthdate")} <span class="sandori-optional">${msg("optional")}</span></label>
                        <input tabindex="7" id="birthdate" class="sandori-input" name="birthdate" value="${(register.formData.birthdate!'')}" type="date" aria-invalid="<#if messagesPerField.existsError('birthdate')>true</#if>">
                        <#if messagesPerField.existsError('birthdate')>
                            <span class="sandori-field-error" role="alert">${kcSanitize(messagesPerField.get('birthdate'))?no_esc}</span>
                        </#if>
                    </div>

                    <div class="sandori-input-group">
                        <label for="gender">${msg("gender")} <span class="sandori-optional">${msg("optional")}</span></label>
                        <select tabindex="8" id="gender" class="sandori-input sandori-select" name="gender" aria-invalid="<#if messagesPerField.existsError('gender')>true</#if>">
                            <option value="" <#if !(register.formData.gender??) || register.formData.gender == "">selected</#if>>${msg("genderNone")}</option>
                            <option value="남성" <#if (register.formData.gender!'') == "남성">selected</#if>>${msg("genderMale")}</option>
                            <option value="여성" <#if (register.formData.gender!'') == "여성">selected</#if>>${msg("genderFemale")}</option>
                        </select>
                        <#if messagesPerField.existsError('gender')>
                            <span class="sandori-field-error" role="alert">${kcSanitize(messagesPerField.get('gender'))?no_esc}</span>
                        </#if>
                    </div>

                    <#if recaptchaRequired??>
                        <div class="form-group">
                            <div class="${properties.kcInputWrapperClass!}">
                                <div class="g-recaptcha" data-size="compact" data-sitekey="${recaptchaSiteKey}"></div>
                            </div>
                        </div>
                    </#if>

                    <section class="sandori-terms-section">
                        <h2>${msg("termsTitle")}</h2>
                        <div id="kc-registration-terms-text" class="sandori-terms-text">
                            ${msg("termsText")?no_esc}
                        </div>
                        <div class="sandori-checkbox-group">
                            <label class="sandori-check-row sandori-terms-row" for="termsAccepted">
                                <input tabindex="9" id="termsAccepted" name="termsAccepted" value="true" type="checkbox" required aria-invalid="<#if messagesPerField.existsError('termsAccepted')>true</#if>">
                                <span class="sandori-checkmark" aria-hidden="true"></span>
                                <span class="sandori-check-label">${msg("termsAccepted")} <span class="sandori-required" aria-hidden="true">*</span></span>
                            </label>
                            <#if messagesPerField.existsError('termsAccepted')>
                                <span class="sandori-field-error" role="alert">${kcSanitize(messagesPerField.get('termsAccepted'))?no_esc}</span>
                            </#if>
                        </div>
                    </section>

                    <button tabindex="10" class="sandori-btn sandori-btn-signup" type="submit">${msg("registerButton")}</button>
                </form>
            </main>

            <footer>
                <div class="sandori-footer-link-block">
                    <span>${msg("alreadyAccount")}</span>
                    <a href="${url.loginUrl}">${msg("backToLogin")}</a>
                </div>
            </footer>
        </div>
    </#if>
</@layout.registrationLayout>
