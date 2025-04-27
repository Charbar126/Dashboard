let Hooks = {};

Hooks.SpotifyPoller = {
  mounted() {
    console.log("SpotifyPoller mounted!");
    const btn = this.el.querySelector("#hidden_get_player");

    btn.click();

    this.timer = setInterval(() => {
      console.log("Polling: clicking button", btn);
      if (btn) btn.click();
    }, 5000);
  },
  destroyed() {
    clearInterval(this.timer);
  },
};

Hooks.AutoScrollToNow = {
  mounted() {
    const calendar = document.getElementById("calendar-scroll");
    const nowLine = document.getElementById("now-line");

    if (calendar && nowLine) {
      const nowTop = nowLine.offsetTop;
      const containerHeight = calendar.clientHeight;

      // Scroll to center 'now'
      calendar.scrollTop = nowTop - containerHeight / 2;

      // After a tiny delay, fade in the calendar
      requestAnimationFrame(() => {
        calendar.classList.remove("opacity-0");
        calendar.classList.add("opacity-100");
      });
    }
  },
};

// This hook no longer loads the Spotify SDK or creates a local player.
// It simply attaches an event handler to the toggle button so that clicking
// it sends an event back to the LiveView server.
// Hooks.SpotifyPlayer = {
//   mounted() {
//     this.attachToggleHandler();
//   },

//   updated() {
//     // Reattach the handler if the element is re-rendered.
//     this.attachToggleHandler();
//   },

//   attachToggleHandler() {
//     // Look for the toggle button within the hook's container.
//     const toggleButton = this.el.querySelector("#togglePlay");
//     if (toggleButton) {
//       toggleButton.onclick = () => {
//         console.log("Toggle Play button clicked, pushing event to server.");
//         // Push an event named "toggle_play" to the server.
//         this.pushEvent("toggle_play", {});
//       };
//     }
//   },
// };

export default Hooks;
