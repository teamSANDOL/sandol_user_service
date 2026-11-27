/* 한돌이 로그인 테마: 로그인/회원가입 단계 전환. JS 가 꺼져 있으면 모든 입력이 한 화면에 보인다. */
(function () {
    'use strict';

    document.documentElement.classList.add('sandori-js');

    function ready(fn) {
        if (document.readyState === 'loading') {
            document.addEventListener('DOMContentLoaded', fn);
        } else {
            fn();
        }
    }

    function initLogin(root) {
        var startButton = root.querySelector('[data-action="show-id"]');
        var backButton = root.querySelector('[data-action="show-start"]');
        var username = root.querySelector('#username');
        var password = root.querySelector('#password');
        var submit = root.querySelector('#kc-login');

        function show(step) {
            root.setAttribute('data-step', step);
            if (step === 'id' && username) {
                username.focus();
            }
        }

        function syncIdle() {
            if (!submit || !username || !password) {
                return;
            }
            var idle = username.value.trim() === '' || password.value === '';
            submit.classList.toggle('is-idle', idle);
        }

        if (startButton) {
            startButton.addEventListener('click', function () { show('id'); });
        }
        if (backButton) {
            backButton.addEventListener('click', function () { show('start'); });
        }
        [username, password].forEach(function (el) {
            if (el) {
                el.addEventListener('input', syncIdle);
            }
        });
        syncIdle();

        // 언어 전환은 페이지를 다시 불러오므로 아이디 로그인 단계를 유지한다.
        var STEP_KEY = 'sandori-login-step';
        root.querySelectorAll('.sandori-locale-option').forEach(function (link) {
            link.addEventListener('click', function () {
                try { sessionStorage.setItem(STEP_KEY, 'id'); } catch (e) { /* 저장소를 못 쓰면 시작화면으로 돌아간다 */ }
            });
        });
        try {
            if (sessionStorage.getItem(STEP_KEY) === 'id') {
                sessionStorage.removeItem(STEP_KEY);
                root.setAttribute('data-step', 'id');
            }
        } catch (e) { /* ignore */ }
    }

    function initRegister(root) {
        var form = root.querySelector('form');
        var back = root.querySelector('[data-action="reg-back"]');
        var next = root.querySelector('[data-action="reg-next"]');
        var label = root.querySelector('.sandori-step');
        var firstStep = root.querySelector('[data-reg-step="1"]');

        function setStep(step) {
            root.setAttribute('data-step', String(step));
            if (label) {
                label.textContent = label.getAttribute('data-template').replace('{0}', String(step));
            }
            window.scrollTo(0, 0);
        }

        function firstStepValid() {
            var fields = firstStep.querySelectorAll('input, select');
            for (var i = 0; i < fields.length; i += 1) {
                if (!fields[i].checkValidity()) {
                    fields[i].reportValidity();
                    return false;
                }
            }
            return true;
        }

        function goNext() {
            if (firstStepValid()) {
                setStep(2);
            }
        }

        if (label) {
            label.textContent = label.getAttribute('data-template').replace('{0}', root.getAttribute('data-step'));
        }
        if (next) {
            next.addEventListener('click', goNext);
        }
        if (back) {
            back.addEventListener('click', function (event) {
                if (root.getAttribute('data-step') === '2') {
                    event.preventDefault();
                    setStep(1);
                }
            });
        }
        if (form) {
            form.addEventListener('submit', function (event) {
                if (root.getAttribute('data-step') === '1') {
                    event.preventDefault();
                    goNext();
                    return;
                }
                // 숨은 1단계 필드가 비어 있으면 브라우저가 조용히 제출을 막으므로 그 단계로 되돌린다.
                var invalid = Array.prototype.find.call(firstStep.querySelectorAll('input, select'), function (el) {
                    return !el.checkValidity();
                });
                if (invalid) {
                    event.preventDefault();
                    setStep(1);
                    invalid.focus();
                    invalid.reportValidity();
                }
            });
        }
    }

    ready(function () {
        var login = document.querySelector('.sandori-login');
        var register = document.querySelector('.sandori-register');
        if (login) {
            initLogin(login);
        }
        if (register) {
            initRegister(register);
        }
    });
})();
