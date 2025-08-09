<#-- login.ftl: SANDOL 커스텀 Keycloak 로그인 템플릿 -->
<#-- 필요 매크로 로드 -->
<#import "template.ftl" as layout>
<@layout.registrationLayout bodyClass="login-pf" displayInfo=social.displayInfo; section>
  <#if section == "title">
    SANDOL 로그인
  <#elseif section == "header">
    <div class="brand_area">
      <div class="brand_logo" aria-hidden="true"></div>
      <h1 class="brand_title">SANDOL 로그인</h1>
      <p class="brand_subtitle">간편하게 시작해 보세요</p>
    </div>
  <#elseif section == "form">
    <div class="login_card">
      <#if messagesPerField.exists('username') || messagesPerField.exists('password') || (message.summary?has_content) >
        <div id="kc-error-message" class="alert-error" role="alert">
          <span class="kc-feedback-text">${message.summary?no_esc}</span>
        </div>
      </#if>

      <#-- 소셜 로그인 -->
      <#if realm.password && social.providers?has_content>
        <nav class="oauth_list" aria-label="소셜 로그인 선택">
          <#list social.providers as p>
            <#-- Provider alias 로 테마 버튼 스타일 매핑 -->
            <#assign btnClass = "oauth_button">
            <#if p.alias == "kakao"> <#assign btnClass = btnClass + " oauth_kakao"> </#if>
            <#if p.alias == "google"> <#assign btnClass = btnClass + " oauth_google"> </#if>
            <#if p.alias == "apple"> <#assign btnClass = btnClass + " oauth_apple"> </#if>
            <a class="${btnClass}" href="${p.loginUrl}">
              <#-- 아이콘 영역 -->
              <#if p.alias == "google">
                <span class="google_quadrants" aria-hidden="true">
                  <span class="q1"></span><span class="q2"></span>
                  <span class="q3"></span><span class="q4"></span>
                </span>
              <#elseif p.alias == "kakao">
                <span class="oauth_icon" aria-hidden="true">K</span>
              <#elseif p.alias == "apple">
                <span class="oauth_icon" aria-hidden="true"></span>
              <#else>
                <span class="oauth_icon" aria-hidden="true">${p.displayName?substring(0,1)?upper_case}</span>
              </#if>
              <span class="oauth_text">${p.displayName}로 계속</span>
            </a>
          </#list>
        </nav>
        <div class="divider" role="separator" aria-label="또는">또는</div>
      </#if>

      <form id="kc-form-login" onsubmit="login.disabled = true; return true;" action="${url.loginAction}" method="post">
        <input type="hidden" id="id-hidden-input" name="credentialId"/>
        <div class="form_group">
          <label for="username" class="form_label">아이디</label>
          <input tabindex="1" id="username" class="" name="username" value="${(login.username!'')?html}" type="text" autocomplete="username" autofocus required />
        </div>
        <div class="form_group">
          <label for="password" class="form_label">비밀번호</label>
          <input tabindex="2" id="password" name="password" type="password" autocomplete="current-password" required />
        </div>

        <div class="form_actions_row">
          <#if realm.rememberMe && !usernameEditDisabled??>
            <label class="checkbox_row" for="rememberMe">
              <input tabindex="3" id="rememberMe" name="rememberMe" type="checkbox" <#if login.rememberMe??>checked</#if> /> 로그인 상태 유지
            </label>
          </#if>
          <#if realm.resetPasswordAllowed>
            <span><a class="link_text" tabindex="5" href="${url.loginResetCredentialsUrl}">비밀번호 찾기</a></span>
          </#if>
        </div>

        <div>
          <input tabindex="4" id="kc-login" type="submit" value="로그인" />
        </div>
      </form>

      <#if realm.registrationAllowed && !registrationDisabled??>
        <p class="page_footer">계정이 없으신가요? <a class="link_text" href="${url.registrationUrl}">회원가입</a></p>
      </#if>
    </div>
  </#if>
</@layout.registrationLayout>
