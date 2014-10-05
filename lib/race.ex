defmodule Race do
    @moduledoc """
    Simulates a race.

    This is meant to be run in IEx in a console which supports printing of
    UTF-8 characters.
    """
    alias Race.Arena

    @racer_count    10
    @refresh_delay  50
    @goal_line      80

    @doc ~S"""
    Starts a new race.

    ## Examples

        iex> Race.start_race

    With options:

        iex> Race.start_race [racers: 20, goal: 10]
    
    ## Options

    | Option       | Description                          | Default value |
    | ------------ | ------------------------------------ | -------------:|
    | **`racers`** | Number of `racer`s in the race.      | 10            |
    | **`delay`**  | Delay between updates in ms.         | 50            |
    | **`goal`**   | Number of columns to the goal line.  | 80            |
    """
    def start_race(opts \\ []) do
        
        racers      = Keyword.get(opts, :racers,    @racer_count)
        delay       = Keyword.get(opts, :delay,     @refresh_delay)
        goal_line   = Keyword.get(opts, :goal,      @goal_line)

        {:ok, arena} = Arena.open
        Arena.add_racers(arena, racers)
        draw(arena, delay, goal_line)
    end

    defp draw(arena, delay, goal_line) do
        :timer.sleep delay
        refresh(get_positions(arena, goal_line), goal_line)
        Arena.update(arena)
        case Arena.check_winners(arena, goal_line) do
            []       -> draw(arena, delay, goal_line)
            [winner] -> IO.puts "The winner is: " <> 
                        get_racer_char(winner + 1)<> 
                        " !"
            winners  -> Enum.map(winners, &(&1 + 1))
                        |> Enum.map(&get_racer_char/1)
                        |> Enum.join(", ")
                        |> (fn ws -> IO.puts "The winners are: #{ws} !" end).()
        end
    end

    defp get_positions(arena, goal_line) do
        Arena.get_positions(arena)
        |> Enum.map(fn p -> goal_line - p end) # should run right -> left
        |> Enum.with_index
        |> Enum.map(fn {pos, idx} -> {pos, idx+1} end)
    end

    defp refresh(arena, goal_line) do
        IEx.Helpers.clear
        IO.puts generate_arena(arena, goal_line)
    end

    # box outline chars
    @horizontal     << 0x2501 :: utf8 >>
    @vertical       << 0x2503 :: utf8 >>
    @topleft        << 0x250f :: utf8 >>
    @topright       << 0x2513 :: utf8 >>
    @bottomright    << 0x251b :: utf8 >>
    @bottomleft     << 0x2517 :: utf8 >>

    @init_racer     0x1f420

    defp generate_arena(positions, goal_line) do
        line_end    = goal_line + 1
        max_x       = goal_line
        max_y       = length(positions) + 1
        for y <- 0..max_y, x <- 0..line_end do
            if {x, y} in positions do
                get_racer_char(y)
            else
                case {x, y} do
                    {^line_end, _}
                                        -> "\n"
                    {0     , 0     }    -> @topleft
                    {0     , ^max_y}    -> @bottomleft
                    {^max_x, 0     }    -> @topright
                    {^max_x, ^max_y}    -> @bottomright
                    { _    , 0     }    -> @horizontal
                    { _    , ^max_y}    -> @horizontal
                    {0     , _     }    -> @vertical
                    {^max_x, _     }    -> @vertical
                    _                   -> " "
                end
            end
        end
    end

    defp get_racer_char(char_offset) do 
        << @init_racer + char_offset :: utf8 >>
    end
end