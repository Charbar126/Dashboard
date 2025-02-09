defmodule Dashboard.SpotifyTokens do
  @moduledoc """
  The SpotifyTokens context.
  """

  import Ecto.Query, warn: false
  alias Dashboard.Repo

  alias Dashboard.SpotifyTokens.SpotifyToken

  @doc """
  Returns the list of spotify_tokens.

  ## Examples

      iex> list_spotify_tokens()
      [%SpotifyToken{}, ...]

  """
  def list_spotify_tokens do
    Repo.all(SpotifyToken)
  end

  @doc """
  Gets a single spotify_token.

  Raises `Ecto.NoResultsError` if the Spotify token does not exist.

  ## Examples

      iex> get_spotify_token!(123)
      %SpotifyToken{}

      iex> get_spotify_token!(456)
      ** (Ecto.NoResultsError)

  """
  def get_spotify_token!(id), do: Repo.get!(SpotifyToken, id)

  @doc """
  Creates a spotify_token.

  ## Examples

      iex> create_spotify_token(%{field: value})
      {:ok, %SpotifyToken{}}

      iex> create_spotify_token(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_spotify_token(attrs \\ %{}) do
    %SpotifyToken{}
    |> SpotifyToken.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a spotify_token.

  ## Examples

      iex> update_spotify_token(spotify_token, %{field: new_value})
      {:ok, %SpotifyToken{}}

      iex> update_spotify_token(spotify_token, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_spotify_token(%SpotifyToken{} = spotify_token, attrs) do
    spotify_token
    |> SpotifyToken.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a spotify_token.

  ## Examples

      iex> delete_spotify_token(spotify_token)
      {:ok, %SpotifyToken{}}

      iex> delete_spotify_token(spotify_token)
      {:error, %Ecto.Changeset{}}

  """
  def delete_spotify_token(%SpotifyToken{} = spotify_token) do
    Repo.delete(spotify_token)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking spotify_token changes.

  ## Examples

      iex> change_spotify_token(spotify_token)
      %Ecto.Changeset{data: %SpotifyToken{}}

  """
  def change_spotify_token(%SpotifyToken{} = spotify_token, attrs \\ %{}) do
    SpotifyToken.changeset(spotify_token, attrs)
  end
end
