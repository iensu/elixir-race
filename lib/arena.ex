defmodule Race.Arena do
    @moduledoc ~S"""
    This module represents the racing `arena`. 
    It keeps track of all `racer`s and their current progress. 
    """
    use GenServer
    alias Race.Racer

    # # # # # # # #
    # Client API  #
    # # # # # # # #

    @doc ~S"""
    Opens the arena by starting a new `arena` process

    ## Examples

        iex> {:ok, arena} = Race.Arena.open
        iex> is_pid arena
        true
    """
    def open(opts \\ []) do 
        GenServer.start_link(__MODULE__, :ok, opts)
    end

    @doc ~S"""
    Adds `racer`s to the `arena` equal to `num_racers`.

    ## Examples

        iex> {:ok, arena} = Race.Arena.open
        iex> Race.Arena.add_racers(arena, 10)
        iex> positions = Race.Arena.get_positions(arena)
        iex> length(positions) == 10
        true
    """
    def add_racers(arena, num_racers) when is_pid(arena) and 
                                           is_integer(num_racers) do
        for _racer <- 1..num_racers do 
            GenServer.cast(arena, :add)
        end
    end

    @doc ~S"""
    Returns a `list` of the `racer`s' current positions in the `arena`.

    ## Examples

        iex> {:ok, arena} = Race.Arena.open
        iex> Race.Arena.add_racers(arena, 1)
        iex> hd Race.Arena.get_positions(arena)
        0
        iex> Race.Arena.update(arena)
        iex> new_pos = hd Race.Arena.get_positions(arena)
        iex> new_pos > 0
        true
    """
    def get_positions(arena) when is_pid(arena) do
        GenServer.call(arena, :positions)
    end

    @doc ~S"""
    Updates the arena by moving all its `racer`s.

    ## Examples

        iex> {:ok, arena} = Race.Arena.open
        iex> Race.Arena.add_racers(arena, 1)
        iex> init_pos = hd Race.Arena.get_positions(arena)
        iex> Race.Arena.update(arena)
        iex> new_pos = hd Race.Arena.get_positions(arena)
        iex> new_pos > init_pos
        true
    """
    def update(arena) when is_pid(arena) do 
        GenServer.call(arena, :race)
    end

    @doc ~S"""
    Returns a `list` of first place winners represented by their respective
    index in the `list` of `racer`s.

    ## Examples
            
        iex> {:ok, arena} = Race.Arena.open
        iex> Race.Arena.add_racers(arena, 2)
        iex> # update arena three times 
        iex> # to be sure to cross goal line
        iex> for _ <- 1..3, do: Race.Arena.update(arena)
        iex> Race.Arena.check_winners(arena, 3)
        [0, 1]

    Returns an empty `list` if there are no winners yet.

        iex> {:ok, arena} = Race.Arena.open
        iex> Race.Arena.add_racers(arena, 2)
        iex> init_pos = Race.Arena.get_positions(arena)
        iex> Enum.max init_pos
        0
        iex> Race.Arena.check_winners(arena, 80)
        []
    """
    def check_winners(arena, goal_line) when is_pid(arena) and
                                             is_integer(goal_line) do
        GenServer.call(arena, :positions)
        |> Enum.with_index
        |> Enum.filter(fn {pos, _idx} -> pos > goal_line end)
        |> Enum.map(fn {_pos, idx} -> idx end)
    end

    @doc ~S"""
    Stops the `arena` GenServer.
    """
    def stop(arena) when is_pid(arena) do 
        GenServer.call(arena, :stop)
    end

    # # # # # # # # # # #
    # Server Callbacks  #
    # # # # # # # # # # #

    def init(:ok) do
        {:ok, []}
    end

    def handle_cast(:add, racers) do
        {:ok, racer} = Racer.create
        {:noreply, [racer|racers]}
    end

    def handle_call(:race, _from, racers) do
        progress = for racer <- racers do
            Racer.move(racer)
            Racer.get_progress(racer)
        end
        {:reply, progress, racers}
    end

    def handle_call(:positions, _from, racers) do
        positions = for racer <- racers do
            Racer.get_progress racer
        end
        {:reply, positions, racers}
    end

    def handle_call(:stop, _from, racers) do
        {:stop, :normal, :ok, racers}
    end
end