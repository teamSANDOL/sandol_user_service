<#-- 회원가입 필드: Keycloak user profile 메타데이터(profile.attributes)로 동적 렌더링.
     구조는 base 테마 user-profile-commons.ftl(userProfileFormFields)과 같고 한돌이 디자인 클래스만 다르다. -->
<#-- 1단계에 두는 속성 이름. 나머지 속성은 2단계. -->
<#assign step1Names = ['username', 'email', 'firstName', 'lastName', 'fullname']>
<#assign placeholderKeys = {'username': 'usernamePlaceholder', 'email': 'emailPlaceholder', 'fullname': 'fullnamePlaceholder', 'nickname': 'nicknamePlaceholder'}>

<#-- step: '1' | '2' | 'all' -->
<#macro attributeFields step reenter=false>
    <#local currentGroup = "">
    <#list profile.attributes as attribute>
        <#local inStep1 = step1Names?seq_contains(attribute.name)>
        <#if attribute.name == 'locale'>
            <#if step != '2' && realm.internationalizationEnabled && locale.currentLanguageTag?has_content>
                <input type="hidden" id="${attribute.name}" name="${attribute.name}" value="${locale.currentLanguageTag}"/>
            </#if>
        <#elseif step == 'all' || (step == '1' && inStep1) || (step == '2' && !inStep1)>
            <#local group = (attribute.group)!"">
            <#if group != currentGroup>
                <#local currentGroup = group>
                <#if currentGroup != "">
                    <#local groupHeader = group.displayHeader!"">
                    <div class="sandori-group-header" id="header-${group.name}"<#list group.html5DataAnnotations as key, value> data-${key}="${value}"</#list>>
                        <#if groupHeader != "">${advancedMsg(groupHeader)}<#else>${group.name!""}</#if>
                    </div>
                    <#if (group.displayDescription!"") != "">
                        <p class="sandori-group-description" id="description-${group.name}">${advancedMsg(group.displayDescription)}</p>
                    </#if>
                </#if>
            </#if>

            <div class="sandori-input-group">
                <label for="${attribute.name}">${advancedMsg(attribute.displayName!'')}<#if attribute.required> <span class="sandori-required" aria-hidden="true">*</span><#else> <span class="sandori-optional">${msg("optional")}</span></#if></label>
                <#if attribute.annotations.inputHelperTextBefore??>
                    <div class="sandori-input-message" id="form-help-text-before-${attribute.name}">${kcSanitize(advancedMsg(attribute.annotations.inputHelperTextBefore))?no_esc}</div>
                </#if>
                <@inputFieldByType attribute=attribute/>
                <#if messagesPerField.existsError(attribute.name)>
                    <span class="sandori-field-error" id="input-error-${attribute.name}" role="alert">${kcSanitize(messagesPerField.get(attribute.name))?no_esc}</span>
                </#if>
                <#if attribute.annotations.inputHelperTextAfter??>
                    <div class="sandori-input-message" id="form-help-text-after-${attribute.name}">${kcSanitize(advancedMsg(attribute.annotations.inputHelperTextAfter))?no_esc}</div>
                </#if>
            </div>

            <#-- 비밀번호 칸은 base 테마처럼 username(이메일이 아이디면 email) 바로 아래 -->
            <#if (step == '1' || step == 'all') && passwordRequired?? && (attribute.name == 'username' || (attribute.name == 'email' && realm.registrationEmailAsUsername))>
                <@passwordFields reenter=reenter/>
            </#if>
        </#if>
    </#list>
</#macro>

<#macro passwordFields reenter=false>
    <div class="sandori-input-group">
        <label for="password">${msg("password")} <span class="sandori-required" aria-hidden="true">*</span></label>
        <input id="password" class="sandori-input" name="password" type="password" autocomplete="new-password" required aria-invalid="<#if messagesPerField.existsError('password','password-confirm')>true<#else>false</#if>">
        <#if messagesPerField.existsError('password')>
            <span class="sandori-field-error" role="alert">${kcSanitize(messagesPerField.get('password'))?no_esc}</span>
        <#elseif reenter>
            <span class="sandori-input-message">${msg("passwordReenterHint")}</span>
        <#else>
            <span class="sandori-input-message">${msg("passwordPolicyHint")}</span>
        </#if>
    </div>
    <div class="sandori-input-group">
        <label for="password-confirm">${msg("passwordConfirm")} <span class="sandori-required" aria-hidden="true">*</span></label>
        <input id="password-confirm" class="sandori-input" name="password-confirm" type="password" autocomplete="new-password" required placeholder="${msg("passwordConfirmPlaceholder")}" aria-invalid="<#if messagesPerField.existsError('password-confirm')>true<#else>false</#if>">
        <#if messagesPerField.existsError('password-confirm')>
            <span class="sandori-field-error" role="alert">${kcSanitize(messagesPerField.get('password-confirm'))?no_esc}</span>
        <#else>
            <span class="sandori-input-message">${msg("passwordConfirmHint")}</span>
        </#if>
    </div>
</#macro>

<#macro inputFieldByType attribute>
    <#switch attribute.annotations.inputType!''>
        <#case 'textarea'>
            <@textareaTag attribute=attribute/>
            <#break>
        <#case 'select'>
        <#case 'multiselect'>
            <@selectTag attribute=attribute/>
            <#break>
        <#case 'select-radiobuttons'>
        <#case 'multiselect-checkboxes'>
            <@inputTagSelects attribute=attribute/>
            <#break>
        <#default>
            <#if attribute.multivalued && attribute.values?has_content>
                <#list attribute.values as value>
                    <@inputTag attribute=attribute value=value!''/>
                </#list>
            <#else>
                <@inputTag attribute=attribute value=attribute.value!''/>
            </#if>
    </#switch>
</#macro>

<#macro inputTag attribute value>
    <input type="<@inputTagType attribute=attribute/>" id="${attribute.name}" name="${attribute.name}" value="${(value!'')}" class="sandori-input"
        aria-invalid="<#if messagesPerField.existsError(attribute.name)>true<#else>false</#if>"
        <#if attribute.required>required</#if>
        <#if attribute.readOnly>disabled</#if>
        <#if attribute.autocomplete??>autocomplete="${attribute.autocomplete}"</#if>
        <#if attribute.annotations.inputTypePlaceholder??>placeholder="${advancedMsg(attribute.annotations.inputTypePlaceholder)}"<#elseif placeholderKeys[attribute.name]??>placeholder="${msg(placeholderKeys[attribute.name])}"</#if>
        <#if attribute.annotations.inputTypePattern??>pattern="${attribute.annotations.inputTypePattern}"</#if>
        <#if attribute.annotations.inputTypeSize??>size="${attribute.annotations.inputTypeSize}"</#if>
        <#if attribute.annotations.inputTypeMaxlength??>maxlength="${attribute.annotations.inputTypeMaxlength}"</#if>
        <#if attribute.annotations.inputTypeMinlength??>minlength="${attribute.annotations.inputTypeMinlength}"</#if>
        <#if attribute.annotations.inputTypeMax??>max="${attribute.annotations.inputTypeMax}"</#if>
        <#if attribute.annotations.inputTypeMin??>min="${attribute.annotations.inputTypeMin}"</#if>
        <#if attribute.annotations.inputTypeStep??>step="${attribute.annotations.inputTypeStep}"</#if>
        <#list attribute.html5DataAnnotations as key, value>
            data-${key}="${value}"
        </#list>
    />
</#macro>

<#macro inputTagType attribute>
    <#compress>
        <#if attribute.annotations.inputType??>
            <#if attribute.annotations.inputType?starts_with("html5-")>${attribute.annotations.inputType[6..]}<#else>${attribute.annotations.inputType}</#if>
        <#else>text</#if>
    </#compress>
</#macro>

<#macro textareaTag attribute>
    <textarea id="${attribute.name}" name="${attribute.name}" class="sandori-input sandori-textarea"
        aria-invalid="<#if messagesPerField.existsError(attribute.name)>true<#else>false</#if>"
        <#if attribute.required>required</#if>
        <#if attribute.readOnly>disabled</#if>
        <#if attribute.annotations.inputTypeCols??>cols="${attribute.annotations.inputTypeCols}"</#if>
        <#if attribute.annotations.inputTypeRows??>rows="${attribute.annotations.inputTypeRows}"</#if>
        <#if attribute.annotations.inputTypeMaxlength??>maxlength="${attribute.annotations.inputTypeMaxlength}"</#if>
    >${(attribute.value!'')}</textarea>
</#macro>

<#function attributeOptions attribute>
    <#if attribute.annotations.inputOptionsFromValidation?? && attribute.validators[attribute.annotations.inputOptionsFromValidation]?? && attribute.validators[attribute.annotations.inputOptionsFromValidation].options??>
        <#return attribute.validators[attribute.annotations.inputOptionsFromValidation].options>
    <#elseif attribute.validators.options?? && attribute.validators.options.options??>
        <#return attribute.validators.options.options>
    </#if>
    <#return []>
</#function>

<#macro selectTag attribute>
    <select id="${attribute.name}" name="${attribute.name}" class="sandori-input sandori-select"
        aria-invalid="<#if messagesPerField.existsError(attribute.name)>true<#else>false</#if>"
        <#if attribute.required>required</#if>
        <#if attribute.readOnly>disabled</#if>
        <#if attribute.annotations.inputType=='multiselect'>multiple</#if>
        <#if attribute.annotations.inputTypeSize??>size="${attribute.annotations.inputTypeSize}"</#if>
    >
        <#if attribute.annotations.inputType=='select'>
            <option value="">${msg("selectNone")}</option>
        </#if>
        <#list attributeOptions(attribute) as option>
            <option value="${option}" <#if attribute.values?seq_contains(option)>selected</#if>><@selectOptionLabelText attribute=attribute option=option/></option>
        </#list>
    </select>
</#macro>

<#macro inputTagSelects attribute>
    <#if attribute.annotations.inputType=='select-radiobuttons'><#local inputType='radio'><#else><#local inputType='checkbox'></#if>
    <#list attributeOptions(attribute) as option>
        <label class="sandori-check-row" for="${attribute.name}-${option}">
            <input type="${inputType}" id="${attribute.name}-${option}" name="${attribute.name}" value="${option}"
                aria-invalid="<#if messagesPerField.existsError(attribute.name)>true<#else>false</#if>"
                <#if attribute.readOnly>disabled</#if>
                <#if attribute.values?seq_contains(option)>checked</#if>
            />
            <span class="sandori-checkmark" aria-hidden="true"></span>
            <span><@selectOptionLabelText attribute=attribute option=option/></span>
        </label>
    </#list>
</#macro>

<#macro selectOptionLabelText attribute option>
    <#compress>
        <#if attribute.annotations.inputOptionLabels??>
            ${advancedMsg(attribute.annotations.inputOptionLabels[option]!option)}
        <#elseif attribute.annotations.inputOptionLabelsI18nPrefix??>
            ${msg(attribute.annotations.inputOptionLabelsI18nPrefix + '.' + option)}
        <#else>${option}</#if>
    </#compress>
</#macro>
