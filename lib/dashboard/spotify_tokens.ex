defmodule Dashboard.SpotifyTokens do
  @moduledoc """
  The SpotifyTokens context.
  """

  import Ecto.Query, warn: false
  alias Dashboard.Repo
  alias Dashboard.SpotifyTokens.SpotifyToken

  @doc """
  Returns the list of spotify_tokens.
  """
  def list_spotify_tokens do
    Repo.all(SpotifyToken)
  end

  @doc """
  Gets a single spotify_token.

  Raises `Ecto.NoResultsError` if the Spotify token does not exist.
  """
  def get_spotify_token!(id), do: Repo.get!(SpotifyToken, id)

  @doc """
  Creates a spotify_token.
  """
  def create_spotify_token(attrs \\ %{}) do
    %SpotifyToken{}
    |> SpotifyToken.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a spotify_token.
  """
  def update_spotify_token(%SpotifyToken{} = spotify_token, attrs) do
    spotify_token
    |> SpotifyToken.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a spotify_token.
  """
  def delete_spotify_token(%SpotifyToken{} = spotify_token) do
    Repo.delete(spotify_token)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking spotify_token changes.
  """
  def change_spotify_token(%SpotifyToken{} = spotify_token, attrs \\ %{}) do
    SpotifyToken.changeset(spotify_token, attrs)
  end

  @doc """
  Gets the most recent Spotify token.
  """
  def get_latest_spotify_token do
    Repo.one(from st in SpotifyToken, order_by: [desc: st.inserted_at], limit: 1)
  end
end
