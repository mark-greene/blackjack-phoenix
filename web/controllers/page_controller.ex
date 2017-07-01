defmodule Blackjack.PageController do
  use Blackjack.Web, :controller
  require IEx

  def index(conn, _params) do
    conn = init_session(conn)

    redirect conn, to: "/new_player"
  end

  defp init_session(conn) do
    conn
    |> put_session(:player_name, nil)
    |> put_session(:player_pot, nil)
    |> put_session(:player_bet, nil)
    |> put_session(:player_hand, nil)
    |> put_session(:dealer_hand, nil)
    |> configure_session(renew: true)
  end

  def show_player(conn, _params) do
    render conn, "new_player.html"
  end

  def new_player(conn, params) do
    if params["player_name"] != "" do
      conn
      |> put_session(:player_name, params["player_name"])
      |> put_session(:player_pot, 500)
      |> redirect(to: "/bet")
    else
      conn
      |> put_flash(:error, "Your name is required.")
      |> render("new_player.html")
    end
  end

  def show_bet(conn, _params) do
    if get_session(conn, :player_pot) <= 0 do
      redirect conn, to: "/game/over"
    else
      render conn, "bet.html"
    end
  end

  def new_bet(conn, params) do
    if params["player_bet"] != "" do
      bet = String.to_integer params["player_bet"]
      pot = get_session(conn, :player_pot)
      if bet <= pot do
        conn
        |> put_session(:player_bet, String.to_integer params["player_bet"])
        |> put_session(:deck, Blackjack.deck())
        |> put_session(:turn, :player)
        |> redirect(to: "/game")
      else
        conn
        |> put_flash(:error, "Your Bet must not exceed $#{pot}.")
        |> render("bet.html")
      end
    else
      conn
      |> put_flash(:error, "A Bet is required.")
      |> render("bet.html")
    end
  end

  def game(conn, _params) do
    conn = conn
    |> assign(:play_again, false)
    |> assign(:show_dealer_hit_button, false)
    |> assign(:show_hit_stay_button, true)

    deck = get_session(conn, :deck)

    { deck, player_hand } = Blackjack.deal(deck)
    { deck, dealer_hand } = Blackjack.deal(deck)
    { deck, player_hand } = Blackjack.deal(deck, player_hand)
    { deck, dealer_hand } = Blackjack.deal(deck, dealer_hand)

    conn
    |> put_session(:deck, deck)
    |> put_session(:player_hand, player_hand)
    |> put_session(:dealer_hand, dealer_hand)
    |> render("game.html")
  end

  def game_player_hit(conn, params) do
    conn = conn
    |> assign(:play_again, false)
    |> assign(:show_dealer_hit_button, false)
    |> assign(:show_hit_stay_button, true)

    deck = get_session(conn, :deck)
    hand = get_session(conn, :player_hand)

    { deck, hand } = Blackjack.deal(deck, hand)

    if params["Double"] do
      bet = get_session(conn, :player_bet)
      conn = put_session(conn, :player_bet, bet*2)
    end

    if Blackjack.calculate_total(hand) > Blackjack.blackjack do
      conn = put_session(conn, :deck, deck)
      conn = put_session(conn, :player_hand, hand)
      redirect(conn, to: "/game/compare")
    else
      conn = put_session(conn, :deck, deck)
      conn = put_session(conn, :player_hand, hand)
      if params["Double"] do
        redirect(conn, to: "/game/dealer")
      else
        render(conn, "game.html")
      end
    end
  end

  def game_player_stay(conn, _params) do
    hand = get_session(conn, :player_hand)
    if Blackjack.calculate_total(hand) == Blackjack.blackjack do
      redirect(conn, to: "/game/compare")
    else
      redirect conn, to: "/game/dealer"
    end
  end

  def game_dealer(conn, _params) do
    conn = put_session(conn, :turn, :dealer)

    hand = get_session(conn, :dealer_hand)

    if Blackjack.calculate_total(hand) >= Blackjack.dealer_hold do
      redirect conn, to: "/game/compare"
    else
      conn
      |> assign(:play_again, false)
      |> assign(:show_dealer_hit_button, true)
      |> assign(:show_hit_stay_button, false)
      |> render("game.html")
    end
  end

  def game_dealer_hit(conn, _params) do
    conn = conn
    |> assign(:play_again, false)
    |> assign(:show_dealer_hit_button, true)
    |> assign(:show_hit_stay_button, false)

    deck = get_session(conn, :deck)
    hand = get_session(conn, :dealer_hand)

    { deck, hand } = Blackjack.deal(deck, hand)

    path = cond do
      Blackjack.calculate_total(hand) >= Blackjack.dealer_hold -> "/game/compare"
      true -> "/game/dealer"
    end

    conn
    |> put_session(:deck, deck)
    |> put_session(:dealer_hand, hand)
    |> redirect(to: path)
  end

  def game_compare(conn, _params) do
    player = Blackjack.calculate_total(get_session(conn, :player_hand))
    dealer = Blackjack.calculate_total(get_session(conn, :dealer_hand))
    pot = get_session(conn, :player_pot)
    bet = get_session(conn, :player_bet)

    {pot, type, msg} = cond do
      player > Blackjack.blackjack -> {pot - bet, :warning, "You busted and lost $#{bet}."}

      dealer > Blackjack.blackjack -> {pot + bet, :success, "The Dealer busted so you Won! $#{bet}"}

      player == Blackjack.blackjack and dealer < Blackjack.blackjack -> {pot + bet, :success, "You hit Blackjack and Won! $#{bet}"}

      player > dealer -> {pot + bet, :success, "You stayed at #{player} and the dealer has #{dealer} and Won! $#{bet}"}

      player < dealer -> {pot - bet, :warning, "You stayed at #{player} and the dealer has #{dealer} so you lost $#{bet}."}

      player == dealer -> {pot, :info, "You and the dealer have #{player} and Tied."}
    end

    conn
    |> assign(:play_again, true)
    |> assign(:show_dealer_hit_button, false)
    |> assign(:show_hit_stay_button, false)
    |> put_session(:player_pot, pot)
    |> put_flash(type, msg)
    |> render("game.html")
  end

  def game_over(conn, _params) do

    {type, msg} = cond do
      get_session(conn, :player_pot) <= 0 -> {:error, "#{get_session(conn, :player_name)}, You are broke!"}
      true -> {:success, "Come back soon!"}
  	end

    conn
    |> put_flash(type, msg)
  	|> render("game_over.html")
  end

end
