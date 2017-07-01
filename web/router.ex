defmodule Blackjack.Router do
  use Blackjack.Web, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", Blackjack do
    pipe_through :browser # Use the default browser stack

    get   "/", PageController, :index
    get   "/new_player", PageController, :show_player
    post  "/new_player", PageController, :new_player
    get   "/bet", PageController, :show_bet
    post  "/bet", PageController, :new_bet
    get   "/game", PageController, :game
    post  "/game/player/hit", PageController, :game_player_hit
    post  "/game/player/stay", PageController, :game_player_stay
    get   "/game/dealer", PageController, :game_dealer
    post  "/game/dealer/hit", PageController, :game_dealer_hit
    get   "/game/compare", PageController, :game_compare
    get   "/game/over", PageController, :game_over
  end

  # Other scopes may use custom stacks.
  # scope "/api", Blackjack do
  #   pipe_through :api
  # end
end
