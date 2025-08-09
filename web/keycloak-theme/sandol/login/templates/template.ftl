<#-- template.ftl: base override wrapper if needed. We just extend the parent layout. -->
<#import "/login/base/login.ftl" as parent>
<@parent.registrationLayout x>
  ${x}
</@parent.registrationLayout>
