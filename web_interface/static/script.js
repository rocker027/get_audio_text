(() => {
    // Fetch translations JSON file
    async function fetchTranslations(lang) {
        try {
            const response = await fetch(`static/translations/${lang}.json`);
            if (!response.ok) {
                throw new Error(`Failed to load translations for ${lang}`);
            }
            return await response.json();
        } catch (error) {
            console.error(`Error loading translations for ${lang}:`, error);
            // Fallback to English if translation fails
            if (lang !== 'en') {
                return await fetchTranslations('en');
            }
            return {};
        }
    }

    // Update the document with translations
    function updateTranslations(translations) {
        document
            .querySelectorAll('[data-i18n]')
            .forEach((element) => {
                const key = element.getAttribute('data-i18n');
                if (translations[key]) {
                    element.textContent = translations[key];
                }
            });
    }

    // Update the language of the website
    async function setLanguage(lang) {
        try {
            const translations = await fetchTranslations(lang);
            updateTranslations(translations);
            document.querySelector('html').setAttribute('lang', lang);
            
            // Store language preference
            localStorage.setItem('preferred-language', lang);
        } catch (error) {
            console.error('Error setting language:', error);
        }
    }

    // Listen for language change & update translations
    document.addEventListener('DOMContentLoaded', function() {
        const languageSelect = document.getElementById('languageSelect');
        
        if (languageSelect) {
            languageSelect.addEventListener('change', function () {
                console.log("Selected language: " + this.value);
                const lang = this.value;
                setLanguage(lang);
            });
        }
        
        // Load saved language preference or default to English
        const savedLang = localStorage.getItem('preferred-language') || 'en';
        if (languageSelect) {
            languageSelect.value = savedLang;
        }
        setLanguage(savedLang);
    });
})();