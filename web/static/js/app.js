// Brunch automatically concatenates all files in your
// watched paths. Those paths can be configured at
// config.paths.watched in "brunch-config.js".
//
// However, those files will only be executed if
// explicitly imported. The only exception are files
// in vendor, which are never wrapped in imports and
// therefore are always executed.

// Import dependencies
//
// If you no longer want to use a dependency, remember
// to also remove its path from "config.paths.watched".
import "phoenix_html"

// Import local files
//
// Local files can be imported directly using relative
// paths "./socket" or full ones "web/static/js/socket".

// import socket from "./socket"

$(document).ready(function() {

  player_hits();
  player_stays();
  player_doubles();
  dealer_hits();

});

function player_hits() {
  $(document).on("click", "form#hit_form input", function() {
    $.ajax({
      type: "Post",
      url: "/game/player/hit",
      data: {double: false},
      headers: {
        "X-CSRF-TOKEN": $.cookie("_csrf_token")
      },
    }).done(function(msg) {
      $("#game").replaceWith(msg);
    });
    return false;
  });
};

function player_stays() {
  $(document).on("click", "form#stay_form input", function() {
    $.ajax({
      type: "Post",
      url: "/game/player/stay",
      headers: {
        "X-CSRF-TOKEN": $.cookie("_csrf_token")
      },
    }).done(function(msg) {
      $("#game").replaceWith(msg);
    });
    return false;
  });
};

function player_doubles() {
  $(document).on("click", "form#double_form input", function() {
    $.ajax({
      type: "Post",
      url: "/game/player/hit",
      data: {double: true},
      headers: {
        "X-CSRF-TOKEN": $.cookie("_csrf_token")
      },
    }).done(function(msg) {
      $("#game").replaceWith(msg);
    });
    return false;
  });
};

function dealer_hits() {
  $(document).on("click", "form#dealer_hit input", function() {
    $.ajax({
      type: "Post",
      url: "/game/dealer/hit",
      headers: {
        "X-CSRF-TOKEN": $.cookie("_csrf_token")
      },
    }).done(function(msg) {
      $("#game").replaceWith(msg);
    });
    return false;
  });
};
