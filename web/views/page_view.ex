defmodule Blackjack.PageView do
  use Blackjack.Web, :view

  def player_name(conn) do
    Plug.Conn.get_session(conn, :player_name)
  end

  def player_pot(conn) do
    Plug.Conn.get_session(conn, :player_pot)
  end

  def player_bet(conn) do
    Plug.Conn.get_session(conn, :player_bet)
  end

  def player_hand(conn) do
    Plug.Conn.get_session(conn, :player_hand)
  end

  def allow_double?(conn) do
    cond do
      length(player_hand(conn)) == 2 and player_bet(conn) * 2 <= player_pot(conn) -> true
      true -> false
    end
  end

  def dealer_hand(conn) do
    Plug.Conn.get_session(conn, :dealer_hand)
  end

  def player_total(conn) do
    hand = Plug.Conn.get_session(conn, :player_hand)

    Blackjack.calculate_total(hand)
  end

  def dealer_total(conn) do
    hand = Plug.Conn.get_session(conn, :dealer_hand)

    Blackjack.calculate_total(hand)
  end

  def dealer_turn?(conn) do
    Plug.Conn.get_session(conn, :turn) == :dealer
  end

  def dealer_first_card?(conn, card) do
    hand = dealer_hand(conn)
    List.first(hand) == card
  end

  def card_image(card) do
    {suit, rank} = card
    rank = cond do
      is_atom(rank) -> String.downcase Atom.to_string rank
      true -> rank
    end
    "/images/cards/#{String.downcase Atom.to_string suit}_#{rank}.jpg"
  end

end
