defmodule Dashboard.GoogleToken do
  use Ecto.Schema
  import Ecto.Changeset

  schema "google_tokens" do
    field :access_token, :string
    field :refresh_token, :string
    field :expires_at, :utc_datetime
    field :scope, :string
    field :token_type, :string

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(google_token, attrs) do
    google_token
    |> cast(attrs, [:access_token, :refresh_token, :expires_at])
    |> validate_required([:access_token, :refresh_token, :expires_at])
  end
end
