# blackjack-phoenix
Port of [Ruby/Sinatra](https://github.com/mark-greene/ruby-web-blackjack) game to Elixir/Phoenix.  Compared with my [golang port](https://github.com/mark-greene/go-blackjack), Elixir is much more effecient but much more challenging (at least to me).
### Language
```Ruby
Ruby
  suits = ['Clubs', 'Diamonds', 'Hearts', 'Spades']
  ranks = ['2', '3', '4', '5', '6', '7', '8', '9', '10', 'Jack', 'Queen', 'King', 'Ace']
  session[:deck] = suits.product(ranks).shuffle!
```
```Elixir
Elixir
  suits = [:Clubs, :Diamonds, :Hearts, :Spades]
  ranks = [2, 3, 4, 5, 6, 7, 8, 9, 10, :Jack, :Queen, :King, :Ace]
  Enum.shuffle(for suit <- suits, rank <- ranks, do: {suit, rank})
```
### Template
```erb
erb
  <% session[:dealer_cards].each_with_index do |card, i| %>
    <% if session[:turn] != 'dealer' && i == 0 %>
      <img src='/images/cards/cover.jpg'>
    <% else %>
      <%= card_image(card) %>
    <% end %>
  <% end %>
 ```
 ```eex
eex
  <%= for card <- dealer_hand(@conn) do %>
    <%= if !dealer_turn?(@conn) && dealer_first_card?(@conn, card) do %>
      <img src=<%= static_path(@conn, "/images/cards/cover.jpg") %> class='card_image'>
    <%= else %>
      <img src=<%= static_path(@conn, card_image(card)) %> class='card_image'>
    <%= end %>
  <%= end %>
 ```
## To run blackjack
```
mix deps.get
npm install
mix phoenix.server
```
http://localhost:4000
