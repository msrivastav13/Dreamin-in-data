document.addEventListener('DOMContentLoaded', () => {
    const searchInput = document.getElementById('search-input');
    if (!searchInput) return;

    const faqItems = document.querySelectorAll('.faq-item');

    searchInput.addEventListener('input', (e) => {
        const query = e.target.value.toLowerCase().trim();

        if (!query) {
            faqItems.forEach(item => {
                item.style.display = '';
                item.removeAttribute('open');
            });
            return;
        }

        faqItems.forEach(item => {
            const summary = item.querySelector('summary').textContent.toLowerCase();
            const answer = item.querySelector('.faq-answer').textContent.toLowerCase();
            const matches = summary.includes(query) || answer.includes(query);
            item.style.display = matches ? '' : 'none';
            if (matches) item.setAttribute('open', '');
        });
    });
});
