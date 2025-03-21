defmodule Dashboard.SpotifyTokensTest do
  use Dashboard.DataCase

  alias Dashboard.SpotifyTokens

  describe "spotify_tokens" do
    alias Dashboard.SpotifyTokens.SpotifyToken

    import Dashboard.SpotifyTokensFixtures

    @invalid_attrs %{access_token: nil, refresh_token: nil, expires_at: nil}

    test "list_spotify_tokens/0 returns all spotify_tokens" do
      spotify_token = spotify_token_fixture()
      assert SpotifyTokens.list_spotify_tokens() == [spotify_token]
    end

    test "get_spotify_token!/1 returns the spotify_token with given id" do
      spotify_token = spotify_token_fixture()
      assert SpotifyTokens.get_spotify_token!(spotify_token.id) == spotify_token
    end

    test "create_spotify_token/1 with valid data creates a spotify_token" do
      valid_attrs = %{
        access_token: "some access_token",
        refresh_token: "some refresh_token",
        expires_at: ~U[2025-02-07 23:26:00Z]
      }

      assert {:ok, %SpotifyToken{} = spotify_token} =
               SpotifyTokens.create_spotify_token(valid_attrs)

      assert spotify_token.access_token == "some access_token"
      assert spotify_token.refresh_token == "some refresh_token"
      assert spotify_token.expires_at == ~U[2025-02-07 23:26:00Z]
    end

    test "create_spotify_token/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = SpotifyTokens.create_spotify_token(@invalid_attrs)
    end

    test "update_spotify_token/2 with valid data updates the spotify_token" do
      spotify_token = spotify_token_fixture()

      update_attrs = %{
        access_token: "some updated access_token",
        refresh_token: "some updated refresh_token",
        expires_at: ~U[2025-02-08 23:26:00Z]
      }

      assert {:ok, %SpotifyToken{} = spotify_token} =
               SpotifyTokens.update_spotify_token(spotify_token, update_attrs)

      assert spotify_token.access_token == "some updated access_token"
      assert spotify_token.refresh_token == "some updated refresh_token"
      assert spotify_token.expires_at == ~U[2025-02-08 23:26:00Z]
    end

    test "update_spotify_token/2 with invalid data returns error changeset" do
      spotify_token = spotify_token_fixture()

      assert {:error, %Ecto.Changeset{}} =
               SpotifyTokens.update_spotify_token(spotify_token, @invalid_attrs)

      assert spotify_token == SpotifyTokens.get_spotify_token!(spotify_token.id)
    end

    test "delete_spotify_token/1 deletes the spotify_token" do
      spotify_token = spotify_token_fixture()
      assert {:ok, %SpotifyToken{}} = SpotifyTokens.delete_spotify_token(spotify_token)

      assert_raise Ecto.NoResultsError, fn ->
        SpotifyTokens.get_spotify_token!(spotify_token.id)
      end
    end

    test "change_spotify_token/1 returns a spotify_token changeset" do
      spotify_token = spotify_token_fixture()
      assert %Ecto.Changeset{} = SpotifyTokens.change_spotify_token(spotify_token)
    end
  end
end
