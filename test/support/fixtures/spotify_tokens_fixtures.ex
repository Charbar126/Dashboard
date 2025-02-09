defmodule Dashboard.SpotifyTokensFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Dashboard.SpotifyTokens` context.
  """

  @doc """
  Generate a spotify_token.
  """
  def spotify_token_fixture(attrs \\ %{}) do
    {:ok, spotify_token} =
      attrs
      |> Enum.into(%{
        access_token: "some access_token",
        expires_at: ~U[2025-02-07 23:26:00Z],
        refresh_token: "some refresh_token"
      })
      |> Dashboard.SpotifyTokens.create_spotify_token()

    spotify_token
  end
end
