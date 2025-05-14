defmodule Dashboard.GoogleTokens do
  @moduledoc """
  The GoogleTokens context.
  """

  import Ecto.Query, warn: false
  alias Dashboard.Repo
  alias Dashboard.GoogleToken

  @doc """
  Returns the list of google_tokens.
  """
  def list_google_tokens do
    Repo.all(GoogleToken)
  end

  @doc """
  Gets a single google_token by ID.
  """
  def get_google_token!(id), do: Repo.get!(GoogleToken, id)

  @doc """
  Creates a google_token.
  """
  def create_google_token(attrs \\ %{}) do
    %GoogleToken{}
    |> GoogleToken.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a google_token.
  """
  def update_google_token(%GoogleToken{} = google_token, attrs) do
    google_token
    |> GoogleToken.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a google_token.
  """
  def delete_google_token(%GoogleToken{} = google_token) do
    Repo.delete(google_token)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking google_token changes.
  """
  def change_google_token(%GoogleToken{} = google_token, attrs \\ %{}) do
    GoogleToken.changeset(google_token, attrs)
  end

  @doc """
  Gets the Google token for a specific user.
  """
  def get_google_token_by_user_id(user_id) do
    Repo.get_by(GoogleToken, user_id: user_id)
  end

  @doc """
  Creates or updates a google token for a specific user.
  """
  def create_or_update_token(%{
        access_token: access_token,
        refresh_token: refresh_token,
        expires_in: expires_in,
        user_id: user_id
      }) do
    expires_at = DateTime.utc_now() |> DateTime.add(expires_in)

    case Repo.get_by(GoogleToken, user_id: user_id) do
      nil ->
        %GoogleToken{}
        |> GoogleToken.changeset(%{
          access_token: access_token,
          refresh_token: refresh_token,
          expires_at: expires_at,
          user_id: user_id
        })
        |> Repo.insert()

      token ->
        token
        |> GoogleToken.changeset(%{
          access_token: access_token,
          refresh_token: refresh_token,
          expires_at: expires_at
        })
        |> Repo.update()
    end
  end

  @doc """
  (Optional) Gets the most recent Google token — used only if global tokens are needed.
  """
  def get_latest_google_token do
    Repo.one(from gt in GoogleToken, order_by: [desc: gt.inserted_at], limit: 1)
  end
end
