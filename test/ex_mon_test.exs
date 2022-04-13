defmodule ExMonTest do
  use ExUnit.Case

  import ExUnit.CaptureIO

  alias ExMon.{Game, Player}

  describe "create_player/4" do
    test "returns a player" do
      expected_response = %Player{life: 100, moves: %{move_avg: :soco, move_heal: :cura, move_rnd: :chute}, name: "Victor"}

      assert expected_response == ExMon.create_player("Victor", :chute, :soco, :cura)
    end
  end

  describe "start_game/1" do
    test "when the game is started, returns a message" do
      player = Player.build("Victor", :chute, :soco, :cura)

      messages =
        capture_io(fn ->
          assert ExMon.start_game(player) == :ok
        end)

      assert messages =~ "The game is started!"
      assert messages =~ "status: :started"
    end
  end

  describe "make_move/1" do
    setup do
      player = Player.build("Victor", :chute, :soco, :cura)

      capture_io(fn ->
        ExMon.start_game(player)
      end)

      :ok
    end

    test "when the move is valid, do the move and the computer makes a move" do
      messages =
        capture_io(fn ->
          ExMon.make_move(:chute)
        end)

      assert messages =~ "The player attack the computer"
      assert messages =~ "It's computer turn."
      assert messages =~ "status: :continue"
    end

    test "when the move is invalid, returns an error message" do
      messages =
        capture_io(fn ->
          ExMon.make_move(:wrong)
        end)

      assert messages =~ "Invalid move: wrong."
    end

    test "when the game is over, returns a game over message" do
      new_state = %{
        computer: %Player{
          life: 85,
          moves: %{move_avg: :soco, move_heal: :cura, move_rnd: :chute},
          name: "Robotinik"
        },
        player: %Player{
          life: 0,
          moves: %{move_avg: :soco, move_heal: :cura, move_rnd: :chute},
          name: "Victor"
        },
        status: :continue,
        turn: :computer
      }

      Game.update(new_state)

      messages =
        capture_io(fn ->
          ExMon.make_move(:soco)
        end)

      assert messages =~ "The game is over!"
      assert messages =~ "status: :game_over"
    end
  end
end
