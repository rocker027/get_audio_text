(() => {
    // Fetch translations JSON file
    async function fetchTranslations(lang) {
        const response = await fetch(`translations/${lang}.json`);
        return response.json();
    }

    // Update the document with translations
    function updateTranslations(translations) {
        document
            .querySelectorAll('[data-i18n]')
            .forEach((element) => {
                const key = element.getAttribute('data-i18n');
                element.textContent = translations[key] || element.textContent;
            });
    }

    // Update the language of the website
    async function setLanguage(lang) {
        const translations = await fetchTranslations(lang);
        updateTranslations(translations);
        document.querySelector('html').setAttribute('lang', lang);
    }

    // Listen for language change & update translations
    document
        .getElementById('languageSelect')
        .addEventListener('change', function () {
            const lang = this.value.toLowerCase();
            setLanguage(lang);
        });

    // Set default language (English)
    setLanguage('en-US');
})();