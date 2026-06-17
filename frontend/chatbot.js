(function() {
  const toggle = document.getElementById('chatbot-toggle');
  const panel = document.getElementById('chatbot-panel');
  const closeBtn = document.getElementById('chatbot-close');
  const input = document.getElementById('chatbot-input');
  const sendBtn = document.getElementById('chatbot-send');
  const messagesDiv = document.getElementById('chatbot-messages');

  let history = [];
  let isLoading = false;

  toggle.addEventListener('click', () => {
    panel.classList.toggle('hidden');
    toggle.classList.toggle('active');
    if (!panel.classList.contains('hidden')) input.focus();
  });

  closeBtn.addEventListener('click', () => {
    panel.classList.add('hidden');
    toggle.classList.remove('active');
  });

  function appendMessage(role, text) {
    const div = document.createElement('div');
    div.className = 'chat-message ' + (role === 'user' ? 'user' : 'bot');
    div.textContent = text;
    messagesDiv.appendChild(div);
    messagesDiv.scrollTop = messagesDiv.scrollHeight;
  }

  async function sendMessage() {
    const message = input.value.trim();
    if (!message || isLoading) return;

    appendMessage('user', message);
    input.value = '';
    isLoading = true;
    sendBtn.disabled = true;

    const typingDiv = document.createElement('div');
    typingDiv.className = 'chat-message bot typing';
    typingDiv.textContent = 'Thinking...';
    messagesDiv.appendChild(typingDiv);
    messagesDiv.scrollTop = messagesDiv.scrollHeight;

    try {
      const res = await fetch('/api/chatbot', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ message, history })
      });
      const data = await res.json();
      messagesDiv.removeChild(typingDiv);

      if (data.reply) {
        appendMessage('assistant', data.reply);
        history.push({ role: 'user', content: message });
        history.push({ role: 'assistant', content: data.reply });
        if (history.length > 20) history = history.slice(-20);
      } else {
        appendMessage('assistant', data.error || 'Sorry, something went wrong.');
      }
    } catch (err) {
      messagesDiv.removeChild(typingDiv);
      appendMessage('assistant', 'Connection error. Please try again.');
    }

    isLoading = false;
    sendBtn.disabled = false;
  }

  sendBtn.addEventListener('click', sendMessage);
  input.addEventListener('keydown', (e) => {
    if (e.key === 'Enter') sendMessage();
  });
})();
