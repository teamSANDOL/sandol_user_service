<#-- SANDOL standalone error.ftl : 부모 template.ftl에 의존하지 않음 -->

<!DOCTYPE html>
<html lang="${(locale!'ko')?lower_case}">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>${msg("errorTitle")!"오류"}</title>
  <link rel="stylesheet" href="${url.resourcesPath}/css/sandol-login.css">
</head>
<body class="sandol-login">

  <main class="container">
    <header class="brand_area" role="banner">
      <div class="brand_logo" aria-hidden="true"></div>
      <h1 class="brand_title">${msg("errorTitle")!"오류"}</h1>
    </header>

    <section class="login_card" role="main" aria-labelledby="errorTitle">
      <h2 id="errorTitle" class="sr-only">에러</h2>

      <div id="kc-error-message" class="alert-error" role="alert">
        <span class="kc-feedback-text">
          ${(message.summary)! (msg("unexpectedError")!"예기치 못한 오류가 발생했습니다.")}
        </span>
      </div>

      <div class="actions">
        <#if client?? && client.baseUrl?has_content>
          <a class="link_text" href="${client.baseUrl}">${msg("backToApplication")!"애플리케이션으로 돌아가기"}</a>
        </#if>
        <#if url.loginUrl??>
          <a class="link_text" href="${url.loginUrl}">${msg("doTryAgain")!"다시 시도"}</a>
        </#if>
      </div>
    </section>
  </main>

</body>
</html>
