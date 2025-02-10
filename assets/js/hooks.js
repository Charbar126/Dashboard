let Hooks = {};

Hooks.SpotifyPlayer = {
  mounted() {
    // Load the Spotify SDK and then initialize the player.
    this.loadSpotifySDK(() => {
      this.initPlayer();
    });
  },

  updated() {
    console.log("SpotifyPlayer updated with new token:", this.el.dataset.token);
    this.initPlayer(); // Reinitialize when the token updates
  },

  loadSpotifySDK(callback) {
    // If the Spotify SDK is already loaded, call the callback immediately.
    if (window.Spotify) {
      callback();
      return;
    }

    // Define the global callback that the Spotify SDK will call when ready.
    window.onSpotifyWebPlaybackSDKReady = callback;

    // Dynamically load the Spotify SDK.
    let script = document.createElement("script");
    script.src = "https://sdk.scdn.co/spotify-player.js";
    script.async = true;
    document.head.appendChild(script);
  },

  initPlayer() {
    const token = this.el.dataset.token;
    if (!token) {
      console.warn("No Spotify token found, skipping player initialization.");
      return;
    }

    // Create a new Spotify Player.
    this.player = new Spotify.Player({
      name: "Phoenix Spotify Player",
      getOAuthToken: (cb) => cb(token),
      volume: 0.5,
    });

    // Set up event listeners.
    this.player.addListener("ready", ({ device_id }) => {
      console.log("Ready with Device ID", device_id);
    });

    this.player.addListener("not_ready", ({ device_id }) => {
      console.log("Device ID has gone offline", device_id);
    });

    this.player.addListener("initialization_error", ({ message }) => {
      console.error("Initialization error:", message);
    });

    this.player.addListener("authentication_error", ({ message }) => {
      console.error("Authentication error:", message);
    });

    this.player.addListener("account_error", ({ message }) => {
      console.error("Account error:", message);
    });

    // Set up the toggle play button.
    const toggleButton = document.getElementById("togglePlay");
    if (toggleButton) {
      toggleButton.onclick = () => {
        this.player.togglePlay();
      };
    }

    // Connect the player.
    this.player.connect();

    this.player.getCurrentState().then((state) => {
      if (!state) {
        console.log("The player is not active.");
        return;
      }
      console.log("Playback state:", state);
      // You can check the 'permissions' based on the actions available in 'state'
    });
  },
};

export default Hooks;
