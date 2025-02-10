let Hooks = {}

Hooks.SpotifyPlayer = {
  mounted() {
    this.loadSpotifySDK(() => this.initPlayer());
  },

  updated() {
    console.log("SpotifyPlayer updated with new token:", this.el.dataset.token);
    this.initPlayer(); // Reinitialize when the token updates
  },

  loadSpotifySDK(callback) {
    if (window.Spotify) {
      callback();
      return;
    }

    let script = document.createElement("script");
    script.src = "https://sdk.scdn.co/spotify-player.js";
    script.onload = () => callback();
    document.head.appendChild(script);
  },

  initPlayer() {
    const token = this.el.dataset.token;
    if (!token) {
      console.warn("No Spotify token found, skipping player initialization.");
      return;
    }

    window.onSpotifyWebPlaybackSDKReady = () => {
      if (this.player) {
        this.player.disconnect();
      }

      this.player = new Spotify.Player({
        name: "Phoenix Spotify Player",
        getOAuthToken: cb => cb(token),
        volume: 0.5
      });

      this.player.addListener("ready", ({ device_id }) => {
        console.log("Ready with Device ID", device_id);
      });

      this.player.addListener("not_ready", ({ device_id }) => {
        console.log("Device ID has gone offline", device_id);
      });

      this.player.addListener("initialization_error", ({ message }) => {
        console.error(message);
      });

      this.player.addListener("authentication_error", ({ message }) => {
        console.error(message);
      });

      this.player.addListener("account_error", ({ message }) => {
        console.error(message);
      });

      document.getElementById("togglePlay").onclick = () => {
        this.player.togglePlay();
      };

      this.player.connect();
    };
  }
};

export default Hooks;
