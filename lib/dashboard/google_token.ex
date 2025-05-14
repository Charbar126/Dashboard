defmodule Dashboard.GoogleToken do
  use Ecto.Schema
  import Ecto.Changeset

  schema "google_tokens" do
    field :access_token, :string
    field :refresh_token, :string
    field :expires_at, :utc_datetime
    field :scope, :string
    field :token_type, :string

    belongs_to :user, Dashboard.Accounts.User

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(token, attrs) do
    token
    |> cast(attrs, [:access_token, :refresh_token, :expires_at, :user_id])
    |> validate_required([:access_token, :refresh_token, :expires_at, :user_id])
    |> assoc_constraint(:user)
    |> unique_constraint(:user_id)
  end
end
