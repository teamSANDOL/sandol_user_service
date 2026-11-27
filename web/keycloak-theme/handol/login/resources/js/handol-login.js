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

        // 서버가 한 화면(single)으로 그렸으면 단계 전환이 필요 없다.
        if (!form || !firstStep || !next) {
            return;
        }

        function setStep(step) {
            root.setAttribute('data-step', String(step));
            if (label) {
                label.textContent = label.getAttribute('data-template').replace('{0}', String(step));
            }
            window.scrollTo(0, 0);
        }

        function firstStepValid() {
            var fields = firstStep.querySelectorAll('input, select, textarea');
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
        next.addEventListener('click', goNext);
        if (back) {
            back.addEventListener('click', function (event) {
                if (root.getAttribute('data-step') === '2') {
                    event.preventDefault();
                    setStep(1);
                }
            });
        }

        // 브라우저는 검증이 실패하면 submit 을 보내지 않고 invalid 만 발생시킨다(버블링 없음).
        // 숨은 단계의 필드가 invalid 이면 그 단계로 전환해 포커스와 안내를 보여 준다.
        // 한 번의 제출에서 숨은 단계 invalid 가 여러 개여도 첫 필드만 전환·포커스하고 나머지는 기본 말풍선만 막는다.
        var switching = false;
        form.addEventListener('invalid', function (event) {
            var field = event.target;
            var stepBox = field.closest('[data-reg-step]');
            if (!stepBox) {
                return;
            }
            var wanted = stepBox.getAttribute('data-reg-step');
            if (switching) {
                if (wanted !== root.getAttribute('data-step')) {
                    event.preventDefault();
                }
                return;
            }
            if (wanted === root.getAttribute('data-step')) {
                return;
            }
            switching = true;
            event.preventDefault();
            setStep(wanted);
            field.focus();
            field.reportValidity();
            setTimeout(function () { switching = false; }, 0);
        }, true);

        // 1단계에서 Enter 로 제출하면 숨은 2단계 필수값 때문에 막히므로 다음 단계로 넘긴다.
        form.addEventListener('keydown', function (event) {
            if (event.key === 'Enter' && root.getAttribute('data-step') === '1' &&
                    event.target.tagName !== 'TEXTAREA' && event.target.tagName !== 'BUTTON') {
                event.preventDefault();
                goNext();
            }
        });
        form.addEventListener('submit', function (event) {
            if (root.getAttribute('data-step') === '1') {
                event.preventDefault();
                goNext();
            }
        });
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
