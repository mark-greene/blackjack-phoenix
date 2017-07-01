defmodule Constants do
  defmacro const(const_name, const_value) do
    quote do
      def unquote(const_name)(), do: unquote(const_value)
    end
  end
end

defmodule Blackjack do
  use Application
  import Constants

  const :blackjack,     21
  const :dealer_hold,   17

  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
    import Supervisor.Spec

    # Define workers and child supervisors to be supervised
    children = [
      # Start the endpoint when the application starts
      supervisor(Blackjack.Endpoint, []),
      # Start your own worker by calling: Blackjack.Worker.start_link(arg1, arg2, arg3)
      # worker(Blackjack.Worker, [arg1, arg2, arg3]),
    ]

    # See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Blackjack.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    Blackjack.Endpoint.config_change(changed, removed)
    :ok
  end

  def deck() do
    suits = [:Clubs, :Diamonds, :Hearts, :Spades]
    ranks = [2, 3, 4, 5, 6, 7, 8, 9, 10, :Jack, :Queen, :King, :Ace]
    Enum.shuffle(for suit <- suits, rank <- ranks, do: {suit, rank})
  end

  def deal(deck) do
    deal(deck, [])
  end

  def deal(deck, hand) do
    [ card | deck ] = deck
    {deck, [ card | hand ]}
  end

  def calculate_total(hand) do

    total = Enum.reduce(hand, 0, fn( { _, rank }, total) ->
      case rank do
      x when x in [ :Ace ] -> total + 11
      x when x in [ :Jack, :Queen, :King ] -> total + 10
      x when is_integer(x) -> total + rank
      end
    end)

    aces = Enum.filter(hand, fn(card) ->
      match?({ _, :Ace }, card)
    end)

    Enum.reduce(aces, total, fn( _, total) ->
      cond do
      total > Blackjack.blackjack -> total - 10
      total <= Blackjack.blackjack -> total
      end
    end)
  end

end
