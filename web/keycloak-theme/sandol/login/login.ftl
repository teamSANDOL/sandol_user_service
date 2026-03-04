<!DOCTYPE html>
<#-- self-contained login.ftl: no imports, no layout macros -->
<html lang="${locale.currentLanguageTag!'ko'}">
  <head>
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <#-- css 적용 -->
    <link rel="stylesheet" href="${url.resourcesPath}/css/sandol-login.css">
    <#function t key defaultText>
      <#assign v = msg(key)!>
      <#if v?has_content && v != key>
        <#return v>
      <#else>
        <#return defaultText>
      </#if>
    </#function>
    <title>${msg("doLogIn")! "로그인"} | SANDOL</title>

  </head>

  <body>
    <main class="page_container" role="main" aria-labelledby="page_title">
      <section class="login_card" aria-label="${msg('doLogIn')! '로그인'} 카드">
        <header class="brand_area">
          <div class="brand_logo" aria-hidden="true"></div>
          <h1 id="page_title" class="brand_title">SANDOL ${msg("doLogIn")!"로그인"}</h1>
          <p class="brand_subtitle">${msg("loginAccountTitle")!"간편하게 시작해 보세요"}</p>
        </header>

        <#-- 글로벌 메시지(오류/경고/성공) -->
        <#if message?? && message.summary?has_content>
          <div class="alert ${message.type!'info'}" role="alert">${message.summary}</div>
        </#if>

        <#-- 소셜 로그인 버튼들 -->
        <#if social?? && social.providers?has_content>
          <nav class="oauth_list" aria-label="${msg('socialProviders')!'소셜 로그인 선택'}">
            <#list social.providers as p>
              <#assign providerClass = "oauth_" + (p.alias! "default") >
              <a class="oauth_button ${providerClass}"
                href="${p.loginUrl}"
                aria-label="${p.displayName!p.alias} ${msg('continue')!'로 계속'}">
                <#-- 아이콘: 제공자별 간단한 표식 -->
                <#if (p.alias!'')?lower_case == "google">
                  <span class="google_quadrants" aria-hidden="true">
                    <span class="q1"></span><span class="q2"></span>
                    <span class="q3"></span><span class="q4"></span>
                  </span>
                <#elseif (p.alias!'')?lower_case == "apple">
                  <span class="oauth_icon" aria-hidden="true">A</span>
                <#elseif (p.alias!'')?lower_case == "kakao">
                  <span class="oauth_icon" aria-hidden="true">K</span>
                <#else>
                  <span class="oauth_icon" aria-hidden="true">•</span>
                </#if>
                <span class="oauth_text">${p.displayName!p.alias}</span>
              </a>
            </#list>
          </nav>

          <div class="divider" role="separator" aria-label="${msg('or')!'또는'}">${msg('or')!'또는'}</div>
        </#if>

        <#-- 기본 아이디/비밀번호 로그인 -->
        <form class="form_login" action="${url.loginAction}" method="post" novalidate>
          <div class="form_field">
            <label class="form_label" for="username">${msg('username')!'아이디'}</label>
            <input
              class="form_input"
              type="text"
              id="username"
              name="username"
              autocomplete="username"
              placeholder="${msg('username')!'아이디를 입력하세요'}"
              value="${(login.username!'')}"
              required
            />
          </div>

          <div class="form_field">
            <label class="form_label" for="password">${msg('password')!'비밀번호'}</label>
            <input
              class="form_input"
              type="password"
              id="password"
              name="password"
              autocomplete="current-password"
              placeholder="${msg('password')!'비밀번호를 입력하세요'}"
              required
            />
          </div>

          <div class="form_actions">
            <#if realm.rememberMe?? && realm.rememberMe>
              <label class="checkbox_row">
                <input type="checkbox" name="rememberMe" <#if login.rememberMe?? && login.rememberMe>checked</#if> />
                <span>${msg('rememberMe')!'로그인 상태 유지'}</span>
              </label>
            </#if>

            <#if realm.resetPasswordAllowed?? && realm.resetPasswordAllowed>
              <a class="link_text" href="${url.loginResetCredentialsUrl}">${msg('doForgotPassword')!'비밀번호 찾기'}</a>
            </#if>
          </div>

          <button class="primary_button" type="submit">${msg('doLogIn')!'로그인'}</button>
        </form>
      </section>

      <#if realm.registrationAllowed?? && realm.registrationAllowed>
        <p class="page_footer">
          ${msg('noAccount')!'계정이 없으신가요?'}
          <a class="link_text" href="${url.registrationUrl}">${msg('doRegister')!'회원가입'}</a>
        </p>
      </#if>
    </main>
  </body>
</html>
