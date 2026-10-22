(function () {
  const IP_TO_COPY = "mc.lacto.vip";

  function showToast(message) {
    let toast = document.getElementById("homepage-clipboard-toast");
    if (!toast) {
      toast = document.createElement("div");
      toast.id = "homepage-clipboard-toast";
      toast.style.cssText =
        "position: fixed; bottom: 24px; left: 50%; transform: translateX(-50%) translateY(20px);" +
        "background: rgba(16, 185, 129, 0.95); color: #ffffff; padding: 10px 22px; border-radius: 9999px;" +
        "font-family: ui-sans-serif, system-ui, sans-serif; font-size: 14px; font-weight: 600;" +
        "box-shadow: 0 10px 25px -5px rgba(0, 0, 0, 0.5), 0 8px 10px -6px rgba(0, 0, 0, 0.4);" +
        "z-index: 999999; opacity: 0; pointer-events: none; transition: all 0.25s cubic-bezier(0.16, 1, 0.3, 1);" +
        "display: flex; align-items: center; gap: 8px; backdrop-filter: blur(8px); border: 1px solid rgba(255,255,255,0.2);";
      document.body.appendChild(toast);
    }
    toast.innerHTML =
      '<svg style="width:16px;height:16px;flex-shrink:0" fill="none" stroke="currentColor" stroke-width="2.5" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" d="M5 13l4 4L19 7"></path></svg> ' +
      message;
    toast.style.opacity = "1";
    toast.style.transform = "translateX(-50%) translateY(0)";

    clearTimeout(toast._timer);
    toast._timer = setTimeout(() => {
      toast.style.opacity = "0";
      toast.style.transform = "translateX(-50%) translateY(20px)";
    }, 2500);
  }

  function copyText(text) {
    if (navigator.clipboard && navigator.clipboard.writeText) {
      return navigator.clipboard.writeText(text);
    }
    return new Promise((resolve, reject) => {
      try {
        const input = document.createElement("input");
        input.value = text;
        input.style.position = "fixed";
        input.style.opacity = "0";
        document.body.appendChild(input);
        input.select();
        document.execCommand("copy");
        document.body.removeChild(input);
        resolve();
      } catch (e) {
        reject(e);
      }
    });
  }

  document.addEventListener(
    "click",
    function (e) {
      const link = e.target.closest("a");
      if (!link) return;

      const href = link.getAttribute("href") || "";
      const text = link.innerText || link.textContent || "";

      if (
        href.includes("copy-server-ip") ||
        (text.includes("Server IP") && text.includes("mc.lacto.vip"))
      ) {
        e.preventDefault();
        e.stopPropagation();
        copyText(IP_TO_COPY).then(() => {
          showToast("¡IP copiada: " + IP_TO_COPY + "!");
        });
      }
    },
    true
  );
})();
