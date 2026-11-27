/* 한돌이 앱 로그인 테마: 로그인 버튼 활성, 회원가입 1→2단계, 동의 합치기, 바텀시트. */
(function () {
    'use strict';

    document.documentElement.classList.add('sandori-js');

    // 영문+숫자 8자 이상. realm Password Policy 와 어긋나면 서버 오류가 해당 칸 아래에 표시된다.
    var PASSWORD_RULE = /^(?=.*[A-Za-z])(?=.*\d).{8,}$/;

    function ready(fn) {
        if (document.readyState === 'loading') {
            document.addEventListener('DOMContentLoaded', fn);
        } else {
            fn();
        }
    }

    // 같은 폼을 두 번 제출하지 않게 하고 버튼에 로딩 표시를 준다.
    function guardSubmit(form) {
        form.addEventListener('submit', function (event) {
            if (event.defaultPrevented) {
                return;
            }
            if (form.getAttribute('data-busy') === 'true') {
                event.preventDefault();
                return;
            }
            form.setAttribute('data-busy', 'true');
            var buttons = form.querySelectorAll('button[type="submit"]');
            for (var i = 0; i < buttons.length; i += 1) {
                buttons[i].classList.add('is-loading');
                buttons[i].setAttribute('aria-busy', 'true');
            }
        });
    }

    // 뒤로가기(bfcache)로 돌아왔을 때 로딩 상태를 푼다.
    window.addEventListener('pageshow', function () {
        document.querySelectorAll('form[data-busy]').forEach(function (form) {
            form.removeAttribute('data-busy');
            form.querySelectorAll('.is-loading').forEach(function (b) {
                b.classList.remove('is-loading');
                b.removeAttribute('aria-busy');
            });
        });
    });

    // 키보드가 올라와도 입력칸이 가려지지 않게 한다.
    function keepFocusedVisible(root) {
        root.addEventListener('focusin', function (event) {
            var el = event.target;
            if (el && /^(INPUT|SELECT|TEXTAREA)$/.test(el.tagName) && el.scrollIntoView) {
                setTimeout(function () { el.scrollIntoView({ block: 'center', behavior: 'smooth' }); }, 250);
            }
        });
    }

    function initLogin(root) {
        var username = root.querySelector('#username');
        var password = root.querySelector('#password');
        var submit = root.querySelector('#kc-login');
        if (!submit) {
            return;
        }
        function sync() {
            var idle = (username && username.value.trim() === '') || (password && password.value === '');
            submit.disabled = !!idle;
        }
        [username, password].forEach(function (el) {
            if (el) {
                el.addEventListener('input', sync);
                el.addEventListener('change', sync);
            }
        });
        // 비밀번호 관리자 자동완성은 input 이벤트 없이 값을 채울 수 있다.
        window.addEventListener('pageshow', sync);
        setTimeout(sync, 300);
        setTimeout(sync, 1200);
        sync();
    }

    function setFieldError(field, text) {
        var id = 'client-error-' + field.id;
        var el = document.getElementById(id);
        if (!text) {
            if (el) { el.remove(); }
            field.setAttribute('aria-invalid', 'false');
            return;
        }
        if (!el) {
            el = document.createElement('span');
            el.id = id;
            el.className = 'sandori-field-error is-client';
            el.setAttribute('role', 'alert');
            field.insertAdjacentElement('afterend', el);
        }
        el.textContent = text;
        field.setAttribute('aria-invalid', 'true');
    }

    function initRegister(root) {
        var form = root.querySelector('form');
        var back = root.querySelector('[data-action="reg-back"]');
        var next = root.querySelector('[data-action="reg-next"]');
        var submit = root.querySelector('.sandori-reg-submit');
        var label = root.querySelector('.sandori-step');
        var stepBoxes = root.querySelectorAll('[data-reg-step]');
        var firstStep = root.querySelector('[data-reg-step="1"]');
        var consents = root.querySelectorAll('[data-consent]');
        var consentAll = root.querySelector('[data-consent-all]');
        var twoSteps = !!next;
        var touched = {};

        function setStep(step) {
            root.setAttribute('data-step', String(step));
            if (label) {
                label.textContent = label.getAttribute('data-template').replace('{0}', String(step));
            }
            window.scrollTo(0, 0);
            sync();
        }

        function checkField(field, show) {
            var value = field.value;
            var text = '';
            if (field.id === 'password' && value && !PASSWORD_RULE.test(value)) {
                text = root.getAttribute('data-msg-password');
            } else if (field.id === 'password-confirm' && value && value !== (form.querySelector('#password') || {}).value) {
                text = root.getAttribute('data-msg-confirm');
            } else if (field.type === 'email' && value && !field.checkValidity()) {
                text = root.getAttribute('data-msg-email');
            }
            var empty = field.required && value.trim() === '';
            if (show) {
                setFieldError(field, text);
            }
            return !text && !empty && field.checkValidity();
        }

        function stepFields(box) {
            return box.querySelectorAll('input:not([type="hidden"]):not([type="checkbox"]), select, textarea');
        }

        function stepValid(box, show) {
            var ok = true;
            stepFields(box).forEach(function (field) {
                if (!checkField(field, show && touched[field.id])) {
                    ok = false;
                }
            });
            return ok;
        }

        function consentsOk() {
            var all = true;
            consents.forEach(function (c) { if (!c.checked) { all = false; } });
            return consents.length === 0 || all;
        }

        function sync() {
            var step = root.getAttribute('data-step');
            if (next) {
                next.disabled = !(firstStep && stepValid(firstStep, true));
            }
            var okConsents = consentsOk();
            if (consentAll) { consentAll.checked = consents.length > 0 && okConsents; }
            if (submit) {
                var needFirst = !twoSteps && firstStep ? stepValid(firstStep, true) : true;
                submit.disabled = !(okConsents && needFirst);
            }
            return step;
        }

        form.addEventListener('input', function (event) {
            var field = event.target;
            // 전체 동의는 input 이벤트에서 sync 를 돌리면 change 전에 체크가 되돌려지므로 제외한다.
            if (field && field.hasAttribute('data-consent-all')) {
                return;
            }
            if (field && field.id) {
                touched[field.id] = true;
                // 서버가 알려 준 오류는 그 칸을 고치기 시작하면 지운다.
                var group = field.closest('.sandori-input-group');
                if (group) {
                    group.querySelectorAll('.sandori-field-error:not(.is-client)').forEach(function (e) { e.remove(); });
                }
                if (field.id === 'password') { touched['password-confirm'] = touched['password-confirm'] || !!(form.querySelector('#password-confirm') || {}).value; }
            }
            sync();
        });
        form.addEventListener('change', sync);
        form.addEventListener('focusout', function (event) {
            if (event.target && event.target.id) { touched[event.target.id] = true; sync(); }
        });

        consents.forEach(function (c) { c.addEventListener('change', sync); });
        if (consentAll) {
            consentAll.addEventListener('change', function () {
                consents.forEach(function (c) { c.checked = consentAll.checked; });
                sync();
            });
        }

        if (twoSteps) {
            next.addEventListener('click', function () { if (!next.disabled) { setStep(2); } });
            if (back) {
                back.addEventListener('click', function (event) {
                    if (root.getAttribute('data-step') === '2') {
                        event.preventDefault();
                        setStep(1);
                    }
                });
            }
            // 1단계에서 Enter 는 제출 대신 다음 단계로.
            form.addEventListener('keydown', function (event) {
                if (event.key === 'Enter' && root.getAttribute('data-step') === '1' &&
                        event.target.tagName !== 'TEXTAREA' && event.target.tagName !== 'BUTTON') {
                    event.preventDefault();
                    if (!next.disabled) { setStep(2); }
                }
            });
            form.addEventListener('submit', function (event) {
                if (root.getAttribute('data-step') === '1') {
                    event.preventDefault();
                    if (!next.disabled) { setStep(2); }
                }
            });
            // 숨은 2단계 필수칸이 비었을 때 브라우저가 막으면 그 단계로 전환한다.
            form.addEventListener('invalid', function (event) {
                var box = event.target.closest('[data-reg-step]');
                if (box && box.getAttribute('data-reg-step') !== root.getAttribute('data-step')) {
                    event.preventDefault();
                    setStep(box.getAttribute('data-reg-step'));
                }
            }, true);
        }

        // 서버가 되돌려 준 오류가 있는 칸은 touched 로 간주해 값이 있으면 즉시 검증한다.
        form.querySelectorAll('.sandori-field-error').forEach(function (e) {
            var group = e.closest('.sandori-input-group');
            var field = group && group.querySelector('input, select, textarea');
            if (field && field.id) { touched[field.id] = false; }
        });
        if (label) {
            label.textContent = label.getAttribute('data-template').replace('{0}', root.getAttribute('data-step') === '2' ? '2' : '1');
        }
        stepBoxes.forEach(function () {});
        sync();
    }

    function initSheets() {
        document.querySelectorAll('[data-sheet-open]').forEach(function (btn) {
            btn.addEventListener('click', function () {
                var dlg = document.getElementById(btn.getAttribute('data-sheet-open'));
                if (dlg && dlg.showModal) { dlg.showModal(); }
            });
        });
        document.querySelectorAll('dialog.sandori-sheet').forEach(function (dlg) {
            dlg.addEventListener('click', function (event) {
                if (event.target === dlg || event.target.closest('[data-sheet-close]')) { dlg.close(); }
            });
        });
    }

    ready(function () {
        keepFocusedVisible(document);
        var login = document.querySelector('.sandori-login');
        var register = document.querySelector('.sandori-register');
        if (login) { initLogin(login); }
        if (register) { initRegister(register); }
        initSheets();
        // 중복 제출 방지는 단계 차단 등 다른 submit 핸들러가 preventDefault 한 뒤에 걸리도록 마지막에 등록한다.
        document.querySelectorAll('form.sandori-form').forEach(guardSubmit);
    });
})();
